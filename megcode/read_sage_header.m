function S = read_sage_header(filename)
% read SAGE header and return location information about voxel
% FIXME: extend later to return more useful info

% add extension if left off
if isempty(strfind(filename,'.'))
    filename = [filename '.shf'];
end

% read text from file
fp = fopen(filename,'r');
C  = textscan(fp,'%s');
fp = fclose(fp);

% find location info, opuser fields are more useful than RAS fields
% note: ras is positive coord, lpi is negative
ind = strmatch('patient_name',C{1});
S.patient_id = char(C{1}(ind+1));
ind = strmatch('tlhc_R',C{1});
S.tlhc_R = str2num(char(C{1}(ind+1)));
ind = strmatch('tlhc_A',C{1});
S.tlhc_A = str2num(char(C{1}(ind+1)));
ind = strmatch('tlhc_S',C{1});
S.tlhc_S = str2num(char(C{1}(ind+1)));
ind = strmatch('trhc_R',C{1});
S.trhc_R = str2num(char(C{1}(ind+1)));
ind = strmatch('trhc_A',C{1});
S.trhc_A = str2num(char(C{1}(ind+1)));
ind = strmatch('trhc_S',C{1});
S.trhc_S = str2num(char(C{1}(ind+1)));
ind = strmatch('brhc_R',C{1});
S.brhc_R = str2num(char(C{1}(ind+1)));
ind = strmatch('brhc_A',C{1});
S.brhc_A = str2num(char(C{1}(ind+1)));
ind = strmatch('brhc_S',C{1});
S.brhc_S = str2num(char(C{1}(ind+1)));
ind = strmatch('opuser8',C{1});
S.lrdim  = str2num(char(C{1}(ind+1)));
ind = strmatch('opuser9',C{1});
S.apdim  = str2num(char(C{1}(ind+1)));
ind = strmatch('opuser10',C{1});
S.sidim  = str2num(char(C{1}(ind+1)));
ind = strmatch('opuser11',C{1});
S.lrcenter  = str2num(char(C{1}(ind+1)));
ind = strmatch('opuser12',C{1});
S.apcenter  = str2num(char(C{1}(ind+1)));
ind = strmatch('opuser13',C{1});
S.sicenter  = str2num(char(C{1}(ind+1)));


end