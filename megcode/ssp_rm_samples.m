function sspout = ssp_rm_samples(ssp, varargin)
% Function: ssp_rm_samples.m
% Author:   Don Rojas, Ph.D.
% Purpose:  To remove sample points from beginning or end of an ssp
%           structure
% Inputs:   ssp structure, argument pair, either,
%           'begin', point OR 'end', point
%           where 'begin' or 'end' indicates first or last sample point
%           in the ssp structure output, and point is the sample
%           number itself, not time point
% Outputs:  ssp structure
% Usage:    ssp = ssp_rm_samples(ssp,'begin',5) will result in trimming off
%           the first 4 samples in the ssp output (5 being the new first
%           point).
% To do:    1. allow trimming from beginning and end in same call
% See also: SSP

% History:  03/24/11 - first working version

% check input
if nargin < 2
    error('This function requires two inputs');
end
if isempty(varargin)
    error('There is nothing to do');
else
    optargin = size(varargin,2);
    if (mod(optargin,2) ~= 0)
        error('Optional arguments must come in option/value pairs');
    else
        for i=1:2:optargin
            switch varargin{i}
                case 'begin'
                    last     = size(ssp.Q,2);
                    first    = varargin{i+1}; 
                case 'end'
                    first    = 1;
                    last     = varargin{i+1};
                otherwise
                    error('Invalid option!');
            end
        end
    end
end

% some information
sr    = ssp.epdur/size(ssp.Q,2);
ind   = first:last;
nsize = length(ind);

% trim the requested samples off ends
sspout              = ssp;
ssp.epdur           = sr*nsize;
sspout.Q            = zeros(size(ssp.Q,1),nsize);
sspout.Q(:,:)       = ssp.Q(:,ind);
sspout.time         = zeros(nsize);
sspout.time         = ssp.time(ind);
end