% script to use FieldTrip to do ICA

redo    = 'no';
file 	= 'c,rfhp0.1Hz';
epwin   = [200 800];
dn_freq = 55;

if strcmp(redo,'no')
    cnt  = get4D(file,'reference','yes');
end

[bad fftrat ff] = fft_detect_bad_chn(cnt,2);
if ~isempty(bad)
    cnt  = deleter(cnt,bad);
end

% convert and denoise using highpassed ref channels so that denoising
% operation is gentle and does not compromise lower frequency signal
% strength
ft   = meg2ft(cnt);
cnt_orig = cnt;
refchans            = ft_channelselection('MEGREF',ft.label);
cfg_ref             = [];
cfg_ref.channel     = refchans;
cfg_ref.hpfreq      = dn_freq;
cfg_ref.hpfiltord   = 2;
cfg_ref.hpfilter    = 'yes';
ft_ref              = ft_preprocessing(cfg_ref,ft);
cfg_denoise         = [];
ft                  = ft_denoise_pca(cfg_denoise,ft,ft_ref);

% view data
%cfg_view                   = [];
%cfg_view.continuous        = 'yes';
%cfg_view.viewmode          = 'butterfly';
%cfg_view.selectmode        = 'eval';
%cfg_view.selcfg.layout     = '4D248.lay';
%cfg_view.selfun            = 'browse_topoplotER';
%cfg_view.channel           = ft_channelselection('MEG',ft.label);
%ft_databrowser(cfg_view,ft);

% do ica in Fieldtrip
cfg_ica             = [];
cfg_ica.channel     = 'MEG';
cfg_ica.method  	= 'runica';
cfg_ica.runica.pca  = 25;
ic_data             = ft_componentanalysis(cfg_ica,ft);

% plot component topography
cfg_comp             = [];
cfg_comp.component   = 1:25;
cfg_comp.layout      = '4D248.lay';
cfg_comp.comment     = 'no';
figure;ft_topoplotIC(cfg_comp,ic_data);

% plot timecourses of compoenents
%cfg_vcomp.continuous        = 'yes';
%cfg_vcomp.viewmode          = 'component';
%cfg_vcomp.layout            = '4D248.lay';
%ft_databrowser(cfg_vcomp,ic_data);

% prompt at command line in MATLAB for components to remove
fprintf('Enter component numbers to remove (e.g., [1:4, 10])\n');
noise = input('Which ones to remove? ');
cfg_rem             = [];
cfg_rem.component   = noise;
ft_rej              = ft_rejectcomponent(cfg_rem,ic_data);

% view results
ft_databrowser(cfg_view,ft_rej);

% convert back, epoch and average to view final
ft_rej.hdr  = ft.hdr;
cnt         = ft2meg(ft_rej);
eps         = epocher(cnt,'trigger',epwin(1),epwin(2));
avg         = offset(averager(eps));
figure;plot(avg.time,avg.data);
