% view inner skull
spmdir=spm('dir');
subdir='canonical';
i=gifti(fullfile(spmdir,subdir,'cortex_20484.surf.gii'));
s=gifti(fullfile(spmdir,subdir,'scalp_2562.surf.gii'));
is=patch('vertices',i.vertices,'faces',i.faces);
sc=patch('vertices',s.vertices,'faces',s.faces);
set(is,'facecolor',[.5 .5 .75]);
set(is,'edgecolor','none');
set(sc,'facecolor','none');
set(sc,'edgecolor',[0 .8 .3]);
axis image off;
lighting gouraud;
set(is,'facelighting','gouraud');
cameratoolbar('setmode','orbit');
set(is,'backfacelighting','lit');
lt=camlight(-45,20); rt=camlight(100,20);
view(-90,0);
alpha(sc,.4);