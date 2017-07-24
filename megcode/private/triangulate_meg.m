function tri = triangulate_meg(cloc)
% TRIANGULATE_MEG creates triangle faces from vertices (cloc)
% AUTHOR: Don Rojas, Ph.D., simplified from code supplied by Keeran
%         Maharajh, Ph.D. to work with MEG struct routines
% INPUT:  cloc = 3 x nchan array of coil locations
% OUTPUT: tri

if size(cloc,1) ~= 3
    cloc = cloc';
end

% flatten and triangulate
loc2d = double(thetaphi(cloc));
tri   = delaunay(loc2d(2,:),loc2d(1,:));

end