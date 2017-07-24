function [epoch events type] = create_epochs(locks,times)
% PURPOSE:   To create an epoch structure from data read as epoch format
%            directly from 4D file.
% AUTHOR:    Don Rojas, Ph.D.
% INPUTS:    locks - nepochs x 2 x nsamples array of trigger and response channels
%            from get4D.m or from epocher.m
%            times - 1 x nsamples array of latencies
% SEE ALSO:  CREATE_EVENTS
% OUTPUT:    epoch - EEGLAB compatible epochs structure
%            events - EEGLAB events structure - may not be as good as if
%            done from continuous file directly
%            type - type of epoch
% HISTORY:   09/19/11 - revised for consistency of time indexing

% make sure input is correct
if nargin < 2
    error('Function requires 2 arguments');
end
lsize = size(locks);
if ~lsize(2) == 2
    error('Second dimension of input must be 2!');
end

% find onset sample point from time array
tmp.time = times;
t0 = get_time_index(tmp,0);

% get trigger and response line onset values
trigs = locks(:,1,t0+1);
resps = locks(:,2,t0+1);

% take care of buggy 4d trigger if present
trigs      = uint16(trigs); resps = uint16(resps);
bug        = find(bitand(trigs,2^13));
trigs(bug) = trigs(bug) - 2^13;

% determine which line was used to create the epochs and report information
if sum(trigs) > sum(resps)
    lock_events = trigs;
    vals        = unique(trigs(trigs > 0));
    type        = 'TRIGGER';
    fprintf('\nEpochs were created using triggers of types:\n');
else
    lock_events = resps;
    vals        = unique(resps(resps > 0));  
    type        = 'RESPONSE';
    fprintf('\nEpochs were created using responses of types:\n');
end
for i = 1:length(vals)
    fprintf('%d\n',vals(i));
end

% create EEGLAB epochs structure
len = length(lock_events);
epoch = struct([]);
for i=1:len
    trigs               = [0 diff(squeeze(locks(i,1,:)))'];
    resps               = [0 diff(squeeze(locks(i,2,:)))'];
    trigs(trigs < 0)    = 0; trigs = uint16(trigs);
    bug                 = find(bitand(trigs,2^13));
    trigs(bug)          = trigs(bug) - 2^13;
    resps(resps < 0)    = 0; resps = uint16(resps);
    sonsets             = find(trigs);
    ronsets             = find(resps);
    onsets              = sort([sonsets ronsets]);
    allevs              = [];
    lats                = cell(1,length(onsets)); 
    pos                 = cell(1,length(onsets));
    types               = cell(1,length(onsets));
    urevent             = cell(1,length(onsets));
    for j = 1:length(onsets)
        allevs      = [allevs i*j];
        lats{j}     = times(onsets(j));
        pos{j}      = 1;
        if ~isempty(find(sonsets == onsets(j)))
            types{j} = num2str(locks(i,1,onsets(j)));
        else
            types{j} = num2str(locks(i,2,onsets(j)));
        end
        urevent{j}   = j;
    end
    epoch(i).event = allevs;
    epoch(i).eventlatency = lats;
    epoch(i).eventposition = pos;
    epoch(i).eventtype = types;
    epoch(i).eventurevent = urevent;
end

% convert epochs to events - is this even needed now?
fprintf('\nDe-epoching lock channels to derive event structure\n');
[locks nepochs nsamples] = deepoch(locks); % to get 'original' indices
events                   = create_events(locks,{'TRIGGER' 'RESPONSE'});
% add epoch information to event structure
for i = 1:length(events)
    events(i).epoch = i;
end
end