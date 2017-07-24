% example script using various megtools programs to demonstrate various
% capabilities

% set defaults
meg_defaults;

% directory for data
pth = fullfiles(which('ft_defaults'),'sample_data');
cd(pth);

% import a continuous file - by default the sample file in installation.
% This is a left finger movement study - see paper for methods:
%   Wilson, T. W. et al. (2010). An extended motor network generates beta 
%       and gamma oscillatory perturbations during development. 
%       Brain and cognition, 73(2), 75-84.
cnt = get4D('c,rfhp0.1Hz');

% delete bad channels - input is single channel or vector e.g., [117 201]
del = deleter(cnt,91);

% separate continuous file into trials, or epochs
type    = 'trigger'; % alternatively, can be 'response'
start   = 200;  % prestim ms
stop    = 1000; % poststim ms
thresh  = 3000; % optional rejection threshold
adj     = 20;   % optional adjustment of trigger latency
epoched = epocher(del,type,start,stop,0);

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
% you should offset before averaging with a rejection threshold
trig = 40;
avg  = averager(epoched,thresh,trig);

% filter avg with a few different filters - only works if signal processing
% toolbox installed
order = 4; low = 20; high = 55;
lp   = filterer(avg,order,'low',low);
hp = filterer(avg,order,'high',2);
bp   = filterer(avg,order,'band',low,high);

% offset correction
corr = offset(lp);
hp   = offset(hp);
bp   = offset(bp);

% you could combine some or all of these calls in one line, as follows:
% corr=offset(filterer(averager(epoched,thresh),4,'low',30));

% get root mean square of waveform
rms  = xrms(corr,1);

% butterfly plot scaled to fT
figure('name','Averaged Evoked Field','color',[.8 .8 .8]);
subplot(2,1,1);plot(corr.time,corr.data*1E15); 
title('Averaged Evoked Field');
axis tight;xlabel('Time (ms)');ylabel('Amplitude fT');
subplot(2,1,2);plot(rms.time,rms.data);
title('Root Mean Squared Amplitude');
axis tight;xlabel('Time (ms)');ylabel('Amplitude fT');

% compare various filtered datasets
figure('name','Various Filters','color',[.8 .8 .8]);
subplot(3,1,1);plot(corr.time,corr.data*1E15); 
title('20 Hz low pass');axis tight;xlabel('Time (ms)');ylabel('Amplitude fT');
subplot(3,1,2);plot(hp.time,hp.data);
title('2 Hz high pass');axis tight;xlabel('Time (ms)');ylabel('Amplitude fT');
subplot(3,1,3);plot(bp.time,bp.data);
title('20-55 Hz band pass');axis tight;xlabel('Time (ms)');ylabel('Amplitude fT');

% topo plot of peak at 155 msec
figure('name','flat topography','color',[.8 .8 .8]);
meg_plot2d(corr,155);

% 3d topo plot at same point
figure('name','3D topography','color',[.8 .8 .8]);
subplot(1,2,1); meg_plot3d(corr,155); title('3D topography');

% uncomment to show headshape too just for fun
% hold on;
% scalp = triangulate_meg(corr.fiducials.pnt);
% s = patch('faces',scalp,'vertices',corr.fiducials.pnt,'Edgecolor','r',...
%       'Facelighting','none','Facecolor','none','Marker','o',...
%        'Linestyle','none');

% demonstrate simple plot function for just headshape, fids and locations
subplot(1,2,2); plot_hs_sens(corr); title('3D headshape, fids and locations');

% time-frequency plot from channel 181(180) in the helmet from 5 to 80 Hz
tf = tft(epoched,[5 80],181,'waven',7);
figure('name','Morlet Wavelet Analysis in Gamma Band','color',[.8 .8 .8]);
meg_plotTFR(tf,'nepower');