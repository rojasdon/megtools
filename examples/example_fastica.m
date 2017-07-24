% need wrapper function to calc ica and return MEG ica structure
% need to write memory mapping into this to do chunks of data that are
% manageable - see spm_eeg_filter.m line 149.

% see http://sccn.ucsd.edu/~arno/jsindexica.html for nice explanation of
% ica from Arno Delorme

% do ica
[icasig, A, W] = fastica(cnt.data*1E15, 'lastEig', 100);

% plot ica component weights
figure;
num=size(A,2);
for i=1:5
    subplot(5,4,i);
    flatmap(A(:,i+39)',del.cloc(:,1:3));
    %flatmap(W(i,:)',cnt.cloc(:,1:3));
    title(num2str(i));
end