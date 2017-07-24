function tfr = meg2ft_tfr(cfg,tft)
% PURPOSE:   to convert tft.m output to fieldtrip compatible structure
% AUTHOR:    Don Rojas, Ph.D.  
% INPUT:     cfg, a structure containing the following fields:
%           .measure should be 'plf','epower','ipower','tpower','nepower',nipower','ntpower'
%           .baselinetype = 'subtraction','percentage','dB' or 'zscore'
%           .label = string with any name you wish e.g., 'VirtualSensor1'
% OUTPUT:    tfr = output structure of tf_freqanalysis
% SEE ALSO:  FT_FREQANALYSIS, TFT

% HISTORY:   03/23/11 - first version
%            10/13/11 - minor mods
%            12/20/12 - revised to check odd naming limitation in Fieldtrip
%            07/15/13 - minor rev to check for wave number

% convert tf structure from tft.m
tfr.powspctrm   = zeros(1,length(tft.freq),length(tft.time));

% check label
if length(cfg.label)~=length(unique(cfg.label))
  error('Fieldtrip cannot have labels with repeating numbers or characters!');
end
% check wave number (not used in some tft)
if ~isfield(tft,'waven')
    tft.waven   = [];
end

% build structure for FT
tfr.label       = {cfg.label};
tfr.dimord      = 'chan_freq_time';
tfr.freq        = tft.freq;
tfr.time        = tft.time/1e3;
cfg1.method     = 'wavelet';
cfg1.width      = tft.waven;
cfg1.output     = 'pow';
cfg1.toi        = tfr.time;
cfg1.foi        = tfr.freq;
cfg1.keeptrials = 'no';
cfg1.keeptapers = 'no';
cfg1.feedback   = 'text';
cfg1.checksize  = 100000;
cfg1.channel    = tfr.label;
cfg1.checkconfig = 'loose';
cfg1.trackconfig = 'off';
cfg1.precision   = 'double';
tfr.cfg          = cfg1;

% mask out data like FieldTrip if there is mask in tft
tmp = eval(['tft.' cfg.measure]);
if isfield(tft,'mask')
    tmp(tft.mask == 0) = nan;
end
tfr.powspctrm(1,:,:) = tmp;

end