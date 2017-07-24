function [mdip dpl] = meg_clinical_process_dipoles(filename,varargin)
% read a dipole file for clinical interp

% defaults
Gof  = .9;
xmax = 80;
xmin = -80;
ymax = 70;
ymin = -70;
zmax = 90;
zmin = -40;

% change defaults if requested
if ~isempty(varargin)
    optargin = size(varargin,2);
    if (mod(optargin,2) ~= 0)
        error('Optional arguments must come in option/value pairs');
    else
        for i=1:2:optargin
            switch lower(varargin{i})
                case 'gof'
                    Gof       = varargin{i+1};
                case 'xmax'
                    xmax      = varargin{i+1};
                case 'xmin'
                    xmin      = varargin{i+1};
                case 'ymax'
                    ymax       = varargin{i+1};
                case 'xmin'
                    ymin      = varargin{i+1};
                case 'zmax'
                    zmax      = varargin{i+1};
                case 'zmin'
                    zmin      = varargin{i+1};
                otherwise
                    error('Invalid option!');
            end
        end
    end
end

% default parameters for reading dipoles
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

% read dipole file
dpl = read_msi_dipole(filename,param);

% select dipoles on Gof criterion
[junk gind] = find([dpl.Gof] >= Gof);
dpl = dpl(gind);

% select remaining dipoles on location range
badind = find([dpl.x] < xmin | [dpl.x] > xmax);
badind = [badind find([dpl.y] < ymin | [dpl.y] > ymax)];
badind = [badind find([dpl.z] < zmin | [dpl.z] > zmax)];
badind = unique(badind);
dpl(badind)=[];

% get mean dipole
mdip   = dpl(1);
mdip.x = mean([dpl.x]);
mdip.y = mean([dpl.y]);
mdip.z = mean([dpl.z]);
mdip.Qx = mean([dpl.Qx]);
mdip.Qy = mean([dpl.Qy]);
mdip.Qz = mean([dpl.Qz]);
mdip.Gof = mean([dpl.Gof]);