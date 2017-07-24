function write_pdf(obj, data, pdf_id, chan_label, dr, trig)

% WRITE_PDF write_pdf(obj, data, pdf_id, chan_label, dr, trig)
% data - channel by latency matrix
% pdf_id - filename for the new pdf (the rest of ids taken from the obj)
% chan_label - cell array of channel names
% dr - digitization rate [Hz]
% trig - trigger onset [sec]

switch nargin
    case 2
        pdf_id = get(obj, 'pdfid');
        chan_label = {'A1'};
        dr = 1;
        trig = 0;
        %create entry in database and small pdf
        asc_to_pdf(obj, 0, pdf_id, chan_label, dr, trig);
        %always big endian (Sun, Mac or Linux)
%         get(obj, 'filename')
        fid = fopen(get(obj, 'filename'), 'w', 'b');
        write_data(fid, obj.Header, data);
        write_header(fid, obj.Header);
        fclose(fid);
    case 6
        asc_to_pdf(obj, data, pdf_id, chan_label, dr, trig);
    otherwise
        error('Wrong number of inputs')
end

function write_data(fid, header, data)
%BTi Data Formats:
SHORT   =	1;
LONG    =	2;
FLOAT   =	3;
DOUBLE  =	4;

switch header.header_data.data_format
    case SHORT
        data_format = 'int16';
    case LONG
        data_format = 'int32';
    case FLOAT
        data_format = 'float32';
    case DOUBLE
        data_format = 'double';
    otherwise
        error('Wrong data format : %d\n', header.header_data.data_format);
end
fwrite(fid, data, data_format);

function asc_to_pdf(obj, data, pdf_id, chan_label, dr, trig)
%tmp file for msi data (name includes date and time)
tmp_file = ['/tmp/pdf4D' sprintf('.%d', fix(clock))];

fid=fopen(tmp_file,'w');

%number of channels, number of time points
fprintf(fid, '%d\n%d\n', size(data,1), size(data,2));

%channel names
for ch = 1:length(chan_label)
    fprintf(fid, '\t%s', chan_label{ch});
end
fprintf(fid, '\n');

%ascii data
for ti = 1:size(data, 2)
    fprintf(fid, '\t%d', data(:,ti));
    fprintf(fid, '\n');
end

fclose(fid);

%command to run asc_to_pdf
run_asc_to_pdf = sprintf( ...
    ['asc_to_pdf -P "%s" -S "%s" -s "%s" -r "%s" -o "%s" ', ...
     '-f %s -R %f -T %f > /dev/null \n'], ...
    get(obj, 'patient'), get(obj, 'scan'), get(obj, 'session'), ...
    get(obj, 'run'), pdf_id, tmp_file, dr, trig);
[stat, msg] = unix(run_asc_to_pdf);

%clean up
delete(tmp_file);