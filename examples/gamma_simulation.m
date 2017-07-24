% simulated evoked auditory gamma-band response

ntrials = 100;
sr      = 678;
time    = 0:1/sr:1;
nsamp   = length(time);
t0      = 0:1/sr:.1;
pre     = zeros(1,136);
Hz      = 40;
ph      = rand(1,9)*101+20;
win     = hann(length(t0))';
AM      = 1*cos(2*pi*Hz*t0);
wAM     = win.*AM;

%plot(t0,wAM);

%pjitter = rand(1,ntrials); pjitter = round((pjitter - .5)*10);
pjitter = zeros(1,ntrials);

% create trial matrix with phase realistic phase jitter
trials  = zeros(ntrials,nsamp);
gamwin  = 340:340+length(t0)-1;
for i=1:ntrials
    trials(i,gamwin+pjitter(i)) = wAM;
end

% add white noise
noisepercent = .8;
for i=1:ntrials
    trials(i,:) = trials(i,:)+noisepercent*rand(1,nsamp);
end

% do Morlet
waven   = 8;
low     = 5;
high    = 60;
Cm      = zeros(high-low+1,ntrials,nsamp*2);
Pm      = zeros(high-low+1,ntrials,nsamp);
Tm      = Pm;
plf     = Pm;
speriod = 1/sr;
for df = low:1:high
    dfi     = df - low + 1;
    s       = 2*pi*df/sr;
    sigf    = df/waven; 
    sigt    = 1/(2*pi*sigf);
    lw      = round((waven/df)/speriod);
    lw2     = round((waven/df)/(2*speriod)); 
    Aw      = 2/(sr*sigt*sqrt(2*pi)); 
    w       = 1:lw;
    for t = 1:lw
        w(t) = Aw*exp(-(((t-(lw/2))/sr)^2)/(2*sigt^2))*exp(s*t*j);% wavelet vector
    end
    %new beginning and endpoints after convolution
    bp = round(lw/2);ep=nsamp-1+round(lw/2);
    for eps = 1:ntrials
        Cm(dfi,eps,1:nsamp+lw-1) = conv(w,(trials(eps,:)));
        Pm(dfi,eps,1:nsamp)      = Cm(dfi,eps,bp:ep)./abs(Cm(dfi,eps,bp:ep));
        Tm(dfi,eps,1:nsamp)      = Cm(dfi,eps,bp:ep);
    end
    tf.plf(dfi,:) = abs(mean(Pm(dfi,:,:)));
end

tf.time   = time;
tf.freq   = low:1:high;
tf.tpower = squeeze(mean(abs(Tm),2)); % this would be evoked plus induced
tf.epower = squeeze(abs(mean(Tm,2))); % this would be the evoked only
tf.ipower = tpower-epower;            % this is the induced power

mask = ones(length(low:high),nsamp);
for df = low:high
    dfi      = df - low + 1;
    wlen     = (1/df * waven)/2; % 1/2 window length in seconds
    slen     = round(wlen/speriod);     % in samples
    if slen > nsamp
        mask(dfi,1:nsamp) = 0;
    else
        mask(dfi,1:slen)            = 0;
        mask(dfi,end-(slen-1):end)  = 0;
    end
end

tf.mask = mask;
