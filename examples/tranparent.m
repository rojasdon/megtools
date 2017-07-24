fig = figure;
set(fig,'renderer','openGL');

c  = gifti(fullfile(spm('Dir'),'canonical','cortex_20484.surf.gii'));
s  = gifti(fullfile(spm('Dir'),'canonical','scalp_2562.surf.gii'));
cortex = patch('vertices',c.vertices,'faces',...
         c.faces,'facecolor',[.8 .5 .5], 'edgecolor','none');
scalp = patch('vertices',s.vertices,'faces',...
         s.faces,'facecolor',[.9 .9 .9], 'edgecolor','none');
hold on;
daspect([1 1 1]);
view(3); axis image off; grid off;
camlight; lighting gouraud; camproj perspective;
alpha(scalp,.3);
cameratoolbar('setmode','orbit');
rotate3d on;