function MEG = concatMEG(varargin)
% PURPOSE: To concatenate MEG datasets together. Sets are appended in the
%          order named in the function input.
% AUTHOR:  Don Rojas, Ph.D.
% INPUTS:  variable input of MEG structs - must be at least 2 named,
%          separated by commas. Example: MEG = concatMEG(A,B,C,D) will
%          concatenate 4 datasets together and the result will be a new
%          struct named MEG. A,B,C and D are all MEG structures.
% OUTPUT:  a MEG struct - see get4D.m
% NOTES:   1. all input structs must be of the same type (e.g., you cannot
%          concatenate an epoched set with a continuous set
%          2. output can be unexpected with respect to time vector, so may
%          need to check to make sure it is what you want, particularly for
%          average files.
% EXAMPLE: eps = concatMEG(ep1,ep2,ep3) will concatenate the 3 inputs into
%                one output file.
% SEE ALSO: EPOCH_EXTRACTOR

% HISTORY: 4/17/10 - revised for MEG struct consistency - see get4D.m
%          12/4/10 - revised for consistency with updates to MEG struct
%          9/16/11 - revision for new updates to MEG struct

% check input to function
nargs = nargin;
if nargs < 2
    error('There must be at least 2 datasets provided to append');
else
    fprintf('Appending %d datasets\n',nargs);
end

% check data type compatibility
types = cell(1,nargs);
for set = 1:nargs
    types{set} = varargin{set}.type;
end
if length(find(strcmp(types,varargin{1}.type))) ~= nargs
    error('Datatypes must all be compatible!');
end

% check data size compatibility
if ndims(varargin{1}.data) > 2
    msize = zeros(nargs,3);
else
    msize = zeros(nargs,2);
end
for set = 1:nargs
    msize(set,:,:) = size(varargin{set}.data);
end
switch varargin{1}.type
    case {'avg'} % all 3 dimensions must match
        if ~isempty(find(diff(msize)))
            error('Data dimensions are not compatible!');
        end
    case {'cnt'} % check only channel numbers for cnt
        if ~isempty(find(diff(msize(:,1))))
            error('Data dimensions are not compatible!');
        end
    case {'epochs'} % check channels and samples, not epochs
        if ~isempty(find(diff(msize(:,2)))) ...
                || ~isempty(find(diff(msize(:,2)))) 
            error('Data dimensions are not compatible!');
        end
end

% get struct info from first set and concatenate data
fprintf('\nTaking header information from first dataset\n');
MEG  = varargin{1};
data = varargin{1}.data;
switch varargin{1}.type
    case 'epochs'
        epochs = varargin{1}.epoch;
        for set = 2:nargs
            data   = [data;varargin{set}.data];
            epochs = [epochs varargin{set}.epoch];
        end
    case 'avg'
        for set = 2:nargs
            data = [data varargin{set}.data];
        end
    case 'cnt'
        events  = varargin{1}.events;
        for set = 2:nargs
            data    = [data varargin{set}.data];
            events  = [events varargin{set}.events];
        end
        MEG.epdur   = MEG.epdur*nargs;
    otherwise
        error('Concatenation not supported for this datatype!');
end

% correct structure information as needed
MEG.data    = data;
switch varargin{1}.type
    case 'cnt'
        for set = 2:nargs
            MEG.time = [MEG.time (varargin{set}.time + max(MEG.time))];
        end
        MEG.events = events;
    case 'avg'
        for set = 2:nargs
            MEG.time = [MEG.time varargin{set}.time];
        end
    case 'epochs'
        MEG.epoch = epochs;
end

end
        