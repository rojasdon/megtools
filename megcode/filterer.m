function OUT = filterer(indat,type,cutoffs,varargin)
% NAME:      filter.m
% AUTHOR:    Don Rojas, Ph.D.
%            University of Colorado Denver MEG laboratory
% PURPOSE:   filterer.m is a basic filtering function for EEG/MEG timeseries
%            that will provide simple low, high and bandpass filtering of
%            the butterworth type IIR in forward/reverse fashion for zero
%            phase-shift.
% INPUTS:    indat = structure of type MEG or SSP
%            type = filter type ('low','high' or 'band')
%            cutoffs = lowcut | highcut | [lowcut highcut] in Hz*
%            * if low or high pass is specified, only one number should be
%            given. If bandpass is specified, then 2 numbers should be
%            given in brackets.
% OPTIONAL:  'filt', 'butter'|'cheby1'|'cheby2' 'butter' = default
%            'order', filter order 2 = default
%            'meg', 1 = filter MEG data (default), 0 do not filter
%            'eeg', 1 = filter EEG data (default), 0 do not filter
%            'ext', 1 = filter EXT data, 0 do not filter (default)
%            'ref', 1 = filter REF data, 0 do not filter (default)
% OUTPUTS:   filtered = filtered version of data
% USAGE: (1) filtered = filterer(MEG,'band',[10 80]) creates
%            a filtered waveform of the data with a bandpass containing
%            low and high cutoffs at 10 and 80 Hz
%        (2) filtered = filterer(MEG,'low',30) creates
%            a filtered waveform of the data with a lowpass at 30 Hz
%        (3) filtered = filterer(MEG,'high',5,'order',4) creates
%            a filtered waveform of the data with a highpass at 5 Hz and
%            filter order of 4
% NOTES: (1) be careful applying this to data uncritically. If bad results
%            are obtained, can evaluate B,A transfer coefficients using freqs(B,A);
% SEE ALSO: OFFSET, SSP, GET4D

% HISTORY: 06/30/08 Original code
%          07/02/08 fixed issue with filter order and bp vs. high/low pass
%          03/19/10 made filtering more robust and changed to accept MEG
%          struct from get4D.m
%          04/14/10 fixed bug related to filtering epochs that caused
%          channels > epochs to be zeroed.
%          04/27/10 added flexibility to filter external channels
%          08/18/11 added ability to filter continuous data
%          09/16/11 updated for revisions to MEG struct, so that trigger
%          and response channels are not filtered, by default
%          09/20/11 added input arg pair options, different filter types
%          and ability to filter ssp structure from megtools
%          03/09/12 - fixed filtering of eeg channel selection bug
%          01/25/13 - added notch filter

% FIXME: check for installation of signal processing toolbox here

% defaults
applytotrigs = 0;
applytorefs  = 0;
applytomeg   = 1;
applytoext   = 0;
applytoeeg   = 1;
filtind      = [];
order        = 2;
isMEG        = 1;
dB           = .5;
filt         = 'butter';

% parse input and set default options
if nargin < 3
    error('Must supply at least 3 arguments to function!');
else
    if ~isempty(varargin)
        optargin = size(varargin,2);
        if (mod(optargin,2) ~= 0)
            error('Optional arguments must come in option/value pairs');
        else
            for i=1:2:optargin
                switch upper(varargin{i})
                    case 'ORDER'
                        order = varargin{i+1};
                    case 'FILT'
                        filt  = lower(varargin{i+1});
                        %if ~strcmp(type,'butter') || ~strcmp(type,'besself')...
                        %   || ~strcmp(type,'cheby1') || ~strcmp(type,'cheby2')
                        %    error('Filter type is not supported');
                        %end
                    case 'MEG'
                        if varargin{i+1} == 1; applytomeg = 1; else applytomeg = 0; end;
                    case 'EEG'
                        if varargin{i+1} == 1; applytoeeg = 1; else applytoeeg = 0; end;
                    case 'EXT'
                        if varargin{i+1} == 1; applytoext = 1; else applytoext = 0; end;
                    case 'REF'
                        if varargin{i+1} == 1; applytoref = 1; else applytoref = 0; end;
                    otherwise
                        error('Invalid option!');
                end
            end
        end
    else
        % do nothing
    end
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
clear('indat');

% channel indices and groups to apply filter to
if isMEG
    megi  = meg_channel_indices(MEG,'multi','MEG');
    refi  = meg_channel_indices(MEG,'multi','REFERENCE');
    exti  = meg_channel_indices(MEG,'multi','EXT');
    eegi  = meg_channel_indices(MEG,'multi','EEG');
    trigi = [meg_channel_indices(MEG,'labels',{'TRIGGER'}) ...
             meg_channel_indices(MEG,'labels',{'RESPONSE'})];

    if applytomeg;    filtind   = [filtind megi];  end;
    if applytotrigs;  filtind   = [filtind trigi]; end;
    if applytorefs;   filtind   = [filtind refi];  end;
    if applytoext;    filtind   = [filtind exti];  end;
    if applytoeeg;    filtind   = [filtind eegi];  end;
end

% get the channel or Q data and other params as input requires
if isMEG
    data    = MEG.data;
    sr      = MEG.sr;
    MEG     = rmfield(MEG,'data');
else
    data    = ssp.Q;
    points  = size(data,2);
    epdur   = ssp.epdur;
    sr      = 1/(ssp.epdur/points);
    ssp     = rmfield(ssp,'Q');
end

% create appropriate filter coefficients
switch type
    case 'low'
        % low pass
        if length(cutoffs) > 1
            error('For high/low pass, enter only one cutoff frequency');
        else
            switch filt
                case 'butter'
                    [B, A] = butter(order, cutoffs/(sr/2), 'low');
                case 'cheby1'
                    [B, A] = cheby1(order, dB, cutoffs/(sr/2),'low');
                case 'cheby2'
                    [B, A] = cheby2(order, dB, cutoffs/(sr/2),'low');
            end
        end
    case 'high'
        % butterworth high pass
        if length(cutoffs) > 1
            error('For high/low pass, enter only one cutoff frequency');
        else
            switch filt
                case 'butter'
                    [B, A] = butter(order, cutoffs/(sr/2), 'high');
                case 'cheby1'
                    [B, A] = cheby1(order, dB, cutoffs/(sr/2),'high');
                case 'cheby2'
                    [B, A] = cheby2(order, dB, cutoffs/(sr/2),'high');
            end
        end
    case 'band'
        % butterworth characteristic bandpass
        if length(cutoffs) ~= 2
            error('For band pass, enter two frequency cutoffs');
        else
            if ~strcmp(filt,'butter')
                warning(['Chosen filter type - %s - not supported for band pass. ' ...
                    'Changing filter type to Butterworth. Try filtering using ' ...
                    'separate lowpass and highpass steps instead.'],filt);
            end
            [B, A] = butter(order, [cutoffs(1) cutoffs(2)]/(sr/2));   
        end
    case 'notch'
        % notch filter
        if length(cutoffs) > 1
            error('For notch filter, enter only one frequency!');
        else
            fn      = sr/2; % Niquist
            fR      = cutoffs/fn; % ratio of notch to Niquist
            nW      = .1 * order; % width
            n0      = [exp(sqrt(-1)*pi*fR), exp(-sqrt(-1)*pi*fR)];
            poles   = (1-nW)*n0;
            B       = poly(n0);
            A       = poly(poles);
        end
    otherwise
        error('Badly formed input!');
end

B = double(B); 
A = double(A);

% apply filter to data
if isMEG
    switch MEG.type
        case {'avg','cnt'}
            fprintf('\nFiltering channel');
            for chn = 1:length(filtind)
                fprintf('\n%s', MEG.chn(filtind(chn)).label);
                % forward and reverse filter for zero phase-shift
                data(filtind(chn),:) = filtfilt(B, A, double(data(filtind(chn),:)));
            end
            fprintf('\ndone!\n');
        case 'epochs'
            fprintf('\nFiltering epochs on channels:\n%s\n',char({MEG.chn(filtind).label}));
            for epoch = 1:size(data,1)
                fprintf('Epoch: %d\n',epoch);
                for chn = 1:length(filtind)
                    % forward and reverse filter for zero phase-shift
                    data(epoch,filtind(chn),:) = filtfilt(B, A, ...
                        double(data(epoch,filtind(chn),:)));
                end
            end
            fprintf('done!\n');
        otherwise
            disp('Data type not supported!');
            return;
    end
else
    fprintf('\nFiltering epoched Q data');
    for epoch = 1:size(data,1)
        fprintf('.');
        % forward and reverse filter for zero phase-shift
        data(epoch,:) = filtfilt(B, A, ...
            double(data(epoch,:)));
    end
    fprintf('done!\n');
end

% put data back in structure
if isMEG
    OUT      = MEG;
    OUT.data = data;
else
    OUT      = ssp;
    OUT.Q    = data;
end

end