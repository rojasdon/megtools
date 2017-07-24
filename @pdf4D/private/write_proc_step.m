%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   Write Process Step
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function write_proc_step(fid, step)

%all structures always start at byte sizeof(double)*N,
%where N is integer and sizeof(double) == 8
%(see <libdftk>/dftk_misc.C: int dftk_align(FILE *fp))
align_file(fid);

fwrite(fid, step.hdr.nbytes, 'uint32');
fwrite(fid, step.hdr.type, 20);
fwrite(fid, step.hdr.checksum, 'int32');

switch step.hdr.type
    case {'b_filt_hp' ...
          'b_filt_lp' ...
          'b_filt_notch'}
        fwrite(fid, step.frequency, 'float32');
        fwrite(fid, step.reserved, 'uint8');
    case {'b_filt_b_pass' ...
          'b_filt_b_reject'}
        fwrite(fid, step.high_frequency, 'float32');
        fwrite(fid, step.low_frequency, 'float32');
        fwrite(fid, step.reserved, 'uint8');
        fwrite(fid, zeros(1, 4, 'uint8'), 'uint8');%alignment
%         fseek(fid, 4, 'cof');%alignment
    otherwise   %user process 
        fwrite(fid, step.user_space_size, 'uint32');
        fwrite(fid, step.reserved, 'uint8');
        %write user data as array of bytes
        fwrite(fid, step.user_data, 'uint8');
        fwrite(fid, zeros(1, mod(double(step.user_space_size),8), 'uint8'), 'uint8');%alignment
%         fseek(fid, mod(double(step.user_space_size),8), 'cof');%alignment
end