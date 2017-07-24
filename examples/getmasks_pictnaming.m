% script to extract aal brain masks from ch2better

aalhdr=spm_vol('aal.nii');
aalvol=spm_read_vols(aalhdr);
lsma=find(aalvol == 19); %19 is left sma label value in aal
rsma=find(aalvol == 20);
lpre=find(aalvol == 1);
rpre=find(aalvol == 2);
lpost=find(aalvol == 57);
rpost=find(aalvol == 58);
cereb=find((aalvol > 90) & (aalvol < 109));
ch2hdr=spm_vol('ch2_best.nii');
ch2vol=spm_read_vols(ch2hdr);

% extract raw data from within rois on specified T1

newhdr=ch2hdr;
newvol=zeros(181,217,181);
newvol(lsma)=ch2vol(lsma);
newhdr.fname='lsma.nii';
spm_write_vol(newhdr,newvol);

newvol=zeros(181,217,181);
newvol(rsma)=ch2vol(rsma);
newhdr.fname='rsma.nii';
spm_write_vol(newhdr,newvol);

newvol=zeros(181,217,181);
newvol(lpre)=ch2vol(lpre);
newhdr.fname='lpre.nii';
spm_write_vol(newhdr,newvol);

newvol=zeros(181,217,181);
newvol(rpre)=ch2vol(rpre);
newhdr.fname='rpre.nii';
spm_write_vol(newhdr,newvol);

newvol=zeros(181,217,181);
newvol(lpost)=ch2vol(lpost);
newhdr.fname='lpost.nii';
spm_write_vol(newhdr,newvol);

newvol=zeros(181,217,181);
newvol(rpost)=ch2vol(rpost);
newhdr.fname='rpost.nii';
spm_write_vol(newhdr,newvol);

newvol=zeros(181,217,181);
newvol(cereb)=ch2vol(cereb);
newhdr.fname='cereb.nii';
spm_write_vol(newhdr,newvol);

% threshold and save surfaces

spm_surf('lsma.nii',2,80); % 80 is threshold - adjust for your data
spm_surf('rsma.nii',2,80);
spm_surf('lpre.nii',2,80);
spm_surf('rpre.nii',2,80);
spm_surf('lpost.nii',2,80);
spm_surf('rpost.nii',2,80);
spm_surf('cereb.nii',2,80);