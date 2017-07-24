% script to do a minimum norm estimate on the spm8 canonical cortical
% surface via Fieldtrip's ft_sourceanalysis function

ft_defaults;
megfile = 'volition_spm8.mat';
load 'ch2_temp.xfm' -mat;
baselinewin = [-.2 0];
spmdir  = spm('dir');

% read in the surfaces
cortex_file = fullfile(spmdir,'canonical','cortex_5124.surf.gii');
iskull_file = fullfile(spmdir,'canonical','iskull_2562.surf.gii');

% plot the cortical surface and inner skull
figure;
cortex = gifti(cortex_file);
iskull = gifti(iskull_file);
c=patch('faces',cortex.faces,'vertices',cortex.vertices,'facecolor','m','edgecolor','none');
i=patch('faces',iskull.faces,'vertices',iskull.vertices,'facecolor','none');
hold on;

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
ft_plot_sens(sensors);
ft_plot_headshape(hshape,'vertexcolor','r');
axis image;
lighting gouraud;
camlight;

% create volume conductor model and sourcespace
hdm                 = [];
hdm.bnd             = export(gifti(iskull),'ft');
hdm.bnd.nrm         = spm_eeg_inv_normals(iskull.vertices,iskull.faces);
hdm.type            = 'nolte';
hdm.unit            = 'mm';
sourcespace         = [];
sourcespace.bnd     = export(gifti(cortex),'ft');
sourcespace.bnd.nrm = spm_eeg_inv_normals(cortex.vertices,cortex.faces);

% convert data to Fieldtrip
ft = D.ftraw(0); 
clear('D');
cfg_pproc                   = [];
cfg_pproc.lpfilter          = 'yes';
cfg_pproc.lporder           = 2;
cfg_pproc.lpfreq            = 35;
cfg_pproc.dmean         	= 'yes';
cfg_pproc.baselinewindow    = baselinewin;
ft = ft_preprocessing(cfg_pproc,ft);

% separate into various trial types now
cfg_trials                  = [];
cfg_trials.trials           = t20;
ft20                        = ft_preprocessing(cfg_trials,ft);
cfg_trials.trials           = t30;
ft30                        = ft_preprocessing(cfg_trials,ft);
cfg_trials.trials           = t40;
ft40                        = ft_preprocessing(cfg_trials,ft);
cfg_trials.trials           = t50;
ft50                        = ft_preprocessing(cfg_trials,ft);
clear('ft');

% averaging baseline correction and noise covariance
cfg_avg                     = [];
cfg_avg.covariance          = 'yes';
cfg_avg.channel             = {'MEG'};
cfg_avg.covariancewindow    = baselinewin;
% type 20
ft20                        = ft_timelockanalysis(cfg_avg,ft20);
cov                         = ft20.cov;
cfg_base                    = [];
cfg_base.baseline           = baselinewin;
ft20                        = ft_timelockbaseline(cfg_base,ft20);
ft20.cov                    = cov;
% type 30
ft30                        = ft_timelockanalysis(cfg_avg,ft30);
cov                         = ft30.cov;
cfg_base                    = [];
cfg_base.baseline           = baselinewin;
ft30                        = ft_timelockbaseline(cfg_base,ft30);
ft30.cov                    = cov;
% type 40
ft40                        = ft_timelockanalysis(cfg_avg,ft40);
cov                         = ft40.cov;
cfg_base                    = [];
cfg_base.baseline           = baselinewin;
ft40                        = ft_timelockbaseline(cfg_base,ft40);
ft40.cov                    = cov;
% type 50
ft50                        = ft_timelockanalysis(cfg_avg,ft50);
cov                         = ft50.cov;
cfg_base                    = [];
cfg_base.baseline           = baselinewin;
ft50                        = ft_timelockbaseline(cfg_base,ft50);
ft50.cov                    = cov;

% compute leadfields
cfg_lf             = [];
cfg_lf.grad        = sensors;                      % sensor positions
cfg_lf.channel     = {'MEG'};                      % the used channels
cfg_lf.grid.pos    = sourcespace.bnd.pnt;              % source points
cfg_lf.grid.inside = 1:size(sourcespace.bnd.pnt,1);    % all source points are inside of the brain
cfg_lf.vol         = hdm;                          % volume conduction model
cfg_lf.reducerank  = 2;
lf                 = ft_prepare_leadfield(cfg_lf);

% source analysis
cfg_src                 = [];
cfg_src.method          = 'mne';
cfg_src.grad            = sensors;
cfg_src.channel         = {'MEG'};
cfg_src.grid            = lf;
cfg_src.vol             = hdm;
cfg_src.mne.lambda      = 1e29;% some custom options have to be passed in mne
cfg_src.reducerank      = 2;
mne20                   = ft_sourceanalysis(cfg_src,ft20);
mne30                   = ft_sourceanalysis(cfg_src,ft30);
mne40                   = ft_sourceanalysis(cfg_src,ft40);
mne50                   = ft_sourceanalysis(cfg_src,ft50);

% plot movie
cfg_desc                = [];
cfg_desc.projectmom     ='yes';
sd20                	= ft_sourcedescriptives(cfg_desc,mne20);
sd20.tri                = sourcespace.bnd.tri;
sd30                	= ft_sourcedescriptives(cfg_desc,mne30);
sd30.tri                = sourcespace.bnd.tri;
sd40                	= ft_sourcedescriptives(cfg_desc,mne40);
sd40.tri                = sourcespace.bnd.tri;
sd50                	= ft_sourcedescriptives(cfg_desc,mne50);
sd50.tri                = sourcespace.bnd.tri;
cfg_plot                = [];
cfg_plot.maskparameter  = 'avg.pow';
figure;ft_sourcemovie(cfg_plot,sd20);
figure;ft_sourcemovie(cfg_plot,sd30);
figure;ft_sourcemovie(cfg_plot,sd40);
figure;ft_sourcemovie(cfg_plot,sd50);