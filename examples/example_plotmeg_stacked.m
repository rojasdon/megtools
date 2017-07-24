% assumes an average in workspace

figure;hold on;

% plot all meg channels stacked
spacing = 50;
scaling = 2;
cind    = meg_channel_indices(avg,'multi','MEG');
% scale data to femtotesla b/c in the stacked plot the scaling and spacing
% is easier with larger numbers.
data=avg.data(cind,:)*1e15;
nchan   = length(cind);
labels  = {avg.chn(cind).label};
set(gca,'YTickMode','manual')
set(gca,'Ytick',linspace(spacing,nchan*spacing,nchan));
set(gca,'YtickLabel',labels);
rgb=[colormap(jet);colormap(jet);colormap(jet);colormap(jet)];

% iterate an increase in scaling in 20% increments
for num=1:10
    cla;
    for i=1:nchan
        plot(avg.time,(data(i,:)*scaling)+(i*spacing),'color',rgb(i,:));
    end
    axis tight; drawnow expose;
    scaling = scaling + .5;
end