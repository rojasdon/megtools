%script to view mask for Tony's paper

%c  = gifti(fullfile(spm('Dir'),'canonical','cortex_20484.surf.gii'));
c  = gifti('ch2_best.surf.gii');
lp = gifti('lpre.surf.gii');
rp = gifti('rpre.surf.gii');
lpo = gifti('lpost.surf.gii');
rpo = gifti('rpost.surf.gii');
ls = gifti('lsma.surf.gii');
rs = gifti('rsma.surf.gii');
cb = gifti('cereb.surf.gii');
fig = figure;
set(fig,'renderer','openGL'); %use zbuffer for phong
cortex = patch('vertices',c.vertices,'faces',...
         c.faces,'facecolor',[.7 .5 .5], 'edgecolor','none');
hold on;
lpre = patch('vertices',lp.vertices,'faces',...
       lp.faces,'facecolor','y', 'edgecolor','none',...
       'FaceLighting','gouraud');
rpre = patch('vertices',rp.vertices,'faces',...
       rp.faces,'facecolor','g', 'edgecolor','none',...
       'FaceLighting','gouraud'); 
lpost = patch('vertices',lpo.vertices,'faces',...
       lpo.faces,'facecolor','m', 'edgecolor','none',...
       'FaceLighting','gouraud');
rpost = patch('vertices',rpo.vertices,'faces',...
       rpo.faces,'facecolor','c', 'edgecolor','none',...
       'FaceLighting','gouraud');
lsma = patch('vertices',ls.vertices,'faces',...
       ls.faces,'facecolor','b', 'edgecolor','none',...
       'FaceLighting','gouraud');
rsma = patch('vertices',rs.vertices,'faces',...
       rs.faces,'facecolor','r', 'edgecolor','none',...
       'FaceLighting','gouraud');
cereb = patch('vertices',cb.vertices,'faces',...
       cb.faces,'facecolor','c', 'edgecolor','none',...
       'FaceLighting','gouraud');
axis image off;
lighting gouraud; %also phong, which is prettier
%set(hnd,'SpecularColorReflectance',0,'SpecularExponent',50);
daspect([1 1 1]);
camva('auto');
colormap(jet(512));
cameratoolbar('setmode','orbit');
set(cortex,'backfacelighting','lit');
lt=camlight(-45,20); rt=camlight(100,20); 
%lightangle(90,45);
view(-90,0);
drawnow;
alpha(cortex,0.5);
rotate3d on;