function MEG = resample_meg(MEG,P)
% PURPOSE:  function to resample an MEG format to an arbitrary sample rate
% AUTHOR:   Don Rojas, Ph.D.
% INPUT:    MEG - MEG struct from get4D.m
%           P = new desired sample rate
% OUTPUT:   MEG - resampled MEG data
% NOTES:    1. Not extensively tested. Beware when downsampling below
%           Niquist for desired frequencies and/or noise
% HISTORY:  07/28/10 - first working version
%           05/25/11 - minor changes
%           09/16/11 - revised for updated MEG structure
%           09/30/11 - revised for updated MEG structure

% warning if new sr is below 200 Hz
if P < 200
    warning('New sample rate may be below that necessary for many analyses!');
end

% determine file type and condition input, and
% extract trigger and response data prior to resampling
tind = [meg_channel_indices(MEG,'multi','TRIGGER')...
        meg_channel_indices(MEG,'multi','RESPONSE')];
switch MEG.type
    case 'epochs' % de-epoch data for input
        [idata nepochs nsamp]   = deepoch(MEG.data);
        idata                   = double(idata);
    case 'cnt'
        idata = double(MEG.data);
    case 'avg'
        idata = double(MEG.data);
end
trigresp = idata(tind,:);

% resample and construct output
Q       = double(round(MEG.sr)); % original rate
P       = double(P); % new sample rate
nlen    = ceil(size(idata,2)*P/Q);
odata   = zeros(size(idata,1),nlen);
for i=1:size(idata,1)
    fprintf('Re-sampling MEG channel: %s\n',MEG.chn(i).label);
    odata(i,:)   = resample(idata(i,:),P,Q);
end

% repair sr, time and epoch fields in MEG structure
MEG.sr      = P;
oldtime     = MEG.time;
time        = MEG.pstim:1/MEG.sr:MEG.epdur-abs(MEG.pstim);
time(end)   = [];
MEG.time    = time*1e3;

% repair trig/resp channels - fills in gaps of 10 ms or less after
% indices of unresampled auxiliary are converted to resampled indices -
% this is an alternative to directly resampling trigger channels, which
% causes undesirable effects on trigger onset/offset values and times
switch MEG.type
    case {'cnt' 'epochs'}
       for chan=1:size(trigresp,1)
            tmp  = trigresp(chan,:);
            oind = find(tmp);
            nind = ceil(oind*P/Q);
            out = zeros(1,nlen);
            out(nind) = tmp(oind);
            for i=1:length(nind)
                if nind(i) == nind(end)
                    continue;
                elseif (nind(i+1) - nind(i)) < round(10/(MEG.sr\1e3));
                    out(nind(i):nind(i+1)) = out(nind(i));
                end
            end
            newtrigresp(chan,:) = out;
       end
    case 'avg'
        % do nothing
end
clear('trigresp');

% get data back into original shape and correct event structures as needed
switch MEG.type
    case 'epochs' % redo epoching
        MEG.data = single(reepoch(odata,nepochs,P));
        MEG.data(:,tind,:) = single(reepoch(newtrigresp,nepochs,P));
        [t t0]    = min(abs(oldtime)); % old trigger onset in samples
        newsamp   = ceil(t0*P/Q);
        for i=1:length(MEG.epoch)
            MEG.epoch(i).eventlatency = MEG.time(newsamp - 1);
        end
    case 'cnt'
        MEG.data   = single(odata);
        MEG.data(tind,:) = newtrigresp;
        types       = {'TRIGGER' 'RESPONSE'};
        MEG.events = create_events(MEG.data(tind,:),types);
    case 'avg'
        MEG.data = single(odata);
end

end