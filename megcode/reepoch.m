function odata = reepoch(idata,nepochs,nsamples)
% PURPOSE:  To re-epoch a dataset that was reshaped by deepoch.m
% AUTHOR:   Don Rojas, Ph.D.
% INPUT:    idata    = nchannel x nsamples array
%           nepochs  = number of epochs to create
%           nsamples = number of samples per epoch to create
% OUTPUT:   nepochs x nchannels x nsamples array
% HISTORY:  07/28/10 - fixed bug in output shape to conform to deepoch.m

if ndims(idata) > 2
    error('Input data must be 2-dimensional!');
end
fprintf('\nRe-epoching data array using %d epochs and %d samples/epoch...',...
    nepochs,nsamples);
nchannels = size(idata,1);
odata = zeros(nchannels,nsamples,nepochs);
for chn = 1:nchannels
    odata(chn,:,:) = reshape(idata(chn,:),nsamples,nepochs);
end
odata = permute(odata,[3 1 2]);
fprintf('done!\n');
end