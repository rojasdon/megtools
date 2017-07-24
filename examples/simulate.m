% script to simulate a statistical test for a time frequency analysis

% do tft on real dataset
tf=tft('ssp.mat',[5 150],'waven',[3 12]);
cfg.label = 'la1';
cfg.baselinetype='percentage';
cfg.measure='nepower';
tfr1=meg2ft_tfr(cfg,tf);

% now create 3 groups of data, adding noise and offsets
N = 10;
offset1 = 1.5; % 50% increase
offset2 = 2.0; % 100% increase
toi = [get_time_index(tf,80) get_time_index(tf,110)];
foi = [get_frequency_index(tf,35) get_frequency_index(tf,45)];
dat = tf.nepower(foi(1):foi(2),toi(1):toi(2));
dat2 = dat*offset1;
dat3 = dat*offset2;
tfr2 = tfr1;
tfr3 = tfr1;
tfr2.powspctrm(1,foi(1):foi(2),toi(1):toi(2)) = dat2;
tfr3.powspctrm(1,foi(1):foi(2),toi(1):toi(2)) = dat3;
ymin = min(tf.nepower(:));
ymax = max(tf.nepower(:));
yrange = ymax-ymin;
gmean  = mean(tf.nepower(:));
gstd   = std(tf.nepower(:))/2;
for ii=1:N
    tmp = tfr1;
    noise = (gmean+gstd*randn(1,146,509));
    tmp.powspctrm = tmp.powspctrm+noise;
    g1{ii} = tmp;
end
for ii=1:N
    tmp = tfr2;
    noise = (gmean+gstd*randn(1,146,509));
    tmp.powspctrm = tmp.powspctrm+noise;
    g2{ii} = tmp;
end
for ii=1:N
    tmp = tfr3;
    noise = (gmean+gstd*randn(1,146,509));
    tmp.powspctrm = tmp.powspctrm+noise;
    g3{ii} = tmp;
end

ga1=ft_freqgrandaverage([],g1{:});
ga2=ft_freqgrandaverage([],g2{:});
ga3=ft_freqgrandaverage([],g3{:});

% make a figure to illustrate group results 
zmax                   = max(ga3.powspctrm(:));
zmin                   = min(ga3.powspctrm(:));
cfg_plot               = [];
cfg_plot.parameter     = 'powspctrm';
cfg_plot.zlim          = [zmin zmax];
h=figure('color','w');
subplot(3,1,1); ft_singleplotTFR(cfg_plot,ga1);
title('G1 Grand Average'); xlabel('Time (ms)'); ylabel('Frequency (Hz)');
subplot(3,1,2); ft_singleplotTFR(cfg_plot,ga2);
title('G2 Grand Average'); xlabel('Time (ms)'); ylabel('Frequency (Hz)');
subplot(3,1,3); ft_singleplotTFR(cfg_plot,ga3);
title('G3 Grand Average'); xlabel('Time (ms)'); ylabel('Frequency (Hz)');

cfg_stat = [];
%cfg_stat.clustercritval    = 5;
cfg_stat.computecritval   = 'yes';
%cfg_stat.clusterthreshold = 'nonparametric_individual';
cfg_stat.clusterthreshold = 'parametric';
cfg_stat.latency          = 'all';
cfg_stat.frequency        = 'all';
cfg_stat.avgovertime      = 'no';
cfg_stat.avgoverfreq      = 'no';
cfg_stat.statistic        = 'indepsamplesF';
cfg_stat.method           = 'montecarlo';
cfg_stat.correctm         = 'cluster';
cfg_stat.neighbours       = [];
cfg_stat.design           = [1:length(g1) 1:length(g2) 1:length(g3);
    ones(1,length(g1))...
    ones(1,length(g2))*2 ...
    ones(1,length(g3))*3];
cfg_stat.ivar = 2;
cfg_stat.tail = 1;
cfg_stat.contrastcoefs = [2/3 -1/3 -1/3;...
                          -1/3 2/3 -1/3;...
                          -1/3 -1/3 2/3];
cfg_stat.numrandomization = 100;

stat = ft_freqstatistics(cfg_stat, g1{:}, g2{:}, g3{:});

figure;
cfg_stat               = [];
cfg_stat.parameter     = 'stat';
ft_singleplotTFR(cfg_stat,stat);
title('F-statistic map'); xlabel('Time (ms)'); ylabel('Frequency (Hz)');
hold on;
if ~isempty(stat.posclusters)
    pos_pvals=[stat.posclusters(:).prob];
    pind = find(pos_pvals<stat.cfg.alpha);
    pos = squeeze(ismember(stat.posclusterslabelmat, pind));
    % over plot a line with the cluster corrected p < .05 result
    contour(stat.time,stat.freq,squeeze(pos),[1 1],'w-','linewidth',3);
end
if ~isempty(stat.negclusters)
    neg_pvals=[stat.negclusters(:).prob];
    nind = find(neg_pvals<stat.cfg.alpha);
    neg = squeeze(ismember(stat.negclusterslabelmat, nind));
    % over plot a line with the cluster corrected p < .05 result
    contour(stat.time,stat.freq,squeeze(neg),[1 1],'k-','linewidth',3);
end