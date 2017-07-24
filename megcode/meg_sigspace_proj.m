function ssp = meg_sigspace_proj(MEG, time, varargin)

% force epoch input
if ~strcmp(MEG.type,'epochs')
    error('Must be epoched input!');
end

hem = [];
avg = averager(MEG);

% variable inputs should be given in arg pairs (e.g., 'xrange',[-100 250])
if nargin > 2
    [val arg] = parseparams(varargin);
    for i=1:2:length(arg)
        switch char(arg{i})
            case 'hem'
                hem = arg{i+1};
            otherwise
        end
    end
end

% extract data
if ~isempty(hem)
    switch hem
        case 'left'
            cind = find(MEG.cloc(:,2) > 0);
        case 'right'
            cind = find(MEG.cloc(:,2) < 0);
    end
    data = MEG.data(:,cind,:);
else
    data = MEG.data;
    cind = 1:size(avg.data,1);
end

% extract requested timeslice
[t tind] = min(abs(MEG.time - time));
f        = avg.data(cind,tind);

% construct spatial filter and apply
nsamp   = size(MEG.data,3);
nepochs = size(MEG.data,1);
f       = f/norm(f);
nf      = repmat(f,1,nsamp);
ssp.Q   = zeros(nepochs,nsamp);
for i=1:nepochs
    fprintf('Applying filter to epoch: %d\n',i);
    trial        = squeeze(data(i,:,:));
    ssp.Q(i,:)   = dot(trial,nf);
end

ssp.time  = MEG.time;
ssp.W     = f;
ssp.epdur = MEG.epdur;

end