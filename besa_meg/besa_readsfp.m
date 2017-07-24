function fid = besa_readsfp(filename)
% function to read in BESA 5.3 sfp file, output is MEG format fiducial field

if isempty(strfind(filename,'.'))
    filename = [filename '.sfp'];
end

% open file
fp = fopen(filename,'r');

% scan into cell struct: surf{1} = names, surf{2} = x, surf{3} = y, surf{4}
% = z coordinate, first 3 rows of each are fiducials
surf=textscan(fp,'%s %.6f %.6f %.6f');
fprintf('There are %d surface points defined in %s\n',length(surf{1}),filename);

% find indices and get fiducial points
% FIXME: x y are switched to conform to usual x, y, z coords for 4D MEG,
% may not generalize
[nas junk]       = find(strcmp(surf{1},'FidNAS'));
[lpa junk]       = find(strcmp(surf{1},'FidLPA'));
[rpa junk]       = find(strcmp(surf{1},'FidRPA'));
if isempty(nas)
    [nas junk] = find(strcmp(surf{1},'spmnas'));
    [lpa junk] = find(strcmp(surf{1},'spmnas'));
    [rpa junk] = find(strcmp(surf{1},'spmnas'));
end
fid.fid.pnt(1,1) = surf{2}(nas);
fid.fid.pnt(1,2) = surf{3}(nas);
fid.fid.pnt(1,3) = surf{4}(nas);
fid.fid.pnt(2,1) = surf{2}(lpa);
fid.fid.pnt(2,2) = surf{3}(lpa);
fid.fid.pnt(2,3) = surf{4}(lpa);
fid.fid.pnt(3,1) = surf{2}(rpa);
fid.fid.pnt(3,2) = surf{3}(rpa);
fid.fid.pnt(3,3) = surf{4}(rpa);
fid.fid.label    = cell(3,1);
fid.fid.label{1} = 'nas';
fid.fid.label{2} = 'lpa';
fid.fid.label{3} = 'rpa';
fid.fid.pnt      = fid.fid.pnt;

% find indices and get surface points
[ind junk]      = find(strncmp(surf{1},'Sfh',3));
fid.pnt         = zeros(length(ind),3);
fid.pnt(:,1)    = surf{2}(ind);
fid.pnt(:,2)    = surf{3}(ind);
fid.pnt(:,3)    = surf{4}(ind);

fclose(fp);