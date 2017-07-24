% beamformer example using spm8 and fieldtrip

% spm eeg defaults
%spm('defaults','eeg');

% options for analysis
freq    = 50; %25 Hz and 50 Hz both good to look at
smooth  = 6; % multi-taper smoothing +/-Hz, should increase with frequency, 6-16
res     = 8; % in mm - smaller the number, longer it will take (but nicer looking) ~5-10 mm ok
spmdir  = [spm('dir') filesep];
invnum  = 1; % 1 for new inverse field in file
usehs   = 1; % 1 to use head shape in coreg, 0 no head shape
invname = ['Piezo' freq]; % a name for your inverse field

% read data
%S.dataset   = 'e,rfhp0.1Hz,x,n,o,bahe001-1';
%S.channels  = {'MEG' 'TRIGGER'};
%D           = spm_eeg_convert(file);
D            = spm_eeg_load('1003_right_ica_spm.mat');

% prep template MRI, not individual MRI
D.inv                   = {struct('mesh', [])};
D.inv{invnum}.date      = strvcat(date,datestr(now,15));
D.inv{invnum}.comment 	= {invname}; % name of your inverse solution
Msize = 3;  % 1 = coarse, 2 = normal 3 = fine
sMRI  = []; % empty if using template
D.inv{invnum}.mesh      = spm_eeg_inv_mesh(sMRI, Msize);

% coregister template with MEG fids - note: if you convert to spm8 directly
% from raw data, not using MEG meg2spm.m function, then you will have 5
% fiducials, most likely, because of the 2 extra coils on head used in our
% laboratory. Next code sets options and input fields. Only first 3
% fiducials are used
meegfid                  = D.fiducials;
mrifid                   = D.inv{invnum}.mesh.fid;
S                        = [];
S.sourcefid              = meegfid;
S.sourcefid.fid.pnt      = meegfid.fid.pnt(1:3,:); %use 1st 3 coils only
S.sourcefid.fid.label    = meegfid.fid.label(1:3,:);
S.targetfid              = mrifid;
S.targetfid.fid.pnt      = [];
S.targetfid.fid.label    = {};
S.targetfid.fid.pnt      = mrifid.fid.pnt(1:3,:);
S.targetfid.fid.label    = S.sourcefid.fid.label;
S.targetfid.fod.label    = S.targetfid.fid.label(1:3, :);
S.useheadshape           = usehs; % try setting to 0 if poor result or bad/no hs info
S.template               = 2;
M1                       = spm_eeg_inv_datareg(S); % actual call to co-register

% set values of D struct from coregistration
ind                                    = 1;
D.inv{invnum}.datareg                  = struct([]);
D.inv{invnum}.datareg(ind).sensors     = D.sensors('MEG');
D.inv{invnum}.datareg(ind).fid_eeg     = S.sourcefid;
D.inv{invnum}.datareg(ind).fid_mri     = ft_transform_headshape(inv(M1), S.targetfid);
D.inv{invnum}.datareg(ind).toMNI       = D.inv{invnum}.mesh.Affine*M1;
D.inv{invnum}.datareg(ind).fromMNI     = inv(D.inv{invnum}.datareg(ind).toMNI);
D.inv{invnum}.datareg(ind).modality    = 'MEG';

% forward model type here
D.inv{invnum}.forward = struct([]);
D.inv{invnum}.forward(invnum).voltype ='Single Sphere'; % also 'Single Shell' if you like
D=spm_eeg_inv_forward(D);
spm_eeg_inv_checkforward(D, invnum);

% save file
D.save;

% convert to fieldtrip
ft = D.ftraw(0);

% define some things about volume and sensors from SPM data
sens        = D.sensors('MEG');
datareg 	= D.inv{1}.datareg;
M1          = datareg.toMNI;
[U,L,V]     = svd(M1(1:3,1:3));
M1(1:3,1:3) = U*V';
if ~isfield(D.inv{1},'forward')
    D.inv{1}.forward = struct([]);
    D.inv{1}.forward(1).voltype = 'Single Shell';
    D = spm_eeg_inv_forward(D);
    spm_eeg_inv_checkforward(D,1);
end
vol         = D.inv{1}.forward.vol;
vol         = ft_transform_vol(M1,vol);
sens        = ft_transform_sens(M1,sens);

% define some time periods of interest in Fieldtrip data
cfg         = [];
cfg.toilim  = [-.15 -.012];
dataPre     = ft_redefinetrial(cfg,ft);
cfg.toilim  = [.012 .15];
dataPost    = ft_redefinetrial(cfg,ft);

% do frequency analysis - just fft here, but could probably use wavelets
cfg             = [];
cfg.method      = 'mtmfft';
cfg.output      = 'powandcsd';
cfg.tapsmofrq   = smooth;
cfg.foilim      = [20 25];
cfg.channel     = {'MEG'};
cfg.channelcmb  = {'MEG' 'MEG'};
freqPre         = ft_freqanalysis(cfg,dataPre);
freqPost        = ft_freqanalysis(cfg,dataPost);

% prepare dipole grid for beamformer
cfg             = [];
cfg.grad        = sens;
cfg.reducerank  = 2;
cfg.channel     = {'MEG'};
cfg.vol         = vol;
cfg.grid.xgrid  = -90:res:90;
cfg.grid.ygrid  = -120:res:100;
cfg.grid.zgrid  = -80:res:120;
grid            = ft_prepare_leadfield(cfg);

% source analysis on pre and post intervals
cfg                 = [];
cfg.method          = 'dics';
cfg.projectnoise    = 'yes'; % if you want to compute Neural Activity Index
cfg.grid            = grid;
cfg.vol             = vol;
cfg.grad            = sens;
cfg.lambda          = '4%'; % regularization parameter
cfg.frequency       = 21;
cfg.channel         = {'MEG'};
sourcePre           = ft_sourceanalysis(cfg,freqPre);
sourcePost          = ft_sourceanalysis(cfg,freqPost);
sourceDiff          = sourcePost;
sourceDiff.avg.pow  = (sourcePost.avg.pow - sourcePre.avg.pow) ./ sourcePre.avg.pow;

% source plotting of normalised, or relative power
mri                 = ft_read_mri(fullfile(spmdir,'canonical','single_subj_T1.nii'));
cfg                 = [];
cfg.downsample      = 1;
sourceDiffInt       = ft_sourceinterpolate(cfg,sourceDiff,mri);
cfg                 = [];
cfg.method          = 'ortho';
cfg.funparameter    = 'avg.pow';
cfg.maskparameter   = cfg.funparameter;
cfg.interactive     = 'yes';
cfg.funcolorlim     = [0.0 1.5]; % 0-1.5 good start
cfg.opacitylim      = [0.0 1.5]; 
cfg.opacitymap      = 'rampup';  
ft_sourceplot(cfg, sourceDiffInt);

