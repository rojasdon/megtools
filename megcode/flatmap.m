function hnd = flatmap(data,cloc,varargin)
% plots 2D channel map of sensor data
% data     = 1 x nchan array of data to plot
% cloc     = nchan x 3 coil location array
% point    = time point to map in ms
% opts     = .locs 1 = on, 0 = off
%            .cbar 1 = colorbar, 0 = none

% check array sizes
if length(data) ~= length(cloc)
    error('Number of channels and data points must be equal!');
end

%do projection of 3D positions into 2D map
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
if nargin > 2
    opts = varargin{1};    
    if opts.locs
        plot(loc2d(2,:),loc2d(1,:),'.k');
    end
    if opts.cbar
        bar = colorbar();
        set(get(bar, 'Title'), 'String', 'T');
    end
end
hold off;

end