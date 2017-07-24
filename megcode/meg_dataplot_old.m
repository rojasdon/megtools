function hnd = meg_dataplot_old(varargin)
%PURPOSE:   function to plot trials from MEG structure input
%AUTHOR:    Don Rojas, Ph.D.  
%INPUT:     Required: MEG structure - see get4D.m
%OUTPUT:    handle to figure
%EXAMPLES:  hnd = meg_dataplot('data',epoch) will plot the MEG struct epochs
%TODO:      1. ica/pca
%           2. draw a line at point of click and use for deleting portions
%              of data/marking as bad
%           3. show/mark events/epoch values if available
%           4. enable/disable buttons contextually
%SEE ALSO:  MEG_PLOT2D, DELETER

%HISTORY:   05/23/11 - first version
%           06/10/11 - bugfixes
%           08/19/11 - fixed bug with respect to channel indexing when
%                      references present in data structure
%           08/22/11 - bugfix for representation of time vector as int
%                      instead of uint32 (math wrong when time > 65535)

% global variables
global chanstoplot rgb;

% defaults
start       = uint16(1);
butterfly   = 1;
savename    = '';
MEG         = [];
seglen      = 5e3; % 1000 sample default length of viewing segment for cnt
SelList     = {'All','1st Quarter','2nd Quarter','3rd Quarter','4th Quarter'};

% FIXME: for viewing quarters of data, get channel numbering correct

% parse input
if ~isempty(varargin)
    optargin = size(varargin,2);
    if (mod(optargin,2) ~= 0)
        error('Optional arguments must come in option/value pairs');
    else
        for i=1:2:optargin
            switch varargin{i}
                case 'data'
                    MEG     = varargin{i+1};
                case 'components'
                    plotica = 1;
                    icasig  = varargin{i+1};
                otherwise
                    error('Invalid option!');
            end
        end
    end
else
    MEG = ReadData;
end

nchans  = [];
ntrials = [];
SetDispEnv(MEG);

% set up gui figure and menu controls
fig     = figure('MenuBar','none','Name','Data Viewer','NumberTitle','off',...
        'Position',[512,512,512,512],'WindowButtonDownFcn', @ButtonDown);
rgb     = [colormap(prism);colormap(prism);colormap(prism);colormap(prism)];
fmenu   = uimenu('Label','&File');
uimenu(fmenu,'Label','Open','Callback',@ReadData);
uimenu(fmenu,'Label','Save','Callback',@SaveData);
uimenu(fmenu,'Label','Quit','Callback','close',...
    'Separator','on','Accelerator','Q');
hmenu = uimenu('Label','&Help');
uimenu(hmenu,'Label','Help',...
    'Callback', @NotImplemented);
uimenu(hmenu,'Label','About','Separator','on',...
    'Callback', @About);
ax      = axes('Ylim',[0 length(chanstoplot)],'TickLength',[0 0]);

% set up buttons
ChnGroup = uicontrol('Style','Text','String','Channels:','units','normalized',...
        'Position',[.025,.97,.15,.025]);
PopChns = uicontrol('Style','PopupMenu','String',SelList,'units','normalized',...
        'Position',[.175,.97,.2,.025],'CallBack', @PopChnsCallBack);
Offset  = uicontrol('Style','PushButton','String','Offset','units','normalized',...
        'Position',[.4,.95,.15,.05],'CallBack',@OffsetData);
PlotHS  = uicontrol('Style','PushButton','String','Headshape','units','normalized',...
        'Position',[.6,.95,.15,.05],'CallBack',@ViewHS);
Disp    = uicontrol('Style','CheckBox','String','Butterfly?','units','normalized',...
        'Position',[.8,.95,.2,.05],'CallBack', @DispSelected);
TrialTxt = uicontrol('Style','Edit','units','normalized','Position',...
        [.025,.01,.15,.05],'CallBack',@Txt_CallBack);
Minus   = uicontrol('Style','PushButton','String','<','units','normalized',...
        'Position',[.2,.01,.025,.05],'CallBack',@DownTrial);
Plus    = uicontrol('Style','PushButton','String','>','units','normalized',...
        'Position',[.225,.01,.025,.05],'CallBack',@UpTrial);
FindChn = uicontrol('Style','PushButton','String','Identify','units','normalized',...
        'Position',[.265,.01,.15,.05],'CallBack',@findChan);
SelChn  = uicontrol('Style','Text','units','normalized','Position',[.425,.01,.15,.05]);
DelChn  = uicontrol('Style','PushButton','String','Delete Chn','units','normalized',...
        'Position',[.6,.01,.15,.05],'CallBack',@delChan);

% set up some variables
tmpDat = updateTmp(MEG);
set(TrialTxt, 'String', start);
set(Disp,'Value',1);
num                 = start;
[times, data]       = selectData(MEG,num);
DispTrial(num);

%callback for text trial display
function Txt_CallBack(varargin)
    num = str2num(get(TrialTxt,'String'));
    num = uint16(num);
    if length(num) == 1 & num <=ntrials & num >=0
      DispTrial(num);
    end  
end

% callback for increasing trial
function UpTrial(varargin)
    num = num + 1;
    if num < 1; num = 1; end
    if num > ntrials; num = ntrials; end;
    DispTrial(num);
end

% callback for decreasing trial
function DownTrial(varargin)
    num = num - 1;
    if num < 1; num = 1; end
    if num > ntrials; num = ntrials; end;
    DispTrial(num);
end

% display a trial function
function DispTrial(num)
    set(TrialTxt, 'String', num2str(num));
    [times data] = selectData(MEG,num);
    plotXY(times, data);
    axis tight;
    ylabel('Channels (normalized units for display)');
end

% pick data to plot
function [times, data] = selectData(MEG,num)
    switch MEG.type
        case 'avg'
            data = squeeze(MEG.data(chanstoplot,:));
            times = MEG.time;
        case 'epochs'
            data = squeeze(MEG.data(num,chanstoplot,:));
            times = MEG.time;
        case 'cnt'
            tind  = 1:length(MEG.time);
            num = uint32(num);
            seglen = uint32(seglen);
            if num == 1
                tind = 1:seglen;
            else
                tind = seglen*(num-1)+1:(seglen*num);
            end
            data  = squeeze(MEG.data(chanstoplot,tind));
            times = MEG.time(tind);
    end
    data = data./max(max(abs(data)));
end

% plotter function
function plotXY(time,data)
   if butterfly
       plot(time,data);
   else
       ylim([0 length(chanstoplot)]);
       for line=1:size(data,1)
           plot(time,data(line,:)+line,'color',rgb(line,:));
           hold on;
       end
       hold off;
   end
end

% display callback
function DispSelected(h, eventdata)
    if get(Disp,'Value') == 0
      butterfly = 0;
    else
      butterfly = 1;
    end 
    trial = str2num(get(TrialTxt, 'String'));
    DispTrial(trial);
end

% callback for button down - plot 2d topography
function ButtonDown(h, eventdata)
    set(fig, 'WindowButtonMotionFcn', '', ...
      'Pointer', 'Arrow');
    p       = get(ax,'CurrentPoint');
    t       = p(1);
    trial   = str2num(get(TrialTxt, 'String'));
    figure('Name',['Trial: ' num2str(trial) ' Time: ' num2str(t/1e3) ' s']);
    set(PopChns,'Value',1);
    [tmpDat.time, tmpDat.data] = selectData(MEG,trial);
    meg_plot2d(tmpDat,t);
end

% subfunction to identify channel based on nearest time and amplitude
function findChan(varargin)
     % click on point to identify a channel
     xy = ginput(1);
     % first find timepoint nearest to click in sample indices
     timeind     = get_index(times, xy(1));
     % now find amplitude nearest selection at time point
     chanind     = get_index(data(:,timeind),xy(2));
     chanlabel   = MEG.chn(chanstoplot(chanind)).label;
     % display channel
     set(SelChn,'String',chanlabel);
end

% subfunction to delete channel
function delChan(varargin)
    chanlabel   = get(SelChn,'String');
    if ~isempty(chanlabel)
        MEG         = deleter(MEG,{chanlabel});
        tmpDat      = updateTmp(MEG);
        set(SelChn,'String','');
        chanstoplot = meg_channel_indices(MEG,'multi','MEG');
        trial   = str2num(get(TrialTxt, 'String'));
        DispTrial(trial);
    else
        % do nothing
    end
end

% subfunction to update temporary header data
function tmpDat = updateTmp(MEG)
    tmpDat  = rmfield(MEG,{'data'});
    if  isfield(tmpDat,'aux'); tmpDat = rmfield(tmpDat,'aux'); end;    
end

% subfunction to delete channel
function OffsetData(varargin)
   MEG      = offset(MEG);
   tmpDat   = updateTmp(MEG);
   trial    = str2num(get(TrialTxt, 'String'));
   DispTrial(trial)
end

% subfunction to delete channel
function ViewHS(varargin)
    figure('Name','Headshape information');
    plot_hs_sens(MEG);
end

% subfunction to save data to disk
function SaveData(varargin)
    % if file not previously saved, ask for name
    if isempty(savename)
        [savename, pathname] = uiputfile('*.mat', 'Pick a mat file');
    end
    save(fullfile(pathname,savename),'MEG');
end

% subfunction to read data from disk
function ReadData(varargin)
    [savename, pathname] = uigetfile('*.mat', 'Pick a mat file');
    if ~isa(savename,'double')
        fprintf('\nReading data...');
        MEG = load(fullfile(pathname,savename));
        MEG = MEG.(char(fieldnames(MEG)));
        SetDispEnv(MEG);
        DispTrial(1);
        fprintf('done.');
    end
end

function SetDispEnv(MEG)
    chanstoplot = find(strcmp({MEG.chn.type},'MEG'));
    nchans      = length(chanstoplot);
    switch MEG.type
        case 'epochs'
            ntrials = length(MEG.epoch);
            seglen  = length(MEG.time);
        case 'avg'
            ntrials = 1;
            seglen  = length(MEG.time);
        case 'cnt'
            ntrials = round(size(MEG.data,2)/seglen);
        otherwise
            error('Type not supported!');
    end
end

% callback subfunction to change channels to display
function PopChnsCallBack(varargin)
    list        = get(PopChns,'String');
    val         = get(PopChns,'Value');
    quart_chns  = round(nchans/4);
    all_chns    = meg_channel_indices(MEG,'multi','MEG');
    switch list{val}
        case 'All'
            chanstoplot = all_chns;
        case '1st Quarter'
            chanstoplot = all_chns(1:quart_chns);
        case '2nd Quarter'
            chanstoplot = all_chns(quart_chns+1:2*quart_chns);
        case '3rd Quarter'
            chanstoplot = all_chns((2*quart_chns)+1:3*quart_chns);
        case '4th Quarter'
            chanstoplot = all_chns((3*quart_chns)+1:end);
        otherwise
            disp('not a plot option');
    end
    num = str2num(get(TrialTxt,'String'));
    DispTrial(num);
end

function About(varargin)
  msgbox('megtools data viewer ver 0.1','About','help','modal')    
end

function NotImplemented(varargin)
  msgbox('Operation is not implemented','Warning','warn','modal')   
end

end