function h = meg_plot3dSPM(D,timeslice,varargin)
% PURPOSE: to create a 3d topographic map of a particular timepoint from
%          SPM8 data structure
% AUTHOR:  Don Rojas, Ph.D.
% INPUTS:  D - SPM struct
%          timeslice - requested time point to plot in ms
%          
% OUTPUTS: h = handle to graphics object
% NOTES:   1. I have not tested this, but in theory, with lots of deleted
%             channels in the array, particularly at the edges, the rendering 
%             will start to look pretty marginal.
%          2. Currently only works with SPM8 structs created via meg2spm.m
%             because default read in SPM8 has all ref channels and also
%             has randomly ordered channels

% create triangles from channel locations for meshing.
chn  = find(strcmp(D.chantype,'MEG'));
locs = zeros(length(chn),3);
for i=1:length(chn)
    if chn(i)
        locs(i,:)=D.sensors('MEG').pnt(i,:);
    end
end
sens = triangulate_meg(locs');

% find nearest sample to requested timepoint
[diff,samp]  = min(abs(D.time*1E3 - timeslice));
disp(sprintf('Plotting at nearest point: %.2f ms',timeslice+diff));
data = squeeze(D(chn,samp,1));

% use patch object for 3d scene
h = figure('color',[.4 .4 .4]);
set(h,'renderer','zbuffer');
sens =  patch('faces',sens,'vertices',locs,'Edgecolor','none',...
        'Facelighting','none','Facecolor','interp','FaceVertexCData',data,...
        'Marker','o','MarkerSize',2,'MarkerEdgeColor',[0 0 0]);
hold on;

view(3); axis image equal off; rotate3d on; lighting phong;
if isfield(D,'inv')
    ctx  = patch('faces',D.inv{1}.forward.mesh.face,'vertices',...
           D.inv{1}.forward.mesh.vert,'edgecolor','none',...
           'FaceColor',[.93 .81 .81],...
            'clipping','off');
      
       %ctx  = patch('faces',D.inv{1}.forward.mesh.face,'vertices',...
         %  D.inv{1}.forward.mesh.vert,'edgecolor','none',...
         %  'clipping','off');
    %model         = D.inv{1}.inverse;
    %J             = zeros(model.Nd,size(model.T,1));
    %[diff,samp]   = min(abs(model.pst*1E3 - timeslice));
    %J(model.Is,:) = model.J{1}*model.T';
    %tex = single(J(:,samp));
    %set(ctx,'FaceVertexCData',tex,'FaceColor','interp');
    alpha(sens,.7);
end
           

% set up lighting for scene to be slightly shiny
set(sens,'backfacelighting','lit','AmbientStrength',.2,...
    'SpecularColorReflectance',1,'SpecularExponent',200,...
    'SpecularStrength',0,'DiffuseStrength',.4);
set(h,'renderer','openGL');
lighting gouraud;
if isfield(D,'inv')
    set(ctx,'backfacelighting','unlit','AmbientStrength',.2,...
    'SpecularColorReflectance',1,'SpecularExponent',200,...
    'SpecularStrength',0,'DiffuseStrength',.4);
end
light('Position',[1 -1 0],'Style','infinite');
light('Position',[1 1 0],'Style','infinite');
light('Position',[-1 0 1],'Style','infinite');
light('Position',[0 0 1],'Style','infinite');



end