% function to identify bad signal channels by amplitude criteria
function badchans = findbadamp(data,thresh)
    % get data
    megchans = find(ft_chantype(data.label,'meg'));
    dat = data.trial{1}(megchans,:)*1e15;
    % compute stats
    mdat = mean(dat,2);
    mmdat = mean(mdat);
    smdat = std(mdat);
    badind = sort([find(mdat>mmdat+(thresh*smdat)); find(mdat<mmdat-(thresh*smdat))]);
    % return channel labels
    meglabels = data.label(megchans);
    badchans = meglabels(badind);
    for ii=1:length(badchans)
        badchans{ii} = ['-' badchans{ii}];
    end
end