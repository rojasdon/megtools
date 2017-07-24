% example of using fastica algorithm to decompose a dataset

% see http://sccn.ucsd.edu/~arno/jsindexica.html for nice explanation of
% ica from Arno Delorme

% get a cnt file and epoch it
cnt=get4D('c,rfhp0.1Hz');

% delete bad channel first - ica can find bad channels, but sometimes it is
% easier to remove them first if you know them
cnt=deleter(cnt,[91 195]); 
epoched = epocher(cnt,'trigger',40,200,600,0);

% save and clear cnt from memory to make some room
save('0006_cnt.mat','cnt'); clear cnt;
save('0006_epoched.mat','epoched');

% reshape epoched input
[data nepochs nsamples] = deepoch(epoched.data);

% do ica
data = data*1e15;
[icasig, A, W] = fastica(data, 'lastEig', 20,'g','tanh');

% plot ica component weights
figure;
for i=1:20
    subplot(4,5,i);
    flatmap(A(:,i)',eps.cloc(:,1:3));
    title(num2str(i));
end

% remove a noise component from the data - you should view this before
% selecting component, because it may not be the same every time you
% repeat the example depending on input selections. We project
% component 14 back to sensors on next line because icasig components are
% unitless and cannot be directly subtracted from the data.
X = A(:,1)*icasig(1,:); 
Y = data-X; % subtract projected component from data

% put data or ica components back into epochs and plot averages - note that
% plots will be very similar, because eye movements were not time locked to
% stimuli, averaging was sufficient to eliminate them - try this with a
% dataset contaminated in the resulting average
newdat      = reepoch(Y, nepochs, nsamples);
neweps      = epoched;
neweps.data = newdat/1e15; % rescale back to T
neweps      = offset(filterer(neweps,4,'low',50));
epoched     = offset(filterer(epoched,4,'low',50));
figure; plot(neweps.time,squeeze(mean(neweps.data)));
figure; plot(neweps.time,squeeze(mean(epoched.data)));

% if you did this on spm8 data (see above) then after reepoching do this:
% data = permute(data,[2 3 1]);
% D(D.meegchannels,:,:)=newdata;
% D.save