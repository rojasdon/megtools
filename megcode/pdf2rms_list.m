function pdf2rms_list(varargin)
%NAME:      pdf2spm5_list()
%AUTHOR:    Don Rojas, Ph.D., U. of Colorado Denver MEG Laboratory
%PURPOSE:   convert multiple 4D MEG datasets to spm5, taking either a file
%           list or cell array of filenames
%NOTES:     (1) will need to add resp/trig prompting at some point
%           (2) should add channel group function to restrict rms
%HISTORY:   11/14/08 - added crude division into l/r sensor based on
%           y-coordinate sign

split = 1;

%check input(s)
error(nargchk(0,1, nargin));
if nargin == 0
    %get files(s) from textfile
    filename = uigetfile({'*.txt';'*.lst';'*.*'}, ...
        'Select a text file containing a file listing');
    fp = fopen(filename,'r');
    i=1; fend=0;
    names = {};
    bases = {};
    while fend ~= 1
       tmp                      = fgetl(fp);
       [s, rem]                 = strtok(tmp);
       names{i}                 = s;
       [tmp, rem]               = strtok(s, filesep);
       while ~isempty(rem)
           [tmp, rem] = strtok(rem, filesep);
           if (tmp(1) == '0' || tmp(1) == '1') && (length(tmp) > 1)
               % to prevent 4D session names from being base name
               if isempty(strfind(tmp,'%')) 
                    bases{i} = tmp;
               end
           end
       end
       i = i + 1; fend = feof(fp);
    end
else
    %get files from cell array
    names = varargin{1};
    bases = {};
    for i = 1:length(names)
       tmp                      = names{i};
       [s, rem]                 = strtok(tmp);
       names{i}                 = s;
       [tmp, rem]               = strtok(s, filesep);
       while ~isempty(rem)
           [tmp, rem] = strtok(rem, filesep);
           if (tmp(1) == '0' || tmp(1) == '1') && (length(tmp) > 1)
               % to prevent 4D session names from being base name
               if isempty(strfind(tmp,'%'))
                    bases{i} = tmp;
               end
           end
       end
    end
end

disp(sprintf('Number of files to process = %s\n\n', int2str(length(names))));
%loop through file list
for i=1:length(names)
    disp(sprintf('Processing %s', bases{i}));
    %get meg data
    MEG = get4D(names{i});
    %get info from meg data
    switch ndims(MEG.data)
        case 3
            epochs = size(MEG.data,1);
            chan   = size(MEG.data,2);
            points = size(MEG.data,3);
        case 2
            chan   = size(MEG.data,1);
            points = size(MEG.data,2);
    end
    t      = zeros(1, points, 'single');
    prestim = MEG.pstim * 1000;
    for j = 1:points
        t(j) = prestim + (j - 1) * (MEG.epdur * 1000/points);
    end
    
    %find left and right sensor locations, if requested
    if split
        left  = find(MEG.cloc(:,3)>0);
        right = find(MEG.cloc(:,3)<0);
        lMEG  = MEG.data(:,left,:);
        rMEG  = MEG.data(:,right,:);
        rms   = xrms(lMEG)';
        save([bases{i} '_lRMS.mat'], 't','rms');
        rms   = xrms(rMEG)';
        save([bases{i} '_rRMS.mat'], 't','rms');
    else
        %convert to rms and save data
        rms = xrms(MEG.data)';
        save([bases{i} '_RMS.mat'], 't','rms');
    end
end
        