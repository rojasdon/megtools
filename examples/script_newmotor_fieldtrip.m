% script to process new motor experiment in Fieldtrip

cwd = pwd;

% read in data from 2 runs
cfg_read = [];
cfg_read.dataset = 'c,rfDC';
cfg_read.trialdef.eventtype = 'TRIGGER';
cfg_read.trialdef.eventvalue = [108 110];
cfg_read.trialdef.prestim = .5;
cfg_read.trialdef.poststim = 8.0;
cd('3');
cfg_read = ft_definetrial(cfg_read);
run1 = ft_preprocessing(cfg_read);
cd(cwd);
cd('4');
cfg_read = ft_definetrial(cfg_read);
run2 = ft_preprocessing(cfg_read);

% append the 2 runs together
cd(cwd);
ft_epochs=ft_appenddata([],run1,run2);
clear run*;

% do ica
cfg_ica.method='binica';
cfg_ica.binica.pca = 50;
cfg_ica.channel = 'MEG';
ft_comp = ft_componentanalysis(cfg_ica,ft_epochs);

% plot ica
cfg_plotic = [];
cfg_plotic.component = 1:50;
cfg_plotic.commnent = 'no';
cfg_plotic.layout = '4D248.lay';
figure; ft_topoplotIC(cfg_plotic,ft_comp);

% reject component(s)
cfg_rem.component = 1;
ft_epochs_corr = ft_rejectcomponent(cfg_rem,ft_comp);

% separate trials for analysis
movetrials=1:2:28;
stilltrials=2:2:28;
cfg_trials.trials = movetrials;
ft_move = ft_preprocessing(cfg_trials,ft_epochs_corr);
cfg_trials.trials = stilltrials;
ft_still = ft_preprocessing(cfg_trials,ft_epochs_corr);

% do frequency analysis on trials
cfg_fft        = [];
cfg_fft.output = 'pow';
cfg_fft.method = 'mtmfft';
cfg_fft.taper  = 'dpss';
cfg_fft.tapsmofrq = 3;
cfg_fft.foi = 1:.05:55;
freq_move = ft_freqanalysis(cfg_fft,ft_move);
freq_still = ft_freqanalysis(cfg_fft,ft_still);