% script to do grand average from besa tfc files

% defaults
filter = '*RIndex_triggers_Right.tfc';
average_channels = true;
GA.ConditionName = '';
GA.DataType = 'freq';
GA.NumberOfTrials = 1;
GA.StatisticsCorrection='off';
GA.EvokedSignalSubtraction='off';

% get files to average
files = dir(filter);
N     = length(files);

% read first file to get info on channels, time and frequency bins
hdr   = readBESAtfc(files(1).name);
nchan = size(hdr.Data,1);
nfreq = length(hdr.Frequency);
ntime = length(hdr.Time);

% read data into array
dataArr = zeros(N,nchan,ntime,nfreq);
for ii=1:length(files)
    tmp                 = readBESAtfc(files(ii).name);
    dataArr(ii,:,:,:)   = tmp.Data;
end

% grand average
mdat    = squeeze(mean(dataArr,1));
GA.Data = zeros(1,ntime,nfreq);

% save the grand averages for each channel to disk
for ii=1:nchan
    GA.ChannelLabels = hdr.ChannelLabels(ii,:);
    GA.ConditionName = strtrim(GA.ChannelLabels);
    GA.Data(1,:,:) = mdat(ii,:,:);
    GA.Time = hdr.Time;
    GA.Frequency = hdr.Frequency;
    besa_writetfc(GA);
end

% write grand average across channels
if average_channels
    mdat = squeeze(mean(squeeze(mean(dataArr,1)),1))';
    GA.Data(1,:,:)=mdat';
    GA.ChannelLabels = 'Grand_Average';
    GA.ConditionName = 'Grand_Average';
    besa_writetfc(GA);
end