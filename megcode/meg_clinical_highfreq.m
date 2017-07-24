% meg high frequency processing ideas

cnthp=filterer(cnt,'high',80)
save cnt.mat cnt
clear cnt
megi=meg_channel_indices(cnthp,'multi','MEG')
meg_dataplot('data',cnthp)
rmsdat=cnthp.data(megi,:).^2;
rmsdat=sqrt(cnthp.data(megi,:).^2);
mrmsdat=mean(rmsdat);
plot(cnthp.time,mrmsdat)
get_time_index(cnt,5.7e4)
get_time_index(cnthp,5.7e4)
cnthp.time(ans)
cnthp.time(115967)/1000
get_time_index(cnthp,8.5e4)
cnthp.time(ans)/1000
get_time_index(cnthp,1.136e5)
cnthp.time(ans)/1000
meg_dataplot('data',cnthp)