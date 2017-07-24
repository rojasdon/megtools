% example of using SPM8 and Fieldtrip together to do DICS beamformer
% assumes you already have a dataset coregistered in SPM8 with an MRI and
% with a forward model defined. Also, that you have the same dataset in
% fieldtrip format. A close relative of this example can be found within
% spm as spm_eeg_ft_beamformer_freq.m, but that function has been
% problematic. You should also have the MRI in the same directory to run
% this example

% fieldtrip and spm defs
spm('defaults','eeg');
ft_defaults; 

% subject specific data
meg_id   = '1258'; 
spm_suffix = '_spm8_epoched.mat';
ft_suffix  = '_ft_epoched.mat';
mri_file = [meg_id '.nii'];
meg_file = [meg_id spm_suffix];

% load spm and fieldtrip datasets (these should be identical)
D = spm_eeg_load(meg_file);
load([meg_id ft_suffix]);
mri = ft_read_mri(mri_file);

% set analysis center frequency and beamformer resolution
freq    = [20 50]; %25 Hz and 50 Hz both good to look at
smooth  = 6; % multi-taper smoothing +/-Hz, should increase with frequency, 6-16
res     = 8; % in mm

% define some things about volume and sensors from SPM data
% FIXME: I think that I need to do registration this way:
%mesh = spm_eeg_inv_transform_mesh(...
%    D.inv{1}.datareg(1).fromMNI*D.inv{1}.mesh.Affine, D.inv{1}.mesh);
%vol = [];
%vol.bnd = export(gifti(mesh.tess_iskull), 'ft');
%vol.type = 'nolte';
%vol = ft_convert_units(vol, 'mm');
%sens = D.inv{1}.datareg.sensors;
% instead of all this!
sens        = D.sensors('MEG');
datareg 	= D.inv{1}.datareg;
M1          = datareg.toMNI;
[U,L,V]     = svd(M1(1:3,1:3));
M1(1:3,1:3) = U*V';
D.inv{1}.forward = struct([]);
D.inv{1}.forward(1).voltype = 'Single Shell';
D = spm_eeg_inv_forward(D);
%spm_eeg_inv_checkforward(D,1);
vol         = D.inv{1}.forward.vol;
vol         = ft_transform_vol(M1,vol);
sens        = ft_transform_sens(M1,sens);
hs          = D.inv{1}.datareg.fid_eeg;
hs          = ft_transform_headshape(M1,hs);

% rescale units for sensors in Fieldtrip data to match SPM8
ft.grad = ft_convert_units(ft.grad,'mm');

% define some time periods of interest in Fieldtrip data
cfg         = [];
cfg.toilim  = [-.2 0];
dataPre     = ft_redefinetrial(cfg,ft);
cfg.toilim  = [.15 .45];
dataPost    = ft_redefinetrial(cfg,ft);

% do frequency analysis - just fft here, but could probably use wavelets
cfg             = [];
cfg.method      = 'mtmfft';
cfg.channel     = 'MEG';
cfg.channelcmb  = {'MEG' 'MEG'};
cfg.output      = 'powandcsd';
cfg.tapsmofrq   = smooth;
cfg.foilim      = [freq freq];
freqPre         = ft_freqanalysis(cfg,dataPre);
freqPost        = ft_freqanalysis(cfg,dataPost);

% prepare dipole grid for beamformer
cfg             = [];
cfg.grad        = sens;
cfg.reducerank  = 2;
% cfg.channel     = D.chanlabels(D.meegchannels('MEG'));
cfg.vol         = vol;
cfg.grid.xgrid  = -90:res:90;
cfg.grid.ygrid  = -120:res:100;
cfg.grid.zgrid  = -80:res:140;
cfg.inwardshift = -10;
grid            = ft_prepare_leadfield(cfg);

% source analysis on pre and post intervals
cfg                 = [];
cfg.method          = 'dics';
cfg.channel         = 'MEG';
cfg.dics.fixedori   = 'yes';
cfg.dics.realfilter = 'yes';
cfg.dics.powmethod  = 'trace';
cfg.projectnoise    = 'no'; % if you want to compute Neural Activity Index
cfg.grid            = grid;
cfg.vol             = vol;
cfg.lambda          = '5%'; % regularization parameter
cfg.frequency       = freq;
cfg.reducerank      = 2;
sourcePre           = ft_sourceanalysis(cfg,freqPre);
sourcePost          = ft_sourceanalysis(cfg,freqPost);
sourceDiff          = sourcePost;
sourceDiff.avg.pow  = (sourcePost.avg.pow - sourcePre.avg.pow) ./ sourcePre.avg.pow;

% source plotting of normalised, or relative power
cfg                 = [];
cfg.downsample      = 1;
sourceDiffInt       = ft_sourceinterpolate(cfg,sourceDiff,mri);
cfg                 = [];
cfg.method          = 'ortho';
cfg.funparameter    = 'avg.pow';
cfg.maskparameter   = cfg.funparameter;
cfg.interactive     = 'yes';
ymax                = max(sourceDiffInt.avg.pow(:));
ymin                = min(sourceDiffInt.avg.pow(:));
cfg.funcolorlim     = [ymin ymax]; % 0-1.5 good start
cfg.opacitylim      = [ymin ymax]; 
cfg.opacitymap      = 'rampup';  
ft_sourceplot(cfg, sourceDiffInt);

%%%NOTE: need to plot the source space on mri and evaluate whether they are
%%%coregistered!!!%%% 

% save result as nifti file - note that any warp that was applied to the
% native mri could also be applied to this volume.
out             = spm_vol(mri_file);
[pth nam ext]   = fileparts(out.fname);
out.fname       = [nam '_' num2str(freq) 'Hz_relpwr.nii'];
out.dt(1)       = spm_type('float32');
out             = spm_create_vol(out);
spm_write_vol(out,sourceDiffInt.avg.pow);