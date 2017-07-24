% example of making a pretty figure using SPM8 mri surfaces

% prefix = 'mr0021';

spmDir=spm('dir');

% read some surface files
c  = gifti(fullfile(spmDir,'cortex_20484.surf.gii'));
s  = gifti(fullfile(spmDir,'scalp_2562.surf.gii'));
is = gifti(fullfile(spmDir,'iskull_2562.surf.gii'));

% make a figure and set renderer
fig = figure;
set(fig,'renderer','zbuffer','color','k');

% set up scalp and cortex patch objects
cortex = patch('vertices',c.vertices,'faces',...
         c.faces,'facecolor',[.9 .7 .7],'edgecolor','none',...
         'clipping','off');
     
hold on;

scalp = patch('vertices',s.vertices,'faces',...
       s.faces,'facecolor',[.93 .81 .81], 'edgecolor','none',...
        'clipping','off');
    
[x, y, z] = ellipsoid(-50,-25,3,7,4,5,50);
fvc     = surf2patch(x,y,z);
dip = patch(fvc,'facecolor',[1 0 0], 'edgecolor','none');

%dip = surfl(x, y, z);
%colormap hot;

%skull = patch('vertices',is.vertices,'faces',...
%        is.faces,'facecolor','none', 'edgecolor',[0 0 1],...
%        'clipping','off');
    
% set up lighting properties
material dull;

set(fig,'renderer','openGL');
lighting gouraud;
alpha(scalp,.2);

% set up axis properties and add lights
daspect([1 1 1]);
view(0,30); axis image off; grid off;
light('Position',[1 -1 0],'Style','infinite');
light('Position',[-1 1 0],'Style','infinite');
rotate3d on;