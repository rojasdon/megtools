% function to write structural image and functional images to dicom format for use in clinical MEG program

clear all;

% set this depending on need to rotate images
rot = 1; % often in the nifti/analyze, images are rotated 90 from original
threshold = 15; % to mask the functional data

% set this if you want it not to overwrite an existing series on import
% into a program like OsiriX
str_seriesID   = 13; % choose unique number not already used for patient
str_seriesname = 'T1 MEG COREG'; % unique name
fun_seriesID   = str_seriesID + 1;
fun_seriesname = 'MEG OVERLAY';


% pick original dicom - should be same as the one you wrote the analyze or
% nifti volume from that you used for source analysis
D = spm_select([1 Inf],'.*dcm','Select dicom images of structural used');
origdicombase = 'IM-0001-';

% read in images
F = strtok(spm_select(1,'image','Select functional image volume'),',');
S = strtok(spm_select(1,'image','Select structural image volume'),',');
Fhdr=spm_vol(F);
Shdr=spm_vol(S);
fvol=spm_read_vols(Fhdr);
svol=spm_read_vols(Shdr);
nslices = size(svol,3);

% read dicom metadata from the original dicom
for slice = 1:nslices
    num =  strtrim(num2str(slice));
    fprintf('Reading metadata for slice %d\n',num);
    orig_metadata(slice)                     = dicominfo(D(slice,:));
    orig_metadata(slice).SeriesNumber        = str_seriesID;
    orig_metadata(slice).SeriesDescription   = str_seriesname;
end

% create a base name from structural image
[pth nam ext] = fileparts(Shdr.fname);

% loop through slices to write structural data
for slice = 1:nslices
    fprintf('Structural slice %d\n',slice);
    dat = uint16(squeeze(svol(:,:,slice)));
    if rot; dat = rot90(dat,-1); end;
    dicomwrite(dat,[nam '_struct_' strtrim(num2str(slice)) '.dcm'],orig_metadata(slice));
end

% change metadata for functional slices
func_metadata = orig_metadata;
for slice = 1:nslices
    func_metadata(slice).SeriesNumber        = fun_seriesID;
    func_metadata(slice).SeriesDescription   = fun_seriesname;
    func_metadata(slice).ColorType           = 'truecolor';
    func_metadata(slice).BitDepth            = 32;
end

% threshold
if ~isempty(threshold)
    fvol(fvol <= threshold) = 0;
end

% loop through slices to write functional data
for slice = 1:nslices
    fprintf('Overlay slice %d\n',slice);
    dat = uint16(squeeze(fvol(:,:,slice)));
    if rot; dat = rot90(dat,-1); end;
    dicomwrite(dat,[nam '_func_' strtrim(num2str(slice)) '.dcm'],func_metadata(slice));
end