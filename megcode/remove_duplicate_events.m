function MEG = remove_duplicate_events(MEG)
% function to find and remove duplicate events - fixes issue with pre-
% August 2011 event field

[~,ind] = unique([MEG.events.latency]);
MEG.events(ind) = [];

end