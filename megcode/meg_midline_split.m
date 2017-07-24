function MEG = meg_midline_split(MEG,hem)
%PURPOSE:   function to split data along midline and return half space
%           sensor data
%AUTHOR:    Don Rojas, Ph.D.  
%INPUT:     Required: MEG structure - see get4D.m
%           hem = side to return
%OUTPUT:    left or right sided MEG structure
%EXAMPLES:  lavg = meg_midline_split(avg,'left') returns a dataset with
%           only left sided channels
%SEE ALSO:  

%HISTORY:   03/25/11 - first working version
%           11/28/11 - minor bugfix
%           04/11/12 - fixes related to v2 of get4D.m

% get meg channel indices
origchans = MEG.chn;
cind = meg_channel_indices(MEG,'multi','MEG');
tind = [meg_channel_indices(MEG,'labels',{'TRIGGER'}) ...
        meg_channel_indices(MEG,'labels',{'RESPONSE'})];

% find l/r based on y loc of sensors
switch hem
    case 'left'
        cind = find(MEG.cloc(cind,2) > 0);
    case 'right'
        cind = find(MEG.cloc(cind,2) < 0);
end

% extract data depending on input
switch MEG.type
    case 'epochs'
        data = [MEG.data(:,cind,:) MEG.data(:,tind,:)];
    case {'avg' 'cnt'}
        data = [MEG.data(cind,:); MEG.data(tind,:)];
end

% correct fields and output
MEG.data  = data; clear data;
MEG.cloc  = MEG.cloc(cind,:);
MEG.cori  = MEG.cori(cind,:);
channums  = [MEG.chn(cind).num];
MEG.chn   = [MEG.chn(cind) MEG.chn(tind)];
missing   = setdiff([origchans.num],channums);
newmchans = {origchans(missing).label};
MEG.mchan = [MEG.mchan newmchans];

end