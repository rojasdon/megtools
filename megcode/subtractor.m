function MEG = subtractor(MEG1,MEG2)
% PURPOSE: To subtract MEG averaged datasets.
% AUTHOR:  Don Rojas, Ph.D.
% INPUTS:  two MEG structs, separated by commas
% OUTPUT:  a MEG struct - see get4D.m
% NOTES:   1. the second input is subtracted from the first, op1 - op2 =
%          output, header taken from first input

% HISTORY: 12/4/10  - minor rev to check sizes
%          09/20/11 - revised for compatibiltiy with current MEG format

% check input to function
nargs = nargin;
if nargs < 2
    error('There must be 2 datasets to proceed');
else
    fprintf('Subtracting dataset %s from %s...',MEG2.fname,MEG1.fname);
end

% check data types
if ~strcmp(op1.type,'avg') || ~strcmp(op2.type,'avg')
    error('Datasets must both be averages...');
end

% check size compatibility
s1 = size(MEG1.data);
s2 = size(MEG2.data);
if (s1(1) ~= s2(1)) || (s1(2) ~= s2(2))
    error('Datasets are not the same size!');
end

% subtract and return corrected structure
cind     = meg_channel_indices(MEG1,'multi','MEG');
tmp      = MEG1.data(cind,:) - MEG2.data(cind,:);
MEG      = MEG1;
MEG.data = tmp;
fprintf('done\n');

end