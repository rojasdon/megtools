% code snippet for piezo experiment mri scans to take meg space measures
% back to mri space, so that we can apply a warp to mri and to beamformer
% results

% NOTE: a transform struct from spm8_manual_coreg must be loaded

id='0710';
mri=ft_read_mri([id '_realigned.img']); % meg aligned mri volume
ft_write_volume('test_tomri.nii',mr2meg.anatomy,'dataformat',...
    'nifti','transform',transform.tomri*mri.transform);
