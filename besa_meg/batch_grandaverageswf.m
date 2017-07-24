% batch script to read in BESA source waveform files (*.swf) and do a grand
% average of them

% get list of files
[files paths]=uigetfile('*1310Hz.swf','MultiSelect','on');

if ischar(files)
    nfiles = 1;
else
    nfiles = size(files,2);
end
   
for i=1:nfiles
    if ischar(files)
        cur = files;
    else
        cur = char(files(i));
    end
    
    % read waveform file 
    fprintf('Reading file: %s\n', cur);
    swf=readBESAswf(cur);
    
    if i == 1
        % create array to hold waveforms
        waves = zeros(nfiles,length(swf.data));
    end
    
    % if there is more than 1 waveform in file, use mean
    if size(swf.data,1) > 1
        swf.data = mean(swf.data);
    end   
    
    waves(i,:) = swf.data;
end

% create struct with data
ga.time = swf.Time;
ga.data = mean(waves);