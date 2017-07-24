% script to do a minimum norm estimate on the spm8 canonical cortical
% surface via Fieldtrip's ft_sourceanalysis function

ft_defaults;
megfile = 'volition_spm8.mat';
load('ch2_temp.xfm', '-mat');
baselinewin = [-.2 0];
posttoi     = [.05 .25];
spmdir      = spm('dir');
res         = 8; % resolution of beamformer grid

% read in the surface and mri data
mri_file    = fullfile(spmdir,'canonical','single_subj_T1.nii');
iskull_file = fullfile(spmdir,'canonical','iskull_2562.surf.gii');
iskull      = gifti(iskull_file);
mri         = ft_read_mri(mri_file);

% read in an spm8 dataset
D=spm_eeg_load(megfile);

% get trial lists for later
t20=find(str2num(char([D.conditions])) == 20); % nogo?
t30=find(str2num(char([D.conditions])) == 30); % go?
t40=find(str2num(char([D.conditions])) == 40); % yellow?
t50=find(str2num(char([D.conditions])) == 50); % cue?

% coregister the MEG sensors and headshape to the MNI template
sensors = D.sensors('MEG');
hshape  = D.fiducials;
megfids = hshape.fid.pnt;
mrifids = [transform.mri.nas;transform.mri.lpa;transform.mri.rpa];
sform   = spm_eeg_inv_rigidreg(mrifids',megfids');
sensors = ft_transform_sens(sform,sensors);
hshape  = ft_transform_headshape(sform,hshape);

% create volume conductor model from inner skull
hdm                 = [];
hdm.bnd             = export(gifti(iskull),'ft');
hdm.bnd.nrm         = spm_eeg_inv_normals(iskull.vertices,iskull.faces);
hdm.type            = 'nolte';
hdm.unit            = 'mm';

% prepare dipole grid for beamformer
cfg_grid             = [];
cfg_grid.grad        = sensors; 
cfg_grid.reducerank  = 2;
cfg_grid.vol         = hdm;
cfg_grid.channel     = 'MEG';
cfg_grid.grid.xgrid  = -120:res:120;
cfg_grid.grid.ygrid  = -120:res:120;
cfg_grid.grid.zgrid  = -120:res:150;
cfg_grid.inwardshift = -5; % helps keep grid boundary from being tightly constrained by anatomy
grid                 = ft_prepare_leadfield(cfg_grid);

% convert data to Fieldtrip
ft                          = D.ftraw(0); clear('D');
cfg_pproc                   = [];
cfg_pproc.lpfilter          = 'yes';
cfg_pproc.lporder           = 2;
cfg_pproc.lpfreq            = 35;
cfg_pproc.dmean         	= 'yes';
cfg_pproc.baselinewindow    = baselinewin;
ft                          = ft_preprocessing(cfg_pproc,ft);

% averaging baseline correction and noise covariance
cfg_avg                     = [];
cfg_avg.covariance          = 'yes';
cfg_avg.channel             = {'MEG'};
cfg_avg.covariancewindow    = baselinewin;
ft_gapre                    = ft_timelockanalysis(cfg_avg,ft);
cov                         = ft_gapre.cov;
cfg_base.baseline           = [-inf 0];
ft_gapre                    = ft_timelockbaseline(cfg_base,ft_gapre);
ft_gapre.cov                = cov;
cfg_avg.covariancewindow    = posttoi;
ft_gapost                   = ft_timelockanalysis(cfg_avg,ft);
cov                         = ft_gapost.cov;
ft_gapost                   = ft_timelockbaseline(cfg_base,ft_gapost);
ft_gapost.cov               = cov;

% averaging of individual conditions
cfg_avg.trials  = t20;
ft_t20avg       = ft_timelockanalysis(cfg_avg,ft);
ft_t20avg       = ft_timelockbaseline(cfg_base,ft_t20avg);
ft_t20avg.cov   = ft_gapost.cov;
cfg_avg.trials  = t30;
ft_t30avg       = ft_timelockanalysis(cfg_avg,ft);
ft_t30avg       = ft_timelockbaseline(cfg_base,ft_t30avg);
ft_t30avg.cov   = ft_gapost.cov;
cfg_avg.trials  = t40;
ft_t40avg       = ft_timelockanalysis(cfg_avg,ft);
ft_t40avg       = ft_timelockbaseline(cfg_base,ft_t40avg);
ft_t40avg.cov   = ft_gapost.cov;
cfg_avg.trials  = t50;
ft_t50avg       = ft_timelockanalysis(cfg_avg,ft);
ft_t50avg       = ft_timelockbaseline(cfg_base,ft_t50avg);
ft_t50avg.cov   = ft_gapost.cov;

% source analysis of grand average to get common spatial filter
cfg_lcmv                    = [];
cfg_lcmv.method             = 'lcmv';
cfg_lcmv.lcmv.keepfilter    = 'yes';
cfg_lcmv.lcmv.fixedori      = 'yes';
cfg_lcmv.grid               = grid;
cfg_lcmv.grad               = sensors;
cfg_lcmv.vol                = hdm;
cfg_lcmv.lcmv.lambda        = '3%';
cfg_lcmv.channel            = 'MEG';
sourcepst                   = ft_sourceanalysis(cfg_lcmv, ft_gapost);
sourcepre                   = ft_sourceanalysis(cfg_lcmv, ft_gapre);
sourceDiff                  = sourcepst;
sourceDiff.avg.pow          = (sourcepst.avg.pow - sourcepre.avg.pow) ./ sourcepre.avg.pow;

% project conditions through common filter
cfg_cond             = cfg_lcmv;
cfg_cond.grid.filter = sourcepst.avg.filter; % use the common filter computed in the previous step 
source20             = ft_sourceanalysis(cfg_cond,ft_t20avg);
source20diff         = source20;
source20diff.avg.pow = (source20.avg.pow - sourcepre.avg.pow') ./ sourcepre.avg.pow';
source30             = ft_sourceanalysis(cfg_cond,ft_t30avg);
source30diff         = source30;
source30diff.avg.pow = (source30.avg.pow - sourcepre.avg.pow') ./ sourcepre.avg.pow';
source40             = ft_sourceanalysis(cfg_cond,ft_t40avg);
source40diff         = source40;
source40diff.avg.pow = (source40.avg.pow - sourcepre.avg.pow') ./ sourcepre.avg.pow';
source50             = ft_sourceanalysis(cfg_cond,ft_t50avg);
source50diff         = source50;
source50diff.avg.pow = (source50.avg.pow - sourcepre.avg.pow') ./ sourcepre.avg.pow';

% contrasts
source20gt30         = source20;
source20gt30.avg.pow = (source20diff.avg.pow - source30diff.avg.pow);
source40gt20         = source40;
source40gt20.avg.pow = (source40diff.avg.pow - source20diff.avg.pow);

% interpolate onto template mri
cfg_int                     = [];
cfg_int.downsample          = 1;
sourcediff_ga               = ft_sourceinterpolate(cfg_int,sourceDiff,mri);
sourcediff_20gt30           = ft_sourceinterpolate(cfg_int,source20gt30,mri);
sourcediff_40gt20           = ft_sourceinterpolate(cfg_int,source40gt20,mri);

% save sources as nifti files
ft_write_mri('volition_lcmv_ga.nii',...
    sourcediff_ga.avg.pow,'dataformat','nifti','transform',...
    mri.transform);
ft_write_mri('volition_lcmv_20gt30.nii',...
    sourcediff_20gt30.avg.pow,'dataformat','nifti','transform',...
    mri.transform);
ft_write_mri('volition_lcmv_40gt20.nii',...
    sourcediff_40gt20.avg.pow,'dataformat','nifti','transform',...
    mri.transform);

% plot source on mri
cfg_plot.interactive = 'yes';
cfg_plot.funparameter = 'avg.pow';
ft_sourceplot(cfg_plot,sourcediff_ga);
