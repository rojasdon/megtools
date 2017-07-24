% function to convert BESA generic dat structure to ssp format for TFT
% using MEG lab routines. Assumes that channels within dat struct are
% actually source space projected.

function ssp = dat2ssp(dat)
    %test number of channels
    if length(size(dat.Data)) > 2
        disp('Number of channels must = 1');
        return;
    end
    
    ssp.Q       = dat.Data;
    ssp.W       = []; % empty weight matrix because not available from BESA
    ssp.cloc    = []; % empty locations (future add in)
    ssp.epdur   = size(ssp.Q,2).*1/dat.sRate;
    first       = -dat.prestim/1000;
    last        = ssp.epdur-abs(first);
    ssp.time    = first:1./dat.sRate:last;
    ssp.time(1) = [];
    ssp.time    = ssp.time.*1000;

end