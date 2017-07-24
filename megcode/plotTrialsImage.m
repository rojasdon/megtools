function hnd = plotTrialsImage(S, chn, varargin)
% PURPOSE: to plot an ERPimage of single trials relative to a stimulus or
% response locked event from MEG or SPM data struct

% crude determination of type of input structure
if isfield(S,'mchan')
    type = 'MEG';
    data = S.data;
else
    type = 'SPM';
    data = permute(S(:,:,:),[3 1 2]);
end
fprintf('Data structure is %s',type);
epochs = 1:size(data,1); time = S.time;

% plot single trials with amplitude as color
hnd = figure('name','Single trial image','color','white');
contourf(time,epochs,data,squeeze(data(:,chn,:)),'linestyle','none');
end