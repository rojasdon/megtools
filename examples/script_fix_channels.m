% repair bad channels script using fieldtrip - assumes MEG epoch format
% input but could be modified for continuous

% IMPORTANT NOTES: 
%   1.  You cannot use these files for source localization
%       without adding more code to this script! The coil locations will not be
%       correct/complete after you run it.
%   2.  You cannot reconvert these back to MEG format without some coding
%       changes.

% need to download install insertrows function from MATHWORKS site

% load files
load bti248.mat; % file containing good channel definitions 
load epsdel.mat; % file with deleted epoched dataset

% get bad indices
bad = eps.chn;
indices=setdiff([chn248.num],[bad.num]);

% de-epoch data for sake of inserting ease
[data nepochs nsamples] = deepoch(eps.data);
dummy                   = zeros(length(indices),nepochs*nsamples);

% insert rows of zeros for bad channels
for ii=1:length(indices)
    data = insertrows(data,dummy(ii,:),indices(ii)-1);
end

% re-epoch data to original dimensions
data = reepoch(data,nepochs,nsamples);

% create new dataset
neweps      = eps;
neweps.data = data;
neweps.chn  = chn248;

% convert to fieldtrip
ft = meg2ft(neweps);

% use fieldtrip to find neighbors for interpolation
cfg_nb.template = 'bti248grad_neighb.mat';
cfg_nb.method   = 'template';
neighbours      = ft_prepare_neighbours(cfg_nb);

% use fieldtrip to interpolate bad channels
cfg_rep.badchannel = ft.label(indices);
cfg_rep.neighbours = neighbours;
ftnew              = ft_channelrepair(cfg_rep,ft);



