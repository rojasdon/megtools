function grad = meg_sensors2grad(MEG,scale)
% NAME:    meg_sensors2grad()
% AUTHORS: Don Rojas, Ph.D.
% PURPOSE: to produce a grad structure output from MEG structure input. The
%          grad structure is compatible with fieldtrip and with modifications to
%          SPM
% INPUT:   MEG structure data produced via get4D() call
%          scale - 'm'|'cm'|'mm'
% USAGE:   grad = meg_sensors2grad(MEG,'mm')
% OUTPUT:  grad structure with following fields:
%          .pnt - lower and upper coil locations for gradiometers, plus
%                 single triplets for magnetometers
%          .ori - lower and upper coil orientations for gradiometers, plus
%                 single triplets for magnetometers
%          .label - channel labels
%          .tra   - field associating upper/lower coils with a channel
%                   number
% SEE ALSO: GET4D, MEG2SPM, MEG2FT

% HISTORY:  06/15/11 First version
%           09/18/11 Updated for new MEG struct and allows scale
%           specification for output
%           05/23/13 changed i indexing to ii

% check input
if nargin ~= 2
    error('meg_sensors2grad requires 2 inputs!');
end

% deal with scale
% original MEG always in mm but this may not be robust enough
if isa(scale,'char')
    switch scale
        case 'm'
            grad.unit = 'm';
            scale     = 1e2;
        case 'cm'
            grad.unit = 'cm';
            scale     = 1e1;
        case 'mm'
            grad.unit = 'mm';
            scale     = 1;
        otherwise
            error('Units not recognized');
    end
else
    error('Units must be a string variable');
end

% get some channel indices and numbers
megi                   = meg_channel_indices(MEG,'multi','MEG');
refi                   = meg_channel_indices(MEG,'multi','REFERENCE');
nchan                  = length(megi) + length(refi);
nmeg                   = length(megi);
cind                   = [megi refi];
locl                   = MEG.cloc(:,1:3);
locu                   = MEG.cloc(:,4:6);
oril                   = MEG.cori(:,1:3);
oriu                   = MEG.cori(:,4:6);
clabels                = char(MEG.chn(cind).label);
clabels                = clabels(:,1)';
magi                   = findstr(clabels,'M');
nmref                  = length(magi);
gradi                  = findstr(clabels,'G');
ngref                  = length(gradi);
ngrad                  = nmeg + ngref;

% location and orientation info to grad
jj=1;
for ii=1:2:ngrad*2
    grad.pnt(ii,:)       = double(locl(jj,1:3))/scale;
    grad.ori(ii,:)       = double(oril(jj,1:3))/scale;
    grad.pnt(ii+1,:)     = double(locu(jj,1:3))/scale;
    grad.ori(ii+1,:)     = double(oriu(jj,1:3))/scale;
    grad.label(jj,1)     = {MEG.chn(cind(jj)).label};
    jj=jj+1;
end

% .tra field associates n grad coils with each other as single channel
grad.tra               = zeros(nchan,(nchan*2)-nmref,'double');
odds                   = 1:2:ngrad*2;
evens                  = 2:2:ngrad*2;
for ii=1:ngrad
    grad.tra(ii,odds(ii))     = 1;
    grad.tra(ii,evens(ii))    = 1;
end

if ~isempty(magi)
    % magnetometer references separately
    for ii=1:nmref
        mag.pnt(ii,:)       = double(locl(ii,1:3))/scale;
        mag.ori(ii,:)       = double(oril(ii,1:3))/scale;
        mag.label(ii,1)     = {MEG.chn(cind(magi(ii))).label};
    end

    % add gradiometer and magnetometer location data
    grad.pnt    = [grad.pnt;mag.pnt];
    grad.ori    = [grad.ori;mag.ori];
    grad.label  = [grad.label;mag.label];

    % add magnetometers to .tra field
    grad.tra(ngrad+1:end,ngrad+1:end) = [zeros(nmref,ngrad) eye(nmref)];
end

% add other fields - FIXME: this is not true for some data, esp pre-2009 at
% 9th avenue - need to read the weights in directly
grad.balance.current = 'Zero';
grad.balance.Zero.labelorg    = grad.label;
grad.balance.Zero.labelnew    = grad.label;
grad.balance.Zero.tra         = eye(nchan);

end