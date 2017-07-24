% batch to convert BESA 2 source montage exports into left/right ssp format
% mat files for input to TFT routines.

% input: *.generic/*.dat pair outputs from BESA
% output: *_Qt.mat files, 1 per source

files  = dir('*.generic');
nfiles = length(files);

for i=1:nfiles
    % read *.dat file and separate 2 channels
    file = char(files(i).name);
    dat  = besa_readdat(file);
    chn1 = dat;
    chn1.Data = squeeze(chn1.Data(1,:,:));
    chn1.nChannels = 1;
    chn2 = dat;
    chn2.Data = squeeze(chn2.Data(2,:,:));
    chn2.nChannels = 1;
    
    % convert to ssp and save
    [pth nam ext] = fileparts(file);
    ssp  = dat2ssp(chn1);
    save([nam '_L_Qt.mat'], 'ssp');
    ssp  = dat2ssp(chn2);
    save([nam '_R_Qt.mat'], 'ssp');
end