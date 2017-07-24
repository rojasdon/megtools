function dpl_struct = read_msi_dipole(filename,param)

% Purpose: read msi dipole file and return structure with fields:
% x, y, z, scale, label
% modified from MRO program private/read_msi_dipole of Eugene Kronberg to
% suit general reading purposes outside of MRO gui

% if no parameters defined, use defaults
if nargin < 2
    param.line_to_skip = 31;
    param.xyz_units    = 'cm';
    param.func         = '1';
    param.lat          = 1;
    param.xcol         = 2;
    param.ycol         = 3;
    param.zcol         = 4;
    param.Qx           = 5;
    param.Qy           = 6;
    param.Qz           = 7;
    param.Gof          = 12;
end

dpl_block = 10000;
nblock = 1;
dpl_struct(dpl_block) = struct('lat',[],'x',[],'y',[],'z',[],...
                            'Qx',[],'Qy',[],'Qz',[],'Gof',[]);

fid = fopen(filename, 'rt');
fseek(fid,0,'eof');
fseek(fid,0,'bof');

%skipping lines from the top of the file
for ii = 1:param.line_to_skip
    tline = fgetl(fid);
end

dpl = 1;
found_first = false; %should be called found_second
first_count = 0;
while 1
    tline = fgetl(fid);
    if isempty(tline), continue, end
    if ~ischar(tline), break, end
    [col,count,errmsg,nextindex] = sscanf(tline,'%f');
    %shortest row must have al least 10 numerical fields
    if count < 10
        continue
    end
    %wrong length of the row
    if found_first && count ~= first_count
            continue
    end
    %this is second "right" row
    if ~found_first && count == first_count
        found_first = true;
    end
    %keep as first "good" row (then check if next row also "good")
    if ~found_first
        first_count = count;
    end
    %from the second and on add dipole to the structure
    if found_first
        dpl = dpl + 1;
    end
    if dpl > nblock * dpl_block
        nblock = nblock + 1;
        dpl_struct(end + dpl_block) = ...
            struct('lat',[],'x',[],'y',[],'z',[],...
               'Qx',[],'Qy',[],'Qz',[],'Gof',[]);
    end
    dpl_struct(dpl).lat   = col(param.lat);
    switch param.xyz_units
        case 'mm'
            dpl_struct(dpl).x = col(param.xcol);
            dpl_struct(dpl).y = col(param.ycol);
            dpl_struct(dpl).z = col(param.zcol);
        case 'cm'
            dpl_struct(dpl).x = col(param.xcol) * 10;
            dpl_struct(dpl).y = col(param.ycol) * 10;
            dpl_struct(dpl).z = col(param.zcol) * 10;
        case 'm'
            dpl_struct(dpl).x = col(param.xcol) * 1000;
            dpl_struct(dpl).y = col(param.ycol) * 1000;
            dpl_struct(dpl).z = col(param.zcol) * 1000;
        otherwise
    end
    dpl_struct(dpl).Qx = col(param.Qx);
    dpl_struct(dpl).Qy = col(param.Qy);
    dpl_struct(dpl).Qz = col(param.Qz);
    dpl_struct(dpl).Gof = col(param.Gof);
end
dpl_struct(dpl+1:end) = [];
fclose(fid);
