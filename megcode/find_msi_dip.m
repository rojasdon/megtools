function [bfit sel flags] = find_msi_dip(dpl,constrain)
% Purpose: find best fitting time point given constraints

% default constraints
check.Gof  = .9;
check.xmin = -90;
check.xmax = 90;
check.ymin = 20;
check.ymax = 90;
check.zmin = 0;
check.zmax = 100;

% custom constraints in future processed here

% flags for potentially bad data
flags.Gof  = 0;
flags.xmin = 0;
flags.xmax = 0;
flags.ymin = 0;
flags.ymax = 0;
flags.zmin = 0;
flags.zmax = 0;

ndip = length(dpl);

% enforce constraints, if specified
if constrain
    set         = find([dpl.x] > check.xmin & [dpl.x] < check.xmax & ...
                       [dpl.z] > check.zmin & [dpl.z] < check.zmax & ...
                       abs([dpl.y]) > check.ymin & ...
                       abs([dpl.y]) < check.ymax);
    sel         = dpl(set)';
    [val ind]   = max([sel.Gof]);
    bfit        = sel(ind);
else
    sel         = dpl(:)';
    [val ind]   = max([dpl.Gof]);
    bfit        = dpl(ind);
end

% check dipole parameters and flag potentially bad ones
if bfit.Gof < check.Gof; flags.Gof = 1; end;
if bfit.x < check.xmin; flags.xmin = 1; end;
if bfit.x > check.xmax; flags.xmax = 1; end;
if abs(bfit.y) < check.ymin; flags.ymin = 1; end;
if abs(bfit.y) > check.ymax; flags.ymax = 1; end;
if bfit.z < check.zmin; flags.zmin = 1; end;
if bfit.z > check.zmax; flags.zmax = 1; end;
names = fieldnames(flags);
for ii = 1:length(names)
    if getfield(flags,char(names(ii)))
        fprintf('\nCheck %s value',char(names(ii)));
    end
end
    
end