function tf = meg_tf_cdemod(indat, freq, varargin)
% Function: meg_tf_cdemod.m
% Author:   Don Rojas, Ph.D.
% Purpose:  To compute Time-Frequency info from MEG/EEG source space
%           projected *Qt.mat files (see SSP.m) using Complex Demodulation
% Ref:      Hoechstetter et al. (2004). Brain Topography 16, 233?238 
% Inputs:   indat - struct from get4D.m, should be epoch type, or ssp
%                   struct from ssp.m, should also be epochs. Can either be string
%                   refererence to file name or can be variable name from workspace.
%           freq  - [low high] vector of frequency cutoffs
% Optional: 'lowpass', Hz, where Hz is integer lowpass cutoff (default = 4)
%           'bc', n: n = baseline correction method. Valid options are:
%                  1 : subtraction
%                  2 : percent change (default)
%                  3 : dB change
%                  4 : z-score change  
%           'ftype', 'gaussian' (default) |'butterworth'
%           'bdef', [first,last], baseline points in ms (default = entire
%                    prestim region
%           'raw',   0 (default) = no raw complex data in tf, 1 returns
%                    complex data, can be useful for compass plots etc.
%           'chan'  - channel to compute time-frequency transform e.g.,
%                    'A142', must be supplied for MEG type input
% Outputs:  tf structure containing fields:
%           mplf    = mean phase locking factor (a.k.a., ITC)
%           tpower  = total power (evoked + induced)
%           epower  = evoked power, or phase-locked power
%           ipower  = induced power, or non-phase-locked power
%           ntpower = baseline corrected tpower
%           nepower = baseline corrected epower
%           nipower = baseline corrected ipower
%           morl    = Morlet wavelet waveform for highest frequency
%           mask    = array of 0 and 1 for each time-frequency point that
%                     allows plotting of edge effect areas.
%           waven   = wavenumber vector used
% Usage:    tf = meg_tf_cdmod(MEG,[5 80]); will produce a time frequency
%           transform on data structure MEG, channel 121, from 5 to 50 Hz, 
%           wave #7
%           tf = tft(MEG,[5 100],'waven',[3 12],'bcdef',[-1000 -800]); will produce a time
%           frequency transform on a file from 5 to 100 Hz, with wave
%           number scaled linearly from 3 to 12 as frequency increases and
%           a baseline definition of -1000 to -800 ms.
% Notes:    1) Only Morlet wavelet is supported
% To do:    1) save raw units and norm units in tf struct
%           2) save morl field as array for each freq centered in time
%              vector at time 0 (nice for visualization of scales)
% History:  02/18/13 - first working version, based on prior crude script

% keep track of calculation time
tic;

% figure out input source to function
if isa(indat,'char')
    % see if file exists
    if ~exist(indat,'file')
        error('File %s does not exist!',indat);
    else
        indat = load(indat,'-mat');
    end
end

% some defaults
bc          = 2; % default baseline method, percent change
isMEG       = 1; % default is MEG input for channel tf
raw         = 0; % no complex data are returned
lowcut      = 4; % 4 Hz Gaussian low-pass cut off
first       = 1;
ftype       = 'gaussian';
det         = 1;

% determine type of structure
flds = fieldnames(indat);
if length(flds) > 1
    if isfield(indat,'Q')
        ssp   = indat;
        isMEG = 0;
        time  = ssp.time;
    elseif isfield(indat,'cori')
        MEG  = indat;
        time = MEG.time;
    else
        error('Unable to determine type of structure input from %s',indat);
    end
else % see if field is in one level because of load from file
    if isfield(indat.(flds{1}),'Q') % probably ssp type
        ssp   = indat.(flds{1});
        isMEG = 0;
    elseif isfield(indat.(flds{1}),'cori') % probably MEG type
        MEG  = indat.(flds{1});
    end
end
clear('indat');

% change defaults if requested
if ~isempty(varargin)
    optargin = size(varargin,2);
    if (mod(optargin,2) ~= 0)
        error('Optional arguments must come in option/value pairs');
    else
        for i=1:2:optargin
            switch varargin{i}
                case 'lowpass'
                    lowcut   = varargin{i+1}; 
                case 'ftype'
                    ftype    = varargin{i+1};
                case 'bc'
                    bc       = varargin{i+1};
                case 'bdef'
                    first    = get_time_index(time,varargin{i+1}(1));
                    last     = get_time_index(time,varargin{i+1}(2));
                case 'raw'
                    if varargin{i+1} == 1
                        raw  = 1;
                    end
                case 'chan'
                    chan     = varargin{i+1};
                otherwise
                    error('Option ''%s'' is not a valid option! See help.',varargin{i});
            end
        end
    end
end

% get the channel or Q data and other params as input requires
if isMEG
    if ~strcmp(MEG.type,'epochs')
        error('MEG struct type must be ''epochs''');
    end
    cind=meg_channel_indices(MEG,'labels',chan);
    if isempty(cind)
        error('Requested channel is missing from array');
    else
        data    = double(squeeze(MEG.data(:,cind,:)));
        speriod = 1/MEG.sr;
        time    = MEG.time;
        ntrials = size(MEG.data,1);
        points  = size(MEG.data,3);
    end
    fprintf('Calculating time-frequency transform for channel: %s...\n',char(MEG.chn(cind).label));
else
    data    = double(ssp.Q);
    ntrials = size(data,1);
    points  = size(data,2);
    time    = ssp.time;
    epdur   = ssp.epdur;
    prestim = ssp.time(1);
    speriod = ssp.epdur/points;
    fprintf('Calculating time-frequency transform for ssp...\n');
end

% demean and detrend if requested
for ii=1:ntrials
    if det
        data(ii,:) = detrend(data(ii,:));
    end
    mX         = mean(data(ii,:)); 
    data(ii,:) = data(ii,:)-mX;
end

sr          = 1/speriod;
tmp.time    = time;
last        = get_time_index(tmp,0); clear('tmp');

foi = freq(1):freq(2);

% filter type
switch ftype
    case 'gaussian'
        B   = gaussfiltcoef(sr,lowcut);
        A   = 1;
    case 'butterworth'
        [B, A] = butter(6, lowcut/(sr/2), 'low');
    otherwise
        error('Filter type not supported/recognized!\n');
end
        
        
C   = zeros(ntrials,length(foi),length(time));

pads = round(length(time)/4);
nt   = (1:length(time)+(2*pads))*(1/sr);
% real and imaginary computed separately
% sw = sin(2 * pi * foi' * nt);
% cw = cos(2 * pi * foi' * nt);
% for ii=1:ntrials
%    dat = [zeros(1,pads) ssp.Q(ii,:) zeros(1,pads)];
%    fprintf('Trial %d\n',ii);
%    for jj=1:length(foi)
%        f_complex = filtfilt(b,1,complex(dat.*sw(jj,:),dat.*cw(jj,:)));
%        C(ii,jj,:) = f_complex(pads+1:pads+length(t));
%    end
% end

% do time-frequency transformation
% complex number exponent representation
cexp = double(exp(2 * pi * 1i * foi' * (0:length(nt) - 1) / sr));
for ii=1:ntrials
    dat = [zeros(1,pads) data(ii,:) zeros(1,pads)];
    fprintf('Trial %d\n',ii);
    for jj=1:length(foi)
        f_complex  = filtfilt(B,A, dat .* cexp(jj,:));
        C(ii,jj,:) = f_complex(pads+1:pads+length(time));
    end
end

% construct tf structure
tf.time     = time;
tf.freq     = foi;
tf.tpower   = squeeze(mean(abs(C),1));
tf.epower   = squeeze(abs(mean(C,1)));
tf.ipower   = tf.tpower-tf.epower;
pnorm       = C./abs(C);
tf.mplf     = squeeze(abs(mean(pnorm)));
baseTP      = repmat(mean(tf.tpower(:,first:last),2),1,points);
baseEP      = repmat(mean(tf.epower(:,first:last),2),1,points);
baseIP      = repmat(mean(tf.ipower(:,first:last),2),1,points);
sdTP        = repmat(std(tf.tpower(:,first:last),0,2),1,points);
sdEP        = repmat(std(tf.epower(:,first:last),0,2),1,points);
sdIP        = repmat(std(tf.ipower(:,first:last),0,2),1,points);

% normalize using various methods
switch bc
    case 1 % subtract baseline only
        tf.ntpower = tf.tpower-baseTP; %normalized total power
        tf.nepower = tf.epower-baseEP; %normalized evoked
        tf.nipower = tf.ipower-baseIP; %normalized induced
        norm_unit = 'amplitude';
    case 2 % express as percent change
        tf.ntpower = (tf.tpower-baseTP)./baseTP; %normalized total power
        tf.nepower = (tf.epower-baseEP)./baseEP; %normalized evoked
        tf.nipower = (tf.ipower-baseIP)./baseIP; %normalized induced
        norm_unit = 'percent';
    case 3 % express in dB change
        tf.ntpower = (log10(tf.tpower./baseTP))*20; %normalized total power
        tf.nepower = (log10(tf.epower./baseEP))*20; %normalized evoked
        tf.nipower = (log10(tf.ipower./baseIP))*20; %normalized induced
        norm_unit = 'dB';
    case 4 % express in units of Z-score change
        tf.ntpower = (tf.tpower-baseTP)./sdTP; %normalized total power
        tf.nepower = (tf.epower-baseEP)./sdEP; %normalized evoked
        tf.nipower = (tf.ipower-baseIP)./sdIP; %normalized induced
        norm_unit = 'z-score';
end
tf.units = norm_unit;
te = toc;
fprintf('Time: %.2f seconds\n',te);