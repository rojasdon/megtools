% example of doing fft analysis in sensors using only Fieldtrip

% first read the data into workspace
cfg_read.dataset='c,rfhp0.1Hz';
cfg_read.trialfun='trialfun_general';
cfg_read.trialdef.triallength=1;
cfg_read.trialdef.ntrials=inf;
cfg_read = ft_definetrial(cfg_read); % chops up continuous data into 1 second trials
ft       = ft_preprocessing(cfg_read);

% now do spectral analysis
cfg_fft=[];
cfg_fft.method='mtmfft';
cfg_fft.output='pow';
cfg_fft.foi=1:55;
cfg_fft.tapsmofrq=3;
cfg_fft.channel='MEG';
freq = ft_freqanalysis(cfg_fft,ft);

% plot results for all sensors
% there are many plotting options for labeling and scaling not shown
cfg_plot.layout='4D248.lay';
ft_multiplotER(cfg_plot,freq); % have to use ER instead of TFR because freq has no time field

% plot an individual sensor
cfg_single.channel = 'A214';
ft_singleplotER(cfg_single,freq);