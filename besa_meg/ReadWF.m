% --------------------------------------------------------------------
% ReadWF: Read all information from a .swf or .uwf file  
% --------------------------------------------------------------------
function [Npts,TSB,DI,waveName,data] = ReadWF(filename)

fp = fopen(filename);

% Read the file
if (fp)
    % Read header of .swf file
    headline = fscanf(fp,'Npts= %f TSB= %f DI= %f SB= %f');
    % New BESA versions include more information in the .swf file header; skip that
    i=1;
    while i<1000
        a = fscanf(fp,'%c',1);
        if strcmp(a,sprintf('\n'))
            i=1000;
        end
        i=i+1;
    end
    
    Npts=headline(1);
    TSB=headline(2);
    DI=headline(3);        
    
    % Read first line after header to decide whether swf's are in rows or
    % columns
    row=1;
    SecondLine = fgets(fp);
    a=strfind(SecondLine,': ');
    if a(end) >= length(SecondLine)-10      %swf's are in columns (because there is a ":" within the last 11 characters of the second line)
        row=0;
    end

    % Read data and labels
    if row == 1             % swf's in rows
        Name = sscanf(SecondLine,'%s',1);
        data(1,:) = sscanf(SecondLine(length(Name)+1:end),'%f',[1 headline(1)]);
        waveName(1) = cellstr(Name(1:length(Name)-1));
        for i=2:1000
            try             % check if there is another waveform
                Name = fscanf(fp,'%s',1);            
                data(i,:) = fscanf(fp,'%f',[1,headline(1)]); 
                waveName(i) = cellstr(Name(1:length(Name)-1));
            catch           % stop if end of file is reached
                break  
            end
        end
    else                    % swf's in columns
        temp1 = SecondLine(1:a(1)-1);              
        temp2 = deblank(temp1(end:-1:1));
        waveName(1) = cellstr(temp2(end:-1:1));
        for i=2:length(a)
            temp1 = SecondLine(a(i-1)+2:a(i)-1);
            temp2 = deblank(temp1(end:-1:1));
            waveName(i) = cellstr(temp2(end:-1:1));
        end
        data = fscanf(fp,'%f',[length(a),headline(1)]);
        i=length(a)+1;
    end
end

waveNameChar = char(waveName);
for j=1:i-1
    O1(j)=(~isempty(findstr('-O1',waveNameChar(j,:))));  % check if there is an oriented regional source in the file (name ends with '-O1')
    O3(j)=(~isempty(findstr('-O3',waveNameChar(j,:))));  % check if there is an oriented regional EEG source in the file (name ends with '-O3')
end

% calculate power if there are oriented regional sources
if ~isempty(find(O1))           % There are regional sources
    if ~isempty(find(O3))       % EEG
        for i=find(O1)
            data(size(data,1)+1,:) = sqrt(data(i,:).^2+data(i+1,:).^2+data(i+2,:).^2);
            % new waveforms gets the string 'Power' appended to the basename
            RSbasename = char(waveName(i));
            waveName(length(waveName)+1) = cellstr([RSbasename(1:length(RSbasename)-2),'Power']);
        end
    else                        % MEG
        for i=find(O1)
            data(size(data,1)+1,:) = sqrt(data(i,:).^2+data(i+1,:).^2);
            % new waveforms gets the string 'Power' appended to the basename
            RSbasename = char(waveName(i));
            waveName(length(waveName)+1) = cellstr([RSbasename(1:length(RSbasename)-2),'Power']);
        end
    end
end

fclose(fp);
