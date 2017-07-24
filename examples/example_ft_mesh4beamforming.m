mrfile          = '1258.nii';
[pth base ext]  = fileparts(mrfile);
masknamesuff    = '_brainmask.nii';
outfile         = [base masknamesuff];

% read mri
mri = ft_read_mri(mrfile);

% create skull brain and scalp and output skull stripped brain
cfg.output      = {'brain' 'skull' 'scalp','tpm'};
cfg.spmversion  ='spm8';
cfg.name        = base;
cfg.write       = 'yes';
cfg.coordsys    = 'spm';
seg             = ft_volumesegment(cfg,mri);

% create an inner skull mask and mesh
ind             = find(seg.brain);
brain           = mri.anatomy;
brain(:)        = 0;
brain(ind)      = mri.anatomy(ind);
ft_write_volume(outfile,brain,'dataformat','nifti','transform',seg.transform)
spm_surf(outfile,2,80);

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