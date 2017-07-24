% script for CSU class demo

useclass=1;

% defaults
spm('defaults','eeg');

% alternative data path
if useclass
    % read in class data
    cnt = get4D('c,rfhp0.1Hz');
    [bad fftrat ff] = fft_detect_bad_chn(cnt,2);
    if ~isempty(bad); cnt = deleter(cnt,bad); end;
else
    % read good data
    load('CSU.mat');
end

% epoch, average, baseline, filter etc.
eps = epocher(cnt,'trigger',200,800);
avg = offset(averager(eps));
lp  = filterer(avg,4,'low',55);
bp  = filterer(avg,2,'band',20,30);

% do some plotting
figure('color','w');
subplot(3,1,1);plot(avg.time,avg.data*1e15); title('Unfiltered Average');
xlabel('Time (ms)'); ylabel('Amp (fT)');
subplot(3,1,2);plot(lp.time,lp.data*1e15); title('Low Passed Average');
xlabel('Time (ms)'); ylabel('Amp (fT)');
subplot(3,1,3);plot(bp.time,bp.data*1e15); title('High Passed Average');
xlabel('Time (ms)'); ylabel('Amp (fT)');

% plot topography
figure;meg_plot2d(avg,157);

% time frequency and plot
if useclass
    ind=meg_channel_indices(eps,'single','A33');
    tf=tft(eps,[10 70],ind);
else
    load('CSU_tf.mat');
end

figure('color','w');
subplot(2,1,1);meg_plotTFR(tf,'nepower'); title('Evoked Power');
xlabel('Time (ms)');
subplot(2,1,2);meg_plotTFR(tf,'mplf'); title('Phase Locking Factor');
xlabel('Time (ms)');

if useclass
    % convert average to spm
    D=meg2spm(eps,'CSU_spm8');

    % average using SPM
    S.D = D;
    S.robust = 0;
    S.review = 0;
    D = spm_eeg_average(S);

    % filter
    S.D = D;
    S.filter.type = 'butterworth';
    S.filter.band = 'band';
    S.filter.PHz  = [20 30];
    S.filter.parameter = [];
    D = spm_eeg_filter(S);

    % baseline
    S.D    = D;
    S.time = [-200 0];
    D      = spm_eeg_bc(S);   
end
