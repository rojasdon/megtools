function hnd = meg_plot2dmovie(MEG)
% plots 2D channel map movie of sensor data
% MEG      = MEG struct from get4D.m

%do projection of 3D positions into 2D map
cloc       = MEG.cloc(:,1:3)*100;
loc2d      = double(thetaphi(cloc')); %flatten
loc2d(2,:) = -loc2d(2,:); %reverse y direction

% grid data across 2d flat map projection
xlin  = linspace(min(loc2d(2,:)),max(loc2d(2,:)));
ylin  = linspace(min(loc2d(1,:)),max(loc2d(1,:)));
[x,y] = meshgrid(xlin,ylin);

% find min and max
ymin = min(MEG.data(:));
ymax = max(MEG.data(:));

% plot result on new figure
figure; caxis([ymin ymax]);

ind = find(MEG.time > 0);

for i=1:length(MEG.time(MEG.time > 0))
    data     = MEG.data(:,ind(i));
    Z     = griddata(loc2d(2,:),loc2d(1,:),double(data),x,y);
    contourf(x,y,Z,20);
end
end