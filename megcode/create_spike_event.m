function MEG = create_spike_event(MEG,latency)
% PURPOSE:   To create an event structure for an epileptic spike
% AUTHOR:    Don Rojas, Ph.D.
% INPUTS:    latency    - spike peak latency
% OUTPUT:    MEG        - structure with events field returned. If it had no prior
%                         events, there will now be an events field.
% SEE ALSO:  CREATE_EPOCHS, CREATE_EVENTS
% HISTORY:   05/08/12 - first version from create_events

% translate latency from milliseconds to sample index
latency = get_time_index(MEG,latency);

% create empty structure if needed
if isempty(MEG.events) || ~isfield(MEG,'events')
    tmp_events = struct( ...
            'type', '99', 'latency', latency, 'urevent',1, ...
            'mode', 'SPIKE');
else
    tmp_events                  = MEG.events;
    eventn                      = length(tmp_events)+1;
    tmp_events(eventn).type     = '99';
    tmp_events(eventn).latency  = latency;
    tmp_events(eventn).urevent 	= eventn;
    tmp_events(eventn).mode     = 'SPIKE';
end

% sort the events by onset time
[~, order] = sort([tmp_events.latency]);
tmp_events = tmp_events(order);

% delete empty events
bad_events = find(cellfun('isempty',{tmp_events.type}));
if ~isempty(bad_events)
    tmp_events(bad_events) = [];
end
MEG.events = tmp_events;