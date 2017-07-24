function D = meg2spm(MEG, varargin)
% NAME:      meg2spm()
% AUTHOR:    Donald C. Rojas, Ph.D.
%            University of Colorado Denver MEG laboratory
% PURPOSE:   meg2spm() creates an SPM8 compatible set of MEG
%            files ready for preprocessing in SPM
% INPUT:  (1) MEG - struct from get4D.m
%         (2) out - optional output filename base
% OUTPUT: (1) D = SPM8 formatted D structure, returned to workspace
%         (2) D struct written to .mat file
%         (3) raw data written to .dat file
% SEE ALSO: MEG2EEGLAB, MEG2FT

% HISTORY:  4/17/10 - conformed to new MEG structure - see get4D.m
%           9/16/11 - conformed to new MEG structure revisions, many
%           changes, including way D is saved (using object now), call to
%           meg_sensors2grad and dump of all channels into D struct instead
%           of just MEG, TRIGGER and RESPONSE
%           12/20/11 - bugfix for event types for epoched data conversion

% input check
if nargin == 2 && isa(varargin{1},'char')
    out = varargin{1};
else
    out = ['spm8_' MEG.fname];
end

% create D structure for spm8 .mat file
D = [];
dsize = size(MEG.data);
switch MEG.type
    case 'avg' % currently not supported
        D.type                  = 'single';
        nepochs                 = 1;
        nsamp                   = dsize(2);
        nchan                   = dsize(1);
        data                    = MEG.data;
    case 'epochs'
        D.type                  = 'single';
        nepochs                 = dsize(1);
        nsamp                   = dsize(3);
        nchan                   = dsize(2);
        data                    = permute(MEG.data,[2 3 1]);
    case 'cnt'
        D.type                  = 'continuous';
        nepochs                 = 1;
        nsamp                   = dsize(2);
        nchan                   = dsize(1);
        data                    = MEG.data;
    otherwise
        error('struct datatype cannot be converted to SPM');
end
D.fname                 = [out '.mat'];

% channel indices
megi  =  meg_channel_indices(MEG,'multi','MEG');
refi  =  meg_channel_indices(MEG,'multi','REFERENCE');
trigi = [meg_channel_indices(MEG,'labels',{'TRIGGER'}) ...
         meg_channel_indices(MEG,'labels',{'RESPONSE'})];
eegi  =  meg_channel_indices(MEG,'multi','EEG');
exti  =  meg_channel_indices(MEG,'multi','EXT');
 
% create D.data structure for spm8
D.data.fnamedat         = [out '.dat'];
D.data.datatype         = 'float32-le';
D.data.scale            = ones(nchan,1,nepochs,'double');
D.data.y.fname          = D.data.fnamedat;
D.data.y.dtype          = 16;
D.data.y.be             = 0;
D.data.y.offset         = 0;
D.data.y.pos            = [1,1,1];
D.data.y.scl_slope      = [];
D.data.y.scl_inter      = [];
D.data.y.permission     = 'rw';
switch MEG.type
    case 'epochs'
        D.data.y.dim    = [nchan nsamp nepochs];
    case {'cnt' 'avg'}
        D.data.y.dim    = [nchan nsamp];
end

% save data and clear up some memory
MEG    = rmfield(MEG,'data');
fid    = fopen(D.data.fnamedat,'w');

% scale MEG and REFERENCE type to fT and write to file
%data([megi refi]) = data([megi refi])*1e15;
fwrite(fid, data, 'float32');
fclose(fid);
clear('data');

%do projection of 3D positions into 2D map
cloc       = MEG.cloc(megi,1:3)*100;
tmp        = double(thetaphi(cloc')); %flatten
loc2d(1,:) = -tmp(2,:); %reverse y direction
loc2d(2,:) = tmp(1,:);

%FIXME: figure out current channel too
% MEG channels
D.channels                      = [];
for i=1:nchan
    switch upper(MEG.chn(i).type);
        case 'MEG'
            D.channels(1,i).bad         = 0;
            D.channels(1,i).label       = MEG.chn(i).label;
            D.channels(1,i).type        = upper(MEG.chn(i).type);
            D.channels(1,i).X_plot2D    = loc2d(1,i);
            D.channels(1,i).Y_plot2D    = loc2d(2,i);
            D.channels(1,i).units       = 'T';
        case 'REFERENCE'
            D.channels(1,i).bad         = 0;
            D.channels(1,i).label       = MEG.chn(i).label;
            if findstr(MEG.chn(i).label,'M')
                D.channels(1,i).type    = 'MAGREF';
            else
                D.channels(1,i).type    = 'GRADREF';
            end
            D.channels(1,i).X_plot2D    = [];
            D.channels(1,i).Y_plot2D    = [];
            D.channels(1,i).units       = 'T';
        case {'TRIGGER' 'RESPONSE'}
            D.channels(1,i).bad         = 0;
            D.channels(1,i).label       = MEG.chn(i).label;
            D.channels(1,i).type        = 'Other';
            D.channels(1,i).X_plot2D    = [];
            D.channels(1,i).Y_plot2D    = [];
            D.channels(1,i).units       = 'bits';
        case 'EXT'
            D.channels(1,i).bad         = 0;
            D.channels(1,i).label       = MEG.chn(i).label;
            D.channels(1,i).type        = 'Other';
            D.channels(1,i).X_plot2D    = [];
            D.channels(1,i).Y_plot2D    = [];
            D.channels(1,i).units       = 'bits';
        case 'EEG'
            D.channels(1,i).bad         = 0;
            D.channels(1,i).label       = MEG.chn(i).label;
            D.channels(1,i).type        = 'EEG';
            D.channels(1,i).X_plot2D    = []; % fix this
            D.channels(1,i).Y_plot2D    = []; % fix this
            D.channels(1,i).units       = 'mV';
        case 'UACURRENT'
            D.channels(1,i).bad         = 0;
            D.channels(1,i).label       = MEG.chn(i).label;
            D.channels(1,i).type        = 'EEG';
            D.channels(1,i).X_plot2D    = []; % fix this
            D.channels(1,i).Y_plot2D    = []; % fix this
            D.channels(1,i).units       = 'mV';
        otherwise % unknown type, do not trust units
            D.channels(1,i).bad         = 0;
            D.channels(1,i).label       = MEG.chn(i).label;
            D.channels(1,i).type        = 'Other';
            D.channels(1,i).X_plot2D    = [];
            D.channels(1,i).Y_plot2D    = [];
            D.channels(1,i).units       = 'V';
    end
end

% other fields in D structure
D.artifacts             = struct([]);
D.timeOnset             = double(MEG.pstim);
D.path                  = '';
D.Nsamples              = double(nsamp);
D.Fsample               = double(MEG.sr);
D.other                 = struct([]);
D.transform.ID          = 'time';

% Get trial info from MEG struct and put into D.trials struct array
D.trials                            = [];
switch MEG.type
    case 'cnt'
        D.trials.label                      = 'Undefined';
        D.trials.onset                      = 1/D.Fsample;
        D.trials.bad                        = 0;  
        D.trials.repl                       = 1;
        for i=1:length(MEG.events)
            D.trials.events(i).type       = 'TRIGGER_UP'; %change to resp for response locked
            D.trials.events(i).value      = MEG.events(i).type;
            D.trials.events(i).time       = MEG.events(i).latency*(1/D.Fsample);
            D.trials.events(i).duration   = [];            % might code trig dur here 
            D.trials.events(i).offset     = 0;
        end
    case 'epochs'
        for i=1:length(MEG.epoch)
            D.trials(1,i).label             = char(MEG.epoch(i).eventtype);
            D.trials(1,i).events.type       = 'TRIGGER_UP'; %change to resp for response locked
            D.trials(1,i).events.value      = str2num(char(MEG.epoch(i).eventtype));
            D.trials(1,i).events.duration   = 0;            % might code trig dur here
            D.trials(1,i).bad               = 0;
            if i == 1
                D.trials(1,i).events.time   = MEG.pstim;
                D.trials(1,i).onset         = 0.0;
            else
                D.trials(1,i).events.time   = MEG.pstim+(MEG.epdur*double(i)); % time of trig in s
                D.trials(1,i).onset         = MEG.epdur*double(i); % time of epoch begining in s
            end
        end
    otherwise
        % do nothing
end

% copy headshape and fiducial info from MEG struct
D.fiducials = MEG.fiducials;

% create D.sensors.meg structure with sensor locations and orientations
D.sensors.meg = meg_sensors2grad(MEG,'mm');

% reorder fields to conform to SPM8, just in case it matters
D = orderfields(D, {'type', 'Nsamples', 'Fsample',...
    'timeOnset','trials','channels','data','fname',...
    'path','sensors','fiducials','artifacts','transform',...
    'other'});

% save header info struct 'D' into matfile
D = meeg(D); % call constructor
D.save;