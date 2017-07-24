function MEG = get37chn(file)
% NAME:    get37chn()
% AUTHOR:  Don Rojas, Ph.D.
% PURPOSE: to produce input data for various megtools routines from
%          MEG data produced on a 37 channel 4DNeuroimaging system
% USAGE:   MEG = get37chn('filename')
% OUTPUT:  MEG structure, containing the following fields:
%          data      = nepochs x nchans x nsamples array of MEG
%          locks     = nepochs x 2 chans x nsamples array of trig and resp.
%                      Not included in average files.
%          epdur     = epoch duration in seconds
%          pstim     = prestimulus start time in seconds
%          fname     = original filename from 4D database
%          type      = 'cnt'|'avg'|'epochs'
%          time      = samples converted into timepoints (ms)
%          sr        = sampling rate (whole number)
%          chn       = structure containing  fields:
%                      type      = 'meg','eeg','ext'
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
% INPUT:   file      = 4D format pdf file name (not exported), typically
%                      something like e,rfp1.0Hz
% EXAMPLE: cnt       = get37chn('c,rfp1.0Hz');
% TO DO:   1. add EEG and other channel type output
%          2. make channel type input calls more robust (see 'ext')
% HISTORY: Rev 0, 07/19/10

fprintf('\nWarning: You should make sure that Eugene''s function read_data_block.m');
fprintf('\nis altered to set scale = false for data type SHORT!\n');

% check input
if nargin ~= 1; error('A single filename must be supplied as an argument!'); end;

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
hdr         = pdf.header;
cfg         = pdf.config;
nepochs     = hdr.header_data.total_epochs;
MEG.fname   = file;
MEG.epdur   = get(pdf,'epoch_duration');
trigger     = get(pdf,'TRIGGER');
MEG.pstim   = -trigger.start_lat;
MEG.sr      = round(single(get(pdf,'dr')));


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

% read data and separate trigger and data
nsamp           = hdr.epoch_data{1}.pts_in_epoch;
data            = read_data_block(pdf);
trig            = data(1,:);
trig            = uint16(trig);
trig            = trig-bitand(2^12,trig);
data(1,:)       = []; % remove trigger from data array
resp            = trig; 
resp(resp > 0)  = 0; % copy trigger to response chan for compatibility
msize           = size(data);
MEG.data        = zeros(msize(1),msize(2),'single');

%channel scale (single, same as units_per_bit)
for ch = 1:msize(1)
    scale           = cfg.channel_data{ch}.units_per_bit;
    MEG.data(ch,:)  = single(data(ch,:)).* repmat(scale, 1, msize(2));
end

% reshape MEG data and trigger
MEG.data = shiftdim(reshape(MEG.data,msize(1),nsamp,[]),2);
MEG.aux  = single(shiftdim(reshape([trig;resp],2,nsamp,[]),2));

% channel info
cvec      = zeros(1,msize(1));
labels    = channel_name(pdf, 1:msize(1));
for i=1:msize(1)
    MEG.chn(i).label    = char(labels{i});
    MEG.chn(i).type     = 'MEG';
    MEG.chn(i).num      = str2num(strtok(MEG.chn(i).label,'A'));
    cvec(i)             = MEG.chn(i).num;
end
MEG.chn(msize(1)+1).type    = 'TRIGGER';
MEG.chn(msize(1)+1).label   = 'TRIGGER';
MEG.chn(msize(1)+1).num     = msize(1)+1;
MEG.chn(msize(1)+2).type    = 'RESPONSE';
MEG.chn(msize(1)+2).label   = 'RESPONSE';
MEG.chn(msize(1)+2).num     = msize(1)+2;
MEG.mchan                   = setxor(1:1:37,cvec);

% get channel locations into array
locs      = channel_position(pdf, 1:36);
MEG.cloc  = zeros(msize(1),6,'single'); MEG.cori = MEG.cloc;
for i=1:msize(1)
    MEG.cloc(i,1:6)     = locs(i).position(1:6)*1E3;
    MEG.cori(i,1:6)     = locs(i).direction(1:6)*1E3;
end

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

% create time vector from sample points
MEG.time = zeros(1, nsamp, 'single');
prestim = MEG.pstim * 1e3;
for t = 1:nsamp
    MEG.time(t) = prestim + single(t-1) * (MEG.epdur * 1e3/single(nsamp));
end

% create an event or epoch structure as needed
switch MEG.type
    case 'cnt'
        fprintf('\nEvents are created for trigger and response channels only.\n');
        fprintf('If you desire triggers from external or eeg channels, you\n');
        fprintf('will need to create them manually - see create_events.m\n');
        types = {'TRIGGER' 'RESPONSE'};
        MEG.events = create_events(MEG.aux(1:2,:),types);
    case 'epochs'
        [MEG.epoch events MEG.eptype] = create_epochs(MEG.aux(:,1:2,:),MEG.time);
    case 'avg'
        MEG.trials = hdr.header_data.input_epochs;
end
disp('done!');

end