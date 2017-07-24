function D = pdf2spm8(file, varargin)
% NAME:      pdf2spm8()
% AUTHOR:    Donald C. Rojas, Ph.D.
%            University of Colorado Denver MEG laboratory
%
% PURPOSE:   pdf2spm8() creates an SPM8 compatible set of MEG
%            files ready for preprocessing in SPM8.  It will
%            convert 4D Neuroimaging Magnes data files without first 
%            exporting from the 4D database and
%            capitalizes on the PDF4D object by Eugene Kronberg
%            for reading the native 4D MEG binaries.
% OUTPUT: (1) D = SPM8 formatted D structure, returned to workspace
%         (2) D struct written to .mat file
%         (3) raw data written to .dat file
%         (4) channel template file (not necessary for SPM8), but can be
%             used to create a site template
%
%
% USAGE: (1) D = pdf2spm8('inputfile') creates
%            a structure D containing the SPM5 fields and produces
%            two files, megpdf.mat and megpdf.dat, that contain the
%            structure D and the raw binary data, respectively. ;inputfile'
%            should be the name of a native 4D Neuroimaging file.  Do not
%            export the data first using pdf2set!
%        (2) pdf2spm8('e,rfhp0.1Hz,bahe001-1epoched', 'e_meg') creates
%            the same files, but names them 'e_meg.mat' and 'e_meg.dat'
%        (3) pdf2spm8('e,rfhp0.1Hz,bahe001-1epoched', 'e_meg', 1)
%            removes the trigger bit (bit 12 in the Magnes system) from
%            the trigger code for convenience and so that they will look
%            identical to how they display in the msi data editor (e.g.,
%            the trigger value 4106 becomes a 10).
%        (4) pdf2spm8('e,rfhp0.1Hz,bahe001-1epoched', 'e_meg', 1,'response')
%            uses response channel locking instead of stimulus channel time
%            locking, in addition to items from #3.
%        (5) pdf2spm8('e,rfhp0.1Hz,bahe001-1epoched', 'e_meg', 1,'response',...
%            'custom.mat') uses a custom channel template file for the
%            site.  You can also simply change the default setting in the
%            code below to suit your site. The ctf file must be in the
%            EEGtemplates subdirectory of the spm installation. See note 5
%            below for details on creating a site specific file.
%
% NOTES: (1) The PDF4D matlab code from Eugene Kronberg
%            must be installed on the matlab path.  See:
%            http://biomag.wikidot.com/msi-matlab
%        (2) Because of display issues in SPM8, data files should
%            be epoched first in the msi environment (e.g., using
%            the Boolean Averager tool) or using some other tool such as EEGLAB.
%        (3) 4D systems have fractional sampling rates such as 1041.7 Hz. 
%            The rate has been rounded to a whole sampling
%            rate to avoid many errors which occur in the SPM8 code that ensue with
%            the fractional rates.
%        (4) A site specific channel file can be created/modified from the
%            ones supplied and the setup line below should be customized to
%            your site.  The channel locations are variable between
%            instruments even of the same model (e.g., two Magnes 3600
%            systems will have different channel locations/orientations),
%            so you should NOT use one from another site without
%            modification. The ctf4D() function is supplied for this task.
%        (5) More flexible input argument combinations to be added in next
%            iteration.  Currently, one must specify all prior args to get
%            to 5th arg, for example.
%        (6) The program has been tested on Magnes WH3600 (Colorado),
%            Magnes WH2500 (Alabama) and Magnes II (Erlangen) data. It may or
%            may not work for other 4D/BTi systems.
%
% HISTORY: Rev 1 11/09/2008
%          Rev 2 01/29/2009 Added support for continuous file conversion
%          Rev 3 02/23/2009 Added external channel support
%          Rev 4 03/11/2009 Added all channel support, fixed a couple of
%                bugs pertaining to non-MEG channels

% check input arguments
error(nargchk(1, 5, nargin));
func     = 'pdf2spm8';
version  = 4;

% basic input check and defaults
for i=1:nargin
    if i == 1 % check filename input
        if ~ischar(file)
            error('Filenames must be in quotes');
        else
            [path,filename,ext,ver] = fileparts(file);
        end
        % defaults
        stripbit  = 0;
        lock_chan = 'trigger';
        prefix    = 'megpdf';
        setup     = 'Magnes3600_setup.mat'; % change to suit your site: note 5
    end
    if i == 2 % check output string
        if ~ischar(varargin{1})
            error('Output prefix must be a string');
        else
            prefix = varargin{1};
        end
    end
    if i == 3 % check bit 12 preference
        if varargin{2} > 0
            stripbit = 1;
        else
            stripbit = 0;
        end
    end
    if i == 4 % check trig/resp locking
        if varargin{3} == 'resp'
            lock_chan = 'response';
        else
            lock_chan = 'trigger';
        end
    end
    if i == 5 % use custom channel template file
        if ~ischar(varargin{4})
            error('Channel template filename must be a string');
        else
            setup = varargin{4};
        end
    end
end

% create PDF4D object
pdf     = pdf4D(file);

% get some basic info from pdf header
hdr     = pdf.header;
if hdr.header_data.total_epochs == 1
    cnt = 1;
    disp(sprintf('File is continuous'));
else
    cnt = 0;
    disp(sprintf('# of epochs in file: %d', hdr.header_data.total_epochs));
end
epdur   = hdr.epoch_data{1,1}.epoch_duration;
trigger = get(pdf,'TRIGGER');
epstart = trigger.start_lat;
triglat = 0;
megi    = channel_index(pdf,'meg','name');
locki   = channel_index(pdf,upper(lock_chan),'name'); % for epoch definition purposes
trigi   = channel_index(pdf,'TRIGGER','name');
respi   = channel_index(pdf,'RESPONSE','name');
exti    = channel_index(pdf,'ext','name');
eegi    = channel_index(pdf,'eeg','name');
nepochs = hdr.header_data.total_epochs;
nmeg    = length(megi); % number of MEG channels only
neeg    = length(eegi);
n_ext   = length(exti);
allchni = [megi exti trigi respi]; %put eegi into brackets to get eeg
ntotal  = length(allchni); % total number of channels to include
disp(sprintf('# of MEG channels in file: %d', nmeg));
disp(sprintf('# of EEG channels in file: %d', neeg));
disp(sprintf('# of other channels in file: %d', length([exti trigi respi])));
    
% get data, trigger indices and event codes
ep          = 0;
events      = [];
codes       = [];
trigdata    = read_data_block(pdf,[],locki);
nsamp       = hdr.epoch_data{1}.pts_in_epoch;
if ~cnt    
    for ep = 1:nepochs
        events(ep) = lat2ind(pdf,ep,triglat);
        codes(ep)  = trigdata(events(ep));
    end
end
clear trigdata;
disp(sprintf('epoch duration: %.2f seconds', epdur));

% may want to strip 4096 from 4D trigger codes
if stripbit == 1
    bit12           = find(bitand(2^12, codes));
    codes(bit12)    = codes(bit12) - 2^12;
end

% write raw data to .dat files (may need to scale eeg as well)
if ~cnt
    megdata             = reshape(read_data_block(pdf,[],allchni),ntotal,nsamp,[]);
    megdata(1:nmeg,:,:) = megdata(1:nmeg,:,:)*1E15; % scale to fT
else
    megdata             = reshape(read_data_block(pdf,[],allchni),ntotal,nsamp);
    megdata(1:nmeg,:)   = megdata(1:nmeg,:)*1E15; % scale to fT
end
fid         = fopen([prefix '.dat'],'w');
fwrite(fid, megdata, 'float32');
fclose(fid);

% create D structure for spm8 .mat file
if ~cnt
    D.type                  = 'single';
else
    D.type                  = 'continuous';
end
D.fname                 = [prefix '.mat'];

% create D.data structure for spm8
D.data.fnamedat         = [prefix '.dat'];
D.data.datatype         = 'float32-le';
D.data.scale            = ones(ntotal,1,nepochs,'double');
D.data.y.fname          = D.data.fnamedat;
if ~cnt
    D.data.y.dim    = [ntotal nsamp nepochs];
else
    D.data.y.dim    = [ntotal nsamp];
end
D.data.y.dtype  = 16;
D.data.y.be     = 0;
D.data.y.offset = 0;
D.data.y.pos    = [1,1,1];
D.data.y.scl_slope = [];
D.data.y.scl_inter = [];
D.data.y.permission = 'rw';

% clear up some memory
clear megdata;

% Get MEG channel info from 4D file and put into D.channels struct array
[Cnames Cpos nchannels Rxy pos3D] = ctf4D(pdf, [prefix '_template']);
D.channels                      = [];

% MEG channels
for i=1:nmeg
    D.channels(1,i).bad         = 0;
    D.channels(1,i).label       = char(Cnames(i));
    D.channels(1,i).type        = 'MEG';
    D.channels(1,i).X_plot2D    = Cpos(1,i);
    D.channels(1,i).Y_plot2D    = Cpos(2,i);
    D.channels(1,i).units       = 'fT';
end

nchan = nmeg;

% Get EEG channel info from 4D file
%chn_names = channel_name(pdf, eegi);

% EEG channels
%for i=1:neeg
 %   D.channels(1,nchan+i).bad         = 0;
 %   D.channels(1,nchan+i).label       = char(chn_names(i));
%    D.channels(1,nchan+i).type        = 'EEG';
 %   D.channels(1,nchan+i).X_plot2D    = [];
%    D.channels(1,nchan+i).Y_plot2D    = [];
%    D.channels(1,nchan+i).units       = hdr.channel_data{1,eegi(i)}.yaxis_label;
%end

%nchan = nchan+neeg;

% external channels (NOTE: may have to manually reconfigure units
% afterwards, but read from header)
for i=1:n_ext
    D.channels(1,nchan+i).bad         = 0;
    D.channels(1,nchan+i).label       = char(Cnames(i));
    D.channels(1,nchan+i).type        = 'Other';
    D.channels(1,nchan+i).X_plot2D    = [];
    D.channels(1,nchan+i).Y_plot2D    = [];
    D.channels(1,nchan+i).units       = hdr.channel_data{1,exti(i)}.yaxis_label;
end

nchan = nchan+n_ext;

%Trigger channel
D.channels(1,nchan+1).bad         = 0;
D.channels(1,nchan+1).label       = 'TRIGGER';
D.channels(1,nchan+1).type        = 'Other';
D.channels(1,nchan+1).X_plot2D    = [];
D.channels(1,nchan+1).Y_plot2D    = [];
D.channels(1,nchan+1).units       = 'bits';

%Response channel
if ~isempty(respi)
    D.channels(1,nchan+2).bad         = 0;
    D.channels(1,nchan+2).label       = 'RESPONSE';
    D.channels(1,nchan+2).type        = 'Other';
    D.channels(1,nchan+2).X_plot2D    = [];
    D.channels(1,nchan+2).Y_plot2D    = [];
    D.channels(1,nchan+2).units       = 'bits';
end

% Get trial info from 4D and put into D.trials struct array
if ~cnt
    D.trials                            = [];
    for i=1:nepochs
        D.trials(1,i).label             = num2str(codes(i));
        D.trials(1,i).events.type       = 'STIM'; %change to resp for response locked
        D.trials(1,i).events.value      = codes(i);
        D.trials(1,i).events.duration   = 0; % might code trig dur here
        if i == 1
            D.trials(1,i).events.time   = epstart;
            D.trials(1,i).onset         = 0.0;
        else
            D.trials(1,i).events.time   = epstart+(epdur*double(i)); % time of trig in s
            D.trials(1,i).onset         = epdur*double(i); % time of epoch begining in s
        end
        D.trials(1,i).bad               = 0;
    end
else
    D.trials                            = [];
    D.trials.label                      = 'Undefined';
    D.trials.events                     = [];
    D.trials.onset                      = 0;
    D.trials.bad                        = 0;
    
end

% other fields in D structure
D.artifacts             = struct([]);
D.timeOnset             = double(-epstart);
D.path                  = '';
D.Nsamples              = double(nsamp);
D.Fsample               = double(get(pdf, 'dr')); %double(round(get(pdf, 'dr')));
D.other                 = struct([]);
D.transform.ID          = 'time';
disp(sprintf('sampling rate: %d Hz', D.Fsample));

% create D.headshape and fiducial files if files are available
% NOTE: 4D headframe coords are anterior = +x and right = -y; SPM8 is +y and +x,
% respectively, so there are going to be display issues unless
% coregistration occurs in SPM8
if exist(fullfile(path,'hs_file'),'file') == 2
    head                        = get(pdf,'headshape');
    D.fiducials.pnt             = zeros(length(head.point),3);
    D.fiducials.fid.pnt         = zeros(3, 3, 'double');
    D.fiducials.fid.pnt(1,1:3)  = double(head.index.nasion'*1000);
    D.fiducials.fid.pnt(2,1:3)  = double(head.index.lpa'*1000);
    D.fiducials.fid.pnt(3,1:3)  = double(head.index.rpa'*1000);
    D.fiducials.pnt             = double(head.point'*1000);
    D.fiducials.fid.label       = cell(3,1);
    D.fiducials.fid.label{1}    = 'nas';
    D.fiducials.fid.label{2}    = 'lpa';
    D.fiducials.fid.label{3}    = 'rpa';
else
    disp('No headshape file in 4D directory! Use Prepare to add manually');
end

% create D.sensors.meg structure with sensor locations and orientations
chn                         = channel_position(pdf, megi);
D.sensors.meg.pnt           = [];
D.sensors.meg.ori           = [];
D.sensors.meg.tra           = [];
D.sensors.meg.label         = cell(nmeg,1);
D.sensors.meg.unit          = 'mm';
if size(chn(1).position,2) == 1 % treat as magnetometers
    D.sensors.meg.pnt               = zeros(nmeg,3,'double');
    D.sensors.meg.ori               = zeros(nmeg,3,'double');
    disp(sprintf('Sensors are magnetometers'));
    for i=1:nmeg
        D.sensors.meg.pnt(i,:)      = double(chn(i).position(1:3)*1000);
        D.sensors.meg.ori(i,:)      = double(chn(i).direction(1:3)*1000);
        D.sensors.meg.label(i,1)    = Cnames(i);
    end
else                            % treat as gradiometers
    D.sensors.meg.pnt               = zeros(nmeg*2,3,'double');
    D.sensors.meg.ori               = zeros(nmeg*2,3,'double');
    disp(sprintf('Sensors are gradiometers'));
    for i=1:nmeg
        for j=1:2
            if j == 1
                D.sensors.meg.pnt(i,:)        = double(chn(i).position(1:3)*1000);
                D.sensors.meg.ori(i,:)        = double(chn(i).direction(1:3)*1000);
                D.sensors.meg.label(i,1)      = Cnames(i);
            else
                D.sensors.meg.pnt(i+nmeg,:)  = double(chn(i).position(4:6)*1000);
                D.sensors.meg.ori(i+nmeg,:)  = double(chn(i).direction(4:6)*1000);
            end
        end
    end
    % .tra field associates n grad coils with each other as single channel
    D.sensors.meg.tra               = zeros(nmeg,nmeg*2,'double');
    for i=1:nmeg
        D.sensors.meg.tra(i,i)          = 1;
        D.sensors.meg.tra(i,i+nmeg)    = 1;
    end
end

% save history of conversion to D structure
D.history                   = struct();
D.history.fun               = [];
D.history.args              = struct();
%D.history.args.ver          = version;
%D.history.args.dataset      = file;
%D.history.args.outfile      = prefix;

% NOTE: HISTORY NOT WORKING CORRECTLY YET! PUT ALL ARGS FROM VARARGIN INTO ARG
% STRUCT!

% reorder fields to conform to SPM8, just in case it matters
D = orderfields(D, {'type', 'Nsamples', 'Fsample',...
    'timeOnset','trials','channels','data','fname',...
    'path','sensors','fiducials','artifacts','transform',...
    'other','history'});

% save header info struct 'D' into matfile
save(D.fname,'D');
D = meeg(D); % call constructor