function meg2besa(MEG,filebase)
%PURPOSE:   wrapper function that calls various export functions to write a BESA
%           generic header/raw data file and ancillary ascii files
%AUTHOR:    Don Rojas, Ph.D.
%INPUTS:    MEG - struct from get4D.m
%           filebase - base name without extension for output files
%EXAMPLES:  meg2besa(cnt,'04111'), writes the MEG struct cnt to a filename
%                                  base of '04011'
%NOTES:     1. Only converts continuous files

%SEE ALSO:  BESA2MEG

% limit to continuous for now
if ~strcmp(MEG.type,'cnt')
    error('Only continuous data conversion to BESA is currently supported!');
end

fprintf('Converting to BESA...');

% strip any extension off of filebase, if present
[pth filebase] = fileparts(filebase);

% write data file and header
besa_writedat(MEG,filebase);

% write channel definition file
besa_writeela(MEG,filebase);

% write channel location data
besa_writepos(MEG,filebase);

% write headshape and fiducials
besa_writesfp(MEG,filebase);

% write event data
besa_writeevt(MEG,filebase);

fprintf('done!\n');