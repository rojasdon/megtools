function data = meg_eeg2edf(MEG,id,sex,birthdate,dateaq,timeaq,run,varargin)
% function to return eeg data from MEG structure, converted to edf file

% FIXME: figure out annotation signal

% defaults
scale = 1e3;
nsec  = 10;

if nargin > 2
    remontage=0;
else
    remontage=0;
end
    
% force to work only on cnt type MEG
if ~strcmpi(MEG.type,'cnt')
    error('Structure must be continuous format');
end

% if new montage requested, do it
if remontage
    MEG = meg_eeg_rereference(MEG);
end

% get eeg channels and info for writing data
eegi        = meg_channel_indices(MEG,'multi','EEG');
data        = MEG.data(eegi,:);
chan        = {MEG.chn(eegi).label};
eegonlyi    = find(~strcmpi(chan,'HEOG') & ~strcmpi(chan,'VEOG') & ~strcmpi(chan,'EKG'));
chan        = [chan 'EDF Annotations']; % add annotation channel for EDF+
data        = data*scale;
nsamp       = size(MEG.data,2);
sr          = round(1/(MEG.epdur/nsamp)); % EDF doesn't have fractional sampling
n_epochs    = deblank(num2str(floor(nsamp/(nsec*sr)))); % number of 10 s trials in data
l_epochs    = numel(n_epochs);
n_sensors   = size(data,1)+1; % add 1 for Annotations signal
n_sensorstr = deblank(num2str(n_sensors));
n_sampper   = nsec*sr;
n_sampstr   = deblank(num2str(n_sampper));

% scale to 2-byte signed integer
idata       = int16(data*(32767/(max(data(:)-min(data(:))))));
adata       = int16(zeros(1,size(data,2))); % annotation signal

% write edf+c format header (256 bytes)
pid = [id ' ' upper(sex(1)) ' ' upper(datestr(birthdate,'dd-mmm-yyyy')) ' EPILEPSY PATIENT'];
lid = numel(pid);
fprintf('Writing new EDF file...');
filename = [id '_' upper(datestr(dateaq,'mm-dd-yyyy')) '_run' deblank(num2str(run)) '.edf'];
fp = fopen(filename,'w');
fwrite(fp,'0       ','char*1'); % header format
fwrite(fp,[pid blanks(80-lid)],'char*1'); % local id
lri = ['Startdate ' upper(datestr(dateaq,'dd-mmm-yyyy')) ' MAGNES WH3600 ROJAS MEGEEG'];
lid = numel(lri);
fwrite(fp,[lri blanks(80-lid)],'char*1'); % local recording info
fwrite(fp,datestr(dateaq,'dd.mm.yy'),'char*1'); % startdate
fwrite(fp,datestr(timeaq,'HH.MM.SS'),'char*1'); % starttime
len_hdr = deblank(num2str(n_sensors*256+256));
fwrite(fp,[len_hdr blanks(8-numel(len_hdr))],'char*1'); % n bytes in header
fwrite(fp,['EDF+C' blanks(39)],'char*1'); % reserved EDF, EDF+C makes this EDF+
fwrite(fp,[n_epochs blanks(8-l_epochs)],'char*1'); % number of data records
fwrite(fp, [deblank(num2str(nsec)) blanks(6)],'char*1'); % number of seconds in data record
fwrite(fp,[n_sensorstr blanks(4-numel(n_sensorstr))],'char*1'); % number of signals in record

% write signal header portion (256+(n_sensors*256) bytes)
% labels
for ii=1:n_sensors % sensor labels
    nelem = numel(chan{ii});
    label = [char(chan{ii}) blanks(16 - nelem)];
    fwrite(fp,label,'char*1');
end

% transducer types
type=['AgAgCl disk electrodes' blanks(58)];
type=repmat(type,1,n_sensors-1);
fwrite(fp,type,'char*1'); % transducer types
fwrite(fp,blanks(80),'char*1'); % blank type for annotation

% physical dimension (i.e., units)
pdim=['uV' blanks(6)];
pdim=repmat(pdim,1,n_sensors-1);
fwrite(fp,pdim,'char*1'); % physical dimensions
fwrite(fp,blanks(8),'char*1'); % blank dim for annotation

% physical min/max and digital min/max
cmin = deblank(num2str(min(min(data(eegonlyi,:)))*1.1));
cmin = [cmin blanks(8-numel(cmin))];
cmin = repmat(cmin,1,n_sensors-1);
fwrite(fp,cmin,'char*1');
fwrite(fp,['-1' blanks(6)],'char*1'); % meaningless # req for annotation
cmax = deblank(num2str(max(max(data(eegonlyi,:)))*1.1));
cmax = [cmax blanks(8-numel(cmax))];
cmax = repmat(cmax,1,n_sensors-1);
fwrite(fp,cmax,'char*1');
fwrite(fp,['1' blanks(7)],'char*1'); % meaningless # req for annotation
cmin = deblank(num2str(min(min(idata(eegonlyi,:)))*1.1));
cmin = [cmin blanks(8-numel(cmin))];
cmin = repmat(cmin,1,n_sensors-1);
fwrite(fp,cmin,'char*1');
fwrite(fp,['-32768' blanks(2)],'char*1'); % meaningless # req for annotation
cmax = deblank(num2str(max(max(idata(eegonlyi,:)))*1.1));
cmax = [cmax blanks(8-numel(cmax))];
cmax = repmat(cmax,1,n_sensors-1);
fwrite(fp,cmax,'char*1');
fwrite(fp,['32767' blanks(3)],'char*1'); % meaningless # req for annotation

% pre-filtering string, number of samples and reserved space
prefilt=['HP:3Hz LP:70Hz' blanks(66)];
prefilt=repmat(prefilt,1,n_sensors-1);
fwrite(fp,prefilt,'char*1'); % prefiltering applied
fwrite(fp,blanks(80),'char*1'); % blank pre-filt string for annotation
nsamp=[n_sampstr blanks(8-numel(n_sampstr))];
nsamp=repmat(nsamp,1,n_sensors);
fwrite(fp,nsamp,'char*1'); % number of samples per data record
fwrite(fp,blanks(32*n_sensors),'char*1'); % reserved space

% write data to file, channels interleaved
for ii=1:str2num(n_epochs)
    for jj=1:n_sensors-1
        start = 1+n_sampper*(ii-1);
        stop  = ii*n_sampper;
        fwrite(fp,idata(jj,start:stop),'int16');
    end
    fwrite(fp,int16(adata(start:stop)),'int16');
end

% close file
fclose(fp);
fprintf('done\n');
end