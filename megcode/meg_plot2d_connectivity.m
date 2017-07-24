function hnd = meg_plot2d_connectivity(MEG,M,varargin)
% plots 2D channel map of sensor connectivity data
% MEG      = MEG struct from get4D.m
% M        = nchan x nchan matrix of connectivities
% 'bc'     = 'on'|'off', calculates and plots betweenness centrality for M
% point    = time point to map in ms
% opts     = .locs = 1 = on, 0 = off
%            .labels 1 = on, 0 = off
% .cbar 1 = colorbar, 0 = none

% check input matrix
cind = meg_channel_indices(MEG,'multi','MEG');
if size(M,1) ~= size(M,2)
    error('Matrix must be square!');
else
    if size(M,1) ~= length(cind)
        error('Size of matrix must equal number of channels!');
    end
end
if ~isempty(find(M ~= 1 & M ~= 0,1))
    % this is a weighted matrix
    W = M;
    M(M ~= 0) = 1;
else
    W = M;
end
% do projection of 3D positions into 2D map

cloc       = MEG.cloc(cind,1:3)*100;
loc2d      = double(thetaphi(cloc')); %flatten
loc2d(2,:) = -loc2d(2,:); %reverse y direction
nodes      = loc2d';

% get line segments
s_id = 0;
segments = zeros(sum(sum(M)), 3);
for i=1:length(M)
    for j=1:length(M)
        if M(i,j)==1
            seg = [i,j];
            s_id = s_id + 1;
            segments(s_id,:) = [s_id, seg];
        end
    end
end

% plot sensors
bc=1;
if bc
    B = betweenness_bin(M);
    scatter(loc2d(2,:),loc2d(1,:),20+(100*B/max(B(:))),'or','filled');
    % scatter(loc2d(2,:),loc2d(1,:),50,20+(100*B/max(B(:))),'o','filled');
else    
    scatter(loc2d(2,:),loc2d(1,:),'or');
end
hold on;

% plot connections
for s=1:length(segments)
    if (segments(s,2)<segments(s,3))
        x1 = nodes(segments(s,2),2);
        x2 = nodes(segments(s,3),2);
        y1 = nodes(segments(s,2),1);
        y2 = nodes(segments(s,3),1);
        line([x1,x2], [y1,y2],'LineWidth',W(segments(s,2),segments(s,3)));
    end
end

% plot result on new figure
if nargin > 2
    opts = varargin{1};    
    if opts.labels
        for i=1:length(cloc)
            text(loc2d(2,i),loc2d(1,i),MEG.chn(i).label);
        end
    end
    if opts.locs
        plot(loc2d(2,:),loc2d(1,:),'.k');
    end
    if opts.cbar
        bar = colorbar();
        set(get(bar, 'Title'), 'String', 'T');
    end
end
hold off;

end