function MEG = meg_updateversion(MEG)
% function to update last MEG structure, v1 to current structure, v2

% check for presence of older fields
if isfield(MEG,'aux')
    aux = MEG.aux;
    MEG = rmfield(MEG,'aux');
else
    aux = [];
end

if isfield(MEG,'ref')
    ref = MEG.ref;
    MEG = rmfield(MEG,'ref');
else
    ref = [];
end

% update data to new format
MEG.data = [MEG.data;aux;ref];

% update mchan field if necessary
if ~isempty(MEG.mchan)
    if isa(MEG.mchan(1),'numeric')
        oldmchan = MEG.mchan;
        MEG = rmfield(MEG,'mchan');
        MEG.mchan = cell(1,length(oldmchan));
        for ii=1:length(oldmchan)
            MEG.mchan{ii} = ['A' num2str(oldmchan(ii))];
        end
    end
else
    MEG.mchan = {};
end

% scan events field for repeats and empties
% sort the events by onset time
if isfield(MEG,'events')
    tmp_events=MEG.events;
    if ~isempty(tmp_events)
        [~, order]=sort([tmp_events.latency]);
        tmp_events=tmp_events(order);
        % delete empty events
        bad_events = find(cellfun('isempty',{tmp_events.type}));
        if ~isempty(bad_events)
            tmp_events(bad_events) = [];
        end
    end
    [~,indices,~] = unique([tmp_events.latency]);
    MEG.events                      = tmp_events(indices);
end