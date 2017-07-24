% script to do a minimum norm estimate on the spm8 canonical cortical
% surface via Fieldtrip's ft_sourceanalysis function

ft_defaults;
megfile = '1003_assr_spm8_epochs.mat';
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

% read in an spm8 dataset - should be coregistered to mni template
D = spm_eeg_load(megfile);

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
cfg_pproc.lpfreq            = 50;
cfg_pproc.dmean         	= 'yes';
cfg_pproc.baselinewindow    = baselinewin;
ft = ft_preprocessing(cfg_pproc,ft);
cfg_avg                     = [];
cfg_avg.covariance          = 'yes';
cfg_avg.channel             = {'MEG'};
cfg_avg.covariancewindow    = baselinewin;
ft = ft_timelockanalysis(cfg_avg,ft);
cov                         = ft.cov;
cfg_base                    = [];
cfg_base.baseline           = baselinewin;
ft = ft_timelockbaseline(cfg_base,ft);
ft.cov                      = cov;

% compute leadfields
cfg_lf             = [];
cfg_lf.grad        = sensors;                      % sensor positions
cfg_lf.channel     = {'MEG'};                      % the used channels
cfg_lf.grid.pos    = sourcespace.bnd.pnt;              % source points
cfg_lf.grid.inside = 1:size(sourcespace.bnd.pnt,1);    % all source points are inside of the brain
cfg_lf.vol         = hdm;                          % volume conduction model
cfg_lf.reducerank  = 2;
lf                 = ft_prepare_leadfield(cfg_lf);

% signal to noise ratio option
t0          = get_time_index(ft,0);
rms         = mean(sqrt(ft.avg.^2));
pre         = rms(:,1:t0);
post        = rms(t0+1:end);
snr         = mean(post)/mean(pre);

% source analysis
cfg_src                 = [];
cfg_src.method          = 'mne';
cfg_src.grad            = sensors;
cfg_src.channel         = {'MEG'};
cfg_src.grid            = lf;
cfg_src.vol             = hdm;
cfg_src.mne.lambda      = []; % 1e8;
cfg_src.mne.snr         = snr; % some custom options have to be passed in mne
cfg_src.reducerank      = 2;
sourcemne               = ft_sourceanalysis(cfg_src,ft);

% plot result at single time point
%figure;
%m = sourcemne.avg.pow(:,136);
%figure;ft_plot_mesh(sourcespace.bnd,'vertexcolor', m);

% plot movie
figure;
cfg_desc            = [];
cfg_desc.projectmom ='yes';
sd = ft_sourcedescriptives(cfg_desc,sourcemne);
sd.tri = sourcespace.bnd.tri;
cfg_plot = [];
cfg_plot.maskparameter = 'avg.pow';
figure;ft_sourcemovie(cfg_plot,sd);