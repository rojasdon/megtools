% script to do grand average from besa tfc files

% defaults
filter = '*.tfc';
GA.ConditionName = '';
GA.DataType = 'ERDERS_POWER'; % 'ITPC'
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
dataArr = zeros(N,1,ntime,nfreq);
for ii=1:length(files)
    tmp                 = readBESAtfc(files(ii).name);
    dataArr(ii,1,:,:)   = tmp.Data;
end

% grand average
mdat    = squeeze(mean(dataArr,1))';
GA.Data = zeros(1,ntime,nfreq);

% save the grand averages for each channel to disk
for ii=1:nchan
    GA.ChannelLabels = hdr.ChannelLabels(ii,:);
    GA.ConditionName = strtrim(GA.ChannelLabels);
    GA.Data(1,:,:) = mdat(:,:)';
    GA.Time = hdr.Time;
    GA.Frequency = hdr.Frequency;
    besa_writetfc(GA);
end