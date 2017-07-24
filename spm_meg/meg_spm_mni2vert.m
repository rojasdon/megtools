function [dist meshind] = meg_spm_mni2vert(D, mni)

% function to find corresponding vertices for mni coordinate input in MEG
% inverse solution

% compute geometric distance to each point in mni vertex list
gd =  sqrt((D.inv{1}.mesh.tess_mni.vert(:,1) - mni(1)).^2 + (D.inv{1}.mesh.tess_mni.vert(:,2) - mni(2)).^2 ...
      + (D.inv{1}.mesh.tess_mni.vert(:,3) - mni(3)).^2);

% return closest index
[dist meshind] = min(gd);

end