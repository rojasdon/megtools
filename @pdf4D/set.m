function obj = set(obj,varargin)

% SET Set pdf4D properties and return the updated object

if isempty(varargin)
    fprintf([ ...
        '\theader : attach header structure to the object\n' ...
        '\tconfig : attach config structure to the object\n' ...
        '\ths | headshape : attach head shape structure to the object\n' ...
        '\tpdf | pdfid : pdf id\n' ...
        ]);
    return
end

%need to check if those id could changed
%         '\tpatient | patientid : patient id\n' ...
%         '\tscan | scanid : scan id\n' ...
%         '\tsession | sessionid : session id\n' ...
%         '\trun | runid : run id\n' ...

propertyArgIn = varargin;

while length(propertyArgIn) >= 2
    
    prop = propertyArgIn{1};
    val = propertyArgIn{2};
    propertyArgIn = propertyArgIn(3:end);
    
    switch lower(prop)
        case 'header'
            obj.Header = val;
        case 'config'
            obj.Config = val;
        case {'hs' 'headshape'}
            obj.HeadShape = val;
        case {'pdf' 'pdfid'}
            obj.ID.PDF = val;
            p = fileparts(obj.FileName);
            obj.FileName = fullfile(p, val);
        otherwise
            error('Wrong pdf4D properties: %s', prop)
    end
end