% example script using various megtools programs to demonstrate various
% capabilities

% This is a left finger movement study - see paper for methods:
%   Wilson, T. W. et al. (2010). An extended motor network generates beta 
%       and gamma oscillatory perturbations during development. 
%       Brain and cognition, 73(2), 75-84.

% set defaults
meg_defaults;

% directory for data
[pth,~,~] = fileparts(which('meg_defaults'));

% check if data are downloaded
if exist(fullfile(pth,'sample_data','motor'),'dir')
    cd(fullfile(pth,'sample_data','motor'));
else
    error('Sample dataset not present!');
end

% import a continuous file - by default the sample file in installation.
cnt = get4D('c,rfhp0.1Hz');

% there are no events in this file. We will create events from an
% accelerometer auxillary channel. The accelerometer was attached to the
% left index finger

% get indices of external channels
ext = meg_channel_indices(cnt,'multi','EXT');

% create triggers from accelerometers
vals                = [10 20]; % trigger codes, one for each accelerometer channel
dur                 = 3000;    % duration re-triggering is prevented
threshold           = 2.5;     % in sd units for trigger definition
[accel, fchn, thresh] = process_auxiliary(cnt.data(ext(1:2),:),vals,cnt.sr,3000,threshold);
newtrigs            = bitor(double(accel(1,:)),double(accel(2,:))); % combine into a single trigger channel
trig                = meg_channel_indices(cnt,'multi','TRIGGER'); % trigger channel index
cnt.data(trig,:)    = cnt.data(trig,:) + newtrigs; % adds values to existing triggers - if already empty, can just replace
cnt.events          = create_events(cnt.data(trig,:),{'TRIGGER'});

% delete bad channels
del = cnt;

% create trials from events
start = 2500;
stop = 2500;
epoched = epocher(del,'trigger',start,stop);

% extract only left finger epochs
left =  epoch_extractor(epoched,10);

% DC offset correction epochs using custom window
left = offset(left,[-2500 -2000]);

% time-frequency plot from channel A82 in the helmet from 5 to 80 Hz
tf = tft(left,[5 50],'chan',{'A146'},'waven',[4 12],'demean','no','detrend','yes');
figure('name','Morlet Wavelet Analysis in Gamma Band','color','w');
meg_plotTFR(tf,'nipower');