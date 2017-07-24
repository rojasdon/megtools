% script to do an event-related SAM analysis on dataset

ft_defaults;
megfile     = '1258_test_noica';
load('ch2_temp.xfm', '-mat'); % template coregistration stuff
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

% coregister the MEG sensors and headshape to the MNI template
sensors = D.sensors('MEG');
hshape  = D.fiducials;
megfids = hshape.fid.pnt;
mrifids = [transform.mri.nas;transform.mri.lpa;transform.mri.rpa];
sform   = spm_eeg_inv_rigidreg(mrifids',megfids');
sensors = ft_transform_sens(sform,sensors);
hshape  = ft_transform_headshape(sform,hshape);

% convert to newer Fieldtrip sensor structure if needed. Comment out if not
sensors = ft_oldgrad2newgrad(sensors);

% find a best fit sphere, could use for head model but here we use it
% simply for input to the SAM analysis to use for spinning option
cfg_vol                 = [];
cfg_vol.grad            = sensors;
cfg_vol.headshape       = hshape;
cfg_vol.feedback        = 'yes';
cfg_vol.singlesphere    = 'yes';
vol                     = ft_prepare_localspheres(cfg_vol);

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
cfg_avg.covariancewindow    = [-Inf Inf];
cfg_avg.removemean          = 'yes';
ft_avg                      = ft_timelockanalysis(cfg_avg,ft);
covar                       = ft_avg.cov;
cfg_base.baseline           = [-inf 0];
ft_avg                      = ft_timelockbaseline(cfg_base,ft_avg);
ft_avg.cov                  = covar;
cfg_time                    = [];
cfg_time.toilim             = [-Inf 0];
ft_pre                      = ft_redefinetrial(cfg_time,ft_avg);
cfg_time.toilim             = [.001 .8];
ft_post                     = ft_redefinetrial(cfg_time,ft_avg);

% source analysis of grand average to get common spatial filter
cfg_sam                         = [];
cfg_sam.method                  = 'sam';
cfg_sam.sam.keepfilter          = 'yes';
cfg_sam.sam.fixedori            = 'spinning'; % 'robert' option works well and is faster
cfg_sam.sam.meansphereorigin    = vol.o;
cfg_sam.grid                    = grid;
cfg_sam.grad                    = sensors;
cfg_sam.vol                     = hdm;
%cfg_sam.sam.lambda              = '.05%';
cfg_sam.channel                 = 'MEG';
source                          = ft_sourceanalysis(cfg_sam, ft_avg);

% normalize using Neural Activity Index approach based on noise estimation
% from smallest singular value from svd() of covariance matrix - this should 
% be approximately the erSAM approach from Cheyne et al. 2006
sourceNAI           = source;
sourceNAI.avg.pow   = source.avg.pow./source.avg.noise;
 
% interpolate onto template mri
cfg_int                     = [];
cfg_int.downsample          = 1;
sourceNAIint                = ft_sourceinterpolate(cfg_int,sourceNAI,mri);

% save sources as nifti files
ft_write_mri('test_sam.nii',...
    sourceNAIint.avg.pow,'dataformat','nifti','transform',...
    mri.transform);

% plot source on mri
cfg_plot.interactive = 'yes';
cfg_plot.funparameter = 'avg.pow';
ft_sourceplot(cfg_plot,sourceNAIint);
