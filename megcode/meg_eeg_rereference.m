function MEG = meg_eeg_rereference(MEG,varargin)
% NAME:    meg_eeg_rereference()
% AUTHORS: Don Rojas, Ph.D.
% PURPOSE: function to reference EEG data within MEG struct to an arbitrary
%          reference schema, which can be supplied as an nchan x nchan matrix
% INPUT:   MEG         = MEG input struct (required)
%          'matrix', M is an nchan x nchan matrix with coefficients to
%                    determine channel combinations. See below for an
%                    example of the default matrix M, which is an average
%                    reference
% USAGE:   MEG = meg_eeg_reference(MEG), computes the average reference
%          MEG = meg_eeg_reference(MEG,'matrix',M), computes a custom
%                reference scheme dependent on M
% OUTPUT:  MEG structure, containing the following fields:
% TODO     1. Adapt for any type of MEG struct
% HISTORY: 05/09/12 First version

% parse input
if nargin < 1
    error('A single filename must be supplied as an argument!');
else
    optargin = size(varargin,2);
    if (mod(optargin,2) ~= 0)
        error('Optional arguments must come in option/value pairs');
    else
        for i=1:2:optargin
            switch varargin{i}
                case 'matrix'
                    M = varargin{i+1};
                otherwise
                    error('Invalid option!');
            end
        end
    end
end

% remove any strictly non-EEG channels categorized that way by MEG struct
eegi     = meg_channel_indices(MEG,'multi','EEG');
labels   = {MEG.chn(eegi).label};
toremove = [];
for ii=1:length(eegi)
    if find(strcmpi(labels{ii},'EKG')); toremove = [toremove ii]; end;
    if find(strcmpi(labels{ii},'ECG')); toremove = [toremove ii]; end;
    if find(strcmpi(labels{ii},'HEOG')); toremove = [toremove ii]; end;
    if find(strcmpi(labels{ii},'VEOG')); toremove = [toremove ii]; end;
    if find(strcmpi(labels{ii},'EMG')); toremove = [toremove ii]; end;
end
labels(toremove)=[];
eegi(toremove)=[];
nchan = length(eegi);
        
% if M not supplied, create M for average reference
if ~exist('M','var')
    M       = zeros(nchan,nchan);
    d       = find(eye(nchan,nchan));
    M(d)    = (nchan-1)/nchan;
    nz      = find(M == 0);
    M(nz)   = -1/nchan;
end

% check M for size
if size(M,1) ~= nchan || size(M,2) ~= nchan
    error('Dimensions of M mixing matrix must equal number of eeg channels');
end

% calculate new reference
MEG.data(eegi,:) = M*MEG.data(eegi,:);

