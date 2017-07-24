%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   Read calc_coil_pos xfm
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function xfm = read_user_block_ccpxfm3600(fid)
xfm.stat = fread(fid, 1, '*uint16');
xfm.xfm0 = fread(fid, 1, '*double',0,'b')
xfm.xfm0 = fread(fid, [1,3], '*double',0,'b')
xfm.stat = fread(fid, 1, '*uint16')
xfm.xfm1 = fread(fid, [1,4], '*double',0,'l')
xfm.xfm2 = fread(fid, [1,4], '*double',0,'l')
xfm.xfm = fread(fid, [1,4], '*double',0,'l')

