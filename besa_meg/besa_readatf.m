function [wts chn] = besa_readatf(file)
% function to read a BESA .atf artifact coefficient file

% get number of weights in file
% seems to be an extra CR/LF in atf files, also subtract 2 lines for header
if exist(file,'file')
    nlines  = countfilelines(file); 
    nlines = nlines - 3; 
else
    error([file ' not found']);
end

fp = fopen(file,'r');

% read atf file
nchan   = fscanf(fp,'Nchan=%d\n'); % nchannels
wts     = zeros(nchan,nlines);
tmp     = textscan(fgetl(fp),'%s'); % channel names
chn     = tmp{1};
for ii=1:nlines
    tmp     = textscan(fgetl(fp),'%s');
    wts(:,ii)= str2num(char(tmp{1}(3:end))); % weights
end
fclose(fp);

end