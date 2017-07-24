function besa_writedat(MEG,filebase)
% function to write a BESA 5.3 compatible raw binary data file and generic
% header

% limit to continuous for now
if ~strcmp(MEG.type,'cnt')
    error('Only continuous data conversion to BESA is currently supported!');
end

megscale = 1e15; % scale data to fT
extscale = 1e16;  % scale to mV
eegscale = 1e3; % scale to mV

% get info from MEG
mindex  = meg_channel_indices(MEG,'multi','MEG');
eindex  = meg_channel_indices(MEG,'multi','EEG');
extind  = meg_channel_indices(MEG,'multi','EXT');
cind    = [mindex eindex extind]; %eindex];
nchan   = length(cind);
nsamp   = size(MEG.data,2);

% Write a generic header
fp = fopen([filebase '.generic'],'w');
fprintf(fp, 'BESA Generic Data\n');
fprintf(fp, 'nChannels=%d\n', nchan);
fprintf(fp, 'sRate=%f\n', MEG.sr);
fprintf(fp, 'nSamples=%d\n', nsamp);
fprintf(fp, 'format=%s\n', 'float');
fprintf(fp, 'file=%s\n',[filebase '.dat']);
fprintf(fp, 'prestimulus=%f\n',MEG.pstim);
fprintf(fp, 'epochs=%d',1);
fclose(fp);

% apply scaling if requested
MEG.data(mindex,:) = MEG.data(mindex,:)*megscale;
MEG.data(extind,:) = MEG.data(extind,:)*extscale;
MEG.data(eindex,:) = MEG.data(eindex,:)*eegscale;

% Write data to file
fp = fopen([filebase '.dat'],'w');
fwrite(fp, MEG.data(cind,:), 'float32');

fclose(fp);
