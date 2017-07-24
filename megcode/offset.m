function corrected = offset(varargin)
%PURPOSE:   code to correct dc offset for MEG/EEG average files
%NOTE:      offset computed from entire prestim baseline and subtracted from
%           data.
%TO DO:     offset correction for continuous data
%INPUT:     required: MEG structure - see get4D.m
%           optional: two point vector in ms [begin end] specify offset
%           calculation range
%EXAMPLES:  cor = offset(inp) produces a pre-stimulus or response
%           subtracted result of every trial if inp is an epoched structure
%           or single trial average if inp is averaged input
%           cor = offset(inp,[-200 -150]) uses a custom portion of the
%           pre-stimulus window to compute the offset correction
%HISTORY:   04/20/10 - added ability to offset based on arbitrary points
%                      point inputs
%           05/31/11 - added ability to offset continuous data using mean
%                      of entire trace
%           09/26/11 - revised for robust time indexing
%           11/29/11 - minor bugfixes for baseline correction to apply only to
%                      MEG channels. This didn't affect prior results, it simply was
%                      inefficient because the offset was also calculated and applied to non MEG
%                      channels. Also increased memory efficiency by
%                      reducing copies of arrays.
%OUTPUT:    MEG structure with corrected data
%SEE ALSO:  EPOCHER, AVERAGER

% defaults
isMEG = 1;

% check input
switch nargin
    case 1
        indat = varargin{1};
    case 2
        indat = varargin{1};
        if length(varargin{2}) ~= 2
            error('You must specify 2 points');
        else
            points   = varargin{2};
        end
    otherwise
        error('Only 2 arguments accepted for this function!');
end

% determine type of structure input
flds = fieldnames(indat);
if length(flds) > 1
    if isfield(indat,'Q')
        ssp   = indat;
        isMEG = 0;
    elseif isfield(indat,'cori')
        MEG  = indat;
    else
        error('Unable to determine type of structure input from %s',indat);
    end
else
    error('Unable to determine type of structure input from %s',indat);
end

% convert baseline from ms to samples
if nargin == 2
    for ii = 1:2
        points(ii) = get_time_index(indat,points(ii));
    end
    start = points(1);
    stop  = points(2);
else % if undefined, use entire prestimulus period
    start     = 1;
    stop      = get_time_index(indat,0);
    points(1) = start;
    points(2) = stop;
end
if isMEG
    if strcmpi(MEG.type,'cnt')
        points(1) = 1;
        points(2) = length(MEG.time);
    end
end

% report actual points used
fprintf('\nNearest time points to requested times:\n');
fprintf('Start of offset:\t%.2f ms\n', indat.time(points(1)));
fprintf('End of offset:\t\t%.2f ms\n', indat.time(points(2)));
clear('indat');

% calculate baseline and subtract from data
if isMEG
    cind = meg_channel_indices(MEG,'multi','MEG');
    switch MEG.type
        case 'avg' 
            baseline  = mean(MEG.data(cind,start:stop),2);
            baseline  = repmat(baseline,1,size(MEG.data,2));
            corrected = MEG; clear('MEG');
            corrected.data(cind,:) = single(corrected.data(cind,:) - baseline);
        case 'epochs'
            nepochs = size(MEG.data,1);
            for ii=1:nepochs
                fprintf('Removing offset for trial: %d\n', ii);
                baseline    = mean(MEG.data(ii,cind,start:stop),3)';
                baseline    = repmat(baseline,1,size(MEG.data,3));
                MEG.data(ii,cind,:) = single(squeeze(MEG.data(ii,cind,:)) - baseline);
            end
            corrected = MEG; clear('MEG');
        case 'cnt'
            baseline        = mean(MEG.data(cind,:),2);
            baseline        = repmat(baseline,1,size(MEG.data,2));
            corrected       = MEG; clear MEG;
            corrected.data(cind,:)  = corrected.data(cind,:) - baseline;
            corrected.data          = single(corrected.data);
    end
else
    for ii=1:size(ssp.Q,1)
        fprintf('Removing offset for trial: %d\n', ii);
        baseline    = mean(ssp.Q(ii,start:stop));
        baseline    = repmat(baseline,1,size(ssp.Q,2));
        ssp.Q(ii,:) = squeeze(ssp.Q(ii,:,:)) - baseline;
    end
    corrected = ssp;
end
