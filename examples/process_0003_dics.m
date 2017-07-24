% options
lambda      = '5%';
pretoi      = [-.2 0];
posttoi     = [.05 .25];
foi         = [20 30];
smooth      = 5;

% load data
ft_defaults;
load 0003_aligned_mni_model.mat;
load template_mri_data_fieldtrip.mat;
load 0003_left_spm8_epochs.xfm -mat;
D=spm_eeg_load('0003_left_spm8_epochs.mat');

% process in fieldtrip
ft=D.ftraw(0);
sens=D.sensors('MEG');
clear D;
chans = ft_channelselection('MEG',ft.label);

% time periods
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
cfg.foilim      = foi;
freqPre         = ft_freqanalysis(cfg,dataPre);
freqPost        = ft_freqanalysis(cfg,dataPost);

% transform sensors to mri space and do leadfields
megfids             = [transform.meg.nas;transform.meg.lpa;transform.meg.rpa];
mrifids             = [transform.mri.nas;transform.mri.lpa;transform.mri.rpa];
sform               = spm_eeg_inv_rigidreg(mrifids',megfids');
hdm                 = ft_convert_units(hdm,'mm');
sens                = ft_transform_sens(sform,sens);
cfg_grid.grid       = grid;
cfg_grid.vol        = hdm;
cfg_grid.grad       = sens;
cfg_grid.reducerank = 2;
cfg_grid.channel    = chans;
dicsgrid            = ft_prepare_leadfield(cfg_grid);

 % DICS analysis on pre and post intervals in time
cfg                     = [];
cfg.method              = 'dics';
cfg.frequency           = 25;
cfg.keepfilter          = 'yes';
cfg.dics.realfilter     = 'yes';
cfg.dics.fixedori       = 'yes';
%cfg.dics.powmethod      = 'trace';
cfg.dics.normalize      = 'yes';
cfg.dics.projectnoise   = 'yes';
cfg.grid                = dicsgrid;
cfg.grad                = sens;
cfg.vol                 = hdm;
cfg.lambda              = '1%';
cfg.reducerank          = 2;
sourcePre               = ft_sourceanalysis(cfg,freqPre);
sourcePost              = ft_sourceanalysis(cfg,freqPost);
sourcePost.pos          = template_grid.pos;
sourcePost.xgrid        = template_grid.xgrid;
sourcePost.ygrid        = template_grid.ygrid;
sourcePost.zgrid        = template_grid.zgrid;
sourcePost.dim          = template_grid.dim;
sourceDiff              = sourcePost;
sourceDiff.avg.pow      = (sourcePost.avg.pow - sourcePre.avg.pow) ./ sourcePre.avg.pow;


% plot on mni single subject brain
mrifile             = fullfile(spm('dir'),'canonical','single_subj_T1.nii');
mri                 = ft_read_mri(mrifile);
int                 = ft_sourceinterpolate([],sourceDiff,mri);
cfgp                = [];
cfgp.funparameter   = 'avg.pow';
cfgp.interactive    = 'yes';
ft_sourceplot(cfgp,int);

% write result
ft_write_volume('test_dics.nii',int.avg.pow,'dataformat','nifti','transform',mri.transform);