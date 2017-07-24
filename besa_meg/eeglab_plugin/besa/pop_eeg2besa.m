function com = pop_besa2eeg(EEG,filename);
%need to add trigger info
% Get name for file(s) to write
com = '';
if nargin < 2
    [filename, filepath] = uiputfile('*.dat;*.DAT', 'Output BESA generic file');
    drawnow;
    if filename == 0
        return;
    end
end

[pth,nam,ext,ver] = fileparts(fullfile(filepath,filename));
% Create structure to pass to eeg2besa()
dat.Type        = 'BESA Generic Data';
dat.nChannels   = EEG.nbchan;
dat.sRate       = EEG.srate;

if isempty(EEG.epoch)
    dat.nSamples    = EEG.pnts;
else
    dat.nSamples    = EEG.pnts*length(EEG.epoch);
end

dat.format      = 'float';
dat.file        = [nam ext];
dat.prestim     = abs(EEG.xmin*1000);
dat.epochs      = length(EEG.epoch);
dat.Data        = [];

%recondition data array for BESA conformity
sz = size(EEG.data);
if length(sz) == 2
    dat.Data = EEG.data; %transpose(EEG.data);
elseif length(sz) == 3
    dat.Data = reshape(EEG.data, [sz(1), sz(2)*sz(3)]);
else
    display('Error reshaping EEG.data!');
    return;
end

besa_writedat(filename, dat);
com = sprintf('pop_eeg2besa();');
return;