function [Cnames Cpos Nchannels Rxy pos3D] = ctf4D(input_pdf, ctf_name)
% NAME:    ctf4D()
% AUTHORS: Eugene Kronberg, Ph.D. and Don Rojas, Ph.D.
% PURPOSE: to produce a customized site-specific channel template file for
%          SPM5 from a 4DNeuroimaging data set
% USAGE:   [Cnames Cpos Nchannels Rxy pos3D] = ctf4D(file, out)
% OUTPUT:  Cnames    = Channel names
%          Cpos      = channel positions projected to 2D flat map
%          Nchannels = number of channels
%          Rxy       = scaling of SPM5 channel display
%          pos3D     = 3D position of sensor
% INPUT:   input_pdf = 4D format pdf file name (not exported), typically
%                      something like e,rfp1.0Hz
%          ctf_name  = output ctf base name without .mat extension
% NOTES:   (1) will not properly convert magnetometer files.  SPM5 cannot
%          currently source analyze axial magnetometer data anyway.
%          (2) this program can be used any time the number of good/bad
%          channels in your system changes to generate a new ctf file.
%          (3) pdf4D matlab object (Eugene Kronberg) must be installed on
%          MATLAB path for this function to work.
% HISTORY: 03/18/08 - original code
%          07/06/08 - revised to show x-direction north instead of east      

pdf        = pdf4D(input_pdf);
chi        = channel_index(pdf,'meg','name');

%spm5 specific channel template file fields
Cnames     = channel_name(pdf, chi);
Nchannels  = length(chi);
Rxy        = 2;
Cpos       = zeros(2,Nchannels,'double');
pos3D      = zeros(3,Nchannels,'double');

% get channel locations into array
chn = channel_position(pdf, chi);
for i=1:Nchannels
    pos3D(:,i) = chn(i).position(1:3);
end

%do projection of 3D positions into 2D map
loc2d      = double(thetaphi(pos3D)); %flatten
loc2d(2,:) = -loc2d(2,:); %reverse y direction for better display

Cpos(2,:)  = loc2d(1,:);
Cpos(1,:)  = loc2d(2,:);

% save new ctf file
save([ctf_name '.mat'], 'Cnames', 'Cpos', 'Rxy', 'Nchannels', 'pos3D');