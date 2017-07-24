% Demo of matched filter
% R. Kozick, ELEC 470, Spring 1998

dt = .01;
t=-1:dt:1;
T = length(t);

% Generate pulse shapes

prect = ones(1,T);
ptri(1:(T-1)/2) = t(1:(T-1)/2)+1;
ptri((T-1)/2+1) = 1;
ptri((T+1)/2:T) = 1-t((T+1)/2:T);

figure(1)
subplot(211)
plot(t,prect)
title('Rectangle Pulse')
subplot(212)
plot(t,ptri)
title('Triangle Pulse')

% Change the noise amplitude with wstddev

wstddev = 10;
w = wstddev*randn(1,T);  % Gaussian noise

% Add noise to the pulses
pw1 = prect + w;
pw2 = ptri + w;

figure(2)
subplot(211)
plot(t,pw1)
axis([-1 1 -4*wstddev 4*wstddev])
title('Noisy Rectangle Pulse')
subplot(212)
plot(t,pw2)
axis([-1 1 -4*wstddev 4*wstddev])
title('Noisy Triangle Pulse')

% Filter the pulses 

rf1 = pw1(1);
rf2 = pw2(1);
mf2 = ptri(1)*pw2(1);
for k=2:T
  rf1(k) = rf1(k-1) + pw1(k);
  rf2(k) = rf2(k-1) + pw2(k);
  mf2(k) = mf2(k-1) + ptri(k)*pw2(k);
end

MaxSum = max(max([rf1; rf2; mf2]));
MinSum = min(min([rf1; rf2; mf2]));
figure(3)
subplot(311)
plot(t,rf1)
axis([-1 1 MinSum MaxSum])
title('Rect. Filter on Rect. Pulse')
subplot(312)
plot(t,rf2)
axis([-1 1 MinSum MaxSum])
title('Rect. Filter on Tri. Pulse')
subplot(313)
plot(t,mf2)
axis([-1 1 MinSum MaxSum])
title('Tri. Filter on Tri. Pulse')
