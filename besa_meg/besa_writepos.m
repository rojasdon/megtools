function besa_writepos(MEG,filebase)
% Writes Cartesian coordinates for gradiometer MEG system to .pos BESA
% format. EEG channels are also written, if any are found, with generic
% locations based on template

% defaults
switchxy = true; % besa's coordinate system's x and y are switched from 4D

% template
templatedir = fileparts(which('haxby'));

% scaling
scale = 1e3;
eind  = meg_channel_indices(MEG,'multi','MEG');

if isempty(findstr(filebase,'.'))
  filename = [filebase '.pos'];
end
fp = fopen(filename,'w');

% get location data
ind    = meg_channel_indices(MEG,'multi','MEG');
eind   = meg_channel_indices(MEG,'multi','EEG');
tmploc = [MEG.cloc(ind,:)*scale MEG.cori(ind,:)];
labels = {MEG.chn(ind).label};

if switchxy
    locs      = zeros(size(tmploc));
    % lower coil pos
    locs(:,1) = -tmploc(:,2);
    locs(:,2) = tmploc(:,1);
    locs(:,3) = tmploc(:,3);
    % upper coil pos
    locs(:,4) = -tmploc(:,5);
    locs(:,5) = tmploc(:,4);
    locs(:,6) = tmploc(:,6);
    % lower orientation
    locs(:,7) = -tmploc(:,8);
    locs(:,8) = tmploc(:,7);
    locs(:,9) = tmploc(:,9);
    % upper orientation
    locs(:,10) = -tmploc(:,11);
    locs(:,11) = tmploc(:,10);
    locs(:,12) = tmploc(:,12);
else
    locs      = tmploc;
end

nchannels = length(labels);
for ii=1:nchannels
    fprintf(fp,...
        'Channel ''%s'':\t%.4f\t%.4f\t%.4f\t%.4f\t%.4f\t%.4f\t%.4f\t%.4f\t%.4f\t%.4f\t%.4f\t%.4f\n',...
        labels{ii},locs(ii,:));
end

if ~isempty(eind)
    neeg = length(eind)-3; % don't write HEOG and VEOG or ECG
    % get default positions from template
    template = fullfile(templatedir,'clinicalMEG1020.pos');
    [labels locs] = besa_readpos(template,'eeg');
    for ii=1:neeg
        fprintf(fp,...
            'Channel ''%s'':\t%.4f\t%.4f\t%.4f\n',...
            labels{ii},locs(ii,:));
    end
end

fclose(fp);
return;