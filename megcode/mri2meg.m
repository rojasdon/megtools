function  new=mri2meg(transform,old,varargin)
%MEG2MRI Summary of this function goes here
%   Detailed explanation goes here

% defaults
operation = 'all';
if nargin > 2
    operation = varargin{1};
end

if size(old,2) ~= 3
    error('Input must be N x 3 array');
else
    npts = size(old,1);
end

new = zeros(size(old,1),size(old,2));

for i=1:npts
    switch operation
        case 'all'
            tmp         = old(i,:);
            tmp         = tmp(:) - transform.xfm.origin(:);
            new(i,:)    = transform.xfm.rotation * tmp(:);
        case 'rotate'
            tmp         = old(i,:);
            new(i,:)    = transform.xfm.rotation * tmp(:);
        case 'translate'
            tmp         = old(i,:);
            new(i,:)    = tmp(:) - transform.xfm.origin(:);
        otherwise
            error('Requested operation not supported!');
    end
end

end

