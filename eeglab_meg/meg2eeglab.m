function EEG = meg2eeglab(MEG,varargin)
% PURPOSE:   convert an MEG structure to EEGLAB structure
% AUTHOR:    Don Rojas, Ph.D.  
% INPUT:     MEG = structure - see get4D.m
%            optional: output filename base string
% OUTPUT:    EEG structure, outfile = saved file
% NOTES:     1) currently the spherical and polar coordinates are not quite
%               correct and the function converts all from Cartesian
% EXAMPLES:  1. EEG = meg2eeglab(MEG,'MyOutFile')
%            2. EEG = meg2eeglab(MEG)
% HISTORY:   04/23/10 - Added EEGLAB event and epoch structures to the
%                       output format (see create_epochs.m and
%                       create_events.m for details)
%            11/22/10 - fixed bug with counting of MEG channels - was
%                       getting non-MEG channels as well.
%            07/19/11 - fix for EEGLAB problem with numbers as string data
%                       in event types
%            04/04/12 - various updates to accomodate v2 MEG struct,
%                       including newer method for channel indices
% SEE ALSO: EEGLAB2MEG, GET4D, PUT4D

eeglab_options;
EEG             = eeg_emptyset;
EEG.comments    = ['Original file: ' MEG.fname ' imported from get4D()'];
EEG.setname     = MEG.fname;
EEG.filepath    = pwd;
s               = size(MEG.data);
chn_ind         = meg_channel_indices(MEG,'multi','MEG');
other_ind       = setdiff(1:EEG.nbchan,chn_ind);

switch MEG.type
    case {'avg';'cnt'}
        EEG.trials  = 1;
        EEG.pnts    = s(2);
        EEG.data    = MEG.data(chn_ind,:)*1e15; % rescale to fT is better for some ICA routines
    case {'epochs'}
        EEG.trials  = s(1);
        EEG.pnts    = s(3);
        EEG.data    = permute(MEG.data(:,chn_ind,:),[2 3 1])*1e15;  
end
EEG.srate       = MEG.sr;
EEG.filename    = MEG.fname;
EEG.xmin        = MEG.time(1)/1e3;
EEG.xmax        = MEG.time(end)/1e3;
EEG.times       = MEG.time;
EEG.nbchan      = length(chn_ind);

% create channel structure
locs                            = MEG.cloc(chn_ind,1:3);
[theta radius]                  = cart2pol(locs(:,1),locs(:,2),locs(:,3));
[sph_theta sph_phi sph_radius]  = cart2sph(locs(:,1),locs(:,2),locs(:,3));
for i=1:EEG.nbchan
    chanlocs(i) = struct( ...
        'labels', MEG.chn(i).label, ...
         'theta', theta(i), ...
        'radius', radius(i), ...
             'X', locs(i,1), ...
             'Y', locs(i,2), ...
             'Z', locs(i,3), ...
     'sph_theta', sph_theta(i), ...
       'sph_phi', sph_phi(i), ...
    'sph_radius', sph_radius(i), ...
          'type', MEG.chbrn(i).type);
end
chanlocs     = convertlocs(chanlocs,'cart2all'); % sphericals aren't right
EEG.chanlocs = chanlocs;

% create events and epochs
tind = [meg_channel_indices(MEG,'labels',{'TRIGGER'}); ...
        meg_channel_indices(MEG,'labels',{'RESPONSE'})];
switch MEG.type
    case 'epochs' % epoch structure
        if ~isfield(MEG,'epoch') || ~isfield(MEG,'events')
            [EEG.epoch EEG.event] = create_epochs(MEG.data(:,tind,:),MEG.time);
        else
            EEG.epoch  = MEG.epoch;
            EEG.event  = MEG.events;
        end
    case 'cnt' % create event struct, if missing
        if ~isfield(MEG,'events')
            EEG.event = create_events(MEG.data(tind,:));
        else
            EEG.event = MEG.events;
        end
end

% set up events
if ~isempty(EEG.event)
    types =  cellstr(char(EEG.event.type));
    for i = 1:length(types)
        EEG.event(i).type = types(i);
    end

    % crude fix for the fact that EEGLAB does not like events as numbers, it
    % wants text descriptors, even when numbers are string data
    for i = 1:length(EEG.event)
        EEG.event(i).type = ['event' char(EEG.event(i).type)];
    end
end

% append MEG struct to EEG struct, minus meg data for easy reconvert
EEG.meg      = MEG;
switch MEG.type
    case 'epochs'
        EEG.meg.data(:,chn_ind,:) = []; 
    otherwise
        EEG.meg.data(chn_ind,:) = [];
end
EEG          = eeg_checkset(EEG);

% save set if desired
if nargin == 2
    out = [varargin{1} '.set'];
    save(out,'EEG');
    % pop_saveset(EEG); % uncomment to use eeglab function
end
end