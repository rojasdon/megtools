function hnd = meg_plot2d_misc(data,cloc,varargin)
% plots 2D channel map of sensor data
% MEG      = MEG struct from get4D.m
% point    = time point to map in ms
% opts     = .locs = 1 = on, 0 = off
%            .labels 1 = on, 0 = off
%            .cbar 1 = colorbar, 0 = none

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
if nargin > 2
    opts = varargin{1};    
    if opts.labels
        for i=1:length(cloc)
            text(loc2d(2,i),loc2d(1,i),MEG.chn(i).label);
        end
    end
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