% fieldtrip basic example - reading data from 4D instrument
% must have config and possibly also hs_file in directory with data

ft_defaults;

% Read directly from 4D format - this follows tutorial example at 
% http://fieldtrip.fcdonders.nl/tutorial/preprocessing
cfg                        = [];
cfg.dataset                 = 'c,rfhp0.1Hz'; % name of 4D file here
cfg.trialdef.eventtype     = 'TRIGGER';
cfg.trialdef.eventvalue    = 4246; % a trigger value here
cfg.trialdef.prestim       = .2;
cfg.trialdef.poststim      = .8; % epoch window in sec

% use fieldtrip to define epochs (called trials by ft) based on the trigger channel
cfg = ft_definetrial(cfg);

% read in the epochs from the original continuous file
cfg.channel                 = {'MEG', '-A117', '-A195'};
cfg.continuous              = 'yes';
ft                          = ft_preprocessing(cfg);

% save data for later
save PreprocData ft;

% if you want to read already epoched data into fieldtrip, you only need
% the .dataset, .channel and .continuous = 'no' parts of the cfg