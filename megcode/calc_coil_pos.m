function calc_coil_pos(pdf, coh, co, tcm, icl, cnf)
% cal_coil_pos(pdf, coh, co, tcm, icl, cnf)
%
% Calculate new transformation matrix (this is front-end for msi
% calc_coil_pos program, new transformation would be forced)
% pdf - pdf4D object for any file in the run for which config should be
%       fixed
% coh - COH file to use: 0 for COH, 1 for COH1 (default COH)
% co - coil order: string, list of coils separated by comas.
%       Use 0 to skip coil. (default use all coils in original order)
% tcm - Transformation Creation Method:
%       0 - Identity
%       1 - Coil Matching
%       2 - Head Fiducial
%       (default Coil Matching)
% icl - Ignore channel list: string, list of channel separated by comas
% cnf - Configuration file name (default Colorado_Aug2010)
%
%Copyleft 2011, eugene.kronberg@ucdenver.edu

%default COH file
if nargin < 2 || isempty(coh) || coh == 0
    coh = 'e,rfhp1.0Hz,COH';
elseif coh == 1
    coh = 'e,rfhp1.0Hz,COH1';
else
    error('Wrong input for COH file')
end

%default coil order
if nargin < 3 || isempty(co)
    co = '';
else
    co = sprintf(' -O %s', co);
end

%default transformation creation method
if nargin < 4 || isempty(tcm)
    tcm = 1;
end

%default "ignore channel list"
if nargin < 5 || isempty(icl)
    icl = '';
else
    icl = sprintf('-I %s', icl);
end

%default config file
if nargin < 6 || isempty(cnf)
    cnf = 'Colorado_Aug2010';
end

run = sprintf('calc_coil_pos -C %s -P "%s" -S "%s" -s "%s" -r %s -p %s -f %s -X %d %s', ...
    cnf, get(pdf, 'patient'), get(pdf, 'scan'), get(pdf, 'session'), ...
    get(pdf, 'run'), coh, co, tcm, icl);

[s,w] = unix(run);
if s~=0
    error('Error while running calc_coil_pos:\n%s', w)
end