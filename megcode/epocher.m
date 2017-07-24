function [MEG,latencies] = epocher(MEG,type,start,stop,varargin)
%PURPOSE:   To epoch a MEG continuous data struct
%AUTHOR:    Don Rojas, Ph.D.
%INPUTS:    MEG - struct from get4D.m
%           type - of lock, 'trigger' or 'response'
%           start - value in msec preceeding trigger (baseline)
%           stop - value in msec post-trigger (start+stop = window)
%OPTIONAL:  offset - signed value in ms to offset time zero from triggers,
%               enter 0 if you want no offset but want a threshold spec
%           threshold - threshold in fT for rejecting trials
%OUTPUT:    epoched   = MEG struct with epochs defined
%           latencies = ntrials x 1 array of latencies between 1st and last
%                       event in sequence input, in ms
%EXAMPLES:  epochs = epocher(cnt,'trigger',200,800) will create a 1 second
%                    epoch window around triggers from structure cnt with a
%                    1000 ms window (-200 to 800 ms) centered on the
%                    trigger)
%           epochs = epocher(cnt,'trigger',200,800,'OFFSET',25) will create epochs with
%                    the timing of the stimulus from the trigger offset by
%                    25 ms. See note 1.
%           epochs = epocher(cnt,'response',5000,5000) will create a 10
%                    second epoch window around responses
%           epochs = epocher(cnt,'trigger',200,800,'THRESHOLD',2500) will
%                    apply a per trial +/- threshold of 2500 fT to exclude trials
%                    from epoch structure
%           epochs = epocher(cnt,'trigger',200,800,'PATTERN',[10 256]) will
%                    epoch on the sequence 10, then 256 (e.g., a trigger of
%                    10 and a response of 256) to create an epoch with the
%                    onset at the time of the first event
%           epochs = epocher(cnt,'trigger',200,800,'PATTERN',[10 256],'TRIGPOS',2) will
%                    epoch on the sequence 10, then 256 (e.g., a trigger of
%                    10 and a response of 256) to create an epoch with the
%                    onset at the time of the second event (256)
%           epochs = epocher(cnt,'trigger',200,800,'PATTERN',[10 256],'TIMEWIN',[100 1200]) will
%                    epoch on the sequence 10, then 256 (e.g., a trigger of
%                    10 and a response of 256) to create epochs only where
%                    the time elapsed between 10 and 256 is between 100 and
%                    1200 ms.
%           epochs = epocher(cnt,'sequential',500,500) will create epochs
%                    of 1000 ms duration on sequential data segments, without regard
%                    to trigger and/or response events.
%NOTES:     1. Make sure you understand what you want to do if you have an
%              offset in your data. If negative, you are sliding the epoch
%              window back in time relative to your trigger, which will
%              effectively increase your evoked response latency. If positive, the
%              opposite effect will occur.
%           2. There is no limit set on the length of the sequence used
%           3. It does not matter what type you set if you are using an
%              event sequence - it will be ignored.
%           4. For multievent epoching beyond n=2 in sequence, time window
%              input via TIMEWIN will always indicate range between first and
%              last event in sequence.
%TO DO:     1. Get rid of all epoch extraction or demote it to non-default
%              action
%SEE ALSO:  AVERAGER, EPOCH_EXTRACTOR, OFFSET

%HISTORY:   04/01/10 - added ability to offset time zero from trigger to
%                      account for delays between trigger and stim (e.g., sound
%                      transit times or video sync delays)
%           04/17/10 - rewrote to use new get4D() info from events. Now
%                      produces epochs of all stimuli or responses
%           06/24/10 - bugfix for input of negative start/stop values
%           07/13/10 - made trigger definition more robust and extended to
%                      channel types 'EEG' and 'EXT'
%           07/15/10 - added event2epoch.m call to make epoch struct
%           11/18/10 - fixed bug that caused epochs field not to return
%           05/25/11 - minor edits
%           06/01/11 - added multi-event epoching and argument/value pair
%                      type variable input
%           06/06/11 - minor bugfix for epoch indexing
%           06/10/11 - added code for using time windows (min max) on
%                      sequences, bugfixes
%           07/21/11 - fixed bug when reference channels were present
%           09/16/11 - time vector calculated as in get4D.m
%           09/19/11 - bugfix to remove bad epochs from epoch struct
%           09/29/11 - corrected bug with thresholding of epochs
%           06/06/12 - bugfix for deleting bad and skipped trials in epoch
%                      structure
%           12/10/12 - bugfix for situation with thresholding and
%                      insufficient samples leading to duplicate trials deleted
%           07/25/13 - bugfix for deletion of skipped trials

% defaults
s_offset  = 0;
thresh    = 1e5;
pattern   = [];
badind    = [];
skipped   = [];

% parse input and set default options
if nargin < 4
    error('Must supply at least 4 arguments to function!');
else
    if ~isempty(varargin)
        optargin = size(varargin,2);
        if (mod(optargin,2) ~= 0)
            error('Optional arguments must come in option/value pairs');
        else
            for i=1:2:optargin
                switch upper(varargin{i})
                    case 'OFFSET'
                        s_offset = varargin{i+1};
                    case 'THRESHOLD'
                        thresh  = varargin{i+1};
                    case 'PATTERN'
                        pattern = varargin{i+1};
                    case 'TRIGPOS'
                        trigpos = varargin{i+1};
                    case 'TIMEWIN'
                        timewin(1) = varargin{i+1}(1);
                        timewin(2) = varargin{i+1}(end);
                    otherwise
                        error('Invalid option!');
                end
            end
        end
    else
        % do nothing
    end
end

% make sure type is continuous
if ~strcmp(MEG.type,'cnt')
    disp('Input must be continuous data!');
    return;
end

if ~isfield(MEG,'events')
    disp('No event structure in specified MEG structure');
    return;
end

% given start and stop in ms, find start and stop in samples
int   = 1e3/MEG.sr; % ms/sample
pstim = abs(start); stop = abs(stop);
start = round(start/int);
stop  = round(stop/int);

% get appropriate information for epoching
if isempty(pattern)
    % extract epochs of all types
    type   = upper(type);
    epind    = find(ismember(char(MEG.events.mode),type,'rows'));
else
    % extract epochs matching pattern
    events    = str2num(char({MEG.events.type}))';
    epind     = strfind(events,pattern);
    % get timing information for reporting purposes
    latencies = zeros(length(epind),1);
    for trial = 1:length(epind)
        latencies(trial) = (MEG.events(epind(trial)+1).latency-MEG.events(epind(trial)).latency)*int;
    end
    % use window information if requested to limit trials
    if exist('timewin','var')
        toolow      = find(latencies < timewin(1));
        toohigh     = find(latencies > timewin(2));
        drop        = [toolow toohigh];
        epind(drop) = [];
        fprintf('\n%d trials did not meet time window criteria\n',length(drop));
    end
    % adjust trigger position in sequence
    if exist('trigpos','var')
        if length(pattern) < trigpos
            error('Trigger position in sequence must be <= length of pattern!');
        else
            epind = epind+(trigpos-1);
        end
    end
    type = 'SEQUENCE';
end
tmp    = [MEG.events.latency];
if length(epind) < length(tmp);
    onsets = tmp(epind);
else
    onsets = tmp;
end

% report stats
if exist('latencies','var')
    for trial = 1:length(onsets)
        fprintf('\nTrial %d pattern latency: %.2f ms',trial,latencies(trial));
    end
end

% correct for offset, if requested
if s_offset ~= 0
    % convert offset from ms to samples
    fprintf('\nAdjusting trigger/response offset by %d ms\n',s_offset);
    s_offset = round(s_offset/int);
    start  = start - s_offset;
    stop   = stop + s_offset;
end

% extract epochs
ep_samples = abs(start)+abs(stop);
epochs     = zeros(length(onsets),size(MEG.data,1),ep_samples);
skipped    = [];
fprintf('\nExtracting epochs');
for ii=1:length(onsets)
    if onsets(ii)-start == abs(onsets(ii)-start) && ...
            onsets(ii)+stop-1 < size(MEG.data,2) && ...
            onsets(ii)-start > 0
        fprintf('\nEpoch: %d',ii);
        epochs(ii,:,:) = MEG.data(:,onsets(ii)-start:onsets(ii)+stop-1);
    else
        skipped = [skipped ii];
    end
end

% report insufficient samples
fprintf('\n%d event(s) not epoched due to lack of sample points.\n',...
    length(skipped));

% delete remaining epochs exceeding threshold if desired
if thresh ~= 1e5
    cind   = meg_channel_indices(MEG,'multi','MEG');
    thresh = thresh/1e15; % scale to Tesla
    bad    = zeros(1,size(epochs,1));
    ymax    = max(max(epochs(:,cind,:),[],3),[],2);
    ymin    = min(min(epochs(:,cind,:),[],3),[],2);
    badind  = unique([find(ymax>thresh); find(ymin<-thresh)])';
    fprintf('\nNumber of trials exceeding +/- %d fT: %d\n',...
        thresh*1e15,length(badind));
end

% correct time data and event fields
epind(badind) = [];
MEG.type                        = 'epochs';
MEG.pstim                       = -pstim/1e3;
MEG.time                        = (1:double(ep_samples))*(1/MEG.sr);
MEG.time                        = (MEG.time-(abs(MEG.pstim)))*1e3;
MEG.epdur                       = (ep_samples*int)/1e3;
if size(epochs,1) > length(epind)
    MEG.data                    = epochs(1:length(epind),:,:);
else
    MEG.data                    = epochs(:,:,:);
end
MEG.eptype                      = type;
MEG.epoch                       = event2epoch(MEG.events(epind), MEG.time);
MEG                             = rmfield(MEG,'events');

fprintf('done!\n');
end

