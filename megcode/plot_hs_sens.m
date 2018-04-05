function plot_hs_sens(MEG,varargin)
% PURPOSE: to display a headshape with sensor locations from MEG structure
% AUTHOR:  Don Rojas, Ph.D.
% REQUIRED INPUT: MEG struct - see get4D.m
% OPTIONAL INPUT: must be in option/arg pairs
%                 'labels','all' or 'labels',{'NAME','NAME'}; % cell array
%                  for specific names
%                 'orient','top'|'left'|'right'|'bottom'|'front'|'back'
%                  initial view of figure
%           
% OUTPUT:  none
% HISTORY: 09/26/11 - revised for consistency with current MEG struct
%          04/05/18 - added labeling options

% define fiducials, headshape and coil locations
cind        = meg_channel_indices(MEG,'multi','MEG');
fids        = MEG.fiducials.fid.pnt;
locs        = double(MEG.cloc(cind,1:3)); % or 4:6 for upper coil
head        = MEG.fiducials.pnt;
lpa         = fids(1,:);
rpa         = fids(2,:);
nas         = fids(3,:);
labels_on   = 0;

% process options
if nargin > 1
    optargin = size(varargin,2);
    if (mod(optargin,2) ~= 0)
        error('Optional arguments must come in key/value pairs');
    else
        for ii=1:2:optargin
            switch varargin{ii}
                case 'labels'
                    labels_on = 1;
                    if isa(varargin{ii+1},'cell')
                        to_plot = varargin{ii+1};
                    else
                        to_plot = 'all';
                    end
                case 'orient'
                    orientation = varargin{ii+1};
                otherwise
                    error('Invalid option!');                   
            end 
        end
    end
else
    orientation = 'default';
end

%plot results
figure('color','w');
plot3(locs(:,1),locs(:,2),locs(:,3), 'LineStyle','none',...
    'Marker','.','MarkerSize',18,'Color','Blue'); xlabel('x (mm)'); 
    ylabel('y (mm)'); zlabel('z (mm)'); hold on;
plot3(head(:,1),head(:,2),head(:,3), 'LineStyle','none',...
    'Marker','.','MarkerSize',12,'Color','Red');
plot3(lpa(1),lpa(2),lpa(3), 'LineStyle','none',...
    'Marker','o','LineWidth',6,'Color','Green');
plot3(rpa(1),rpa(2),rpa(3), 'LineStyle','none',...
    'Marker','o','LineWidth',6,'Color','Green');
plot3(nas(1),nas(2),nas(3), 'LineStyle','none',...
    'Marker','o','LineWidth',6,'Color','Green');
hold off;
axis image equal off; rotate3d on;

if labels_on
    if isa(to_plot,'cell')
        ind = meg_channel_indices(MEG,'labels',to_plot);
        labels = {MEG.chn(ind).label};
    else
        ind = cind;
        labels = {MEG.chn(ind).label};
    end
    fidnames = MEG.fiducials.fid.label;
    text(fids(:,1)+3,fids(:,2)+3,fids(:,3)+3,fidnames);
    text(locs(ind,1)+3,locs(ind,2)+3,locs(ind,3)+3,labels);
end
    

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