% example of fitting dipole to spm8 data using fieldtrip function - assumes
% headmodel and coreg done in spm8

% options
file = 'bfm1003_right_spm.mat';
fitint = [.4 .45]; % fit interval in ms

% defaults
spm('defaults','eeg');
ft_defaults;
spmdir = [spm('dir') filesep];

% convert spm8 to fieldtrip
D                   = spm_eeg_load(file);
ft                  = D.ftraw(0);
cfg                 = [];
cfg.channel         = 'all';
cfg.trials          = 'all';
ft                  = ft_timelockanalysis(cfg,ft);

% configure head model
val         = 1;
modality    = spm_eeg_modality_ui(D, 1, 1);
vol         = D.inv{val}.forward(val).vol;
datareg     = D.inv{val}.datareg(val);
sens        = datareg.sensors;
M1          = datareg.toMNI;
[U,L,V]     = svd(M1(1:3, 1:3));
M1(1:3,1:3) = U*V';
vol         = ft_transform_vol(M1,vol);
sens        = ft_transform_sens(M1,sens);

% do fit - first pass is symmetrically constrained 2-dipole fit
cfg_dip                 = [];
cfg_dip.symmetry        = 'x';
cfg_dip.numdipoles      = 2;
cfg_dip.vol             = vol;
cfg_dip.inwardshift     = 0;
cfg_dip.grid.resolution = 8;
cfg_dip.grad            = sens;
cfg_dip.reducerank      = 2; % for gradiometers
cfg_dip.latency         = 1e-3*fitint;
src                 = ft_dipolefitting(cfg_dip, ft);

% fit again using no symmetry constraint and last iteration as start
cfg                 = [];
cfg.numdipoles      = 2;
cfg.dip.pos         = src.dip.pos;
cfg.vol             = vol;
cfg.nonlinear       = 'yes';
cfg.gridsearch      = 'no';
cfg.grad            = sens;
cfg.reducerank      = 2; % for gradiometers
cfg.latency         = 1e-3*fitint;
src                 = ft_dipolefitting(cfg, ft);

% plot fit on spm8 template mri scan
mfile = fullfile(spmdir,'canonical','single_subj_T1.nii');
mri = ft_read_mri(mfile);
cfg = [];
cfg.location = src.dip.pos(1,:);
figure; ft_sourceplot(cfg,mri);
cfg.location = src.dip.pos(2,:);
figure; ft_sourceplot(cfg,mri);