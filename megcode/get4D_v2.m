function MEG = get4D(file,varargin)
% NAME:    get4D()
% AUTHORS: Don Rojas, Ph.D.
% PURPOSE: to produce input data for various megtools routines from
%          MEG data produced on a 248 channel 4DNeuroimaging system
% INPUT:   file        = 4D format pdf file name (not exported), typically
%                        something like e,rfp1.0Hz
%          'reference' = 'no'|'yes' keep reference channels (default = 'yes')
% USAGE:   MEG = get4D('filename')
%          MEG = get4D('filename','ref','no') - no reference channels
% OUTPUT:  MEG structure, containing the following fields:
%          data      = nchans x nsamples array of MEG, TRIGGER, REF channels,
%                      for continuous and average type data, or nepochs x nchans x nsamples
%                      for epoched data
%          epdur     = epoch duration in seconds
%          pstim     = prestimulus start time in seconds
%          fname     = original filename from 4D database
%          type      = 'cnt'|'avg'|'epochs'
%          time      = samples converted into timepoints (ms)
%          sr        = sampling rate (whole number)
%          chn       = structure containing  fields:
%                      type      = 'meg','eeg','ext','ref'
%                      num       = channel number
%                      label     = channel label
%          fiducials = structure containing: .pnt = headshape, .fid = fids
%          cloc      = coil/electrode locations in mm
%          cori      = coil/electrode orientations
%          mchan     = missing/deleted channels
%          events    = event EEGLAB struct
%                      returned for continuous files
%          epoch     = epoch structure in EEGLAB format, returned for
%                      epoched files
%          trials    = number of input trials for average type files
% TO DO:   1. extend keep_ref logic so that each type of channel can be
%             selectively excluded, rather than all or none
% SEE ALSO: PUT4D, PDF4D

% HISTORY: Rev 0, 07/03/08 First version
%          Rev 1, 03/18/10 Added items to structure output for universal
%                          use in all megcode routines requiring 4D reads
%                          Added continuous file conversion
%          Rev 2, 04/17/10 Changed events/locks structures to return more
%                          info for other programs
%          Rev 3, 04/23/10 Added epochs field to return structure
%                          compatible with EEGLAB epochs if input file is 
%                          epoched. Added trials field for avg types
%          Rev 4, 04/27/10 Added flexibility in returning EEG/EMG channels,
%                          and/or EXT channels, primarily for triggering
%                          purposes.
%          Rev 5, 07/16/10 Altered call to create_epochs to accomodate
%                          re-written function.
%          Rev 6, 05/26/11 Added options to include/exclude reference
%                          channels in calls, as well as to delete auxillary channels after
%                          epoch or events are done
%          Rev 7, 08/19/11 Bugfix for external channel index, updated the
%                          way missing channels were handled

% FIXME NOTE: This is a test version of a new structure revision that will
% include all channels in one data field instead of using data, ref and aux
% fields - this will enable many other functions to not have to keep track
% of the various other fields (i.e., deleter, epocher, averager, etc.)

% FIXME: try to make MEG.fname more informative if possible, including
% whatever data on acquisition scan - maybe include a field for config
% info. Also need to try to get the data from the weight table

% FIXME: when this replaces old get4D, supply old version renamed for
% awhile, must test/look at put4D, any function refering to the ref and aux
% fields and revise - also need to supply converter between old/new
% formats, which should be easy

% defaults
keep_ref = 'no';

% parse input
if nargin < 1
    error('A single filename must be supplied as an argument!');
else
    optargin = size(varargin,2);
    if (mod(optargin,2) ~= 0)
        error('Optional arguments must come in option/value pairs');
    else
        for i=1:2:optargin
            switch varargin{i}
                case 'reference'
                    keep_ref = varargin{i+1};
                case 'auxillary'
                    keep_aux = varargin{i+1};
                otherwise
                    error('Invalid option!');
            end
        end
    end
end

% create PDF4D object and empty MEG struct
if ~isempty(which('pdf4D'))
    [path nam ext]  = fileparts(file);
    nam             = [nam ext]; % assumes 4D convention of using '.' in filename
    pdf             = pdf4D(fullfile(path,nam));
    MEG             = [];
else
    error( ...
        'You do not have E. Kronberg''s pdf4D object installed (see http://biomag.wikidot.com/msi-matlab)');
end

% get some basic info from pdf header
hdr     = pdf.header;
nepochs = hdr.header_data.total_epochs;

%assumes average files have 1 epoch and are less than 5 seconds in length
switch nepochs
    case 1
        if hdr.header_data.input_epochs > nepochs
            disp('Reading average file...');
            MEG.type = 'avg';
        else
            disp('Reading continuous file...');
            MEG.type = 'cnt';
        end
    otherwise
        fprintf('Reading epoch file: %d epochs...\n', nepochs);
        MEG.type = 'epochs';
end

MEG.fname   = file;
MEG.epdur   = get(pdf,'epoch_duration');
trigger     = get(pdf,'TRIGGER'); %response lock problem!?
MEG.pstim   = double(-trigger.start_lat);
megi        = channel_index(pdf,'MEG','name');
refi        = channel_index(pdf,'REFERENCE','name');
trigi       = channel_index(pdf,'TRIGGER','name');
respi       = channel_index(pdf,'RESPONSE','name');
exti        = channel_index(pdf,'ext','name');
eegi        = channel_index(pdf,'EEG','name');
eventi      = [trigi respi];
chani       = [megi eventi exti eegi];
nmeg        = length(megi);
nchan       = length(chani);
nref        = length(refi);
nsamp       = hdr.epoch_data{1}.pts_in_epoch;
MEG.sr      = double(get(pdf,'dr'));

% channel labels
if strcmpi(keep_ref,'yes')
    chani  = [chani refi];
    nchan  = nchan + nref;
end
labels = channel_name(pdf, chani);

% construct channel information structure
% cvec      = zeros(1,nmeg);
for i=1:nchan
    MEG.chn(i).label    = char(labels{i});
    if ismember(chani(i),megi)
        MEG.chn(i).type = 'MEG';
        MEG.chn(i).num      = str2num(strtok(MEG.chn(i).label,'A'));
    else
        %MEG.chn(i).num      = i;
    end
    if ismember(chani(i),eegi);  MEG.chn(i).type = 'EEG';       end
    if ismember(chani(i),exti);  MEG.chn(i).type = 'EXT';       end
    if ismember(chani(i),trigi); MEG.chn(i).type = 'TRIGGER';   end
    if ismember(chani(i),respi); MEG.chn(i).type = 'RESPONSE';  end
    if ismember(chani(i),refi);  MEG.chn(i).type = 'REFERENCE'; end
end

% get channel locations into array
locs      = channel_position(pdf, megi);
cloc      = zeros(length(locs),6,'single'); cori = cloc;
for i=1:nmeg
    cloc(i,1:6)     = locs(i).position(1:6)*1E3;
    cori(i,1:6)     = locs(i).direction(1:6)*1E3;
end
MEG.cloc = cloc;
MEG.cori = cori;

% reference channel locations if requested
if strcmpi(keep_ref,'yes')
    locs      = channel_position(pdf, refi);
    cloc      = zeros(length(locs),6,'single'); cori = cloc;
    for i=1:nref
        if size(locs(i).position,2) == 2
            cloc(i,1:6)     = locs(i).position(1:6)*1E3;
            cori(i,1:6)     = locs(i).direction(1:6)*1E3;
        else
            cloc(i,1:3)     = locs(i).position(1:3)*1E3;
            cori(i,1:3)     = locs(i).direction(1:3)*1E3;
        end
    end
    MEG.cloc =[MEG.cloc;cloc];
    MEG.cori =[MEG.cori;cori];
end

% find missing channels (assumes 248 channel MEG array)
cvec = meg_channel_indices(MEG,'multi','MEG');
tmp = setxor(1:1:248,cvec);
MEG.mchan = {};
for mchn=1:length(tmp)
    MEG.mchan{mchn} = ['A' num2str(tmp(mchn))];
end

% create time vector in ms
MEG.time =((MEG.pstim:double(nsamp))*(1/MEG.sr))*1e3;

% get headshape and fiducials, scaled to mm
if exist(fullfile(path,'hs_file'),'file') == 2
    head                          = get(pdf,'headshape');
    MEG.fiducials.pnt             = zeros(length(head.point),3);
    MEG.fiducials.fid.pnt         = zeros(3, 3, 'double');
    MEG.fiducials.fid.pnt(1,1:3)  = double(head.index.nasion'*1e3);
    MEG.fiducials.fid.pnt(2,1:3)  = double(head.index.lpa'*1e3);
    MEG.fiducials.fid.pnt(3,1:3)  = double(head.index.rpa'*1e3);
    MEG.fiducials.pnt             = double(head.point'*1e3);
    MEG.fiducials.fid.label       = cell(3,1);
    MEG.fiducials.fid.label{1}    = 'nas';
    MEG.fiducials.fid.label{2}    = 'lpa';
    MEG.fiducials.fid.label{3}    = 'rpa';
else
    disp('No headshape file in 4D directory! Not adding to MEG struct');
end

% read data in file into nepoch x nchan x nsamp single array (nepoch dim will
% not be there for average and continuous files)
MEG.data   = shiftdim(reshape(read_data_block(pdf,[],megi),nmeg,nsamp,[]),2);
switch MEG.type
    case {'epochs','cnt'}
        trigresp   = shiftdim(reshape(read_data_block(pdf,[],eventi),2,nsamp,[]),2);
        trigresp   = uint16(trigresp);
        trigresp   = trigresp-bitand(2^13,trigresp);
        trigresp   = trigresp-bitand(2^11,trigresp);
        trigresp   = trigresp-bitand(2^12,trigresp); % strip bit 12 from code
        
        extn       = sum(ismember(char(MEG.chn.type),'EXT','rows'));
        eegn       = sum(ismember(char(MEG.chn.type),'EEG','rows'));
        eeg = [];  ext = [];
        if extn > 0
             ext   = shiftdim(reshape(read_data_block(pdf,[],...
                        exti),extn,nsamp,[]),2);
        end
        if eegn > 0         
             eeg   = shiftdim(reshape(read_data_block(pdf,[],...
                        eegi),eegn,nsamp,[]),2);
        end
        auxchn      = [ext; eeg];
        MEG.data    = [MEG.data; single(trigresp);auxchn];
        clear('trigresp','auxchn','ext','eeg');
    otherwise
        % currently do nothing for average type
end

% read reference data if requested
if strcmpi(keep_ref,'yes')
    refdat = shiftdim(reshape(read_data_block(pdf,[],refi),nref,nsamp,[]),2);
    MEG.data = [MEG.data;refdat];
    clear('refdat');
end


% create an event or epoch structure as needed
switch MEG.type
    case 'cnt'
        fprintf('\nEvents are created for trigger and response channels only.\n');
        fprintf('If you desire triggers from external or eeg channels, you\n');
        fprintf('will need to create them manually - see create_events.m\n');
        types = {'TRIGGER' 'RESPONSE'};
        trigrespi  = [meg_channel_indices(MEG,'single','TRIGGER'); ...
                      meg_channel_indices(MEG,'single','RESPONSE')];
        MEG.events = create_events(MEG.data(trigrespi,:),types);
    case 'epochs'
        [MEG.epoch , ~, MEG.eptype] = create_epochs(MEG.data(:,trigrespi,:),MEG.time);
    case 'avg'
        MEG.trials = hdr.header_data.input_epochs;
end
    
disp('done!');