% method 1: fft on hilbert transform on band passed data

% filter and average the ssp
bp=filterer(ssp,'band',[40 50]);
bQ=mean(bp.Q);

% take the absolute value of the hilbert transform
h=abs(hilbert(bQ));

% do an fft
sr=1/(ssp.epdur/length(ssp.time));
N=length(bp.time);
nfft=2^nextpow2(N);
N_unique=ceil((nfft+1)/2);
f=(0:N_unique-1)*sr/nfft;
spect=abs(fft(h,nfft))/N;

% plot fft result
figure;plot(f(1:round(length(f)/2)),spect(1:round(length(f)/2)));

% method 2: fft on time-frequency transform data evoked power. No need for
% hilbert because morlet wavelet is roughly equivalent to it.

% get frequency indices that you want from tf struct
indices=[get_frequency_index(tf,40) get_frequency_index(tf,50)];

% get mean evoked power using your indices
mTF = mean(tf.epower(indices(1):indices(2),:));

% do fft
spect2=abs(fft(mTF,nfft))/N;