% meg_coherence
ft_defaults;
cnt=get4D('c,rfhp0.1Hz');
cnt=deleter(cnt,{'A248'});
ep=epocher(cnt,'trigger',200,800);
ep=offset(ep);
ep=meg_threshold_trials(ep,3000);
avg=offset(averager(ep));
cind=meg_channel_indices(ep,'multi','MEG');
ft=meg2ft(ep); clear cnt ep;

cfg_freq=[];
cfg_freq.method='mtmfft';
cfg_freq.foilim=[20 55];
cfg_freq.tapsmofrq=6;
cfg_freq.keeptrials='yes';
cfg_freq.channelcmb={'MEG' 'MEG'};
cfg_freq.output='powandcsd';

freq=ft_freqanalysis(cfg_freq,ft);

cfg_con=[];
cfg_con.method='wpli_debiased';
cfg_con.channelcmb={'all' 'all'};
wpli=ft_connectivityanalysis(cfg_con,freq);

wpli_gamma=wpli.wpli_debiasedspctrm(:,8);
nchan=length(cind);
m=ones(nchan,nchan);
M=zeros(size(m)); % adjacency matrix
uind=triu(m,1);
count=0;
for ii=1:nchan
    ind=find(uind(ii,:));
    len=length(ind);
    fprintf('%d %d\n',ii,len);
    M(ii,ind)=wpli_gamma(count+1:count+len);
    count=count+len;
end
[i j] = find(triu(m,1));
M(j + nchan*(i-1))= M(i + nchan*(j-1)); % mirror lower triangle to upper
M(1: size(M,1)+1:end)=0; % diagnonals should be zero but just in case
figure;imagesc(M);
axis xy;
thresh=.1;
ind=find(M>thresh);
W=zeros(size(M));
W(ind)=M(ind);
figure;meg_plot2d_connectivity(avg,W);