% get MEG file with inverse solution
sampletoplot = 3;
D=spm_eeg_load;
model         = D.inv{1}.inverse;
J             = zeros(model.Nd,size(model.T,1));
J(model.Is,:) = model.J{1}*model.T';
tex = single(J(:,sampletoplot));

% get scalp and cortex to display
fig = figure;
cortex  = D.inv{1}.forward.mesh;
cb      = patch('faces',cortex.face,'vertices',cortex.vert,...
                'edgecolor','none','facecolor',[.5 .5 .5]);
cf      = patch('faces',cortex.face,'vertices',cortex.vert,...
                'edgecolor','none','facecolor','interp',...
                'FaceVertexCData',tex);
set(cf,'facealpha','interp','facevertexalphadata',tex);
set(cb,'backfacelighting','lit');
axis vis3d image off;
lighting gouraud;
camlight('left');
camlight('right');
camlight(180,0);

% set threshold for activation - this is arbitrary since it is source
% strength data - just choose something that highlights the sources you are
% interested in
threshold = 0;
alim([threshold max(tex)]);
caxis([threshold max(tex)]);

% uncomment to rotate
%for i=1:180
%    rotate(cortex,[0 0 1],2);
%    pause(.05);
%    x=getframe(fig);
%    fname=['ssr_' num2str(i) '.bmp'];
%    imwrite(x.cdata,fname,'bmp');
%end