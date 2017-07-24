function mni = vox2mni(imgfile,nonzeros)
% get a list of all the voxels in an image and return their mni coordinates

% get files and mask
if nargin < 1
    imgfile       = spm_select([1,1],'image','Select individual image...',...
                    '',pwd,'.*');
end

% Read image info
Vi          = nifti(imgfile);
if nonzeros % only return indices of non-zero voxels
    indices = find(Vi.dat(:));
else
    indices = 1:length(Vi.dat(:));
end
nvox        = uint32(length(indices));
O           = Vi.mat\[0 0 0 1]'; O=O(1:3)';
R           = Vi.mat(1:3,1:3);

fprintf('Finding coordinates for %d voxels...',nvox);
[i,j,k]     = ind2sub(size(Vi.dat),indices);
if nonzeros
    ijk         = double([i j k]);
else
    ijk         = double([i' j' k']);
end
% convert ijk to MNI coordinate
mni         = (ijk - repmat(O,nvox,1))*R;
fprintf('done\n');