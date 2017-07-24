% preprocessing script for MEG data

clear all;
%set(0,'DefaultFigureRenderer','zbuffer'); % for better graphics in FT
times_to_plot = [-100 80 100 120 140 160 180 200 220 240];

meg_id      = '1303';
bad         = {};  % {'A229' 'A156'}; % channels to always delete
prompt      = 'Components to remove?';
isfastica   = 1;
qa_suffix   = 'qa.jpg';
cn          = {};
for ii=1:25
    cn{ii}=num2str(ii);
end
cn{26}      = 'None';

% read 4D file
cnt = get4D('c,rfhp0.1Hz');
orig = cnt;                

% delete bad channels, keep indices for later
[morebad fftrat f]  = fft_detect_bad_chn(cnt,3);
bad                 = unique([bad morebad]);
bad_ind = [];
fp = fopen([meg_id '_bad_channels.txt'],'w');
for ii=1:length(bad)
    bad_ind = [bad_ind meg_channel_indices(cnt,'labels',bad(ii))];
    fprintf(fp,'%s\n',bad{ii});
end
fclose(fp);
if ~isempty(bad)
    cnt = deleter(cnt,bad); % delete bad chans before ICA
end

% get MEG channel list
chi = meg_channel_indices(cnt,'multi','MEG');

% get data
data = cnt.data(chi,:);

% do ica on MEG data, scaling up first to fT from T
nchan       = length(chi);
data        = data * 1e15;
npoints     = size(data,2);
rowmeans    = mean(data,2);
sphere      = eye(nchan);
[icasig, U, W] = fastica(data, 'approach', 'symm', 'LastEig', 30, 'g','pow3');
activations = W * sphere * (data-repmat(rowmeans,1,npoints)); % ica waveforms for plotting

% plot component topography and waveforms of components
h=figure('name','ICA topography');
for ii=1:25
    subplot(5,5,ii);
    flatmap(U(:,ii)',cnt.cloc(chi,1:3));
    title(num2str(ii));
end
f=figure('name','ICA waveforms');
time = round(5 * cnt.sr):round(5 * cnt.sr) * 2;
for line = 1:25
    plot(time,activations(line,time(1):time(end)) + line);  
    hold on;
end
[noise,ok] = listdlg('liststring',cn,'promptstring',prompt);
print(h, '-djpeg', [meg_id '_ica_topo_' qa_suffix]); close(h);
print(f, '-djpeg', [meg_id '_ica_wave_' qa_suffix]); close(f);
save([meg_id '_icdata.mat'],'icasig','U','W');

% rescale and correct data
if noise ~= 26
    tokeep     = setdiff(1:size(W,1),noise);
    tmpdata    = (W(tokeep,:) * sphere) * data;
    newdata    = U(:,tokeep) * tmpdata;
    cnt.data(chi,:) = newdata / 1e15; % rescale back to T
end

% plot waveform and topography for reference
h = figure('name','Waveform and Topography');
ep = epocher(cnt,'trigger',200,800);
ep = offset(ep);
avg = averager(ep,'threshold',2500);
subplot(3,5,1:5);plot(avg.time,avg.data(chi,:)); axis tight;
for ii=1:10
    subplot(3,5,5+ii);
    meg_plot2d(avg,times_to_plot(ii),'labels','off');
    title(num2str(times_to_plot(ii)));
end
print(h, '-djpeg', [meg_id '_wave_topo_' qa_suffix]); close(h);

% save a corrected copy of 4D format data
for ii=1:length(chi)
    label = cnt.chn(ii).label;
    ori   = meg_channel_indices(orig,'labels',{label});
    orig.data(ori,:) = cnt.data(chi(ii),:);
end
put4D('c,rfhp0.1Hz','c,rfhp0.1Hz,ica',orig);