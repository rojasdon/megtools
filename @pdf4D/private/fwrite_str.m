function  fwrite_str(fid, str, n)

%convert char array into 'uint8' array of length n
%and write to file

new_str = zeros(1, n, 'uint8');
new_str(1:length(str)) = uint8(str);
fwrite(fid, new_str, 'uint8');
