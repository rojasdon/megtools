function [MEG, ntrials] = meg_threshold_trials(MEG,threshold,varargin)
%PURPOSE:   To remove trials exceeding a certain threshold
%AUTHOR:    Don Rojas, Ph.D.
%INPUTS:    MEG - epoched type only
%           threshold - threshold in fT for rejecting trials
%OUTPUT:    MEG - MEG struct with epochs exceeding threshold removed
%           ntrials = number of trials exceeding threshold
%EXAMPLES:  ep = meg_threshold_trials(ep,2500) will remove trials exceeding
%                a +/- 2500 fT threshold
%           ep = meg_threshold_trials(ep,2500,'window',[-50 100]) will
%                remove only those trials exceeding threshold between -50 and
%                100 ms of event defining epoch
%NOTES:     1. Normally, you would only do threshold based artifact
%              rejection if the data had first been baseline corrected - see
%              offset.m
%TO DO:     1. add gradient based rejection and default minimum amplitude
%              criteria
%           2. add EEG channels for thresholding if desired
%           3. add ability to input sub-group of channels for threshold
%HISTORY:   12/12/12 - first version

%SEE ALSO:  AVERAGER, EPOCHER, EPOCH_EXTRACTOR, OFFSET

% defaults
threshold = threshold/1e15;
window    = [];

% parse input and set default options
if nargin < 2
    error('Must supply at least 2 arguments to function!');
else
    if ~isempty(varargin)
        optargin = size(varargin,2);
        if (mod(optargin,2) ~= 0)
            error('Optional arguments must come in option/value pairs');
        else
            for i=1:2:optargin
                switch upper(varargin{i})
                    case 'WINDOW'
                        window = varargin{i+1};
                    case 'GRADIENT'
                        gradient  = varargin{i+1}; % not implemented
                    case 'CHANNELS'
                        channels = varargin{i+1}; % not implemented
                    otherwise
                        error('Invalid option!');
                end
            end
        end
    else
        % do nothing
    end
end
if isempty(window)
    window = [MEG.time(1) MEG.time(end)];
end

% restrict to epoched data
if ~strcmpi(MEG.type,'epochs')
    error('Input data type must be epochs!\n');
end

% get relevant channel indices
cind      = meg_channel_indices(MEG,'multi','MEG');

% define window in samples
tind = [get_time_index(MEG,window(1)) get_time_index(MEG,window(2))];

% find max min in channels for each trial
ymax      = max(max(MEG.data(:,cind,tind(1):tind(2)),[],3),[],2);
ymin      = min(min(MEG.data(:,cind,tind(1):tind(2)),[],3),[],2);

% get trial indices for max min gt threshold and remove
badind    = unique([find(ymax>threshold); find(ymin<-threshold)])';
if ~isempty(badind)
    MEG.data(badind,:,:) = [];
    MEG.epoch(badind)    = [];
    ntrials              = length(badind);
else
    ntrials = 0;
end
fprintf('Trials exceeding threshold: %d\n',ntrials);