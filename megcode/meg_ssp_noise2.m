function MEG = meg_ssp_noise2(MEG,varargin)
% PURPOSE: function to project out noise component from MEG object by
%          sub-space and/or signal space projection (ssp). Filter may be constructed 
%          directly from noise topography, or estimated from svd or ica. 
%          Beware significant overlap with signals of interest because these will also be 
%          projected out! Does not work as well with non-stationary noise sources.
% AUTHOR:  Don Rojas, Ph.D.
% INPUT:   Required: MEG epoch structure - see get4D.m
%          Optional: 'method' 'ica|pca|topo' (default = 'ica')
%                    'algorithm' 'fastica' or 'binica' fastica = default
%                    'timeslice'    time in ms to get topography for filter, used
%                                   in conjunction with .method 'topo' (default =
%                                   0)
%                    'ntrials'  scalar indicating number of trials to use
%                               for ica method (e.g., 10). If ntrials is
%                               not specified and ica is chosen, ica is on
%                               averaged response. If ntrials is specified
%                               and < actual number of trials in MEG
%                               object, then random subsample of data is
%                               selected. This can be useful to speed up
%                               ica on large chunks of data.
%                    'pca'      n components to retain from pca (default =
%                               25)
%                    'average'  'yes|no', average before estimation of
%                               component structure. No effect on method 
%                               'svd'
%                    'epoch'    [begin end] -100 100 default, can be
%                               supplied with 'average' 'yes' to pre-process
%                               continuous data prior to component estimation
%                    'filter'   'yes|no' No is default. Set to yes to
%                               filter input to method chosen. Must supply,
%                               both ftype and band settings
%                    'ftype'    'low|high|band'
%                    'band'     [lowcut highcut] or simply [cutoff]
% OUTPUT:  MEG structure with noise projected out of individual trials
% EXAMPLE: corrected_MEG = meg_ssp_noise(uncorrected_MEG,'method','ica')
% HISTORY: 11/19/10 - first working version
%          07/25/11 - complete re-write with more options, addition of pca
%                     as method, and output of ica components
%          08/18/11 - added fft plotting of components
%          08/19/11 - added timecourse plotting for components
%          08/22/11 - removed svd method - pca suffices
%          08/23/11 - added choice of using binica instead of fastica

% global variables
global method sr rgb intype fh fw megi average;
sr        = MEG.sr;
h         = figure;
rgb       = [colormap(prism);colormap(prism);colormap(prism)];
set(0,'units','pixels');
ss        = get(0,'ScreenSize');
fh        = round(ss(3)/2);
fw        = round(ss(4)/2);
megi      = find(strcmp({MEG.chn.type},'MEG'));

% close figure used by colormap call
close(h);

% defaults
usetrials = 1;
pca       = 25;
method    = 'ica';
algorithm = 'fastica';
trials    = 1;
if strcmp(MEG.type,'epochs'); trials = 1:size(MEG.data,1); end
epwin     = [100 100];
average   = 0;
filter    = 0;

% parse options
if ~isempty(varargin)
    optargin = size(varargin,2);
    if (mod(optargin,2) ~= 0)
        error('Optional arguments must come in option/value pairs');
    else
        for i=1:2:optargin
            switch upper(varargin{i})
                case 'METHOD'
                    method = varargin{i+1};
                case 'ALGORITHM'
                    algorithm = varargin{i+1};
                case 'NTRIALS'
                    ntrials   = varargin{i+1};
                    N         = size(MEG.data,1);
                    if ntrials < N
                        trials = randsample(N,ntrials);
                    else
                        trials = 1:N;
                    end
                case 'TIMESLICE'
                    time = varargin{i+1};
                case 'PCA',
                    pca  = varargin{i+1};
                case 'EPOCH'
                    epwin = varargin{i+1};
                case 'AVERAGE'
                    if strcmpi(varargin{i+1},'YES')
                        average = 1;
                    end
                case 'FILTER'
                    if strcmpi(varargin{i+1},'YES')
                        filter = 1;
                    end
                case 'FTYPE'
                    ftype = varargin{i+1};
                case 'CUTOFF'
                    cutoff  = varargin{i+1};
                otherwise
                    error('Invalid option!');
            end
        end
    end
else
    error('Arguments are required for this function!');
end

% check if fastica/binica installed on path
if isempty(which(algorithm))
    fprintf('You need to have the %s toolbox installed to use this function!\n',algorithm);
    return;
end

% make temp copy of original data
intype = MEG.type;
MEG_orig = MEG;

% fix erroneous user combinations
if strcmp(intype,'avg') || strcmp(intype,'cnt')
    if length(trials) > 1
        trials = 1;
    end
end

% must have correct fields for filtering
if filter
    if ~exist('cutoff','var') || ~exist('ftype','var')
        error('To filter data you must specify a filter type and filter cutoff(s)!');
    end
end

% preprocess (epoch, average and filter) if necessary
switch MEG.type
    case 'cnt'
        if average
            MEG = epocher(MEG,'trigger',epwin(1),epwin(2));
            MEG = averager(MEG);
        end
    case 'epochs'
        if average
            MEG = averager(MEG);
        end
    case 'avg'
        % do nothing
end
if filter
    switch ftype
        case {'low','high'}
            MEG = filterer(MEG,ftype,cutoff);
        case 'band'
            MEG = filterer(MEG,ftype,cutoff);
    end
end

% get relevant data for projections
cind = meg_channel_indices(MEG,'multi','MEG');
switch MEG.type
    case {'avg' 'cnt'}
        data = MEG.data(cind,:)*1e15;
    case 'epochs'
        [data, nepochs, nsamples] = deepoch(MEG.data(trials,cind,:)*1e15);
    otherwise
        error('Input data format not supported!');
end

if strcmpi(method,'TOPO') && ~exist('time','var')
    error('TIMESLICE must be defined for method TOPO');
end

% calculate sub-space projection(s)
nchan    = length(cind);
npoints  = size(data,2);
switch method
    case 'ica'
       if usetrials
           switch algorithm
               case 'fastica'
                   [~, U, W] = fastica(data, ...
                       'lastEig', pca,'approach','symm','g','pow3');
                   sphere = eye(nchan);
               case 'binica'
                   [W,sphere] = binica(data, ...
                       'lrate', 0.001, 'pca', pca, 'extended',1);
                   U = pinv(W);
               otherwise
                   error('Unsupported ICA algorithm');
           end
       else
            avg.data  = avg.data*1e15; % scale up to avoid small number problem
            [~, U, W] = fastica(avg.data, 'lastEig', pca,'approach','symm');
       end
    case 'pca'
       if usetrials
            [U, W] = fastica(data, 'lastEig', pca,'only','pca');
       else
            avg.data = avg.data*1e15; % scale up to avoid small number problem
            [U, W]   = fastica(avg.data, 'lastEig', pca,'only','pca');
       end
    case 'topo'
        % find nearest sample to requested point
        tind = get_time_index(MEG,time);
        W = MEG.data(:,tind);
        U = W;
end

switch method
    case {'pca','ica'}
        % compute component activations
        rowmeans = mean(data,2);
        if strcmp(method,'pca'); w=pinv(U); else w=W; end;
        activations=w*eye(nchan)*(data-repmat(rowmeans,1,npoints));

        % plot topography
        plotTopo(U,MEG.cloc);

        % plot component fft results
        plotFFT(activations,U,data)

        % plot timecourses
        plotComponents(MEG_orig.time,activations,'components')

        % plot waveforms of channels most likely to have artifacts
        plotComponents(MEG_orig.time,data(nchan-24:nchan,:),'data')

        % prompt for noise sources to project out
        if ~strcmp(method,'topo')
            fprintf('Enter source numbers to remove (e.g., [1:4, 10])\n');
            remove = input('Which ones to remove? ');
        end
    case 'topo'
        % do nothing
end

% project out undesired components
nchan = length(find(strcmp({MEG.chn.type},'MEG')));
switch method
    case {'ica','pca'}
        MEG = MEG_orig;
        %if strcmp(MEG.type,'epochs')
        %    data = MEG.data(:,cind,:) * 1e15;
        %else
        % 	data = MEG.data(cind,:) * 1e15;
        %end
        weights    = W;
        winv       = U;
        if strcmp(method,'pca'); weights = pinv(winv); end;
        tra        = eye(nchan);
        tokeep     = setdiff(1:size(weights,1),remove);
        tmpdata    = (weights(tokeep,:)*tra)*data;
        newdata    = winv(:,tokeep)*tmpdata;
        newdata    = newdata / 1e15;
        switch MEG.type
            case {'cnt' 'avg'}
                MEG.data(cind,:)   = newdata;
            case 'epochs'
                MEG.data(:,cind,:)   = reepoch(newdata,nepochs,nsamples);
        end
    case 'topo'
        clear MEG;
        MEG     = MEG_orig;
        f       = W;
        nf      = f/norm(f);
        switch MEG.type
            case 'epochs'
                nepochs   = size(MEG.data,1);
                nsamp     = size(MEG.data,3);
                nf        = repmat(nf,1,nsamp);
                for j = 1:nepochs
                    data      = squeeze(MEG.data(j,:,:));
                    trialp    = dot(data,nf);       % trial projector
                    trialx    = (f*trialp)/norm(f);   % scaled subtraction signal
                    data      = data - trialx;
                    MEG.data(j,:,:) = data;
                end
            case {'cnt','avg'}
                nsamp     = size(MEG.data,2);
                nf        = repmat(nf,1,nsamp);
                data      = MEG.data;
                trialp    = dot(data,nf);       % trial projector
                trialx    = (f*trialp)/norm(f);   % scaled subtraction signal
                data      = data - trialx;
                MEG.data  = data;
        end
end

end
% END OF MAIN

% FUNCTION TO PLOT COMPONENT TOPOGRAPHY
function plotTopo(U,cloc)
    global fh fw method megi;
    h=figure('color','white','name',[upper(method) ' topo results']);
    pos = get(h,'Position');
    set(h,'Position',[pos(1) pos(2) fh fw]);
    whitebg(h,[.8 .8 .8]);
    switch method
        case {'svd' 'ica' 'pca'}
            % plot first 25 components
            if size(U,2) > 25
                toplot = 25;
            else
                toplot = size(U,2);
            end
            for i=1:toplot
                subplot(5,5,i);
                meg_plot2d_misc(U(:,i),cloc(megi,:));
                title(['Component ' num2str(i)]);
                axis off;
            end
        case 'topo'
            meg_plot2d_misc(noise,cloc(megi,:));
    end
end

% FUNCTION TO PLOT COMPONENT FFT
function plotFFT(compsignals,U,data)
    global fh fw rgb sr method;
    N    = size(compsignals,2);
    nfft = 2^nextpow2(N);
    f    = (sr+1)/2*linspace(0,1,nfft/2);
    flim = [get_index(f,.5) get_index(f,200)];
    pline = get_index(f,50);
    if isempty(flim) || length(flim) < 2
        flim = [f(1) length(f)];
    end
    Y = zeros(size(compsignals,1),length(f(flim(1):flim(2))));
    for comp = 1:size(compsignals,1)
        fprintf('Computing fft on component %d\n', comp);
        tmp              = fft(data(comp,:),nfft)/N;
        Y(comp,:)        = tmp(flim(1):flim(2));
    end
    h=figure('color','white','name',[upper(method) ' fft results']);
    pos = get(h,'Position');
    set(h,'Position',[pos(1) pos(2) fh fw]);
    whitebg(h,[.8 .8 .8]);
    % plot first 25 components
    if size(U,2) > 25
        toplot = 25;
    else
        toplot = size(U,2);
    end
    for comp=1:toplot
        subplot(5,5,comp);
        ymax = max(abs(Y(comp,flim(1):pline)));
        plot(f(flim(1):flim(2)),abs(Y(comp,:)),'color',rgb(comp,:));
        title(['Component ' num2str(comp)]);
        ylim([0 ymax]);
        xlabel('Hz'); set(gca,'XTick',0:50:200); axis tight;
    end
end

% FUNCTION TO PLOT COMPONENT/WAVEFORM TIMECOURSES
function plotComponents(time,compsignals,type)
    global fh fw rgb intype average;
    tmax = 5000; % 5 s default plot
    if time(end) < tmax; tmax = time(end); end;
    switch intype
        case {'cnt','epochs'} % plot only 1st second of data
            if average
               time = 1:size(compsignals,2);
               sig  = compsignals;
            else
               time = time(1):time(get_index(time,tmax));
               sig  = compsignals(:,1:get_index(time,tmax));
            end
        case 'avg'
           sig = compsignals;
    end
    % normalize the component amplitudes for better plotting
    ymax = max(sig(:));
    sig  = sig/ymax;
    if strcmp(type,'components')
        h=figure('color','white','name','Component Timecourse');
    else
        h=figure('color','white','name','Lower 25 Channel Timecourse');
    end
    pos = get(h,'Position');
    set(h,'Position',[pos(1) pos(2) fh fw]);
    whitebg(h,[.8 .8 .8]);
    nsig = size(sig,1);
    ylim([-2 (nsig + 2)]);
    if nsig > size(rgb,1); rgb = [rgb;rgb]; end;
    if strcmp(type,'components')
        for line = 1:nsig
            plot(time,sig(line,:)+line,'color',rgb(line,:));  
            hold on;
        end
    else
        for line = 1:nsig
            plot(time,sig(line,:)+line,'color','k');  
            hold on;
        end
    end
    xlabel('Time (ms)');
    if strcmp(type,'components') 
        ylabel('Component #');
    else
        ylabel('Channel #');
    end
    hold off;
end