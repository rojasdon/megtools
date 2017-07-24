% function to identify bad signal channels by amplitude criteria
function badsigs = findbad(data,thresh)
    % compute stats
    mdat = mean(data,2);
    mmdat = mean(mdat);
    smdat = std(mdat);
    badsigs = sort([find(mdat>mmdat+(thresh*smdat)); find(mdat<mmdat-(thresh*smdat))]);
end