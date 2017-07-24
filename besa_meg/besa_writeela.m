function besa_writeela(MEG,filebase)
% Writes BESA label file

if isempty(findstr(filebase,'.'))
  filename = [filebase '.ela'];
end
fp = fopen(filename,'w');

% get label information
megind    = meg_channel_indices(MEG,'multi','MEG');
extind    = meg_channel_indices(MEG,'multi','EXT');
eegind    = meg_channel_indices(MEG,'multi','EEG');

cind    = [megind eegind extind];
labels = {MEG.chn(cind).label};
types  = {MEG.chn(cind).type};

% replace label info for types not recognized by BESA
types = regexprep(types,{'EXT' 'REFERENCE' 'TRIGGER' 'RESPONSE' 'UACURRENT'},...
        'PGR');

% write data
nchannels = length(labels);
for ii=1:nchannels
    fprintf(fp,'%s\t%s\n',types{ii},labels{ii});
end

fclose(fp);
return;