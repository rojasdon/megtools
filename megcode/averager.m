function [MEG badtrials] = averager(MEG,varargin)
%PURPOSE:   average epoched MEG data
%AUTHOR:    Don Rojas, Ph.D.  
%INPUT:     MEG     - see get4D.m
%           thresh  - in fT from baseline to reject trials from
%                     average. Should only use if epochs have 
%                     been baseline corrected. See offset.m tool
%           select  - trigger to select for output
%           grand   - grand average over channels if set to 1
%           var     - if 1, provide variance output in field .sd
%OUTPUT:    MEG structure with averaged data
%           trials field added to indicate number of trials in average
%           events field removed from returned MEG struct
%EXAMPLES:  avg = averager(MEG) to average all trials
%           avg = averager(MEG,'threshold',2500) to average all trials not exceeding
%           +/- 2500 fT from baseline
%           avg = averager(MEG,'select',20) to average trials of type 20
%           avg = averager(MEG,'grand',1) to produce grand average across
%                 all MEG channels
%SEE ALSO:  EPOCHER, OFFSET, EXTRACT_EPOCHS

%HISTORY:   04/19/10 - revised to account for changes to MEG
%                      structure - see get4D.m
%           05/08/11 - revised to allow argument pair inputs
%           05/09/11 - corrected way that trigger codes were selected for
%                      consistency with epoch_extractor (there was no bug, 
%                      but this will help with future revisions)
%           06/15/11 - argument pair input
%           09/16/11 - updates for MEG struct changes
%           09/29/11 - fixed threshold option
%           11/29/11 - improved speed of bad trial indexing, added that as
%                      output
%           04/24/12 - added grand average capability
%           10/11/13 - return variance optionally

% keep track of calculation time
tic;

% defaults
selective = 0;
threshold = 0;
ga        = 0;
if ~isempty(varargin)
    optargin = size(varargin,2);
    if (mod(optargin,2) ~= 0)
        error('Optional arguments must come in option/value pairs');
    else
        for i=1:2:optargin
            switch varargin{i}
                case 'select'
                    selection = varargin{i+1};
                    selective = 1;
                case 'threshold'
                    height      = varargin{i+1};
                    threshold   = 1;
                case 'grand'
                    ga          = varargin{i+1};
                otherwise
                    error('Invalid option!');
            end
        end
    end
end

if ~strcmp(MEG.type, 'epochs')
    error('Data are not epoched');
end

if isempty(varargin)
    % average all trials without regard to type or thresholding
    fprintf('\nAveraging all trials...');
    MEG.trials = size(MEG.data,1);
    MEG.data   = squeeze(mean(MEG.data,1));
    fprintf('done!\n');
else
    % process optional arguments
    bad    = zeros(1,length(MEG.epoch));  
    % find bad trials
    if threshold
        cind = meg_channel_indices(MEG,'multi','MEG');
        fprintf('\nAveraging trials using threshold of %d fT...', height);
        height = height/1E15; %scale to Tesla
        data   = MEG.data(:,cind,:);
        ymin = min(min(data,[],3),[],2);
        ymax = max(max(data,[],3),[],2); clear('data');
        indn = find(ymin<-height);
        indx = find(ymax>height);
        tind = unique(sort([indn' indx']));
        MEG.data(tind,:,:) = [];
        fprintf('\nNumber of trials rejected: %d\n',length(tind));
    else
        tind = [];
    end

    % selective average on particular trigger if desired
    if selective
        trigs       = str2num(char(cellfun(@(v) v(1), {MEG.epoch.eventtype})));
        ind         = find(trigs == selection);
        MEG.data    = squeeze(mean(MEG.data(ind,:,:),1));
        MEG.trials  = length(ind);
    else
        MEG.trials  = size(MEG.data,1);
        MEG.data    = squeeze(mean(MEG.data,1));
    end
end

if ~exist('tind','var')
    tind = [];
end
MEG.type    = 'avg';
MEG         = rmfield(MEG,'epoch');
badtrials   = tind;

% grand average if requested
if ga
    cind            = meg_channel_indices(MEG,'multi','MEG');
    gavg            = mean(MEG.data(cind,:));
    MEG.data        = gavg;
    MEG.mchan       = {'All'};
    MEG.chn(cind)   = [];
end 

% report time taken in function
t = toc;
fprintf('Time: %.2f seconds\n',t);

end

