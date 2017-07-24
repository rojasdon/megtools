clear;

ft_defaults;

id = '1035';
side = 'left';
file = [id '_' side '_ft.mat'];

load(file);

% do fix for non-meg channels and update to latest version of Fieldtrip
% format
toremove =[];
for ii=1:length(ft.label)
    if ~strcmp(ft.label{ii}(1),'A')
        toremove = [toremove ii];
    end
end
ft.label(toremove)=[];
ft.trialinfo=ones(length(ft.trial),1);
if length(ft.label) ~= size(ft.trial,1)
    cind=find(ft_chantype(ft.label,'meg'));
    bind=find(ismember(1:size(ft.trial{1},1),cind)==0);
    for ii=1:length(ft.trial)
        tmp = ft.trial{ii};
        tmp(bind,:)=[];
        ft.trial{ii}=tmp;
    end
end

% configure Fieldtrip viewer to show most likely artifact channels,
% skipping trial 1 due to filter settling
cfg_chan.channel = 'all';
cfg_chan.trials = 2:length(ft.trial);
ft = ft_selectdata(cfg_chan,ft);
cfg_view.continuous = 'no';
cfg_view.viewmode = 'butterfly';
ft_databrowser(cfg_view,ft);

