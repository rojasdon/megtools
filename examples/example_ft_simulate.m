% read 4D file - it doesn't matter which file, any with sensor information
% will do
file = 'c,rfhp0.1Hz';
hdr  = ft_read_header(file);
hs   = ft_read_headshape('hs_file');

% create a single sphere conductor model
cfg                 = [];
cfg.grad            = hdr.grad;
cfg.headshape   	= hs.pnt;
cfg.singlesphere    = 'yes';
cfg.feedback        = 'yes';
figure;
ft_sphere           = ft_prepare_localspheres(cfg);

% simulate a single dipole
cfg_sim.vol            = ft_sphere;
cfg_sim.grad           = hdr.grad;
cfg_sim.fsample        = hdr.Fs;
cfg_sim.relnoise       = .1;
cfg_sim.dip.frequency  = 10;
cfg_sim.dip.phase      = pi/2; % 90 degree phase
cfg_sim.triallength    = 1;
cfg_sim.ntrials        = 109;
cfg_sim.dip.pos        = [-.01 .05 .06]; % position in meters ap,lr,is (neg is right)
cfg_sim.dip.mom        = [0 0 -1]';
sim                    = ft_dipolesimulation(cfg_sim);

% average simulation
ft_dip_avg              = ft_timelockanalysis([],sim);

% plot simulation
cfg_ploter = [];
cfg_ploter.channel = 'MEG';
cfg_ploter.layout  = '4D248.lay';
figure;ft_multiplotER(cfg_ploter,ft_dip_avg);

% plot topography
cfg_topoplot = [];
cfg_topoplot.xlim = [.5 .5];
cfg_topoplot.channel = 'MEG';
cfg_topoplot.layout  = '4D248.lay';
figure;ft_topoplotER(cfg_topoplot,ft_dip_avg);

% do a dipole fit on simulation
%cfg_fit                 = [];
%cfg_fit.numdipoles      = 1;
%cfg_fit.vol             = ft_sphere;
%cfg_fit.grad            = ft_dip_avg.grad;
%cfg_fit.reducerank      = 2; % for gradiometers
%cfg_fit.latency         = 1e-3*[100 200];
%cfg_fit.vol             = ft_sphere;
%cfg_fit.grid.xgrid      = linspace(cfg_fit.vol.o(1)-.1,cfg_fit.vol.o(1)+.1,20);
%cfg_fit.grid.ygrid      = linspace(cfg_fit.vol.o(2)-.1,cfg_fit.vol.o(2)+.1,20);
%cfg_fit.grid.zgrid      = linspace(cfg_fit.vol.o(3)-.1,cfg_fit.vol.o(3)+.1,20);
%cfg_fit.nonlinear       = 'yes';
%cfg_fit.channel         = {'MEG'};
%cfg_fit.model           = 'regional';
%src                     = ft_dipolefitting(cfg_fit,ft_dip_avg);