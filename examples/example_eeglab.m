% example of using EEGLAB to do ica, using a few of Don's megtools programs
% as intermediaries. Any function with a pop_ prefix is an EEGLAB function.
% Read the comments and understand before you start running this example

id = '0003'; % change to your subject's id
file = 'c,rfhp0.1Hz';

% get file
cnt = get4D(file);

% deleting bad channels is good idea before ica (uncomment if necessary)
cnt = deleter(cnt,91);

% convert to epochs
eps = epocher(cnt,'trigger',200,800); % a stimulus locked average

% look at uncorrected offset average
avg = offset(averager(eps)); % output of one function used as input to another
figure('name','Uncorrected Average'); plot(avg.time,avg.data);

% convert to EEGLAB structure
EEG = meg2eeglab(eps,[id '_eeglab']);

% do ica using fastica and using pca to restrain data to first 25
% components - may need to be higher for some data. This uses EEGLAB
% interface to fastica. Fastica can be called independent of EEGLAB if
% desired.
% OUT = pop_runica(EEG,'icatype','fastica','lastEig',25);

% or, use binica/runica algorithm - keep only one uncommented
OUT = pop_runica(EEG,'icatype','runica','pca',25);

% use EEGLAB GUI or individual functions to reject components and save
pop_eegplot(OUT, 1, 1, 0); % shows data
pop_eegplot(OUT, 0, 1, 0); % shows component time courses

% plot 25 component topography in 5 x 5 grid
pop_topoplot(OUT, 0, 1:size(OUT.icaweights,1),'ica_estimated_data',[5 5] ,0,'electrodes','off');

% prompt at command line in MATLAB for components to remove
fprintf('Enter component numbers to remove (e.g., [1:4, 10])\n');
noise = input('Which ones to remove? ');

% remove the components you don't like
OUT = pop_subcomp(OUT, noise, 0);

% save EEGLAB set 
pop_saveset(OUT,[id '_eeglab_ica']);

% use EEGLAB to view corrected average, first removing offset
OUT = pop_rmbase(OUT,[-200 0]);
figure;pop_timtopo(OUT,[OUT.xmin*1e3 OUT.xmax*1e3],[NaN],'ERF','chantype','MEG');

% re-read EEGLAB data into workspace if not already there
% load([id '_eeglab_ica.set'], '-mat');
% OUT = EEG;

% convert back to MEG structure for megtools
eps = eeglab2meg(OUT);

% take a look at the new offset average - redundant if using EEGLAB to do
% it a few lines above
avg = offset(averager(eps));
figure('name','Corrected Average'); plot(avg.time,avg.data);

% do whatever you like with your ica corrected data - you can put it back
% in the 4D software (put4D.m), convert to Fieldtrip (meg2ft.m) or SPM
% (meg2spm.m) or continue to use a combination of tools from whatever package
% you like.