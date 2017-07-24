function [chnmid chni] = meg_autochansel(MEG,win)
% AUTHOR:  Don Rojas, Ph.D.
% PURPOSE: to find maximum and minimum channel and return selection from midpoint
%          between them - will work best if input channels are restricted to those
%          that are likely to include max/min for a single dipole
% INPUTS:  MEG struct
%          win - time window to search for min/max
% OUTPUTS: chnmid - midpoint channel
%          chni   - channel indices of selection
% HISTORY: 10/03/11 - revised for new MEG struct
%          11/28/11 - minor bugfix

% SEE ALSO: MEG_PLOT2D

% check input
if nargin < 2
    error('This function requires two inputs!');
end
if length(win) ~= 2
    error('The time window must be a range of form [min max]');
end
if ~strcmp(MEG.type,'avg')
    error('Input type must be average!');
end

% compute the mean of time range input if a range is given
start       = get_time_index(MEG,win(1));
if length(win) == 2
    stop        = get_time_index(MEG,win(2));
else
    stop        = start;
end
cind = meg_channel_indices(MEG,'multi','MEG');
mt   = mean(MEG.data(cind,start:stop)*1e15,2);

% find max and min channel
[~, cmax] = max(mt);
[~, cmin] = min(mt);

% flatten channel locs to 2d
loc2d = double(thetaphi(MEG.cloc(cind,1:3)'));
loc2d = loc2d(1:2,:);

% find midpoint between channels and nearest channel to that point
min2d  = loc2d(:,cmin);
max2d  = loc2d(:,cmax);
mid    = mean([min2d max2d],2);
tloc2d = loc2d';
gd     = sqrt((tloc2d(:,1) - mid(1)).^2 + (tloc2d(:,2) - mid(2)).^2);
[~, chnmid] = min(gd);

% get 2d neighbors for selected channel
d           = .75; % normed distance to define neighbors
dist        = sqrt((loc2d(1,:)-loc2d(1,chnmid)).^2+(loc2d(2,:)-loc2d(2,chnmid)).^2);
chni        = find(dist < d);

% return channel names
chni        = {MEG.chn(chni).label};
chnmid      = {MEG.chn(chnmid).label};

end