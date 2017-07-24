function mri = meg2mri(meg,filename)
% PURPOSE:   convert meg coordinates to mri coordinates
%            uses xfm created by mro program
% AUTHOR:    Don Rojas, Ph.D.
% INPUT:     filename of xfm
% OUTPUT:    coordinates in mri space
% NOTES:     currently does not work

error('Function not ready yet!');

% read in transform
Mfile     = load(filename,'-mat');
Dname     = fieldnames(Mfile);
transform = getfield(Mfile, Dname{1});

% read in file of coordinates
fpi = fopen('MEGcoords.txt','r');
tmp = fgetl(fpi);

% file for output
fpo = fopen('MRIcoords.txt','w');

% loop through file to convert
i=1; fend=0;
while fend ~= 1
    tmp = fgetl(fpi);
    tmp = textscan(tmp,'%f','Delimiter',',');
    tmp = tmp{1};
    id   = tmp(1);
    lxyz = tmp(2:4);
    rxyz = tmp(5:7);
    % do transform
    lxyz = transform.matrix' * lxyz(:) + transform.vector(:);
    rxyz = transform.matrix' * rxyz(:) + transform.vector(:);
    lxyz = int16(lxyz);
    rxyz = int16(rxyz);
    fprintf(fpo,'%d, %d, %d, %d, %d, %d, %d\n', ... 
        id, lxyz(2), lxyz(1), lxyz(3), rxyz(2),rxyz(1), rxyz(3));
    i = i + 1; fend = feof(fpi);
end

fclose('all');