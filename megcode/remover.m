function MEG = remover(MEG,tindices)
% function to remove time periods from MEG structure - beta function

% FIXME: needs lots of revision and testing on cnt, epoch and average types

% need to correct events and epochs fields
    MEG.time(tindices)=[];
    MEG.data(:,tindices)=[];
    MEG.time = (1:length(MEG.time))*(1/MEG.sr);
    MEG.epdur = MEG.time(end);
    tmp = intersect([MEG.events.latency],tindices);
    for i=1:length(tmp)
        badev = find([MEG.events.latency] == tmp(i));
        MEG.events(badev) = [];
    end
end

