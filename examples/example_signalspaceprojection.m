% signal space projection

load eyeblinks.mat
plot(avg.time,avg.data*1e15);
figure;meg_plot2d(avg,700);
f=avg.data(:,611); % spatial filter from data
nf=f/norm(f); % normalize by largest eigenvalue
rnf=repmat(nf,1,678); % make filter as long as data
projector=dot(avg.data,rnf); % create projector
plot(avg.time,projector);
sprojector=(f*projector)/norm(f); % scale projector to each channel
plot(avg.time,sprojector);
corr=avg.data-sprojector; % simple subtraction
plot(avg.time,corr);

% or, instead project back trial by trial
data = eps.data;
epcorr=data;
for i=1:300
    trial=squeeze(data(i,:,:));
    trialcorr=trial-sprojector;
    epcorr(i,:,:)=trialcorr;
end
plot(avg.time,squeeze(mean(epcorr)*1e15));