function MEG = create_generic_event(MEG,latency,code,label)
% PURPOSE:   To create an event structure for any user specified event
% AUTHOR:    Don Rojas, Ph.D.
% INPUTS:    latency    - spike peak latency
% OUTPUT:    MEG        - structure with events field returned. If it had no prior
%                         events, there will now be an events field.
% SEE ALSO:  CREATE_EPOCHS, CREATE_EVENTS
% HISTORY:   05/08/12 - first version from create_events
%            02/13/12 - added check for duplicate events

% translate latency from milliseconds to sample index
latency = get_time_index(MEG,latency);

% create empty structure if needed
if isempty(MEG.events) || ~isfield(MEG,'events')
    tmp_events = struct( ...
            'type', num2str(code), 'latency', latency, 'urevent',1, ...
            'mode', label);
else
    tmp_events                  = MEG.events;
    eventn                      = length(tmp_events)+1;
    tmp_events(eventn).type     = num2str(code);
    tmp_events(eventn).latency  = latency;
    tmp_events(eventn).urevent 	= eventn;
    tmp_events(eventn).mode     = label;
end

% sort the events by onset time
[~, order] = sort([tmp_events.latency]);
tmp_events = tmp_events(order);

% delete empty events and duplicate events
bad_events = find(cellfun('isempty',{tmp_events.type}));
if ~isempty(bad_events)
    tmp_events(bad_events) = [];
end
[~,indices,~] = unique([tmp_events.latency]);
MEG.events    = tmp_events(indices);