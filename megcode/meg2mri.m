function  new=meg2mri(transform,old)
%MEG2MRI Summary of this function goes here
%   Detailed explanation goes here

if size(old,2) ~= 3
    error('Input must be N x 3 array');
else
    npts = size(old,1);
end

new = zeros(size(old,1),size(old,2));

for i=1:npts
    tmp = old(i,:);
    new(i,:) = transform.xfm.rotation' ...
        * (tmp(:) + transform.xfm.origin(:));
end

end

