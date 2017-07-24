% to use BOTH transparency and opaqueness with Cdata in two separate objects, first
% render the opaque object in zbuffer, then the transparent one in openGL.

fig = figure;
set(fig,'renderer','zbuffer');

[x1,y1,z1]=sphere(40);
[x2,y2,z2]=sphere(40);
h1=surf(x1*.7,y1*.7,z1*.7);
hold on;
axis equal;

view(3); axis image off; grid off; lighting gouraud;
set(h1,'facecolor','r');
set(h1,'edgecolor','w');
drawnow;

set(fig,'renderer','openGL');
shading interp;
h2=surf(x2*.9,y2*.9,z2*.9);
set(h2,'facecolor',[.8 .6 .8])
set(h2,'edgecolor','none');
alpha(h2,.5);
alpha(h1,'opaque');

cameratoolbar('setmode','orbit');
rotate3d on;