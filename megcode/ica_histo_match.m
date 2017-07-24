function [tol,wind] = ica_histo_match(weights,template)
% function to automatically find a match between a set of input weights and
% a template set. Could be used to automatically determine which ica
% component is closest to a classic eye blink or movement, for example

% template should be a 1 x nbin set of normed weights

% no need to drop missing channels to use this method

% normalize the weights
nbins    = 20; % default histogram bins
nweights = size(weights,2);
nhist    = zeros(nweights,nbins);
for ii=1:nweights
    nhist(ii,:)=hist(weights(:,ii)/max(weights(:,ii)),nbins);
end

% compute differences between weights and template histograms
diffs = nhist-repmat(template,nweights,1);

% sum differences and return index of minimum sum
sums     = sum(abs(diffs),2);
[~,wind] = min(sums);
tol      = (sums(wind)/nbins)*100;

end