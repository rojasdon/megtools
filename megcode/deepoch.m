function [odata, nepochs, nsamples] = deepoch(idata)
% PURPOSE:  To prepare data for algorithms that do not take epoched input,
%           such as the fastica function.
% AUTHOR:   Don Rojas, Ph.D.
% INPUT:    nepochs x nchannels x nsamples array of data
% OUTPUT:   odata       = nchan x nsamples array
%           nepochs     = number of epochs in original
%           nsamples    = number of samples per epoch in original
% NOTES:    1) use function reepoch.m to re-epoch an epoch dataset that has
%           been deepoched.
%           2) nepochs and nsamples are for convenience for re-assembly
%           using the reepoch.m function.
% SEE ALSO: REEPOCH

% HISTORY:  04/23/10 - fixed bug in reshaping data by transposing columns
%           and rows.

if ndims(idata) < 3
    error('Input array must be 3 dimensional!');
else % reshape array
    fprintf('\nDe-epoching data array...\n');
    s = size(idata);
    odata = zeros(s(2), s(3)*s(1));
    for chn = 1:s(2)
        odata(chn,:) = reshape(squeeze(idata(:,chn,:))',...
            1,s(1)*s(3));
    end
    nepochs = s(1); nsamples = s(3);
    fprintf('done!\n'); 
end

end