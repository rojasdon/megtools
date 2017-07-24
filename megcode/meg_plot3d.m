function [h sens] = meg_plot3d(MEG,timeslice)
% PURPOSE:  to create a 3d topographic map of a particular timepoint
% AUTHOR:   Don Rojas, Ph.D.
% INPUTS:   MEG struct - see get4D.m
%           timeslice - requested time point to plot in ms
%          
% OUTPUTS:  h = handle to graphics object
%           sens = mesh for sensors
% NOTES:    1. I have not tested this, but in theory, with lots of deleted
%             channels in the array, particularly at the edges, the rendering 
%             will start to look pretty marginal.
% TO DO:    1. add in plot option for spm8 template brain in sensors, with
%              coregistration done on the fly
% HISTORY:  5/25/11 - revised for consistent indexing of timeslice
%           9/16/11 - revised for consistent MEG channel indexing

% SEE ALSO: MEG_PLOT2D, MEG_PLOTTFR, MEG_PLOT_MISC

% find nearest sample to requested timepoint
tind     = get_time_index(MEG,timeslice);
megi     = meg_channel_indices(MEG,'multi','MEG');
data     = MEG.data(megi,tind);
cloc     = MEG.cloc(megi,1:3);
fprintf('\nPlotting at nearest to requested point: %.2f ms\n', MEG.time(tind));

% create triangles from channel locations for meshing.
sens = triangulate_meg(cloc');

% use patch object for 3d scene
h =  patch('faces',sens,'vertices',cloc,'Edgecolor','none',...
    'Facelighting','none','Facecolor','interp','FaceVertexCData',data,...
    'Marker','o','MarkerSize',2,'MarkerEdgeColor',[0 0 0]);

view(3); axis image equal off; rotate3d on;

% set up lighting for scene to be slightly shiny
lighting phong;
set(h,'backfacelighting','unlit','AmbientStrength',.2,...
    'SpecularColorReflectance',1,'SpecularExponent',200,...
    'SpecularStrength',0,'DiffuseStrength',.4);
%light('Position',[1 -1 0],'Style','infinite');
%light('Position',[1 1 0],'Style','infinite');
%light('Position',[-1 0 1],'Style','infinite');
%light('Position',[0 0 1],'Style','infinite');


end