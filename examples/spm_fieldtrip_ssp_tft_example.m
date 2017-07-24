% EXAMPLE SCRIPT
% using Fieldtrip, SPM and megtools to do signal space projection and
% time-frequency analysis

% spm eeg defaults
spm('defaults','eeg');

% load SPM8 meeg struct
D = spm_eeg_load('bfm1000_spm.mat');

% do single dipole source analysis on average
start = 91;
stop  = 91;
pair  = 1;
[src mni] = dipfit_spm_ft(D,start,stop,pair);

% load epochs and copy relevant inv field to epochs
E = spm_eeg_load('1000_spm.mat');
E.inv = D.inv;

% compute ssp
[proj, W] = signalspace_spm_ft(E,src);

% make ssp struct - this will change soon!
ssp.Q     = proj;
ssp.time  = D.time;
ssp.epdur = abs(D.time(1)) + D.time(end);
ssp.pstim = D.time(1);
ssp.cloc  = D.sensors('MEG').pnt(1:length(D.sensors('MEG').label),:);
ssp.W     = W;
save('1000_L_Qt.mat','ssp');

% compute tft and plot
tf = QTF('1000_L_Qt.mat',5,60);
figure;subplot(2,1,1);
contourf(tf.time,tf.freq,tf.epower,30,'linestyle','none');
title('Evoked power'); xlabel('Time (s)'); ylabel('Freq (Hz)');
subplot(2,1,2);
contourf(tf.time,tf.freq,tf.mplf,30,'linestyle','none');
title('PLF'); xlabel('Time (s)'); ylabel('Freq (Hz)');

% save tft
save('1000_L_Qt_TFT.mat','tf');