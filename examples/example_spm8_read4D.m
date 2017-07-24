% example of reading 4D MEG data into SPM8 via script - need to have
% hs_file and config in same directory as data

% spm eeg defaults
spm('defaults','eeg');

% read data
S.dataset   = 'e,rfhp0.1Hz,x,n,o,bahe001-1';
S.channel   = {'MEG' 'TRIGGER'}; % use 'ALL' if you want all channel types
D           = spm_eeg_convert(file);

% save data
D.save;
