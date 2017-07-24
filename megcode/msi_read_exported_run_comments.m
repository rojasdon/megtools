function c = msi_read_exported_run_comments(file)
    offset = 400; % bytes in export run comment file
    csize  = 16;  % comment size in bytes - probably needs to change
    if exist(file,'file')
        fp=fopen(file,'r');
    else
        error('File does not exist!');
    end
    fseek(fp,0,'eof');
    p=ftell(fp);
    if p < offset
        fclose(fp);
        error('No run comment!');
    else
        fseek(fp,offset,'bof');
        c=fread(fp,csize,'uint8=>char')';
    end
    fclose(fp);
end