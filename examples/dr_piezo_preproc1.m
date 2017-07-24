% Script to do the following processes:
% 1. Read 4D data
% 2. Detect bad channels automatically and delete them
% 3. Convert data to FieldTrip
% 4. Noise reduction
% 5. Save result

% get file
file 	= 'c,rfhp0.1Hz';
bad     = [];
cnt     = get4D(file,'reference','yes');

% save original
save orig.mat cnt;

% detect and delete bad channels
[bad fftrat ff] = fft_detect_bad_chn(cnt,2);

if ~isempty(bad)
    cnt  = deleter(cnt,bad);
end

% convert to FieldTrip and denoise using pca and ref channels
ft   = meg2ft(cnt);
ft   = ft_denoise_pca([],ft);

% save FieldTrip data for later
fprintf('\nSaving data...');
save ft_cont.mat ft;
fprintf('done.\n');
