function hnd = meg_plot2d(MEG,point,varargin)
%PURPOSE:   plots 2D channel map of sensor data
%AUTHOR:    Don Rojas, Ph.D.  
%INPUT:     Required: MEG structure - see get4D.m
%           point = time point to map in ms
%           'labels' 'on|off', chan labels, 'locs', 'on|off', chan locations, 
%           'cbar' 'on|off', color bar
%           'mark' {1 x n} channel vector of channels to mark in red by
%            name of channel
%           'trial' integer indicating trial number to plot
%OUTPUT:    handle to figure
%EXAMPLES:  fig = meg_plot2d(avg,100) will produce a flatmap projection of
%           the topography of avg at 100 ms
%SEE ALSO:  MEG_PLOT3D, MEG_PLOTTFR, MEG_PLOT_MISC

%HISTORY:   04/19/10 - revised to account for changes to MEG
%                      structure - see get4D.m
%           03/27/11 - allows input of channels to mark on plot
%           03/28/11 - revised so optional input is in argument pairs
%           05/23/11 - revised to allow epoch input
%           06/15/11 - bugfix for reference channel problem
%           09/16/11 - adapted for new MEG struct

% defaults
locs   = 1;
labels = 1;
cbar   = 0;
mark   = 0;
epoch  = 0;
if ~isempty(varargin)
    optargin = size(varargin,2);
    if (mod(optargin,2) ~= 0)
        error('Optional arguments must come in option/value pairs');
    else
        for i=1:2:optargin
            switch varargin{i}
                case 'locs'
                    if strcmp(varargin{i+1},'on')
                        locs = 1;
                    else
                        locs = 0;
                    end
                case 'labels'
                    if strcmp(varargin{i+1},'on')
                        labels = 1;
                    else
                        labels = 0;
                    end
                case 'cbar'
                    if strcmp(varargin{i+1},'on')
                        cbar = 1;
                    else
                        cbar = 0;
                    end
                case 'mark'
                    mark   = 1;
                    marked = varargin{i+1};
                case 'trial'
                    epoch  = varargin{i+1};
                otherwise
                    error('Invalid option!');
            end
        end
    end
end

% find nearest sample to requested timepoint
tind = get_time_index(MEG,point);
fprintf('\nPlotting at nearest to requested point: %.2f ms\n', MEG.time(tind));

% get MEG data
megi        = meg_channel_indices(MEG,'multi','MEG');
if epoch > 0
    data    = squeeze(MEG.data(epoch,megi,tind));
else
    data    = MEG.data(megi,tind);
end

%do projection of 3D positions into 2D map
cloc       = MEG.cloc(megi,1:3)*100;
loc2d      = double(thetaphi(cloc')); %flatten
loc2d(2,:) = -loc2d(2,:); %reverse y direction

% grid data across 2d flat map projection
xlin  = linspace(min(loc2d(2,:)),max(loc2d(2,:)));
ylin  = linspace(min(loc2d(1,:)),max(loc2d(1,:)));
[x,y] = meshgrid(xlin,ylin);
Z     = griddata(loc2d(2,:),loc2d(1,:),double(data),x,y);

% plot result on new figure
contourf(x,y,Z,20);
hold on;   
if labels
    for i=1:length(cloc)
        text(loc2d(2,i),loc2d(1,i),MEG.chn(i).label,'FontSize',8);
    end
end
if locs
    plot(loc2d(2,:),loc2d(1,:),'.k');
end
if cbar
    bar = colorbar();
    set(get(bar, 'Title'), 'String', 'T');
end
if mark
    cinds = meg_channel_indices(MEG,'labels',marked);
    plot(loc2d(2,cinds),loc2d(1,cinds),'.m');
end
hold off;

end