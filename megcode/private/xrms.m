function rms = xrms(MEG,rescale)
% NAME:     xrms.m
% AUTHOR:   Don Rojas, Ph.D.
% PUPROSE:  to compute the root mean square of an array of epochs or an
%           average, depending on input
% INPUTS:   MEG = struct from get4D.m - should be averaged or epoched
%           rescale = 0 (T) | 1 (fT)
% OUTPUTS:  rms  = root mean squared MEG struct
% NOTES:
% HISTORY:  03/24/10 - revised to work with new MEG structure

% rescale to fT, if requested - note: fix to make flexible for
% different scales people might want

disp('Calculating root mean square waveform...');
switch rescale
    case 1
        MEG.data = MEG.data*1E15;
    case 0
        MEG.data = MEG.data;
    otherwise
        error('rescale must be 0 or 1')
end

% check size of input
switch MEG.type
    case 'epochs' % epoched data
        avg      = averager(MEG);
        tmp      = mean(sqrt(avg.data.^2),1);
    case 'avg'    % average data
        data     = squeeze(MEG.data);
        tmp      = mean(sqrt(data.^2));
    otherwise
        error('Input must be epoched or averaged');
end

% edit structure for return
rms = MEG;
rms.data = tmp;
rms.type = 'rms';
rms = rmfield(rms,{'chn','cori','cloc','mchan'});
disp('Done!');

end