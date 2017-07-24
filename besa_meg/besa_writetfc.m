function fid = besa_writetfc(tfc)
xmin = min(tfc.Time);
xmax = max(tfc.Time);
xsize = length(tfc.Time);
xint = tfc.Time(2)-tfc.Time(1);
ymin = min(tfc.Frequency);
ymax = max(tfc.Frequency);
ysize = length(tfc.Frequency);
yint = tfc.Frequency(2)-tfc.Frequency(1);
fname=[tfc.ConditionName '.tfc'];
fid = fopen(fname,'w');
fprintf(fid,'VersionNumber=__v_5.1 ');
fprintf(fid,'DataType=%s ',tfc.DataType);
fprintf(fid,'ConditionName=%s ',tfc.ConditionName);
fprintf(fid,'NumberTrials=%d ',tfc.NumberOfTrials);
fprintf(fid,'NumberTimeSamples=%d ',xsize);
fprintf(fid,'TimeStartInMS=%.1f ',tfc.Time(1));
fprintf(fid,'IntervalInMS=%.1f ',xint);
fprintf(fid,'NumberFrequencies=%d ',ysize);
fprintf(fid,'FreqStartInHz=%.1f ',tfc.Frequency(1));
fprintf(fid,'FreqIntervalInHz=%.1f ',yint);
fprintf(fid,'NumberChannels=%d ',size(tfc.Data,1));
fprintf(fid,'StatisticsCorrection=%s ',tfc.StatisticsCorrection);
fprintf(fid,'EvokedSignalSubtraction=%s\n',tfc.EvokedSignalSubtraction);
for i=1:size(tfc.ChannelLabels,1)
    fprintf(fid,'%s ',tfc.ChannelLabels(i,:));
end
fprintf(fid,'\n');
for i=1:size(tfc.ChannelLabels,1)
    for j=1:size(tfc.Data,3)
        fprintf(fid,'%.4f\t',tfc.Data(i,:,j));
        fprintf(fid,'\n');
    end
    fprintf(fid,'\n');
end
status=fclose(fid);
