function MEG = meg_ssp_noise(MEG,varargin)
% PURPOSE: function to project out noise component from MEG object by
%          sub-space and/or signal space projection (ssp). Filter may be constructed 
%          directly from noise topography, or estimated from svd or ica. 
%          Beware significant overlap with signals of interest because these will also be 
%          projected out! Does not work as well with non-stationary noise sources.
% AUTHOR:  Don Rojas, Ph.D. and Dan Collins, B.S. 
% INPUT:   Required: MEG epoch structure - see get4D.m
%          Optional: opt, a structure containing the following fields:
%                    .method 'svd|ica|topo' (default = 'svd')
%                    .time   time in ms to get topography for filter, used
%                            in conjunction with .method 'topo' (default =
%                            0)
%                    .ntrials = scalar indicating number of trials to use
%                               for ica method (e.g., 10). If ntrials is
%                               not specified and ica is chosen, ica is on
%                               averaged response. If ntrials is specified
%                               and < actual number of trials in MEG
%                               object, then random subsample of data is
%                               selected. This can be useful to speed up
%                               ica on large chunks of data.
% OUTPUT:  MEG structure with noise projected out of individual trials
% EXAMPLE: corrected_MEG = meg_ssp_noise(uncorrected_MEG,opts)
% HISTORY: 11/19/10 - first working version, derived from code snippet of
%                     Dan Collins signal space method

% FIXME: force epoch file input
if ~strcmp(MEG.type,'epochs')
    error('Must be epoched input!');
end

usetrials = 0;

% parse options
switch nargin
    case 1
        % default
        method = 'svd';
    case 2
    	if isa(varargin{1},'struct')
            % set options
            method = varargin{1}.method;
            switch method
                case 'topo'
                    if isfield(varargin{1},'time')
                        time = varargin{1}.time;
                    else
                        time = 0;
                    end
                case 'ica'
                    % check for fastica toolbox on path
                    if isempty(which('fastica'))
                        error('You must have fastica toolbox to do ica method');
                    end
                    if isfield(varargin{1},'ntrials') % select trials
                        ntrials = varargin{1}.ntrials;
                        N = size(MEG.data,1);
                        if ntrials < N
                            trials = randsample(N,ntrials);
                        else
                            trials = 1:N;
                        end
                        pca = 15;
                        usetrials = 1;
                    else
                        pca = 15;
                    end
                otherwise
                    method = 'svd';
                    pca    = 15;
            end
        else
           error('Options must be provided in a structure. See help.'); 
        end
    otherwise
        error('Only 2 arguments can be provided to this function.');
end

% average epochs
avg = averager(MEG);

% calculate filter(s)
switch method
    case 'svd'
       % do singular value decomposition to get estimates of noise
       [U,S,V] = svd(avg.data); 
    case 'ica'
       if usetrials
            data = deepoch(MEG.data(trials,:,:)*1e15);
            [icasig, U, W] = fastica(data, 'lastEig', pca,'g','tanh');
       else
            avg.data = avg.data*1e15; % scale up to avoid small number problem
            [icasig, U, W] = fastica(avg.data, 'lastEig', pca,'g','tanh');
       end
       clear icasig data;
    case 'topo'
        % find nearest sample to requested point
        if time < 0
            [t ind] = min(abs(MEG.time(MEG.time < 0) - time));
        else
            [t ind] = min(abs(MEG.time(MEG.time > 0) - time));
            ind     = ind+length(MEG.time(MEG.time < 0));
        end
        noise = avg.data(:,ind);
end

% plot filter(s)
% FIXME: make plotting more flexible in terms of row column N
figure('color','white','name',[upper(method) ' results']);
switch method
    case 'svd'
        % plot first 15 columns svd U
        for i=1:15
            subplot(5,3,i);
            meg_plot2d_misc(U(:,i),avg.cloc);
            xlabel(['Component ' num2str(i)]);
        end
        % prompt for noise sources to project out
        fprintf('Enter source numbers to remove (e.g., [1:4, 10])\n');
        noise = input('Which ones to remove? ');
    case 'ica'
        % plot N components
        for i=1:size(U,2)
            subplot(5,5,i);
            meg_plot2d_misc(U(:,i),avg.cloc);
            xlabel(['Component ' num2str(i)]);
        end
        % prompt for noise sources to project out
        fprintf('Enter source numbers to remove (e.g., [1:4, 10])\n');
        noise = input('Which ones to remove? ');
    case 'topo'
        meg_plot2d_misc(noise,avg.cloc);
end

% construct spatial filter and iteratively apply
nsamp   = size(MEG.data,3);
nepochs = size(MEG.data,1);
for i=1:size(noise,2)
    switch method
        case {'svd' 'ica'} 
            f       = U(:,noise(i));
        case 'topo'
            f       = noise;
    end
    nf      = f/norm(f);
    nf      = repmat(nf,1,nsamp);
    for j = 1:nepochs
        if strcmp(method,'topo'); n = 1; else n = noise(i); end
        fprintf('Projecting out noise component %d from trial %d\n',...
            n,j);
        data      = squeeze(MEG.data(j,:,:));
        trialp    = dot(data,nf);       % trial projector
        trialx    = (f*trialp)/norm(f);   % scaled subtraction signal
        data      = data - trialx;
        MEG.data(j,:,:) = data;
    end
end
end