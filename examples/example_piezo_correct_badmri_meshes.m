% script corrects meshes produced by batch on mr scans that had to be
% corrected for a strange inhomogeneity artifact that affected some early
% Autism Speaks MRI scan data. These MRI scans have a _corr suffix appended
% to them.

basefile        = spm_select(1,'image','Select base mri scan');
[pth base ext]  = fileparts(basefile);
masknamesuff    = '_brainmask.nii';
outfile         = [base masknamesuff];

% select mri data (gm, wm and csf tpm)
f=spm_select(3,'any','Select gm, wm and csf images','','','^c');

% read mri data, threshold and write back to new brainmask
gm              = ft_read_mri(f(1,:));
wm              = ft_read_mri(f(2,:));
csf             = ft_read_mri(f(3,:));
new             = gm;
new.anatomy(:)  = 0;
gind            = find(gm.anatomy>.5);
wind            = find(wm.anatomy>.5);
cind            = find(csf.anatomy>.5);
new.anatomy(cind) = 80;
new.anatomy(gind) = 120;
new.anatomy(wind) = 160;

% fill holes then erosion/dilation
for i=1:size(new.anatomy,2)
	tmp(:,i,:)=imfill(squeeze(new.anatomy(:,i,:)),'holes');
end
se = ones(8,8,8);
new.anatomy = imopen(tmp,se);

ft_write_volume(outfile,new.anatomy,'dataformat',...
    'nifti','transform',new.transform);

clear tmp gm wm csf new;

% create an inner skull mask and mesh
spm_surf(outfile,2,79);

% view results for QA purposes
top   = [0 90];
bot   = [180 -90];
front = [-180 0];
back  = [0 0];
left  = [-90 0];
right = [90 0];
figure;
[pth nam ext]   = fileparts(outfile);
skull           = gifti([nam '.surf.gii']);
i               = patch('faces',skull.faces,'vertices',skull.vertices,'facecolor','none','edgecolor','none');
iskull = reducepatch(i,.025);
subplot(3,2,1); j = patch('faces',iskull.faces,'vertices',iskull.vertices,'facecolor','b','edgecolor','none');
lighting gouraud;
axis image off;
lt = camlight(-45,20); rt = camlight(100,20);
view(top);
subplot(3,2,2); j = patch('faces',iskull.faces,'vertices',iskull.vertices,'facecolor','b','edgecolor','none');
lighting gouraud;
axis image off;
lt = camlight(-45,20); rt = camlight(100,20);
view(bot);
subplot(3,2,3); j = patch('faces',iskull.faces,'vertices',iskull.vertices,'facecolor','b','edgecolor','none');
lighting gouraud;
axis image off;
lt = camlight(-45,20); rt = camlight(100,20);
view(left);
subplot(3,2,4); j = patch('faces',iskull.faces,'vertices',iskull.vertices,'facecolor','b','edgecolor','none');
lighting gouraud;
axis image off;
lt = camlight(-45,20); rt = camlight(100,20);
view(right);
subplot(3,2,5); j = patch('faces',iskull.faces,'vertices',iskull.vertices,'facecolor','b','edgecolor','none');
lighting gouraud;
axis image off;
lt = camlight(-45,20); rt = camlight(100,20);
view(front);
subplot(3,2,6); j = patch('faces',iskull.faces,'vertices',iskull.vertices,'facecolor','b','edgecolor','none');
lighting gouraud;
axis image off;
lt = camlight(-45,20); rt = camlight(100,20);
view(back);

iskull = export(gifti(iskull));

save([base '_iskull.mat'],'iskull');