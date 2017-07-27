function z = fisherztrans(r)
% compute Fisher r to z transform on matrix or vector of r input
% author: Don Rojas
    tmp = r(:);
    z = 0.5.*log((1+tmp)./(1-tmp));
    if ndims(r) > 1
        z = reshape(z, size(r));
    end
end