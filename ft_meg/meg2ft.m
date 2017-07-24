function ft = meg2ft(MEG)
% NAME,      meg2ft()
% AUTHOR,    Donald C. Rojas, Ph.D.
%            University of Colorado Denver MEG laboratory
% PURPOSE,   meg2ft() creates a Fieldtrip compatible set of MEG
%            data.
% INPUT,    (1) MEG - struct from get4D.m
% OUTPUT,   (1) ft - fieldtrip structure
% NOTES,    (1) Only epoched datasets can be converted to Fieldtrip using
%               this function
%           (2) Much of the cfg structure may not be necessary
% SEE ALSO: MEG2SPM, MEG2EEGLAB

% HISTORY,  4/30/10 - first version
%           3/22/11 - corrected trialdef issue - fieldtrip structure is
%                     changing so may have to test with upgrades
%           5/26/11 - added support for re-conversion from ft back to
%                     megtools
%           9/29/11 - updated to reflect new format, added support for
%                     averaged data
%           6/18/12 - allow empty events structures
%           9/12/12 - compatibility tweaks
%           5/29/13 - tweak for empty events
%           9/21/15 - fixed some channel indexing issues with non-MEG chans

% check input
switch MEG.type
    case 'epochs'
        continuous = 0;
        nsamp      = size(MEG.data,3);
        trials     = size(MEG.data,1);
    case {'cnt' 'avg'}
        continuous = 1;
        nsamp      = size(MEG.data,2);
        trials     = 1;
    otherwise
        error('Nice try! Format not supported yet.');
end
fprintf('\nConverting MEG structure to Fieldtrip structure.\n');

% get grad structure prepared
grad = meg_sensors2grad(MEG,'mm');

% create the header structure
hdr.Fs          = MEG.sr;
hdr.nChans      = length(grad.label);
hdr.nSamples    = nsamp;
[~, ind]        = min(abs(MEG.time) - 0);
hdr.nSamplesPre = ind - 1;
hdr.nTrials     = trials;
hdr.label       = grad.label;
hdr.grad        = grad;

% get chan info
tind             = [meg_channel_indices(MEG,'labels',{'TRIGGER'}) ...
                    meg_channel_indices(MEG,'labels',{'RESPONSE'})];
extind           = meg_channel_indices(MEG,'multi','EXT');
eegind           = meg_channel_indices(MEG,'multi','EEG');
uaind            = meg_channel_indices(MEG,'labels',{'UACurrent'});

if continuous
    events = MEG.events;
    type   = 'TRIGGER'; % FIXME
else
    [~, events type] = create_epochs(MEG.data(:,tind,:),MEG.time);
end
hdr.orig        = rmfield(MEG,'data');

% trialdef struct
if isfield(MEG,'events')
    if ~isempty(MEG.events)
        trialdef = struct(...
            'eventtype',  upper(type),...
            'eventvalue', str2num(events(1).type),...
               'prestim', abs(MEG.time(1)/1e3),...
              'poststim', MEG.time(end)/1e3);
    else
        fprintf('No event structure or empty events!\n');
    end
else
    if ~isempty(MEG.epoch)
        epochs=MEG.epoch;
        trialdef = struct(...
            'eventtype',  upper(type),...
            'eventvalue', str2num(char(epochs(1).eventtype)),...
               'prestim', abs(MEG.time(1)/1e3),...
              'poststim', MEG.time(end)/1e3);
    end
end
  
% create ft_event structure and convert events to it
ft_event = [];
for i=1:length(events)
    if isempty(events(i).type)
        continue;
    else
        ft_event(i).type     = trialdef.eventtype;
        ft_event(i).sample   = events(i).latency;
        ft_event(i).value    = str2num(events(i).type);
        ft_event(i).offset   = [];
        ft_event(i).duration = [];
    end
end

% create ft_trl structure and convert events to it
ft_trl = zeros(length(events),3);
pre    = MEG.time(1)/(1e3/MEG.sr);
post   = MEG.time(end)-abs(MEG.time(1))/(1e3/MEG.sr);
for i=1:length(events)
    if isempty(events(i).type)
        continue;
    else
        ft_trl(i,1) = events(i).latency - pre;
        ft_trl(i,2) = events(i).latency + post;
        ft_trl(i,3) = -pre;
    end
end

ft_version = [];
ft_version.name = 'meg2ft.m';
ft_version.id   = '1.0';

% create cfg struct
cfg = [];
cfg.dataset = MEG.fname;
% cfg.trialdef= trialdef;
cfg.trackconfig = 'off';
cfg.checkconfig = 'loose'; 
cfg.checksize = 100000;
cfg.datafile = MEG.fname;
cfg.headerfile = MEG.fname;
cfg.dataformat = '4d';
cfg.headerformat = '4d';
cfg.trl= ft_trl;
cfg.version = ft_version;
cfg.channel = hdr.label;
cfg.continuous = 'no';
cfg.method = 'trial';
cfg.removemcg = 'no';
cfg.removeeog= 'no';
cfg.inputfile =  [];
cfg.outputfile =  [];
cfg.feedback =  'text';
cfg.precision =  'double';
cfg.padding =  0;
cfg.dftfilter =  'no';
cfg.lpfilter =  'no';
cfg.hpfilter =  'no';
cfg.bpfilter =  'no';
cfg.bsfilter =  'no';
cfg.medianfilter =  'no';
cfg.reref =  'no';
cfg.refchannel = cell({});
cfg.implicitref =  [];
cfg.polyremoval =  'no';
cfg.polyorder =  2;
cfg.detrend =  'no';
cfg.blc =  'no';
cfg.blcwindow =  'all';
cfg.lpfiltord =  6;
cfg.hpfiltord =  6;
cfg.bpfiltord =  4;
cfg.bsfiltord =  4;
cfg.lpfilttype =  'but';
cfg.hpfilttype =  'but';
cfg.bpfilttype =  'but';
cfg.bsfilttype =  'but';
cfg.lpfiltdir =  'twopass';
cfg.hpfiltdir =  'twopass';
cfg.bpfiltdir =  'twopass';
cfg.bsfiltdir =  'twopass';
cfg.medianfiltord =  9;
cfg.dftfreq =  [60 120 180];
cfg.hilbert =  'no';
cfg.derivative =  'no';
cfg.rectify =  'no';
cfg.boxcar =  'no';
cfg.absdiff =  'no';
cfg.conv =  'no';
cfg.montage =  'no';
cfg.dftinvert =  'no';
cfg.standardize =  'no';
cfg.denoise =  '';
cfg.subspace =  [];

% create trial structure
if continuous
    ntrials     = 1;
    trial       = cell(1,1);
    data        = double(MEG.data); MEG.data = [];
    data([tind extind eegind uaind],:) = [];
    trial{1}    = data;
else
    ntrials = size(MEG.data,1);
    trial   = cell(1,ntrials);
    data    = double(MEG.data); MEG.data = [];
    data(:,[tind extind eegind uaind],:) = [];
    for i=1:ntrials
        trial{i} = squeeze(data(i,:,:));
    end
end

% create time structure
if continuous
    time = {MEG.time/1e3 - 1/MEG.sr};
else
    time = cell(1,length(events));
    for i=1:ntrials
        time(i) = {MEG.time/1e3};
    end
end

% create trialdef structure
nsmp       = zeros(ntrials,1);
offset     = nsmp;
for i=1:ntrials
    nsmp(i)   = size(trial{i}, 2);
    offset(i) = round(time{i}(1)*hdr.Fs);
end
if continuous
    begsample = 1;
    endsample = length(MEG.time);
else
    begsample = cat(1, 0, cumsum(nsmp(1:end-1))) + 1;
    endsample = begsample + nsmp - 1;
end

% assemble the whole cfg structure
ft.hdr      = hdr;
ft.label    = hdr.label;
ft.time     = time;
ft.trial    = trial;
ft.fsample  = double(hdr.Fs);
% ft.trialdef = trialdef;
ft.grad     = grad;
ft.cfg      = cfg;
if isfield(MEG,'events')
    if ~isempty(MEG.events)
        if continuous
            ft.trialinfo = str2num(char(MEG.events.type));
        else
            ft.trialinfo = str2num(char([MEG.epoch.eventtype]));
        end
        if ~continuous
            ft.cfg.trl  = [begsample endsample offset ft.trialinfo];
        end
    end
end
ft.sampleinfo = [begsample endsample];

