% script to do template matching via correlation for eyeblink patterns

cfg_read.dataset = 'c,rfhp0.1Hz';
cfg_read.channel = {'MEG'};
ft = ft_preprocessing(cfg_read);
for i=1:length(ft.trial)
    ft.trial{i} = ft.trial{i}*1e15;
end

cfg_ica.method = 'fastica';
cfg_ica.fastica.lasteig = 25;
cfg_ica.fastica.approach = 'symm';
cfg_ica.channel = {'MEG'};
cfg_ica.trials  = 1:2:length(ft.trial);
ft_ica = ft_componentanalysis(cfg_ica,ft);

cfg_view.component = 1:25;
cfg_view.layout = '4D248.lay';
ft_topoplotIC(cfg_view,ft_ica);
