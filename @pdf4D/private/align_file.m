function align_file(fid)

%all structures always start at byte sizeof(double)*N,
%where N is integer and sizeof(double) == 8
%(see <libdftk>/dftk_misc.C: int dftk_align(FILE *fp))

current_position = ftell(fid);
if mod(current_position, 8) ~= 0
    offset = 8 - mod(current_position,8);
    [dum, permission] = fopen(fid);%do we read or write file?
    switch permission
        case {'r' 'rb'}%rb for windows
            fseek(fid, offset, 'cof');%go to next 8*N position
        case {'w' 'wb'}%wb for windows
            fwrite(fid, zeros(1,offset,'uint8'), 'uint8');%white zeros
        otherwise
            error('Wrong permission %s', permission)
    end
end