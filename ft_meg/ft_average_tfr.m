function tfr = ft_average_tfr(tfr,channels)
% function to average channel group for Fieldtrip time frequency data

% check input
tfr = ft_checkdata(tfr,'dimord','chan_freq_time','feedback','yes');

% find channel indices
ind = [];
for ii=1:length(channels)
    tmp = find(ismember(tfr.label,channels{ii}));
    ind = [ind tmp];
end

% average requested channels together
if length(channels) > 1
    avg = mean(tfr.powspctrm(ind,:,:));
    tfr.powspctrm = avg;
    tfr.label = {'avg_tfr'};
end