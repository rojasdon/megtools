function D = spm_correct_besa_avr_eeg(file) 

%function to import BESA avr exports and correct fields for SPM8

% define some variables
onset = -600.145; % onset of prestim in ms from avr file

% convert the avr to spm
D = spm_eeg_convert(file);
clear D;

% load the spm file
[pth nam ext] = fileparts(file);
spmfile = fullfile(pth,['spm8_' nam '.mat']);
load(spmfile);

D.timeOnset = onset/1e3;

% save corrected file
save(spmfile, 'D');


