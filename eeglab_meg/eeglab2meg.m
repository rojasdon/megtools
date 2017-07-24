function MEG = eeglab2meg(EEG)
% PURPOSE:   convert an EEGlab structure to MEG structure
% AUTHOR:    Don Rojas, Ph.D.  
% INPUT:     EEG = EEGlab structure
% OUTPUT:    MEG structure
% NOTES:     1) This function is meant to be used to back convert
%            EEG sets that were converted to EEGLAB via the
%            meg2eeglab.m routine. Do not use for generic
%            EEGLAB conversions!
%            2) cannot return a different datatype than sent to eeglab
%            (e.g., return epoched file after sending it as continuous)
% HISTORY:   4/04/12 - revised to accept revisions to meg2eeglab.m
% SEE ALSO:  MEG2EEGLAB

% test for .meg struct
if ~isfield(EEG,'meg') || isempty(EEG.meg)
    error('This dataset was not originally converted using meg2eeglab function!');
else
    MEG = EEG.meg;
end

% if EEGLAB two-file option is set, data will not be in EEG structure, but
% in .fdt or .dat file - we use EEGLAB function to read it.
if isa(EEG.data,'char')
    EEG.data = eeg_getdatact(EEG);
end

% rescale data back to T from fT
EEG.data = EEG.data/1e15;

% do a crude check to make sure data type hasn't changed - future will fix
% this limitation
switch MEG.type
    case {'avg';'cnt'}
        if ndims(EEG.data) > 2
            error('Data are no longer %s format!',MEG.type);
        end
    case {'epochs'}
        if ndims(EEG.data) < 3
            error('Data are no longer %s format!',MEG.type);
        end
end

% rearrange data
switch MEG.type
    case {'avg';'cnt'}
        data    = EEG.data;
    case {'epochs'}
        data    = permute(EEG.data, [3 1 2]);
end
data = [data; MEG.data];
MEG.data = data; clear('data');
    
end