% get MEG file with inverse solution
[file path]=uigetfile('*.mat');
load(fullfile(path,file));

model         = D.other.inv{1}.inverse;
J             = zeros(model.Nd,size(model.T,1));
J(model.Is,:) =model.J{1}*model.T';
tex = single(J(:,3));

%tex = repmat(tmp,1,length(tmp));

% get scalp and cortex to display
fig = figure;
set(fig,'renderer','zbuffer','color','k');
c  = gifti(fullfile(spm('Dir'),'canonical','cortex_20484.surf.gii'));

cortex = patch('vertices',c.vertices,'faces',...
         c.faces,'facecolor','interp','edgecolor','none',...
         'clipping','off');
     
% NOTE might be able to use 2 cortex models, 1 tranparent, 1 opaque, with
% alpha mapping set to tex on transparent so that non-zero vals show opaque
% and zero values show through to the opaque cortex. Otherwise, have to
% figure out how to use 1 cmap to get everything looking good.

colormap(jet);
set(cortex,'facevertexcdata',tex);
set(cortex,'backfacelighting','lit');
lighting phong;
set(cortex,'SpecularColorReflectance',0,'SpecularExponent',50);
set(cortex,'specularstrength',.8,'diffusestrength',.6);
hold on;
daspect([1 1 1]);
view(0,30); axis image off; grid off;
lt=camlight(-45,20); rt=camlight(100,20); 
%cameratoolbar('setmode','orbit');
rotate3d on;

set(fig,'renderer','openGL');
lighting gouraud;
s  = gifti(fullfile(spm('Dir'),'canonical','scalp_2562.surf.gii'));
scalp = patch('vertices',s.vertices,'faces',...
         s.faces,'facecolor',[.93 .81 .81], 'edgecolor','none','clipping','off');
set(scalp,'SpecularColorReflectance',.2,'SpecularExponent',25);
set(scalp,'specularstrength',.5,'diffusestrength',.5);
set(scalp,'backfacelighting','lit');

alpha(scalp,1); j = 1;

hg = hggroup;
set(cortex,'Parent',hg);
set(scalp,'Parent',hg);

for i=1:180
    rotate(cortex,[0 0 1],2);
    rotate(scalp,[0 0 1],2);
    alpha(scalp, j);
    j=j-(1/180);
    pause(.05);
    x=getframe(fig);
    fname=['ssr_' num2str(i) '.bmp'];
    imwrite(x.cdata,fname,'bmp');
end

for i=1:180
    rotate(cortex,[0 0 1],2);
    rotate(scalp,[0 0 1],2);
    alpha(scalp, j);
    j=j+(1/180);
    pause(.05);
    x=getframe(fig);
    fname=['ssr_' num2str(180+i) '.bmp'];
    imwrite(x.cdata,fname,'bmp');
end
