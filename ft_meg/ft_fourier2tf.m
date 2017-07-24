function tfr = ft_fourier2tf(cfg,tfr)
%PURPOSE:   to produce measures of evoked power, induced power, plf, and
%           normalized power from output of Fieldtrip's ft_freqanalysis.m
%AUTHOR:    Don Rojas, Ph.D.  
%INPUT:     Required: cfg.measure should be
%           'plf','epower','ipower','tpower','nepower',nipower','ntpower',
%           cfg.baselinetype = 'subtraction','percentage','dB' or 'zscore'
%           tfr = output of ft_freqanalysis, must have cfg.keeptrials = 'yes'
%           and cfg.output = 'fourier' as config to ft_freqanalysis
%OUTPUT:    tfr = output structure of tf_freqanalysis
%SEE ALSO:  FT_FREQANALYSIS, TFT, QTF

%HISTORY:   03/23/11 - first version

% check input for relevant fields
if nargin < 2
    error('This function requires two inputs - see help');
end
if ~isfield(tfr,'fourierspctrm')
    error('Must have complex fourier data in structure - see help');
end

if ~strcmp(tfr.cfg.keeptrials,'yes')
    error('Individual trials not present for computation!');
end

% compute desired measure
switch cfg.measure
    
    case 'plf'
        plf     = squeeze(abs(mean(...
                tfr.fourierspctrm./abs(tfr.fourierspctrm),1)));
    case {'epower' 'nepower' 'ipower' 'nipower' 'tpower' 'ntpower'}
        tpower  = squeeze(mean(abs(tfr.fourierspctrm),1));
        epower  = squeeze(abs(mean(...
                tfr.fourierspctrm,1)));
        ipower  = tpower-epower;
        [t s]   = min(abs(tfr.time) - 0);
        stop    = s - 1; % stop point in samples
        start   = 1; % start point in samples
        for i=1:length(tfr.label)
            base           = nanmean(squeeze(tpower(i,:,start:stop))');
            baseTP(i,:,:)  = repmat(base',1,length(tfr.time));
            base           = nanmean(squeeze(epower(i,:,start:stop))');
            baseEP(i,:,:)  = repmat(base',1,length(tfr.time));
            base           = nanmean(squeeze(ipower(i,:,start:stop))');
            baseIP(i,:,:)  = repmat(base',1,length(tfr.time));
            %sdTP(i,:,:)    = repmat(std(squeeze(tpower(i,:,start:stop)),0,2),1,length(tfr.time));
            %sdEP(i,:,:)    = repmat(std(squeeze(epower(i,:,start:stop)),0,2),1,length(tfr.time));
            %sdIP(i,:,:)    = repmat(std(squeeze(ipower(i,:,start:stop)),0,2),1,length(tfr.time));
        end
        switch cfg.baselinetype
            case 'subtraction' % subtract baseline only
                ntpower = tpower-baseTP; %normalized total power
                nepower = epower-baseEP; %normalized evoked
                nipower = ipower-baseIP; %normalized induced
            case 'percentage' % express as percent change
                ntpower = (tpower-baseTP)./baseTP; %normalized total power
                nepower = (epower-baseEP)./baseEP; %normalized evoked
                nipower = (ipower-baseIP)./baseIP; %normalized induced
            case 'dB' % express in dB change
                ntpower = (log10(tpower./baseTP))*20; %normalized total power
                nepower = (log10(epower./baseEP))*20; %normalized evoked
                nipower = (log10(ipower./baseIP))*20; %normalized induced
            case 'zscore' % express in units of Z-score change
                error('Not implemented yet');
                ntpower = (tpower-baseTP)./sdTP; %normalized total power
                nepower = (epower-baseEP)./sdEP; %normalized evoked
                nipower = (ipower-baseIP)./sdIP; %normalized induced
        end
    otherwise
        error('Measure is not supported by this function - see help.');
end

% construct fieldtrip structure
tfr                 = rmfield(tfr,'fourierspctrm');
tfr.powspctrm       = eval(cfg.measure);
tfr.dimord          = 'chan_freq_time';
tfr.cfg.output      = 'fourier';
tfr.cfg.keeptrials  = 'no';
tfr.cfg.keeptapers  = 'no';
    
end