function el = read_el(filename)

%read *.el file

%as of 04/06/09 *.el written as native-endian but should be big-endian
% fid = fopen(filename, 'r', 'b');
fid = fopen(filename, 'r');

index = 0;
while ftell(fid) < 640
    index = index + 1;
    el(index) = read_one_el(fid);
end

function one_el = read_one_el(fid)

one_el = struct( ...
    'loc', fread(fid, 3, '*double'), ...
    'lbl', fread(fid, 16, '*uchar'), ...
    'state_str', fread(fid, 16, '*uchar'), ...
    'state', fread(fid, 1, '*int32'), ...
    'padding', fread(fid, 4, '*uchar'));
