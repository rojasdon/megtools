function [types labels] = besa_readela(filename)
% function to read in BESA 5.3 ela file containing labels and channel
% types, returning channel 

if isempty(strfind(filename,'.'))
    filename = [filename '.ela'];
end

% open file
fp = fopen(filename,'r');

% scan into cell struct: surf{1} = names, surf{2} = x, surf{3} = y, surf{4}
% = z coordinate, first 3 rows of each are fiducials
chans=textscan(fp,'%s %s');
fprintf('There are %d channel labels defined\n',length(chans{1}));

types  = chans{1};
labels = chans{2};

fclose(fp);