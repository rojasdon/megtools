% example of motor processing from accelerometers

% read 4D file
cnt                 = get4D('c,rfhp0.1Hz');

% get indices of external channels
ext                 = meg_channel_indices(cnt,'multi','EXT');

% create triggers from accelerometers
vals                = [10 20]; % trigger codes, one for each accelerometer channel
dur                 = 3000;    % duration re-triggering is prevented
threshold           = 2.5;     % in sd units for trigger definition
[accel,fchn,thresh] = process_auxiliary(cnt.data(ext(1:2),:),vals,cnt.sr,3000,threshold);
newtrigs            = bitor(double(accel(1,:)),double(accel(2,:))); % combine into a single trigger channel
trig                = meg_channel_indices(cnt,'multi','TRIGGER'); % trigger channel index
cnt.data(trig,:)    = cnt.data(trig,:) + newtrigs; % adds values to existing triggers - if already empty, can just replace
cnt.events          = create_events(cnt.data(trig,:),{'TRIGGER'});

% if you want to put it back into 4D pdf file
% put4D('c,rfhp0.1Hz','c,rfhp0.1Hz,modified',cnt); 