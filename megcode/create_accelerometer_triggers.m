function MEG = create_accelerometer_triggers(file)
% function to process accelerometer signals and create triggers in original
% file, as well as outputting a new continuous file structure on the
% workspace

% defaults TODO: alter via arguments
threshold = 2; % SD
duration  = 3000; % ms
vals      = [10 20];

% get pdf
MEG = get4D(file);

% get channel indices
ext     = meg_channel_indices(MEG,'multi','EXT');
tri     = meg_channel_indices(MEG,'multi','TRIGGER');
tri     = [tri meg_channel_indices(MEG,'multi','RESPONSE')];

% create triggers from accelerometers
[accel fchn thresh] = process_auxiliary(MEG.data(ext(1:2),:),vals,MEG.sr,duration,threshold);
trig                = meg_channel_indices(MEG,'multi','TRIGGER'); % trigger channel index
MEG.data(trig,:)    = bitor(double(accel(1,:)),double(accel(2,:)));
events              = create_events(MEG.data(trig,:),{'TRIGGER'}); % create event structure
MEG.events = events;

% write back to 4D format
put4D('c,rfhp0.1Hz','c,rfhp0.1Hz,triggers',MEG);

end

