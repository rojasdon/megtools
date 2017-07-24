function MEG = ft2meg(ft)
%PURPOSE:   converts Fieldtrip data to MEG struct
%AUTHOR:    Don Rojas, Ph.D.  
%INPUT:     ft = fieldtrip data structure
%OUTPUT:    MEG = structure conforming to get4D()
%EXAMPLES:  MEG = ft2meg(ft);
%SEE ALSO:  MEG2FT, MEG2SPM

%HISTORY:   06/15/11 - first version

% get original header
MEG = ft.hdr.orig;
if ~isfield(MEG,'cloc')
    error('This FieldTrip data was not converted with meg2ft!');
end

% extract data
switch MEG.type
    case 'cnt'
        MEG.data = cell2mat(ft.trial);
    case 'epochs'
        for trial=1:length(MEG.epoch)
            MEG.data(trial,:,:) = cell2mat(ft.trial(trial));
        end
    otherwise
        error('Conversion of this type not supported!');
end

% remove reference channels from data if present
if isfield(MEG,'ref')
    switch MEG.type
        case 'cnt'
            ndat = size(MEG.data,1) - size(MEG.ref,1);
            
        case 'epochs'
            ndat = size(MEG.data,2) - size(MEG.ref,2);
    end
    if length(find(strcmp({MEG.chn.type},'MEG'))) < ndat
        switch MEG.type
            case 'cnt'
                MEG.data = MEG.data(1:ndat,:);
            case 'epochs'
                MEG.data = MEG.data(:,1:ndat,:);
        end
    end
end

% convert back to single precision
MEG.data = single(MEG.data);

end