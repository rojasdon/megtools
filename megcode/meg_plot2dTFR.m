function hnd = meg_plot2dTFR(tf,cloc,varargin)
% PURPOSE: function to plot 2d MEG topographies
% AUTHOR:  Don Rojas, Ph.D.
% INPUT:   Required:
%          tf       = a time-frequency structure - see tft.m, note that if
%                     tf is supplied, additional 'optional' parameter pairs must be
%                     given - see type, tfvar and freq below.
%          cloc     = nchan x 6 array of channel locations
%          Optional (in pairs):
%          'type'   'nepower' | 'mplf' | 'ntpower', etc. see tft.m
%          'locs'   1 = on, 0 = off
%          'labels' 1 = on, 0 = off
%          'cbar'   1 = colorbar, 0 = none
%          'freq'   number indicating frequency in Hz to plot in tf structure
%          'time'   time to plot in tf structure in ms
% OUTPUT:  handle to figure
% EXAMPLE: fig = meg_plot2d(tf, cloc, 'type','mplf','time',50,'freq',10)
%
% HISTORY: 2/7/11 - revised to allow topographic plots of tf structures

% FIXME
error('This function is not yet operational!');

% default options
type   = 'nepower';
locs   = 1;
labels = 1;
cbar   = 0;
time   = [tf.time(1) tf.time(end)];
freq   = [tf.freq(1) tf.time(end)];

% variable inputs should be given in arg pairs (e.g., 'xrange',[-100 250])
if nargin > 2
    [val arg] = parseparams(varargin);
    for i=1:2:length(arg)
        switch char(arg{i})
            case 'type'
                type = arg{i+1};
            case 'freq'
                freq(1) = arg{i+1}(1);
                freq(2) = arg{i+1}(2);
            case 'time'
                time(1) = arg{i+1}(1);
                time(2) = arg{i+1}(2);
            case 'labels'
                labels = arg{i+1};
            case 'cbar'
                cbar = arg{i+1};
            case 'locs'
                locs = arg{i+1};    
            otherwise
        end
    end
end

% find nearest time-frequency points to requested points
[junk,tstart]  = min(abs(tf.time - time(1)));
[junk,tstop]   = min(abs(tf.time - time(2)));
[junk,fstart]  = min(abs(tf.freq - freq(1)));
[junk,fstop]   = min(abs(tf.freq - freq(2)));

% FIXME: put checks in for length of requested windows
% get data
alldat     = eval(['tf.' type]);
data       = mean(mean(alldat(fstart:fstop,tstart:tstop)));

%do projection of 3D positions into 2D map
cloc       = cloc(:,1:3)*100;
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
        text(loc2d(2,i),loc2d(1,i),MEG.chn(i).label);
    end
end
if locs
    plot(loc2d(2,:),loc2d(1,:),'.k');
end
if cbar
    bar = colorbar();
    set(get(bar, 'Title'), 'String', 'T');
end
hold off;

end