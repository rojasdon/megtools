function [accel fchn thresh] = process_auxiliary(chn,trigs,sr,dur,varargin)
% NAME:     process_auxilliary.m
% AUTHOR:   Don Rojas, Ph.D.
% PUPROSE:  to preprocess accelerometer data from raw into the form of
%           triggers to use for event processing
% INPUTS:   chn     = nchannel x nsample array of accelerometer data
%           trigs   = 1 x ntrig vector of new trigger values - ntrigs
%                     should equal number of input channels
%           sr      = sampling rate in Hz
%           dur     = time during which re-triggering will be prevented (in
%                     milliseconds)
%           thresh  = optional threshold in stdev for creating trigger events
% OUTPUTS:  accel:  nchannel x nsample array of trigger channels
%           fchn:   filtered input upon which triggers were based
%           thresh: threshold used for triggering
% EXAMPLES: [accel fchn thresh] = process_accelerometers(channels,[10 20],508.63,5000) processes
%           accelerometer data and returns codes of 10 and 20 based on
%           default thresholds for 2 accelerometer channels, with
%           retriggering prevented for 5 seconds
% NOTES:    1) triggers only created at onset currently
% TO DO:    1) offset triggering
%           2) make trig duration fixed
%           3) option to change hp and lp cutoffs
% HISTORY:  04/27/10 - first version
%           07/15/10 - option to change threshold in units of standard
%           deviation
%           07/16/10 - changed filter cutoffs for better results
% SEE ALSO: CREATE_EVENTS

fprintf('Processing accelerometer data...\n');

% check size of input
if ndims(chn) > 2
    error('\nInput arrays may only have 2 dimensions!\n');
else
    nchan = size(chn,1);
end

% check arguments
if nargin < 5
    std_t = 2; % default threshold is 2 standard deviations
else
    std_t = varargin{1};
end

% convert re-trigger duration to nearest samples
int = 1e3/sr;
dur = round(dur/int);

% notch filter data at 60, 120 and 180 line frequencies
notches = [60,120,180];
fn      = sr/2; % Niquist
order   = 4;
tmp = chn;
for ii=1:length(notches)
    fR      = notches(ii)/fn; % ratio of notch to Niquist
    nW      = .1 * order; % width
    n0      = [exp(sqrt(-1)*pi*fR), exp(-sqrt(-1)*pi*fR)];
    poles   = (1-nW)*n0;
    B       = poly(n0);
    A       = poly(poles);
    for jj=1:nchan
        tmp(jj,:) = filtfilt(B, A, double(tmp(jj,:)));
    end
end

% high pass filter data at 20 Hz
[B, A] = butter(6, 20/(sr/2), 'high'); 
B = double(B); 
A = double(A);
tmp = zeros(size(chn,1),size(chn,2));
for chan=1:nchan
    tmp(chan,:) = filtfilt(B, A, double(chn(chan,:)));
    chn(chan,:) = tmp(chan,:);
end

% rectify
chn = abs(chn);

% low pass filter data at 10 Hz
[B, A] = butter(6, 10/(sr/2), 'low'); 
B = double(B); 
A = double(A);
tmp = zeros(size(chn,1),size(chn,2));
for chan=1:nchan
    tmp(chan,:) = filtfilt(B, A, double(chn(chan,:)));
    chn(chan,:) = tmp(chan,:);
end

fchn = chn;

% Automated threshold on mean + n*std
for chan=1:nchan
    fprintf('Thresholding channel: %d\n', chan);
    tmp             = zeros(1,length(chn));
    Xbar            = mean(chn(chan,:));
    stdev           = std(chn(chan,:));
    thresh(chan)    = Xbar+(std_t*stdev);
    ind             = find(chn(chan,:) > thresh(chan));
    tmp(ind)        = trigs(chan);
    chn(chan,:)     = tmp;
end

% find onsets by taking temporal derivative
for chan=1:nchan
    chn(chan,:) = [0 diff(chn(chan,:))];
end
chn(chn < 0)    = 0; % assume onsets are positive, offsets negative

% clean up trigger channel to prevent re-triggering within specified
% interval
for chan=1:nchan
    tmp = chn(chan,:);
    ind = find(tmp);
    for i=1:length(ind)
        if ind(i) == ind(end)
            continue;
        elseif (ind(i+1) - ind(i)) < dur
            tmp(ind(i):ind(i+1)) = tmp(ind(i));
        end
    end
    chn(chan,:) = tmp;
end

accel = chn;
fprintf('Done!\n');

end