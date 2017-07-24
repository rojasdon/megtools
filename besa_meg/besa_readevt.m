function [events, hdr] = besa_readevt(filename)

if isempty(findstr(filename,'.'))
  filename = [filename '.evt'];
end
fp = fopen(filename,'r');

% For convenience, we will use the EEGLAB structure (ie, EEG.events)
events.latency      = [];
events.position     = [];
events.type         = [];

% NOTE: This may will not work on all evt files, depending on how
% BESA outputs the evt data in the 4th column on (i.e., if numeric)...
% Potential bug: what happens when evt file reflects all evts but
% export excludes bad trials?

% Read column headings and determine time scale
hdr = textscan(fgetl(fp),'%s %s %s %s');
switch char(hdr{1})
    case 'Tms'
        scale = 1e3;
    case 'Tmu'
        scale = 1e6;
    case 'Tsec'
        scale = 1;
    otherwise
        error('BESA evt file header does not have time scale as first column');
end

% Read remainder of file into structure
s       = textscan(fp,'%s %s %s');
nevents = length(s{1});
fprintf('Reading %d events from %s\n',nevents,filename);
donotimport = zeros(nevents,1);
for ii=1:nevents
   events(ii).latency        = str2double(s{1}(ii))/scale;
   events(ii).type           = num2str(str2double(s{3}(ii)));
   events(ii).urevent        = ii;
   if str2double(s{2}(ii)) == 1
       events(ii).mode       = 'TRIGGER';
   else
       donotimport(ii)       = 1;
   end
end
events(donotimport == 1)    = [];
warning('BESA event latencies are in units of sec - convert to samples for use with MEG struct!');