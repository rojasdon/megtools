% complex demodulation

load('ssp.mat');
t=ssp.time;
ntrials=size(ssp.Q,1);
foi=5:150;
sr=1/(ssp.epdur/length(ssp.time));
%[B,A]=butter(2,4/(sr/2),'low');
b = gaussfiltcoef(sr,4);
C = zeros(ntrials,length(foi),length(t));
start = get_time_index(ssp,0);
pads = round(length(t)/4);
nt   = (1:length(t)+(2*pads))*(1/sr);
method=2;
tic;
switch method
    case 1 % separate filtering of real and imaginary
        for ii=1:ntrials
            dat = [zeros(1,pads) ssp.Q(ii,:) zeros(1,pads)];
            fprintf('Trial %d\n',ii);
            for jj=1:length(foi)
                f  = foi(jj);
                sw = sin(2*pi*f*nt);
                cw = cos(2*pi*f*nt);
                real_s=dat.*sw;
                imag_s=dat.*cw;
                f_real_s=filtfilt(b,1,double(real_s));
                f_imag_s=filtfilt(b,1,double(imag_s));
                %f_real_s=filtfilt(double(B),double(A),double(real_s));
                %f_imag_s=filtfilt(double(B),double(A),double(imag_s));
                f_real_s=f_real_s(pads+1:pads+length(t));
                f_imag_s=f_imag_s(pads+1:pads+length(t));
                C(ii,jj,:)=complex(f_real_s,f_imag_s);
            end
        end
    case 2 % filter real and imaginary together
        for ii=1:ntrials
            dat = [zeros(1,pads) ssp.Q(ii,:) zeros(1,pads)];
            fprintf('Trial %d\n',ii);
            for jj=1:length(foi)
                %f  = foi(jj);
                sw = sin(2*pi*foi(jj)*nt);
                cw = cos(2*pi*foi(jj)*nt);
                %real_s=dat.*sw;
                %imag_s=dat.*cw;
                %complex_s = complex(dat.*sw,dat.*cw);
                f_complex = filtfilt(b,1,complex(dat.*sw,dat.*cw));
                %f_complex = f_complex(pads+1:pads+length(t));
                C(ii,jj,:) = f_complex(pads+1:pads+length(t));
            end
        end
end
        
te=toc;
fprintf('Time: %.2f seconds\n',te);
tpower   = squeeze(mean(abs(C),1));
epower   = squeeze(abs(mean(C,1)));
ipower   = tpower-epower;
pnorm    = C./abs(C);
mplf     = squeeze(abs(mean(pnorm)));
baseTP = repmat(mean(tpower(:,1:start),2),1,length(t));
baseEP = repmat(mean(epower(:,1:start),2),1,length(t));
baseIP = repmat(mean(ipower(:,1:start),2),1,length(t));
ntpower  = (tpower-baseTP)./baseTP;
nepower  = (epower-baseEP)./baseEP;
nipower  = (ipower-baseIP)./baseIP;
figure;imagesc(t,foi,nepower); axis xy; title('nepower');
figure;imagesc(t,foi,ntpower); axis xy; title('ntpower');
figure;imagesc(t,foi,nipower); axis xy; title('nipower');
figure;imagesc(t,foi,mplf); axis xy; title('mplf');