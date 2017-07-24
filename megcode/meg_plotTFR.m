function fig = meg_plotTFR(tf,fld,varargin)
% PURPOSE: function to plot time-frequency results
% AUTHOR:  Don Rojas, Ph.D.
% INPUT:   Required: tf, a time-frequency structure - see tft.m
%          Optional: xrange, a 1x2 vector range of times in ms (e.g., 'xrange',[-200
%          600], entire range is default setting.
%          yrange, a 1x2 vector of frequencies in Hz
%          zrange, a 1x2 vector of color scale for amplitudes
%          scale, 'off'|'on' color scale bar on or off
% OUTPUT:  MEG structure with noise projected out of individual trials
% EXAMPLE: fig = meg_plotTFR(tf,'nepower',[-100 500])
% HISTORY: 11/29/10 - first working version
%          06/01/11 - fixed scaling issue (range erroneously determined from region
%                     including mask)
%          02/25/13 - changed basic plot function from contourf to imagesc

% defaults
xrange = size(tf.time);
yrange = size(tf.freq);
scale  = 'off';

% variable inputs should be given in arg pairs (e.g., 'xrange',[-100 250])
if nargin > 2
    [val arg] = parseparams(varargin);
    for i=1:2:length(arg)
        switch char(arg{i})
            case 'xrange'
                [val xrange(1)] = min(abs(tf.time - arg{i+1}(1)));
                [val xrange(2)] = min(abs(tf.time - arg{i+1}(2)));
            case 'yrange'
                [val yrange(1)] = min(abs(tf.freq - arg{i+1}(1)));
                [val yrange(2)] = min(abs(tf.freq - arg{i+1}(2)));
            case 'zrange'
                zrange(1) = arg{i+1}(1);
                zrange(2) = arg{i+1}(2);
            case 'scale'
                scale = arg{i+1};
            otherwise
        end
    end
end

data = eval(['tf.' fld ';']);
% mask out tf regions with suspect data if mask is present
if isfield(tf,'mask')
    data(tf.mask < 1) = NaN;
end

% scale range
if ~exist('zrange','var')
    zrange(1) = min(data(:));
    zrange(2) = max(data(:));
end

% FIXME: figure out plotting of normalized vs. original units
% plot tf data
clevel = 25; % default # of contours
plotunit = '%'; % default plot unit
if isfield(tf,'units')
    if strcmp(tf.units,'dB')
        clevel = 100;
    end
    plotunit = tf.units;
end

imagesc(tf.time(xrange(1):xrange(2)),...
       tf.freq(yrange(1):yrange(2)),...
       data(yrange(1):yrange(2),xrange(1):xrange(2)));
axis xy;
xlabel('Time (ms)'); ylabel('Frequency (Hz)');
if strcmp(scale,'on')
    h    = colorbar(); ylabel(h,plotunit);
end
hold on;

%if isfield(tf,'mask')
%    contour(tf.time(xrange(1):xrange(2)),...
%      tf.freq(yrange(1):yrange(2)),...
%       tf.mask(yrange(1):yrange(2),xrange(1):xrange(2)),...
%       [1 1],'k');
%       hold off;
%end
caxis([zrange(1) zrange(2)]);

end