% example of creating/using triggers from emg and eeg channels
cnt = deleter(get4D('c,rfhp0.1Hz'),[63 117 195]);
[accel fchn tresh] = process_auxiliary(cnt.aux(6,:),10,cnt.sr,3000);
cnt.events = create_events(accel,{'EEG'});
cnt.aux(6,:) = accel;
eps = offset(epocher(cnt,'EEG',2500,2500),[-2500 -2000]);
avg = averager(eps,3500);
plot(avg.time,avg.data*1e15); axis tight;