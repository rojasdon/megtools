% script to read in and preprocess Volition data using Fieldtrip and
% megtools

cwd = pwd;
filename = 'c,rfhp0.1Hz';

% read in data from 2 runs
cd('Run1');
run1 = get4D(filename);
cd(cwd);
cd('Run2');
run2 = get4D(filename);

% append the 2 runs together
cd(cwd);
cnt = concatMEG(run1,run2);
clear run*;

% convert to Fieldtrip and run 4D-style noise reduction (only advisable for
% 9th avenue datasets)
ft = meg2ft(cnt); clear cnt;
refchans            = ft_channelselection('MEGREF',ft.label);
cfg_ref             = [];
cfg_ref.channel     = refchans;
ft_ref              = ft_preprocessing(cfg_ref,ft);
cfg_denoise         = [];
ft                  = ft_denoise_pca(cfg_denoise,ft,ft_ref); clear ft_ref;

% do ica
cfg_ica.method='binica';
cfg_ica.binica.pca = 50;
cfg_ica.channel = 'MEG';
ft_comp = ft_componentanalysis(cfg_ica,ft);

% plot ica
cfg_plotic = [];
cfg_plotic.component = 1:25;
cfg_plotic.commnent = 'no';
cfg_plotic.layout = '4D248.lay';
figure; ft_topoplotIC(cfg_plotic,ft_comp);
cfg_plotic.component = 26:50;
figure; ft_topoplotIC(cfg_plotic,ft_comp);

% reject ica component(s)
cfg_rem.component = [1,26,35];
ft_corr = ft_rejectcomponent(cfg_rem,ft_comp);

% don't forget to add back the non-MEG channels to the corrected data!
ismeg            = find(ft_chantype(ft.label,'meg'));
notmeg           = find(ft_chantype(ft.label,'meg') == 0);
ft_corr.trial    = {[ft_corr.trial{1}(ismeg,:); ft.trial{1}(notmeg,:)]};
ft_corr.label    = [ft_corr.label(ismeg);ft.label(notmeg)];


% convert back to megtools
ft_corr.hdr = ft.hdr; % for some reason, hdr removed in ica
cnt = ft2meg(ft_corr);

% get events in convenient form for sorting trials
events=str2num(char({cnt.events.type}));

% examples of logic to extract correct incorrect trial indices
comission_errors = strfind(events,[20 32]);

% epoch the data from -200 to 800 ms around triggers - this would probably
% be the dataset you would source analyze. Or, a grand average of all
% triggers
ep  = epocher(cnt,'trigger',200,800); % all trigger types, no sequences
% epmaybego = epocher(cnt,'trigger',200,800,'pattern',[40 32]);
% epmaybeno = epocher(cnt,'trigger',200,800,'pattern',[40 50]);
save('ica_corr.mat','cnt','events'); % save to disk

% convert to spm8 for later use by Fieldtrip and SPM8
D = meg2spm(ep,'volition_spm8'); clear D;

% extract epochs for each trigger type - if you want correct/incorrect,
% must do this on epocher line, not here
ep20 = epoch_extractor(ep,20);
ep30 = epoch_extractor(ep,30);
ep40 = epoch_extractor(ep,40);
ep50 = epoch_extractor(ep,50);

% average each type using rejection threshold of 3000 fT
avg20 = offset(averager(ep20,'threshold',3000));
avg30 = offset(averager(ep30,'threshold',3000));
avg40 = offset(averager(ep40,'threshold',3000));
avg50 = offset(averager(ep50,'threshold',3000));
ga    = offset(averager(ep,'threshold',3000)); % grand average
clear ep;

% low pass filter the averages at 55 Hz
avg20 = filterer(avg20,'low',55);
avg30 = filterer(avg30,'low',55);
avg40 = filterer(avg40,'low',55);
avg50 = filterer(avg50,'low',55);

% display averages in plot
cind = meg_channel_indices(avg20,'multi','MEG');
figure;
subplot(2,2,1); plot(avg20.time,avg20.data(cind,:)*1e15);
xlabel('Time (ms)'); ylabel('Amplitude (fT)');
title('Trigger type: 20'); axis tight;
subplot(2,2,2); plot(avg30.time,avg30.data(cind,:)*1e15);
xlabel('Time (ms)'); ylabel('Amplitude (fT)');
title('Trigger type: 30'); axis tight;
subplot(2,2,3); plot(avg40.time,avg40.data(cind,:)*1e15);
xlabel('Time (ms)'); ylabel('Amplitude (fT)');
title('Trigger type: 40'); axis tight;
subplot(2,2,4); plot(avg50.time,avg50.data(cind,:)*1e15);
xlabel('Time (ms)'); ylabel('Amplitude (fT)');
title('Trigger type: 50'); axis tight;
