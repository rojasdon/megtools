function lf = meg_singlesphere_lf(bfs,dipole,cloc)
% NAME:    meg_singlesphere_lf.m
% AUTHORS: Peter Teale, M.S.E.E. and Don Rojas, Ph.D.
% PURPOSE: Lead field computed using Sarvas's vector formulation for the 
%          forward solution as in Sarvas (Basic Mathematical and electromagnetic 
%          concepts of the biomagnetic inverse problem, Phys Med Biol, 1987)
% USAGE:   lf        = meg_singlesphere_lf(bfs, dipole, cloc)
% OUTPUT:  lf        = nchan * 3 leadfield array
% INPUTS:  bfs       = x, y, z location of best-fitting sphere, in meters
%          dipole    = x, y, z loc (meters) and Qx, Qy, Qz (in nA-m) for dipole
%          cloc      = nchannels x 6 array of numbers and coil locations 
%                      and orientations (e.g., x, y, z, ox, oy, oz). For
%                      gradiometers, provide lower coil numbers, in meters.
% SEE ALSO: MEG_SSP

% HISTORY: 10/12/11 - first version, separated from old ssp.m 

% some crude error checking
error(nargchk(3, 3, nargin));
if length(bfs) ~= 3
    error('Best fit sphere must be an array of form [x y z]');
end
if length(dipole) ~= 6
    error('Dipole params must be an array of form [x y z Qx Qy Qz]');
end

% get some dipole parameters and some info about meg data
rz      = dipole(1:3);% Sarvas r sub zero will be rz (location of the dipole)
q       = dipole(4:6); % source strength vector

% convert channel locations to best fit sphere coordinates
nchan = size(cloc,1);
for i = 1:nchan
    cloc(i,1:3) = cloc(i,1:3)-bfs;
end
rz = rz - bfs;

% preallocate some arrays for speed
qx  = [1;0;0];       qy  = [0;1;0];       qz  = [0;0;1];
Bx  = zeros(nchan,3,'single'); By  = zeros(nchan,3,'single'); Bz  = zeros(nchan,3,'single');
Bx2 = zeros(nchan,3,'single'); By2 = zeros(nchan,3,'single'); Bz2 = zeros(nchan,3,'single');
lf   = zeros(nchan,3,'single');

% compute the vector a from the dipole location to the various coil
% (measurment) locations, i.e., a(i) = cloc(i) - rz(i)
% note that norm(a) is the magnitude of the vector a
% calculate the lead field array L
for i = 1:nchan
    r        = cloc(i,1:3); % vector to coil location
    rg       = cloc(i,4:6) * .05; % vector to upper coil from lower coil in meters
    r2       = r + rg; r2mag = norm(r2);
    a        = r - rz; a2 = r2 - rz;
    rmag     = norm(r);
    amag     = norm(a); a2mag = norm(a2);
    F        = amag*(rmag*amag + rmag^2 - dot(rz,r)); % Sarvas's F
    delFr    = (amag^2/rmag + dot(a,r)/amag + 2*amag + 2*rmag)*r;
    delFrz   = (amag +2*rmag + dot(a,r)/amag)*rz;
    delF     = delFr - delFrz;
    Bx(i,:)  = (1e-7) * (F*cross(qx,rz) - dot(cross(qx,rz),r)*delF)/F^2;
    By(i,:)  = (1e-7) * (F*cross(qy,rz) - dot(cross(qy,rz),r)*delF)/F^2;
    Bz(i,:)  = (1e-7) * (F*cross(qz,rz) - dot(cross(qz,rz),r)*delF)/F^2;
    F2       = a2mag*(r2mag*a2mag + r2mag^2 - dot(rz,r2)); % Sarvas's F
    delFr2   = (a2mag^2/r2mag + dot(a2,r2)/a2mag + 2*a2mag + 2*r2mag)*r2;
    delFrz2  = (a2mag +2*r2mag + dot(a2,r2)/a2mag)*rz;
    delF2    = delFr2 - delFrz2;
    Bx2(i,:) = (1e-7) * (F2*cross(qx,rz) - dot(cross(qx,rz),r2)*delF2)/F2^2;
    By2(i,:) = (1e-7) * (F2*cross(qy,rz) - dot(cross(qy,rz),r2)*delF2)/F2^2;
    Bz2(i,:) = (1e-7) * (F2*cross(qz,rz) - dot(cross(qz,rz),r2)*delF2)/F2^2;
    lf(i,1)   = dot(Bx(i,:),cloc(i,4:6)) - dot(Bx2(i,:),cloc(i,4:6));
    lf(i,2)   = dot(By(i,:),cloc(i,4:6)) - dot(By2(i,:),cloc(i,4:6));
    lf(i,3)   = dot(Bz(i,:),cloc(i,4:6)) - dot(Bz2(i,:),cloc(i,4:6));
end
