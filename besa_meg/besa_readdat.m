function [hdr dat] = besa_readdat(filebase,varargin)
% function to read a BESA raw dat/generic formatted dataset

% HISTORY: 9/17/13 - changed reshape order to nchan,nsamp,nepochs

scale = 1; % default is not to rescale data
if nargin == 3 && strcmpi(varargin{2},'scale')
    scale = varargin{3};
end

if isempty(strfind(filebase,'.'))
  hdrfile = [filebase '.generic'];
end
fp = fopen(hdrfile,'r');

if fp < 0
    error([hdrfile ' not found']);
end

%set up header structure: this will probably need more flexibility
ignore      = fscanf(fp,'BESA Generic Data ');
hdr.type    = 'BESA Generic Continuous Data';
hdr.nchan   = fscanf(fp, 'nChannels=%d\n');
hdr.sr      = fscanf(fp, 'sRate=%f\n');
hdr.nsamp   = fscanf(fp, 'nSamples=%d\n');
hdr.format  = fscanf(fp, 'format=%s\n');
hdr.file    = fscanf(fp, 'ile=%s\n'); %why 'file' doesn't work is a mystery
hdr.prestim = fscanf(fp, 'prestimulus=%f\n');
hdr.epochs  = fscanf(fp, 'epochs=%d ');
fclose(fp);

% force continuous data for now
if hdr.epochs > 1
    fprintf('Data are epoched into %d trials\n',hdr.epochs);
    continuous   = 0;
    samppertrial = hdr.nsamp/hdr.epochs;
else
    fprintf('Data are continuous\n');
    continuous = 1;
end

%read data
datfile = [filebase '.dat'];
fp = fopen(datfile);
if fp < 0
    error([datfile ' not found']);
end

% format of dat file
switch hdr.format
    case 'float'
        format = 'float32';
    case 'short'
        format = 'int16';
    case 'int'
        format = 'int32';
    case 'double'
        format = 'double';
end

% read dat file
dat = fread(fp,[1,Inf],format);
if continuous
    dat = reshape(dat,hdr.nchan,hdr.nsamp)/scale;
else
    dat = reshape(dat,hdr.nchan,samppertrial,hdr.epochs)/scale;
    dat = permute(dat,[3 1 2]); % reorder array
end
hdr.time = ((1:size(dat,ndims(dat)))/hdr.sr)-(hdr.prestim/1e3);
fclose(fp);