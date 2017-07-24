function preproc_list(varargin)
%NAME:      pdf2spm5_list()
%AUTHOR:    Don Rojas, Ph.D., U. of Colorado Denver MEG Laboratory
%PURPOSE:   convert multiple 4D MEG datasets to spm5, taking either a file
%           list or cell array of filenames
%NOTES:     (1) expand varargin to include optional scripting routes on
%           shell

%check input(s)
error(nargchk(0,1, nargin));
if nargin == 0
    error('Not supported at this time');
else
    %get files from cell array
    names           = varargin{1};
    psel            = {};
    for i=1:length(names) %convert from full path to psel path
        tmp             = names{i};
        [s, rem]        = strtok(tmp);
        names{i}        = s;
        s               = regexprep(names{i}, '@', ' ');
        [tmp, rem]      = strtok(s, filesep);
        while ~isempty(rem)
           [tmp, rem] = strtok(rem, filesep);
           if (tmp(1) == '0' || tmp(1) == '1') && (length(tmp) > 1)
               % to prevent 4D session names from being base name
               if isempty(strfind(tmp,'%'))
                    psel{i} = [tmp '@' rem];
                    psel{i} = regexprep(psel{i}, filesep, '@');
                    psel{i} = regexprep(psel{i}, '@@', '@');
                    psel{1} = regexprep(psel{i}, '%', '/');
               end
           end
        end
    end
    %make file list for shell script
    list = ['preproc_' date() '.lst'];
    fp = fopen(list,'w');
    for i = 1:length(names)
       fprintf(fp, '%s\n', psel{i});
    end
    fclose(fp);
    
    %run shell script
    eval(['!/opt/msw/users/scripts/AEF1Hz_list.sh ' pwd filesep list]);
end

