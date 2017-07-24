%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   Read COH Points (COHBlock)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% from COH.h
% #define MAX_COH_POINTS		(16)
% struct COHPnt
% {	Pnt	pos;
% 	Vec	dir;
% 	double	error;
% };
% 
% struct COHBlock
% {	long	NumPoints;
% 	long	status;
% 	COHPnt	points [MAX_COH_POINTS];
% };
function COH_Points = read_user_block_coh3600(fid)

MAX_COH_POINTS = 16;

COH_Points.NumPoints = fread(fid, 1, '*uint32');
COH_Points.status = fread(fid, 1, '*uint32');
COH_Points.COHPnt = cell(1, MAX_COH_POINTS);

for ii = 1:MAX_COH_POINTS
    COH_Points.COHPnt{ii} = read_coh_point(fid);
end

function coh_point = read_coh_point(fid)
coh_point.pos = fread(fid, 3, '*double');
coh_point.dir = fread(fid, 3, '*double');
coh_point.error = fread(fid, 1, '*double');
