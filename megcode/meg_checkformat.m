function MEG = meg_checkformat(MEG,varargin)
% function to check format of megtools MEG struct and convert between old
% and new formats if necessary

% defaults
new     = 1;
convert = 1;

% check input
if nargin > 1
    if varargin > 1
        error('Number of arguments cannot exceed 2!');
    else
        convert = varargin{1};
    end
end

% check old v. new format
if isfield(MEG,'ref') || isfield(MEG,'aux')
    new = 0;
end

% check various fields
if isfield(MEG,'type')
    nd = ndims(MEG.data);
    switch MEG.type
        case {'cnt','avg'}
            if nd ~= 2
                warning('Dimensions of data are not correct for type!');
            end
        case 'epochs'
            if nd ~= 3
                warning('Dimensions of data are not correct for type!');
            end
        otherwise
            % do nothing for now
    end
else
    warning('Type of MEG cannot be determined!');
end

% convert old to new format if requested (default)
if convert && ~new
    MEG.data = [MEG.data;MEG.aux];
    MEG = rmfield(MEG,'aux');
    if isfield(MEG,'ref')
        MEG.data = [MEG.data;MEG.ref];
        MEG = rmfield(MEG,'ref');
    end
end

% check events field for repeated events
if strcmp(MEG.type,'cnt')
    MEG = remove_duplicate_events(MEG);
end

end

