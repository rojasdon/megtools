% defaults to change
sampletoplot = 3; % this is the sample relative to the onset of your source analysis window, not your epoch!
spmdir = [spm('dir') filesep 'canonical'];
brain  = 'cortex_8196.surf.gii'; % choose the one (5124, 8196 or 20484) that matches your choice in analysis
head   = 'scalp_2562.surf.gii';

% get MEG file with inverse solution
D=spm_eeg_load;
model         = D.inv{1}.inverse;
J             = zeros(model.Nd,size(model.T,1));
J(model.Is,:) = model.J{1}*model.T';
tex           = single(J(:,sampletoplot));

% read in surfaces
cortex = gifti([spmdir filesep brain]);
scalp  = gifti([spmdir filesep head]);

% display
fig     = figure;
cb      = patch('faces',cortex.faces,'vertices',cortex.vertices,...
                'edgecolor','none','facecolor',[.5 .5 .5]);
cf      = patch('faces',cortex.faces,'vertices',cortex.vertices,...
                'edgecolor','none','facecolor','interp',...
                'FaceVertexCData',tex);
%cs      = patch('faces',cortex.faces,'vertices',cortex.vertices,...
%                'edgecolor','none','facecolor',[.8 .4 .4]);
set(cf,'facealpha','interp','facevertexalphadata',tex);
set(cb,'backfacelighting','lit');
%alpha(cs,.5);
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