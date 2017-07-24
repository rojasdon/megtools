function [tomeg, tomri] = spm8_apply_xform2D(xformfile,megfile)
% spm8_apply_xform2D applies existing mri fiducials to a new meg data file

% SEE ALSO: spm8_manual_coreg

% load transform file
load(xformfile,'-mat');

% load MEG fiducials
D = spm_eeg_load(megfile);
megfids = D.fiducials.fid.pnt;

% set fields of transform structure
transform.meg.nas = megfids(1,:);
transform.meg.lpa = megfids(2,:);
transform.meg.rpa = megfids(3,:);

% create homogeneous 4 x 4 rigid body only transform (no scaling)
mrifids = [transform.mri.nas;transform.mri.lpa;transform.mri.rpa];
xform               = spm_eeg_inv_rigidreg(megfids',mrifids');
transform.xfm.xform = xform;
tomeg               = xform*transform.mri.mat;
coreg               = tomeg*inv(transform.mri.mat);
tomri               = inv(coreg);
transform.tomeg     = tomeg;
transform.tomri     = tomri;

% save transform data
[pth, nam, ~] = fileparts(megfile);
save(fullfile(pth,[nam '.xfm']),'transform');

end

