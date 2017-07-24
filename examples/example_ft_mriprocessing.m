% examples of using FieldTrip to call SPM for MRI processing
% assumes that spm8 is used not spm2. You have somewhat more flexibility
% doing this directly within SPM8

mrfile = 'E0071_T1FFE3dGd.nii';
[pth base ext] = fileparts(mrfile);

% read mri
vol = ft_read_mri(mrfile);

% warp an mri
cfg             = [];
cfg.spmversion  = 'spm8';
cfg.coordinates = 'spm';
cfg.name        = ['w' base];
cfg.nonlinear   = 'yes';
cfg.write       = 'yes';
norm_vol=ft_volumenormalise(cfg,vol);

% segment an mri into gray white and csf
cfg             = [];
cfg.spmversion  = 'spm8';
cfg.name        = base;
cfg.write       = 'yes';
seg_vol = ft_volumesegment(cfg, vol);

% use ft_volumesegment to create a mask of scalp anatomy - could be used
% with Eugene Kronberg's MRO to replace a missing hs_file
cfg             = [];
cfg.spmversion  = 'spm8';
cfg.smooth      = 5;
cfg.threshold   = 0.1;
cfg.name        = [mrfile '_scalp_mask'];
cfg.segment     = 'no';
cfg.write       = 'yes';
scalp = ft_volumesegment(cfg, vol);
ft_write_volume([mrfile '_scalp.nii'],...
    scalp.scalpmask,'dataformat','nifti','transform',scalp.transform)

% create skull brain and scalp and output skull stripped brain
cfg.output      = {'brain' 'skull' 'scalp'};
cfg.spmversion  ='spm8';
cfg.name        = '1258';
cfg.write       = 'yes';
cfg.coordsys    = 'spm';
seg             = ft_volumesegment(cfg,mri);

% create skull strip and generate surface
ind             = find(seg.brain);
brain           = mri.anatomy;
brain(:)        = 0;
brain(ind)      = mri.anatomy(ind);
ft_write_volume('1258_brainmask.nii',brain,'dataformat','nifti','transform',seg.transform)
spm_surf('1258_brainmask.nii',2,80);
figure;
skull           = gifti('1258_brainmask.surf.gii');
i               = patch('faces',skull.faces,'vertices',skull.vertices,'facecolor','none','edgecolor','b');
iskull          = reducepatch(i,.025);

lighting gouraud;
axis image off;
lt = camlight(-45,20); rt = camlight(100,20);
rotate3d on;

