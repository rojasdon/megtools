% fieldtrip basic example - reading data into fieldtrip 2 ways

ft_defaults;

% 1st way - directly from 4D format - this follows tutorial example at 
% http://fieldtrip.fcdonders.nl/tutorial/preprocessing
cfg                        = [];
cfg.dataset                 = 'c,rfhp0.1Hz';
cfg.trialdef.eventtype     = 'TRIGGER';
cfg.trialdef.eventvalue    = 4096+250; % i.e., a 250 code
cfg.trialdef.prestim       = .5;
cfg.trialdef.poststim      = 1;

% use fieldtrip to define epochs (called trials by ft) based on the trigger channel
cfg = ft_definetrial(cfg);

% read in the epochs from the original continuous file
cfg.channel                 = {'MEG', '-A91', '-A127', 'A234','A244'};
cfg.continuous              = 'yes';
ft                          = ft_preprocessing(cfg);

% save data for later
save PreprocData ft;

% OR, you can do some basic things in other programs first, then convert to
% Fieldtrip
cnt = get4D('c,rfhp0.1Hz');
cnt = deleter(cnt,117);
eps = epocher(cnt,'trigger',200,800);
ft  = meg2ft(eps);

% do some basic things in Fieldtrip like averaging, filtering and baseline
% correction

cfg         = [];
cfg.channel = 'all';
cfg.trials  = 'all';
avg         = ft_timelockanalysis(cfg,ft);

cfg                 = [];
cfg.lpfilter        = 'yes';
cfg.lpfreq          = 50;
cfg.lpfiltord       = 2;
avg                 = ft_preprocessing(cfg,avg);

cfg             = [];
cfg.baseline    = [-.2 0];
avg             = ft_timelockbaseline(cfg,avg);

% plot it using Fieldtrip function
cfg         = [];
cfg.xlim    = [-0.2 1];
cfg.ylim    = [-1e-13 1e-13];
cfg.layout  = '4D248.lay';
figure;multiplotER(cfg,avg);

% plot topography in Fieldtrip
cfg         = [];
cfg.comment = 'xlim';
cfg.commentpos = 'leftbottom';
cfg.xlim    = 0.025:.05:0.25;
cfg.zlim    = [-6e-14 6e-14];
cfg.layout  = '4D248.lay';
figure; ft_topoplotER(cfg,avg);