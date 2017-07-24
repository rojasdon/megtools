function events = create_events(locks,types)
% PURPOSE:   To create an event structure, part of which will be EEGLAB
%            compatible
% AUTHOR:    Don Rojas, Ph.D.
% INPUTS:    locks - nchan x nsamples array of trigger and response channels
%            from get4D.m
%            types - 1 x nchan cell array of channel types (e.g.,
%            {'TRIGGER' 'RESPONSE' 'EXT'}, from MEG.chn.type)
% OUTPUT:    events - structure with information about triggers and
%            response events for use in epoching - for convenience, 
%            the event structure format for EEGLAB is returned
% FIXME:     1) Assumption of trigger as positive may need revision
% NOTES:     1) Only supports onset positive triggering now. Could revise
%               to allow offset triggering if needed
% SEE ALSO:  CREATE_EPOCHS
% HISTORY:   07/13/10 - major revision to allow multi-channel trigger
%                       inputs to define events.
%            11/18/10 - fixed bug that affected event counts and sometimes
%                       resulted in doubling the number of events
%            06/01/11 - added sort to make sure that events are in order of
%                       original appearance in aux channels
%            06/23/11 - does scan to remove empty events now (fixes rare bug in
%                       epocher.m)
%            07/12/11 - fixed bug with bug-fix dated 6/23/11
%            08/21/11 - fixed bug that sometimes doubled events
%            09/19/11 - better fix for empty events
%            08/13/12 - scan for duplicates

% number of input channels to create events from
lsize  = size(locks);

% init variables
tmp_events = [];

% loop through events
for ii = 1:lsize(1)
    % find onsets by taking 1st temp derivative of appropriate channels
    tmp          = [0 diff(locks(ii,:))];
    tmp(tmp < 0) = 0; % assumes trigger onsets are positive
    tmp          = uint16(tmp);
    if strcmp(types{ii},'TRIGGER')
        bug      = find(bitand(tmp,2^13)); % to remove buggy 4d trig if present
        tmp(bug) = tmp(bug)-2^13;
    end
    onsets = find(tmp);
    % report some stats
    if isempty(onsets)
        fprintf('\nNo events in %s to use...skipped\n',types{ii});
    else
        codes  = unique(tmp(onsets));
        counts = zeros(1,length(codes));
        for jj=1:length(codes)
            counts(jj) = length(find(tmp == codes(jj)));
            fprintf('\nFound %d events coded %d in channel type: %s\n', ...
                counts(jj), codes(jj), types{ii});
        end
        % create EEGLAB events structure
        these_events(length(onsets)) = struct( ...
            'type', [], 'latency', [], 'urevent',[], ...
            'mode', []);
        % populate EEGLAB events structure
        for jj=1:length(onsets)
            these_events(jj).type       = num2str(tmp(onsets(jj)));
            these_events(jj).latency    = onsets(jj);
            these_events(jj).urevent    = ii+jj;
            these_events(jj).mode       = types{ii};
        end
        tmp_events = [tmp_events these_events];
    end
end

% sort the events by onset time
% FIXME: this may violate the EEGLAB urevent convention (might use order
% variable to fix this)
if ~isempty(tmp_events)
    [~, order]=sort([tmp_events.latency]);
    tmp_events=tmp_events(order);
    % delete empty events
    bad_events = find(cellfun('isempty',{tmp_events.type}));
    if ~isempty(bad_events)
        tmp_events(bad_events) = [];
    end
    [~,indices,~]          = unique([tmp_events.latency]);
    tmp_events             = tmp_events(indices);
end

events                     = tmp_events;

end