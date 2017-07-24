% example of using SPM8 and Fieldtrip together to do DICS beamformer
% assumes you already have a dataset saved in SPM8 format with an MRI and
% with a raw forward model saved from the MRI. A close relative of this example 
% can be found within spm as spm_eeg_ft_beamformer_freq.m, but that function has been
% problematic.

% FIXME: should put one call to do fft on entire spectrum for saving and
% also loop through 25 and 50 Hz response imaging

% fieldtrip and spm defs
ft_defaults; 

% subject specific data and defaults
meg_id      = '1011'; 
megdirs     = {'left' 'right'};
meg_suffix  = '_cnt.mat';
spm_suffix  = '_spm8_epochs.mat';
mri_file    = [meg_id '.nii'];
mri_dir     = 'mri';
pretoi      = [-.2 0];
posttoi     = [.1 .3];
freq        = [25 25]; %25 Hz and 50 Hz both good to look at
smooth      = 5; % multi-taper smoothing +/-Hz, should increase with frequency
res         = 8; % in mm
average     = 1;

basedir   = pwd;

for iter=1:length(megdirs)
    cd(megdirs{iter});
    
    % read SPM8 format
    meg_file  = [meg_id '_' megdirs{iter} spm_suffix];
    spm8file  = fullfile(basedir,megdirs{iter},meg_file);
    [pth,nam,ext] = fileparts(spm8file);

    % convert spm8 data to FieldTrip
    fprintf('Loading %s and converting to FieldTrip...',meg_file);
    if ~exist('D','var')
        D  = spm_eeg_load(spm8file);
    end
    ft = D.ftraw(0);
    fprintf('done!\n');

    % average
    if average
        ft_avg =ft_timelockanalysis([],ft);
        ft_avg =ft_timelockbaseline([],ft_avg);
        ft=ft_avg;
    end

    % select time periods of interest in Fieldtrip data
    cfg         = [];
    cfg.toilim  = [pretoi(1) pretoi(2)];
    dataPre     = ft_redefinetrial(cfg,ft);
    cfg.toilim  = [posttoi(1) posttoi(2)];
    dataPost    = ft_redefinetrial(cfg,ft);

    % do frequency analysis - just fft here, but could probably use wavelets
    cfg             = [];
    cfg.method      = 'mtmfft';
    cfg.channel     = 'MEG';
    cfg.channelcmb  = {'MEG' 'MEG'};
    cfg.output      = 'powandcsd';
    cfg.tapsmofrq   = smooth;
    cfg.foilim      = [freq(1) freq(2)];
    freqPre         = ft_freqanalysis(cfg,dataPre);
    freqPost        = ft_freqanalysis(cfg,dataPost);
    cd(basedir);

    % do realign on MRI - interpolate sources onto this!
    load(fullfile(pth,[nam '.xfm']),'-mat');
    mrifids             = [transform.mri.nas;transform.mri.lpa;transform.mri.rpa];
    megfids             = [transform.meg.nas;transform.meg.lpa;transform.meg.rpa];
    sform               = spm_eeg_inv_rigidreg(megfids',mrifids');
    cd('mri');
    mri                 = ft_read_mri(mri_file);
    ft_write_volume([meg_id '_' megdirs{iter} '_realigned.nii'],mri.anatomy,...
        'dataformat','nifti','transform',sform*mri.transform);
    clear mri;
    mri_realigned = ft_read_mri([meg_id '_' megdirs{iter} '_realigned.nii']);
    cd(basedir);
    % note: to write back to original mri space, transform should be
    % mri_realigned.transform*inv(sform) - need to test!
    sens                 = D.sensors('MEG');

    % done with SPM D, so clear it for memory
    clear D;

    % load inner skull and apply mri to meg transformation
    % all source analyses conducted in the MEG headframe
    % calculate surface normals for vol.bnd.nrm outside of FieldTrip
    % FT's normals.m routine sometimes returns NaNs which cause failure
    % at leadfield step - using Dirk-Jan Kroon patchnormals.m code from File
    % Exchange
    load(fullfile(basedir,'mri',[meg_id '_iskull.mat'])); 
    iskull.vertices      = mri2meg(transform,iskull.vertices);
    nrm                  = patchnormals(iskull);
    vol                  = [];
    vol.bnd              = export(gifti(iskull),'ft');
    vol.bnd.nrm          = nrm;
    vol.type             = 'nolte';

    % prepare dipole grid for beamformer
    cfg             = [];
    cfg.grad        = sens; 
    cfg.reducerank  = 2;
    cfg.vol         = vol;
    cfg.grid.xgrid  =-120:res:120;
    cfg.grid.ygrid  =-120:res:120;
    cfg.grid.zgrid  =-120:res:150;
    cfg.inwardshift = -5; % helps keep grid boundary from being tightly constrained by anatomy
    grid            = ft_prepare_leadfield(cfg);

    % source analysis on pre and post intervals
    cfg                 = [];
    cfg.frequency       = freq(1);
    cfg.method          = 'dics';
    cfg.channel         = 'MEG';
    cfg.grad            = sens;
    cfg.dics.fixedori   = 'yes';
    cfg.dics.realfilter = 'yes';
    cfg.dics.powmethod  = 'trace';
    cfg.projectnoise    = 'no'; % if you want to compute Neural Activity Index
    cfg.grid            = grid;
    cfg.vol             = vol;
    cfg.lambda          = '2%'; % covariance regularization parameter
    cfg.reducerank      = 2;
    sourcePre           = ft_sourceanalysis(cfg,freqPre);
    sourcePost          = ft_sourceanalysis(cfg,freqPost);
    sourceDiff          = sourcePost;
    sourceDiff.avg.pow  = (sourcePost.avg.pow - sourcePre.avg.pow) ./ sourcePre.avg.pow;

    % source plotting of normalised, or relative power
    cfg                 = [];
    cfg.downsample      = 1;
    sourceDiffInt       = ft_sourceinterpolate(cfg,sourceDiff,mri_realigned);
    cfg                 = [];
    cfg.method          = 'ortho';
    cfg.funparameter    = 'avg.pow';
    cfg.maskparameter   = cfg.funparameter;
    cfg.interactive     = 'no';
    ymax                = max(sourceDiffInt.avg.pow(:));
    ymin                = min(sourceDiffInt.avg.pow(:));
    cfg.funcolorlim     = [ymin ymax]; % 0-1.5 good start
    cfg.opacitylim      = [ymin ymax]; 
    cfg.opacitymap      = 'rampup';  
    ft_sourceplot(cfg, sourceDiffInt);

    % save result as nifti file - this output is in headframe
    % and will overlay with realigned mri scan data.
    % Note that any warp that was later applied to the
    % native mri could also be applied to this volume.

    % NOTE: if analysis is done in units of mm and fT (defaults for SPM and FT), 
    % output will be scaled incorrectly (i.e., not in A-m)
    cd('mri');
    out             = spm_vol([meg_id '_' megdirs{iter} '_realigned.nii']);
    [pth nam ext]   = fileparts(out.fname);
    out.fname       = [nam '_' megdirs{iter} '_' num2str(freq(1)) 'Hz_relpwr.nii'];
    out.dt(1)       = spm_type('float32');
    out             = spm_create_vol(out);
    spm_write_vol(out,sourceDiffInt.avg.pow);
    cd(basedir);

end