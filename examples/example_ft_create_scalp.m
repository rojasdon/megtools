% create a scalp surface from mri scan using Fieldtrip. This can be useful
% for replacing a missing hs_file from a meg scan in conjunction with
% Eugene Kronberg's MRO program, or for co-registration using point
% matching from scalp digitization in MEG if you have an hs_file

mrfile = '0956.nii';
[pth base ext] = fileparts(mrfile);

% read mri and create scalp
vol             = ft_read_mri(mrfile);
cfg             = [];
cfg.spmversion  = 'spm8';
cfg.smooth      = 5;
cfg.threshold   = 0.1;
cfg.name        = [mrfile '_scalp_mask'];
cfg.segment     = 'no';
cfg.output      = {'scalp'};
cfg.write       = 'no';
scalp           = ft_volumesegment(cfg, vol);

% save as nifti file and create surface for viewing
ft_write_volume([base '_scalp.nii'],scalp.scalp,'dataformat','nifti','transform',scalp.transform)
spm_surf([base '_scalp.nii'],2);
scalp    = gifti([base '_scalp.surf.gii']);
s        = patch('vertices',scalp.vertices,'faces',scalp.faces,'facecolor','g','edgecolor','none');
axis image off;
lt      = camlight;
lighting gouraud;