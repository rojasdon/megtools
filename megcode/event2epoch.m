function epoch = event2epoch(events, times)
% PURPOSE:   To create an epoch structure from and event structure
% AUTHOR:    Don Rojas, Ph.D.
% INPUTS:    events - event structure from create_events.m
%            times - 1 x nsamples array of latencies of epoch, NOT from
%            continuous time series
% OUTPUT:    epoch - EEGLAB compatible epochs structure
% TODO:      1) support multiple events, per create_epochs.m
% SEE ALSO:  CREATE_EVENTS, CREATE_EPOCHS

% HISTORY:   07/16/10 - first version

% check input
if nargin ~= 2; error('Two arguments are required!'); end;
if ~isstruct(events); error('1st argument must be a structure!'); end

% find onset sample point from time array
[t t0] = min(abs(times));

% print some facts
nevents = length(events);
vals    = unique(str2num(char(events.type)));
fprintf('\nEpochs will be created from %d events of type(s):\n',nevents);
for i=1:length(vals)
    fprintf('%d\n',vals(i));
end

% create EEGLAB epochs structure - crude, no multi-event support currently
epoch = struct([]);
for i=1:nevents
    lat  = cell(1); lat{1} = t;
    pos  = cell(1); pos{1} = i;
    type = cell(1); type{1} = events(i).type;
    epoch(i).event = i;
    epoch(i).eventlatency = lat;
    epoch(i).eventposition = pos;
    epoch(i).eventtype = type;
    epoch(i).eventurevent = pos;
end
end