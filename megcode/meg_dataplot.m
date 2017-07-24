function varargout = meg_dataplot(varargin)
%MEG_DATAPLOT M-file for meg_dataplot.fig
%      MEG_DATAPLOT, by itself, creates a new MEG_DATAPLOT or raises the existing
%      singleton*.
%
%      H = MEG_DATAPLOT returns the handle to a new MEG_DATAPLOT or the handle to
%      the existing singleton*.
%
%      MEG_DATAPLOT('Property','Value',...) creates a new MEG_DATAPLOT using the
%      given property value pairs. Unrecognized properties are passed via
%      varargin to meg_dataplot_OpeningFcn.  This calling syntax produces a
%      warning when there is an existing singleton*.
%
%      MEG_DATAPLOT('CALLBACK') and MEG_DATAPLOT('CALLBACK',hObject,...) call the
%      local function named CALLBACK in MEG_DATAPLOT.M with the given input
%      arguments.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help meg_dataplot

% Last Modified by GUIDE v2.5 08-May-2012 10:10:00

%% Begin initialization code - DO NOT EDIT
gui_Singleton = 0;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @meg_dataplot_OpeningFcn, ...
                   'gui_OutputFcn',  @meg_dataplot_OutputFcn, ...
                   'gui_LayoutFcn',  [], ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
   gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
%% End initialization code - DO NOT EDIT


%% --- Executes just before meg_dataplot is made visible.
function meg_dataplot_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   unrecognized PropertyName/PropertyValue pairs from the
%            command line (see VARARGIN)

% Choose default command line output for meg_dataplot
handles.output = hObject;

% UIWAIT makes meg_dataplot wait for user response (see UIRESUME)
% uiwait(handles.figure1);
% guidata(hObject, handles);
rgb     = colormap(jet);
rgb     = [rgb;rgb;rgb;rgb];

% get the data if passed as argument
if ~isempty(varargin)
    if strcmp(varargin{1},'data')
        handles.MEG = varargin{2};
        handles.rgb = rgb;
        handles     = SetDispEnv(hObject,handles);
        DispTrial(hObject,handles);
    end
end
%%

%% --- Outputs from this function are returned to the command line.
function varargout = meg_dataplot_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
%%

%% --- Executes on selection change in pop_ChanSel.
function pop_ChanSel_Callback(hObject, eventdata, handles)
% hObject    handle to pop_ChanSel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: contents = cellstr(get(hObject,'String')) returns pop_ChanSel contents as cell array
%        contents{get(hObject,'Value')} returns selected item from pop_ChanSel
contents = cellstr(get(handles.pop_ChanSel,'String'));
handles.cind = meg_channel_indices(handles.MEG,'multi',contents{get(handles.pop_ChanSel,'Value')});
if strcmp(contents{get(handles.pop_ChanSel,'Value')},'MEG')
    set(handles.pop_SubChan,'Enable','On');
    set(handles.pop_SubChan,'Value',1);
    set(handles.pop_SubChan,'String',{'All','1st Quarter','2nd Quarter',...
        '3rd Quarter','4th Quarter'});
elseif strcmp(contents{get(handles.pop_ChanSel,'Value')},'REFERENCE')
    set(handles.pop_SubChan,'Enable','On');
    set(handles.pop_SubChan,'Value',1);
    set(handles.pop_SubChan,'String',{'MAGREF','GRADREF'});
else
    set(handles.pop_SubChan,'Enable','Off');
end
guidata(hObject, handles);
DispTrial(hObject,handles);
%%

%% --- Executes during object creation, after setting all properties.
function pop_ChanSel_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pop_ChanSel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
%%

%% --- Executes on button press in pb_trialUp.
function pb_trialUp_Callback(hObject, eventdata, handles)
% hObject    handle to pb_trialUp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.num = handles.num + 1;
if handles.num < 1; handles.num = 1; end
if handles.num > handles.ntrials; handles.num = handles.ntrials; end;
guidata(hObject, handles); %without this line, the handles structure would not update
DispTrial(hObject,handles);
%%

%% --- Executes on button press in pb_trialUp.
function pb_trialDown_Callback(hObject, eventdata, handles)
% hObject    handle to pb_trialUp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.num = handles.num - 1;
if handles.num < 1; handles.num = 1; end
if handles.num > handles.ntrials; handles.num = handles.ntrials; end;
guidata(hObject, handles); %without this line, the handles structure would not update
DispTrial(hObject,handles);
%%

%% --------------------------------------------------------------------
function FileMenu_Callback(hObject, eventdata, handles)
% hObject    handle to FileMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%%

%% --------------------------------------------------------------------
function OpenFile_Callback(hObject, eventdata, handles)
% hObject    handle to OpenFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[savename, pathname] = uigetfile('*.mat', 'Pick a mat file');
if ~isa(savename,'double')
    fprintf('\nReading data...');
    handles.MEG = load(fullfile(pathname,savename));
    handles.MEG = handles.MEG.(char(fieldnames(handles.MEG)));
    handles = SetDispEnv(hObject, handles);
    guidata(hObject, handles); %without this line, the handles structure would not update
    DispTrial(hObject,handles);
    fprintf('done.');
end
%%

%% --------------------------------------------------------------------
function PrintMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to PrintMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%%

%% --------------------------------------------------------------------
function CloseMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to CloseMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
close(handles.figure1);
%%

%% --------------------------------------------------------------------
function ToolMenu_Callback(hObject, eventdata, handles)
% hObject    handle to ToolMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%%

%% --------------------------------------------------------------------
function OffsetCorrect_Callback(hObject, eventdata, handles)
% hObject    handle to OffsetCorrect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
switch handles.MEG.type
    case {'avg','epochs'}
        tind(1) = handles.MEG.time(1); 
        tind(2) = get_time_index(handles.MEG,0);
        tind(2) = handles.MEG.time(tind(2));
        b = dialog_offset(tind);
        handles.MEG = offset(handles.MEG,b.baseline);
    otherwise
        handles.MEG = offset(handles.MEG);
end
set(handles.pop_SubChan,'Value',1);
guidata(hObject, handles); % update handles
DispTrial(hObject,handles);
%%

%% --------------------------------------------------------------------
function FilterData_Callback(hObject, eventdata, handles)
% hObject    handle to FilterData (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
f = dialog_filterer; 
if isnan(f.low) && isnan(f.high)
    return;
end
switch f.type
    case 'band'
        cutoffs = [f.low f.high];
    case 'low'
        cutoffs = f.low;
    case 'high'
        cutoffs = f.high;
end
handles.MEG = filterer(handles.MEG,f.type,cutoffs,'order',f.order);
guidata(hObject, handles); % update handles
DispTrial(hObject,handles);
%%

%% --------------------------------------------------------------------
function ChannelDelete_Callback(hObject, eventdata, handles)
% hObject    handle to ChannelDelete (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
val   = get(handles.pop_ChanSel,'Value');
cind  = meg_channel_indices(handles.MEG,'multi','MEG');
chans = dialog_deleter({handles.MEG.chn(cind).label});
handles.MEG = deleter(handles.MEG,chans);
set(handles.pop_ChanSel,'Value',val);
guidata(hObject, handles); % update handles
DispTrial(hObject,handles);
%%

%% --------------------------------------------------------------------
function SaveDataToWorkspace_Callback(hObject, eventdata, handles)
% hObject    handle to SaveDataToWorkspace (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
assignin('base','OUTMEG', handles.MEG);
%%

%% --- Executes during object creation, after setting all properties.
function figure1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
%%

%% --- Executes on mouse press over figure background, over a disabled or
%% --- inactive control, or over an axes background.
function figure1_WindowButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
p              = get(handles.axes1,'CurrentPoint');
handles.cursor = p(1);
DispTrial(hObject,handles); % redisplay trial to wipe prior line/markings
% plot a line at point of button down
hold on;
plot([handles.cursor handles.cursor],ylim,'k');
hold off;
% create event mark in event structure if requested
if get(handles.markevents,'Value') == 1
    disp('marking spike');
    handles.MEG = create_spike_event(handles.MEG,handles.cursor);
end
% plot topography at time point
topoPlot(handles.cursor, hObject, handles);
guidata(hObject, handles);% update handles
%% end of sub function

%% --- Function to plot 2d topography
function topoPlot(tpoint, hObject, handles, varargin)
axes(handles.axes2);
if nargin > 3
    if strcmp(varargin{1},'mark')
        hchan = varargin{2};
    end
end
switch handles.MEG.type
    case {'cnt' 'avg'}
        if exist('hchan','var')
            meg_plot2d(handles.MEG,tpoint,'mark', {hchan});
        else
            meg_plot2d(handles.MEG,tpoint);
        end
    case 'epochs'
        if exist('hchan','var')
            meg_plot2d(handles.MEG,tpoint,'trial',handles.num, 'mark', {hchan});
        else
            meg_plot2d(handles.MEG,tpoint,'trial',handles.num);
        end
end
set(handles.tpoint_Text,'String', [num2str(tpoint) ' ms']);
set(handles.axes2,'XTick',[],'YTick',[]);
%% end of subfunction

%%
function tpoint_Text_Callback(hObject, eventdata, handles)
% hObject    handle to tpoint_Text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of tpoint_Text as text
%        str2double(get(hObject,'String')) returns contents of tpoint_Text as a double
%%

%% --- Executes during object creation, after setting all properties.
function tpoint_Text_CreateFcn(hObject, eventdata, handles)
% hObject    handle to tpoint_Text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
%% end of sub function

%% sub function to set display parameters depending on input type
function handles = SetDispEnv(hObject, handles, varargin)
handles.cind = meg_channel_indices(handles.MEG,'multi','MEG');
switch handles.MEG.type
    case 'epochs'
        handles.ntrials = length(handles.MEG.epoch);
        handles.seglen  = uint32(length(handles.MEG.time));
    case 'avg'
        handles.ntrials = 1;
        handles.seglen  = uint32(length(handles.MEG.time));
        set(handles.pb_trialUp,'Enable','off');
        set(handles.pb_trialDown,'Enable','off');
    case 'cnt'
        handles.seglen  = uint32(4000); % default ms window
        handles.ntrials = round(size(handles.MEG.data,2)/handles.seglen);
    otherwise
        error('Type not supported!');
end
set(handles.tgl_Butterfly,'String','Stacked');
set(handles.pop_ChanSel,'String', unique({handles.MEG.chn.type}));
set(handles.pop_SubChan,'String',{'All','1st Quarter','2nd Quarter',...
        '3rd Quarter','4th Quarter'});
handles.num     = uint32(1);
handles.cursor  = 0;
handles.scaling = 1;
handles.spacing = 50;
if handles.ntrials == 1
    set(handles.pb_ScaleUp,'Enable','off');
    set(handles.pb_ScaleDown,'Enable','off');
end
set(handles.pb_ScaleUp,'Enable','Off');
set(handles.pb_ScaleDown,'Enable','Off');
%% end of sub function

%% sub function to display a trial 
function DispTrial(hObject,handles)
set(handles.trial_Text, 'String', num2str(handles.num));
axes(handles.axes1);
xlabel('Time (ms)');
handles.tind = 1:length(handles.MEG.time);
switch handles.MEG.type
    case 'avg'
        data = squeeze(handles.MEG.data(handles.cind,:));
        times = handles.MEG.time;
    case 'epochs'
        data = squeeze(handles.MEG.data(handles.num,handles.cind,:));
        times = handles.MEG.time;
    case 'cnt'
        if handles.num == 1
            handles.tind = 1:handles.seglen;
        else
            handles.tind = handles.seglen*(handles.num-1)+1:(handles.seglen*handles.num);
        end
        data  = squeeze(handles.MEG.data(handles.cind,handles.tind));
        times = handles.MEG.time(handles.tind);
end
labels   = {handles.MEG.chn(handles.cind).label};
contents = cellstr(get(handles.pop_ChanSel,'String'));
group    = contents{get(handles.pop_ChanSel,'Value')};
cla;
if get(handles.tgl_Butterfly,'Value') == 0
    nchans = length(handles.cind);
    set(gca,'YTickMode','manual');
    set(gca,'Ytick',linspace(handles.spacing,nchans*handles.spacing,nchans));
    set(gca,'YtickLabel',labels);
    hold on;
    if strcmp(group,'EEG')
        yy=ylim;
        ry=range(yy);
        scaling=1e5;
        for line=1:nchans
            plot(times,data(line,:)*scaling+(line*handles.spacing),'color','b');
        end
    else
        data = data*1e15;
        for line=1:nchans
           plot(times,(data(line,:)*handles.scaling)+(line*handles.spacing),'color','b');
        end
    end
    ylabel('Channel Labels');
else
    set(gca,'YTickMode','auto');
    plot(times,data);
    ylabel('Amplitude (fT)'); % FIXME
end
set(handles.goto_time,'String',num2str(times(1)));
axis tight; drawnow expose; hold off;
guidata(hObject, handles);% update handles
% mark events
if isfield(handles.MEG,'events')
    if ~isempty(handles.MEG.events)
        t1      = get_time_index(handles.MEG,times(1));
        t2      = get_time_index(handles.MEG,times(end));
        indices = [handles.MEG.events.latency];
        index   = find(ismember(t1:t2,indices));
        tomark  = handles.tind(index);
        PlotEvents(tomark,handles);
    end
end
%% end of sub function

%% callback for text trial display
function trial_Text_Callback(hObject, eventdata, handles)
% hObject    handle to trial_Text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of trial_Text as text
%        str2double(get(hObject,'String')) returns contents of trial_Text as a double
handles.num = str2num(get(handles.trial_Text,'String'));
if handles.num > handles.ntrials; handles.num = handles.ntrials; end;
if length(handles.num) == 1 && handles.num <= handles.ntrials && handles.num >=0
  guidata(hObject,handles);
  DispTrial(hObject,handles);
end  
%%

%% --- Executes during object creation, after setting all properties.
function trial_Text_CreateFcn(hObject, eventdata, handles)
% hObject    handle to trial_Text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
%%

%% --- Executes on button press in pb_FindChn.
function pb_FindChn_Callback(hObject, eventdata, handles)
% hObject    handle to pb_FindChn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%%

%% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over pb_FindChn.
function pb_FindChn_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to pb_FindChn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% click on point to identify a channel
xy    = ginput(1);
xy(2) = xy(2);
if handles.scaling > 1
    xy(2) = xy(2) / handles.scaling;
elseif handles.scaling < 1
    xy(2) = xy(2) * handles.scaling;
end
timeind     = get_index(handles.MEG.time(handles.tind), xy(1));
if strcmp(handles.MEG.type,'epochs')
    dat         = squeeze(handles.MEG.data(handles.num,handles.cind,timeind))*1e15;
    chanind     = get_index(dat,xy(2));
else
    dat         = handles.MEG.data(handles.cind,timeind)*1e15;
    chanind     = get_index(dat,xy(2));
end
chanlabel   = handles.MEG.chn(handles.cind(chanind)).label;
set(handles.txt_ChanSel,'String',chanlabel);
topoPlot(handles.cursor, hObject, handles, 'mark', chanlabel);
%% end of subfunction

%% --- Executes on button press in tgl_Butterfly.
function tgl_Butterfly_Callback(hObject, eventdata, handles)
% hObject    handle to tgl_Butterfly (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of tgl_Butterfly
if get(handles.tgl_Butterfly,'Value')
    set(handles.pb_ScaleUp,'Enable','Off');
    set(handles.pb_ScaleDown,'Enable','Off');
    set(handles.tgl_Butterfly,'String','Stacked');
else
    set(handles.pb_ScaleUp,'Enable','On');
    set(handles.pb_ScaleDown,'Enable','On');
    set(handles.tgl_Butterfly,'String','Butterfly');
end
DispTrial(hObject,handles);
%% end of subfunction

%% ---- Average data
function AverageData_Callback(hObject, eventdata, handles)
% hObject    handle to AverageData (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if ~strcmpi(handles.MEG.type,'epochs')
    msgbox('File type must be epoch');
else
    handles.MEG = averager(handles.MEG);
    handles     = SetDispEnv(hObject, handles);
    DispTrial(hObject,handles);
    guidata(hObject, handles);% update handles
end
%% end of subfunction


%% --- Executes on button press in pb_ShowHeadShape.
function pb_ShowHeadShape_Callback(hObject, eventdata, handles)
% hObject    handle to pb_ShowHeadShape (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
figure('Name','Head Shape'); plot_hs_sens(handles.MEG);
%% end of function

%% --------------------------------------------------------------------
function EpochData_Callback(hObject, eventdata, handles)
% hObject    handle to EpochData (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
ep          = dialog_epocher({'TRIGGER' 'RESPONSE'});
if isnan(ep.thresh)
    handles.MEG = epocher(handles.MEG,char(ep.type),ep.start,ep.stop);
else
    handles.MEG = epocher(handles.MEG,char(ep.type),ep.start,ep.stop,...
        'threshold',ep.thresh);
end
handles     = SetDispEnv(hObject,handles);
guidata(hObject, handles); % update handles
DispTrial(hObject,handles);
%% end of function


%% --- Executes on button press in pb_ScaleUp.
function pb_ScaleUp_Callback(hObject, eventdata, handles)
% hObject    handle to pb_ScaleUp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.scaling = handles.scaling +.2;
guidata(hObject, handles);
DispTrial(hObject, handles);
%% end of sub function


% --- Executes on button press in pb_ScaleDown.
function pb_ScaleDown_Callback(hObject, eventdata, handles)
% hObject    handle to pb_ScaleDown (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if handles.scaling > .4; handles.scaling = handles.scaling -.2; end;
guidata(hObject, handles);
DispTrial(hObject, handles);
%% end of sub function


% --- Executes on selection change in pop_SubChan.
function pop_SubChan_Callback(hObject, eventdata, handles)
% hObject    handle to pop_SubChan (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns pop_SubChan contents as cell array
%        contents{get(hObject,'Value')} returns selected item from pop_SubChan
contents = cellstr(get(handles.pop_ChanSel,'String'));
group    = contents{get(handles.pop_ChanSel,'Value')};
switch group
    case 'MEG'
        all_chns   = meg_channel_indices(handles.MEG,'multi','MEG');
        nchans     = length(all_chns);
        quart_chns = round(nchans/4);
        contents   = cellstr(get(handles.pop_SubChan,'String'));
        group      = contents{get(handles.pop_SubChan,'Value')};
        switch group
            case 'All'
                handles.cind = all_chns;
            case '1st Quarter'
                handles.cind = all_chns(1:quart_chns);
            case '2nd Quarter'
                handles.cind = all_chns(quart_chns+1:2*quart_chns);
            case '3rd Quarter'
                handles.cind = all_chns((2*quart_chns)+1:3*quart_chns);
            case '4th Quarter'
                handles.cind = all_chns((3*quart_chns)+1:end);
        end
    case 'REFERENCE'
        contents   = cellstr(get(handles.pop_SubChan,'String'));
        group      = contents{get(handles.pop_SubChan,'Value')};
        handles.cind = meg_channel_indices(handles.MEG,'multi',...
            group);
    case 'EEG'
        handles.cind = meg_channel_indices(handles.MEG,'multi','EEG');
    otherwise
        % do nothing
end
guidata(hObject, handles);
DispTrial(hObject, handles);

% --- Executes during object creation, after setting all properties.
function pop_SubChan_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pop_SubChan (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function goto_time_Callback(hObject, eventdata, handles)
% hObject    handle to goto_time (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of goto_time as text
%        str2double(get(hObject,'String')) returns contents of goto_time as a double
ntime = str2num(get(handles.goto_time,'String'));
switch handles.MEG.type
    case 'avg'
        times = handles.MEG.time;
    case 'epochs'
        times = handles.MEG.time;
    case 'cnt'
        if handles.num == 1
            handles.tind = 1:handles.seglen;
        else
            handles.tind = handles.seglen*(handles.num-1)+1:(handles.seglen*handles.num);
        end
        times = handles.MEG.time(handles.tind);
end
if ntime > times(1) && ntime < times(end)
    % do nothing - you are already here
else
    % change to requested time
    ind   = get_time_index(handles.MEG,ntime);
    starts = double(1:handles.seglen:handles.seglen*handles.ntrials);
    [junk,tind] = min(abs(starts - ind));
    fprintf('Changing to sample %d in trial %d\n',ind, tind);
    handles.num = tind;
    guidata(hObject, handles);
    DispTrial(hObject,handles);
end

% --- Executes during object creation, after setting all properties.
function goto_time_CreateFcn(hObject, eventdata, handles)
% hObject    handle to goto_time (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in markevents.
function markevents_Callback(hObject, eventdata, handles)
% hObject    handle to markevents (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of markevents

function PlotEvents(tomark,handles)
% function for marking events for continuous data
yy = ylim;
times = handles.MEG.time;
hold on;
indices = [handles.MEG.events.latency];
for ii=1:length(tomark)
    [~,event] = find(indices == tomark(ii));
    plot([times(tomark(ii)) times(tomark(ii))],ylim,'r','linewidth',2);
    text('Position',[times(tomark(ii)),yy(2)+range(yy)*.02],...
        'String',char(handles.MEG.events(event).type),'rotation',90,'color','r');
end
hold off;