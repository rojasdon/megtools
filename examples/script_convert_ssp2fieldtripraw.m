% script to combine ssp data into Fieldtrip raw structure

basename = '0813';
structname = 'Broca';
suffix = 'allfrequencies_ssp.mat';
sides = {'Left' 'Right'};


file=[basename '_Left_' structname '_' suffix];
left=load(file);
file=[basename '_Right_' structname '_' suffix];
right=load(file);


ft = [];
epdur = (ssp.time(end)+abs(ssp.time(1)))/1e3;
ft.fsample =  1/(epdur/length(ssp.time));
time=ssp.time; time(end+1)=time(end)+(epdur/length(ssp.time));
time=time/1e3;
for jj = 1:size(ssp.Q,1)
    trial = [left.Q(jj,:); right.Q(jj,:)];
    trial = [trial trial(:,end)];
    ft.trial{jj} = trial;
    ft.time{jj}  = time;
end

ft.label={'LBroca';'RBroca'};
ft.cfg.ntrials = size(ssp.Q,1);
ft.cfg.triallength = epdur;
ft.cfg.fsample = ft.fsample;
ft.cfg.nsignal = 2;