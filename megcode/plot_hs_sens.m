function plot_hs_sens(MEG,varargin)
% PURPOSE: to display a headshape with sensor locations from MEG structure
% AUTHOR:  Don Rojas, Ph.D.
% INPUT:   MEG struct - see get4D.m
% OUTPUT:  none
% HISTORY: 09/26/11 - revised for consistency with current MEG struct

% define fiducials, headshape and coil locations
cind        = meg_channel_indices(MEG,'multi','MEG');
fids        = MEG.fiducials.fid.pnt;
locs        = MEG.cloc(cind,1:3); % or 4:6 for upper coil
head        = MEG.fiducials.pnt;
lpa         = fids(1,:);
rpa         = fids(2,:);
nas         = fids(3,:);

if nargin > 1
    if length(varargin) ~= 2
        error('Optional arguments must come in key/value pairs');
    else
        orientation = varargin{2};
    end
else
    orientation = 'default';
end

%plot results
plot3(locs(:,1),locs(:,2),locs(:,3), 'LineStyle','none',...
    'Marker','.','MarkerSize',12,'Color','Cyan'); xlabel('x (mm)'); 
    ylabel('y (mm)'); zlabel('z (mm)'); hold on;
plot3(locs(247,1),locs(247,2),locs(247,3), 'LineStyle','none',...
    'Marker','.','MarkerSize',16,'Color','black');
plot3(head(:,1),head(:,2),head(:,3), 'LineStyle','none',...
    'Marker','.','Color','Red');
plot3(lpa(1),lpa(2),lpa(3), 'LineStyle','none',...
    'Marker','o','LineWidth',6,'Color','Green');
plot3(rpa(1),rpa(2),rpa(3), 'LineStyle','none',...
    'Marker','o','LineWidth',6,'Color','Green');
plot3(nas(1),nas(2),nas(3), 'LineStyle','none',...
    'Marker','o','LineWidth',6,'Color','Green');
hold off;
axis image equal off; rotate3d on;

switch orientation
    case 'default'
        view(3);
    case 'top'
        view(0,90);
    case 'bottom'
        view(180,90);
    case 'front'
        view(90,0);
    case 'left'
        view(180,0);
    case 'right'
        view(0,0);
    case 'back'
        view(-90,0);
end

return;