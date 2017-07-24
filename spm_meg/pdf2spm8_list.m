function pdf2spm8_list(varargin)
%NAME:      pdf2spm8_list()
%AUTHOR:    Don Rojas, Ph.D., U. of Colorado Denver MEG Laboratory
%PURPOSE:   convert multiple 4D MEG datasets to spm8, taking either a file
%           list or cell array of filenames
%NOTES:     (1) will need to add resp/trig prompting at some point

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
           if tmp(1) == '0'
               % to prevent 4D session names from being base name
               if isempty(strfind(tmp,'%')) 
                    bases{i} = tmp;
               end
           end
       end
       i = i + 1; fend = feof(fp);
    end
    disp(sprintf('Number of files to process = %s\n\n', int2str(length(names))));
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
           if tmp(1) == '0'
               % to prevent 4D session names from being base name
               if isempty(strfind(tmp,'%'))
                    bases{i} = tmp;
               end
           end
       end
    end
end

%loop through file list and process each file
for i=1:length(names)
    disp(sprintf('Processing %s', bases{i}));
    %create custom ctf file for each file
    ctf4D(names{i}, [bases{i} '_template']);
    %convert 4D file to SPM8 - NOTE: make more flexible!
    pdf2spm8(names{i}, bases{i}, 1, 'trig', [bases{i} '_template.mat']);
end
disp('Done with file conversion!');