function MEG = besa2meg(filebase)
%PURPOSE:   wrapper function that calls various export functions to write a BESA
%           generic header/raw data file and ancillary ascii files
%AUTHOR:    Don Rojas, Ph.D.
%IO:        MEG - struct from get4D.m
%           filebase - base name without extension for output files
%EXAMPLES:  cnt = besa2meg('04111'), outputs a MEG struct from besa input
%                 files prefixed 04111
%NOTES:     1. Only converts continuous files

%SEE ALSO:  MEG2BESA

%FIXME: add checking for mismatches of chan numbers and epoch numbers

% strip any extension off of filebase, if present
[pth, filebase] = fileparts(filebase);

% read data file and header *.dat/*.generic
[hdr, dat] = besa_readdat(filebase);

% read channel definitions
[ctypes, elalabels] = besa_readela(filebase);

% read channel location data
[poslabels, pos]=besa_readpos(filebase);

% read fiducials/headshape
fid=besa_readsfp(filebase);

% read event data
events = besa_readevt(filebase);

% assemble a MEG structure
MEG = [];
MEG.type  = 'cnt';
MEG.fname = filebase;
MEG.epdur = (1/hdr.sr)*hdr.nsamp;
MEG.pstim = hdr.prestim;
MEG.sr    = hdr.sr;
for ii=1:hdr.nchan
    chn(ii).label = elalabels{ii};
    chn(ii).type  = ctypes{ii};
    chn(ii).num   = ii;
end
MEG.chn          = chn;
MEG.cloc         = pos(:,1:6);
MEG.cori         = pos(:,7:12);
MEG.mchan        = {};
MEG.time         = 1:hdr.nsamp; MEG.time = (MEG.time*(1/MEG.sr))*1e3;
MEG.fiducials    = fid;
MEG.data         = single(dat); clear('dat');
latencies        = num2cell([events.latency]/(1/MEG.sr)); % convert to sample indices from seconds
[events.latency] = latencies{:};
MEG.events       = events;



