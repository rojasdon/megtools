% Example script using various megtools programs to demonstrate various
% capabilities. This is an auditory steady state response example - see:
%   Teale, P. et al. (2008). Cortical source estimates of gamma band 
%   amplitude and phase are different in schizophrenia. Neuroimage, 42(4),
%   1481-1489.

% set defaults
meg_defaults;

% directory for data
[pth,~,~] = fileparts(which('meg_defaults'));
pth = fullfile(pth,'sample_data','auditory');
cd(pth);

% import a continuous file - by default the sample file in installation.
cnt = get4D('c,rfhp0.1Hz');

% list of bad channels during recording
bad_channels = {'A248'};

% delete bad channels - input is single channel or vector e.g., [117 201]
del = deleter(cnt,bad_channels);

% get indices of MEG data channels
megind = meg_channel_indices(del,'multi','MEG');

% separate continuous file into trials, or epochs
type    = 'trigger'; % alternatively, can be 'response'
start   = 200;  % prestim ms
stop    = 800; % poststim ms
adj     = 20;   % optional adjustment of trigger latency
epoched = epocher(del,'trigger',200,800,'offset',adj);

% uncomment next line to epoch with a threshold and and latency adjustment
% epoched = epocher(del,'trigger',trigval,start,stop,adj,thresh);

% if you have multiple trigger types and you want to concatenate them all
% into a single epoch file, you could use the following code, assuming that
% you'd separately epoched a set called epoched1 and another called
% epoched2 (you can have as many MEG structs concatenated as you wish in a
% single call to the function

% concatenated = concatMEG(epoched1,epoched2);

% you can save this file as an SPM8 formatted result as follows
% D = meg2spm(concatenated);

% you could also save this file as an EEGLAB formatted file as follows
% EEG = meg2eeglab(concatenated);

% DC offset correction epochs - default is prestim window if present
epoched = offset(epoched);

% average epochs (note you could also reject on amplitude in epocher
% you should offset epochs before applying rejection threshold
trig = 40;
avg = averager(epoched,'threshold',3000);

% filter avg with a few different filters - only works if signal processing
% toolbox installed
order = 4; lc = 0.5; hc = 55;
bp    = filterer(avg,'band',[lc hc],'order',order);

% offset correction
bp   = offset(bp);

% butterfly plot scaled to fT
scale = 1e15; % to plot in fT
figure('name','Averaged Evoked Field','color','w');
subplot(2,1,1);plot(avg.time,avg.data(megind,:)*scale); 
title('Raw');
axis tight;xlabel('Time (ms)');ylabel('Amplitude fT');
subplot(2,1,2);plot(bp.time,bp.data(megind,:)*scale);
title('Filtered');
axis tight;xlabel('Time (ms)');ylabel('Amplitude fT');

% 2d topo plot of a component
figure('name','2d topography','color','w');
meg_plot2d(bp,88);

% 3d topo plot at same point
figure('name','3D topography','color','w');
meg_plot3d(bp,88); title('3D topography');

% show headshape too just for fun
hold on;
scalp = triangulate_meg(bp.fiducials.pnt);
s = patch('faces',scalp,'vertices',bp.fiducials.pnt,'Edgecolor','r',...
       'Facelighting','none','Facecolor','none','Marker','o',...
        'Linestyle','none');

% demonstrate simple plot function for just headshape, fids and locations
subplot(1,2,2); plot_hs_sens(bp); title('3D headshape, fids and locations');

% time-frequency plot from channel 181(180) in the helmet from 5 to 80 Hz
tf = tft(epoched,[5 80],181,'waven',7);
figure('name','Morlet Wavelet Analysis in Gamma Band','color',[.8 .8 .8]);
meg_plotTFR(tf,'nepower');