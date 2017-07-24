% time frequency example in Fieldtrip

% fieldtrip defs
ft_defaults; 

% load an epoched Fieldtrip file
load 1040_ft.mat;

% configure and run a morlet wavelet
cfg = [];
cfg.channel    = 'MEG';
cfg.method     = 'wavelet';
cfg.width      = 6;
cfg.output     = 'pow';
cfg.foi        = 5:1:100;
cfg.toi        = -.2:.01:1;
TFRwave        = ft_freqanalysis(cfg, ft);

% configure and run a multitaper analysis
cfg = [];
cfg.channel    = 'MEG';
cfg.method     = 'mtmconvol';
cfg.output     = 'pow';
cfg.foi        = 10:2:60;
cfg.tapsmofrq  = 0.4*cfg.foi;
cfg.t_ftimwin  = 5./cfg.foi;
cfg.toi        = -1:.05:1;
cfg.pad        = 'maxperlen';
TFRwave        = ft_freqanalysis(cfg, ft); 

% plot one channel and multichannel display
cfg = [];
cfg.baseline     = [-1 -.2];
cfg.baselinetype = 'relative';
cfg.zlim         = 'maxmin';
%cfg.ylim         = [10 60];
cfg.channel      = 'A152';
figure;ft_singleplotTFR(cfg, TFRwave);
cfg.layout       = '4D248.lay';
cfg.showlabels   = 'yes';
figure;ft_multiplotTFR(cfg, TFRwave);

