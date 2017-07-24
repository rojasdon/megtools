function pdf2 = put4D(infile, outfile, MEG)
% PURPOSE: function to copy 4D raw data file and replace data in the
%          copy with your own input data. This function essentially can plug data
%          you've already processed back into the 4D software.
% AUTHOR:  Don Rojas, Ph.D.
% INPUT:   Required: infile = valid filename of raw 4D file
%                    outfile = filename for copied file
%                    MEG epoch structure - see get4D.m
% OUTPUT:  pdf object for copied file
% EXAMPLE: pdf = put4D('e,rfhp0.1Hz','mycopy',MEG);
% NOTES:   1. this might be used for replacing original data with ica noise reduced
%          data. You probably don't want to delete bad channels if original infile
%          still has them, but may have to remove them . So, either delete bad channels prior 
%          to import and correction, or save the bad channels for later because any 
%          difference in channel numbers between infile and MEG will lead
%          to errors. You can always reinsert a bad channel or dummy
%          channel for deletion after before using this function, then
%          delete it again in the MSI software.
%          2. Same idea as note 1, but # of samples/epochs, etc. must also
%          be identical!
%          3. The file you are putting back into the 4D database must
%          already exist (i.e., a version of it with the same name must be
%          present in the database already) - you are simply replacing the
%          data inside of that file with put4D
% SEE ALSO: GET4D, PDF4D

% HISTORY: 11/30/10 - first working version
%          05/20/11 - allows continuous and average types as well as epochs
%          10/03/11 - compatible with new get4D.m
%          04/26/12 - bugfix for EEG/EXT channel ordering
%          06/08/12 - fix for custom EEG names present as per get4D 5/9/12
%                     feature addition
%          10/23/12 - bugfix for UACurrent channel, which is upper and
%                     lower case string in pdf4D calls, also changed calls to
%                     strcmp to strcmpi to avoid missing certain channels

% check for 4D object on path
if isempty(which('pdf4D'))
    error('pdf4D object not found on path');
end

% make a copy of input file named to desired output filename
copyfile(infile,outfile);
pdf1 = pdf4D(infile);
pdf2 = pdf4D(outfile);

% get info on original file
hdr    = get(pdf1,'header');
nchans = length(hdr.channel_data);
labels = channel_name(pdf1,1:nchans);

% get channel indices for all channel types contained in MEG
types = lower(unique({MEG.chn.type}));
chi   = [];
for i=1:length(types)
    if strcmpi(types{i},'uacurrent')
        types{i} = 'UACurrent';
    end
    chi  = [chi channel_index(pdf1,char(types{i}),'name')];
end
chi = sort(chi);
if find(strcmpi('EEG',types))
    eegi = channel_index(pdf1,'EEG','name');
    for ii = 1:length(eegi)
        labels{eegi(ii)} = hdr.channel_data{eegi(ii)}.chan_label;
    end
end

% read in original data block - all channels, all data
fprintf('Reading in original data block...\n');
data = read_data_block(pdf1,[]);
fprintf('done\n');

% reshape MEG.data into original array shape - see get4D.m
switch MEG.type
    case {'epochs'}
        sdat = shiftdim(MEG.data,1);
        rdat = reshape(sdat,length(chi),[]);
    case {'cnt' 'avg'}
        sdat = MEG.data;
        rdat = sdat;
end
clear sdat;

% check dimensions of two arrays
s1 = size(data);
s2 = size(rdat);
if s1(2) ~= s2(2)
    error('Input replacement data size does not match original data!');
end

% loop to reorder data to original array order, replacing data along the
% way with the new MEG.data
meglabels = {MEG.chn.label};
for ii=1:length(chi)
    cindex = find(strcmpi(meglabels{ii},labels));
    fprintf('%d %d: Replacing channel %s data\n',ii, cindex, char(labels{ii}));
    data(cindex,:) = rdat(ii,:);
end

% write data back
fprintf('\nWriting new data block...');
write_data_block(pdf2,data);
fprintf('done\n');

end