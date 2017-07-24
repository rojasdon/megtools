function MEG = meg_chan_subset(MEG,nums)
%PURPOSE:   function to extract a subset of channels from dataset given
%           input of the channel numbers to extract
%AUTHOR:    Don Rojas, Ph.D.  
%INPUT:     Required: MEG structure - see get4D.m
%           nums = 1 x n channel numbers - no 'A' prefix
%OUTPUT:    MEG sub structure
%EXAMPLES:  
%SEE ALSO:  

%HISTORY:   03/27/11 - first working version

% find indices of channels given numbers
cinds = meg_channel_indices(MEG,nums);

% extract data depending on input
switch MEG.type
    case 'epochs'
        data = MEG.data(:,cinds,:);
    case {'avg' 'cnt'}
        data = MEG.data(cinds,:);
end

% correct fields and output
MEG.data  = data; clear data;
MEG.cloc  = MEG.cloc(cinds,:);
MEG.cori  = MEG.cori(cinds,:);
channums  = [MEG.chn.num];
MEG.chn   = MEG.chn(cinds);
MEG.mchan = [MEG.mchan setdiff(channums,[MEG.chn.num])];

end