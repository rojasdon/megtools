function [labels pos]=besa_readpos(filebase,varargin)
% Reads Cartesian coordinates for gradiometer MEG system from .pos BESA
% format

if isempty(findstr(filebase,'.'))
    filename = [filebase '.pos'];
else
    filename = filebase;
end
fp = fopen(filename,'r');

iseeg = 0;
if nargin>1
    if strcmpi(varargin{1},'eeg')
        iseeg = 1;
    end
end

% read text from file - this is hardcoded right now, should change
% for flexibility away from axial gradiometer system (i.e., electrodes or
% magnetometer systems, etc.)
if ~iseeg
    chans=textscan(fp,...
        'Channel%s %.4f %.4f %.4f %.4f %.4f %.4f %.4f %.4f %.4f %.4f %.4f %.4f');
else
    chans=textscan(fp,...
        'Channel%s %.4f %.4f %.4f');
end
nchans = length(chans{1});
fprintf('Reading %d channel positions from %s\n',nchans,filename);
labels = cell(nchans,1);

% strip extra quotes and colons from channel names
for ii=1:nchans
    [tmp rem]       = strtok(char(chans{1}(ii)),':');
    [tmp rem]       = strtok(tmp,'''');
    labels{ii}      = tmp; 
end

% format the rest
if ~iseeg
    pos = single([chans{2} chans{3} chans{4} chans{5} chans{6} chans{7} chans{8} chans{9} ...
           chans{10} chans{11} chans{12} chans{13}]);
else
    pos = single([chans{2} chans{3} chans{4}]);
end

fclose(fp);
