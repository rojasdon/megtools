function MEG = meg_regional_split(MEG,chans)
%PURPOSE:   function to split data along user-defined regions
%AUTHOR:    Don Rojas, Ph.D.  
%INPUT:     Required: MEG structure - see get4D.m
%           chans - nchannel x 1 cell array of channel names
%OUTPUT:    MEG - new structure with channels selecte4d
%EXAMPLES:  ltemp = meg_regional_split(avg,mygroup);
%           example channel definition: 
%           mygroup = {'A1' 'A2' 'A40' 'A60'};
%SEE ALSO:  MEG_MIDLINE_SPLIT

%HISTORY:   07/25/12 - first working version

% find indices based on channel names
nchan = size(chans,1);
cind  = [];
for ii = 1:nchan
    channel = chans{ii};
    cind    = [cind meg_channel_indices(MEG,'labels',{channel})];        
end
origchans   = MEG.chn;  
cind        = sort(cind);
tind        = [meg_channel_indices(MEG,'labels',{'TRIGGER'}) ... 
               meg_channel_indices(MEG,'labels',{'RESPONSE'})];

% extract data depending on input
switch MEG.type
    case 'epochs'
        data        = MEG.data(:,cind,:);
		trigs       = MEG.data(:,tind,:);
        MEG.data    = [data trigs];
    case {'avg' 'cnt'}
        data        = MEG.data(cind,:);
		trigs       = MEG.data(tind,:);
        MEG.data    = [data; trigs];
end
clear data;

% correct fields and output
MEG.cloc  = MEG.cloc(cind,:);
MEG.cori  = MEG.cori(cind,:);
channums  = [MEG.chn(cind).num];
MEG.chn   = MEG.chn([cind tind]);
missing   = setdiff([origchans.num],channums);
newmchans = {origchans(missing).label};
MEG.mchan = [MEG.mchan newmchans];

end