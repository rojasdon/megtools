function besa_writedat(filebase, datStruct)
% function to write a BESA 5.3 compatible raw binary data file and generic
% header

scale = 1e15; % scale to fT

% Write a generic header
fp = fopen([filebase '.generic'],'w');
fprintf(fp, 'BESA Generic Data\n');
fprintf(fp, 'nChannels=%d\n', datStruct.nChannels);
fprintf(fp, 'sRate=%f\n', datStruct.sRate);
fprintf(fp, 'nSamples=%d\n',datStruct.nSamples);
fprintf(fp, 'format=%s\n',datStruct.format);
fprintf(fp, 'file=%s\n',[filebase '.dat']);
fprintf(fp, 'prestimulus=%f\n',datStruct.prestim);
fprintf(fp, 'epochs=%d',datStruct.epochs);
fclose(fp);

% Figure out format
switch datStruct.format
    case 'float'
        format = 'float32';
    case 'short'
        format = 'int16';
    case 'int'
        format = 'int32';
    case 'double'
        format = 'double';
end

% Write data to file
if length(size(datStruct.Data)) == 2
    fp = fopen([filebase '.dat'],'w');
    fwrite(fp, datStruct.Data*scale, format);
else
    error('Array size must be 2 dimensional!');
end
fclose(fp);
end