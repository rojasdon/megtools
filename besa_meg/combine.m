function varargout = combine(varargin)
% --------------------------------------------------------------------
% gui for combining selected waveforms
% --------------------------------------------------------------------


if nargin == 0  % LAUNCH GUI

	fig = openfig(mfilename,'reuse');
    close(fig);
    fig = openfig(mfilename,'new');
    set(fig,'Color',get(0,'DefaultUicontrolBackgroundColor'));
    set(fig,'Visible','Off');
    
	% Use system color scheme for figure:
	set(fig,'Color',get(0,'defaultUicontrolBackgroundColor'));

	% Generate a structure of handles to pass to callbacks, and store it. 
	handles = guihandles(fig);
	guidata(fig, handles);

    set_figure_layout(handles);
    set(fig,'Visible','On');
    
	if nargout > 0
		varargout{1} = fig;
	end

elseif ischar(varargin{1}) % INVOKE NAMED SUBFUNCTION OR CALLBACK

	try
		if (nargout)
			[varargout{1:nargout}] = feval(varargin{:}); % FEVAL switchyard
		else
			feval(varargin{:}); % FEVAL switchyard
		end
	catch
		disp(lasterr);
	end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Subfunctions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --------------------------------------------------------------------
% set figure layout
% --------------------------------------------------------------------
function set_figure_layout(handles)
global SELECTED_DATA_COMBINE

% Determine number of selected waveforms
len = size(SELECTED_DATA_COMBINE,2);

wid = 0;
for i=1:len
    % Determine length of longest name of selected waveforms
    if length(SELECTED_DATA_COMBINE(i).name) > wid
        wid = length(SELECTED_DATA_COMBINE(i).name);
    end
    % Create popupmenu, edit text box and static text box for each selected waveform
    uicontrol(gcf,'Style', 'text', 'Tag', ['text',num2str(i)], 'HorizontalAlignment','left','String', ['x ',SELECTED_DATA_COMBINE(i).name], ...
        'Units','Characters','Position', [19.7 1.5*(len+2.5-i) wid+18 1.2],'Visible','On');
    uicontrol('Style', 'edit', 'Tag', ['edit',num2str(i)], 'BackgroundColor',[1 1 1], 'HorizontalAlignment','left','String', '1', ...
        'Units','Characters','Position',[13.2 1.5*(len+2.5-i) 5 1.3]);
    uicontrol('Style', 'popupmenu', 'Tag', ['popupmenu',num2str(i)], 'BackgroundColor',[1 1 1], 'String', ['+';'-'], ...
        'Units','Characters','Position',[5.8 1.5*(len+2.5-i) 6 1.4]);  
end
% position buttons 
set(handles.radiobutton_GA,'Position',[2 1.5*len+6 45 1],'Value',0);
set(handles.radiobutton_Combine,'Position',[2 1.5*len+4.5 37 1],'Value',1);
set(handles.figure_combine,'Position',[1 1 40+wid 1.5*len+8]);
% get handles of current figure
handles = guihandles(gcf);
guidata(gcf,guihandles);
% move current figure to upper left corner
movegui(handles.figure_combine,'northwest');


% --------------------------------------------------------------------
% Set values of chosen handles in vector 'off' to zero
% --------------------------------------------------------------------
function mutual_exclude(off)
set(off,'Value',0)



% --------------------------------------------------------------------
% radiobutton_GA_Callback: radiobutton for the option to calculate mean of selected waveforms
% --------------------------------------------------------------------
function varargout = radiobutton_GA_Callback(h, eventdata, handles, varargin)
global SELECTED_DATA_COMBINE

% get number of selected waveforms
len = size(SELECTED_DATA_COMBINE,2);

% if the radiobutton was already checked, don't turn it off but leave it checked
if get(handles.radiobutton_GA,'Value')==0   
    set(handles.radiobutton_GA,'Value',1);
else    % if the radiobutton was turned on, set the 'combine' radio button's value to zero 
    off = handles.radiobutton_Combine;
    mutual_exclude(off);
    % disable all user interfaces related to the 'combine' option
    for i=1:len  
        set(eval(['handles.text',num2str(i)]),'Enable','Off');
        set(eval(['handles.edit',num2str(i)]),'Enable','Off');
        set(eval(['handles.popupmenu',num2str(i)]),'Enable','Off');
    end
end


% --------------------------------------------------------------------
% radiobutton_Combine_Callback
% --------------------------------------------------------------------
function varargout = radiobutton_Combine_Callback(h, eventdata, handles, varargin)
global SELECTED_DATA_COMBINE

% get number of selected waveforms
len = size(SELECTED_DATA_COMBINE,2);

% if the radiobutton was already checked, don't turn it off but leave it checked
if get(handles.radiobutton_Combine,'Value')==0
    set(handles.radiobutton_Combine,'Value',1);
else    % if the radiobutton was turned on, set the 'combine' radio button's value to zero 
    off = handles.radiobutton_GA;
    mutual_exclude(off);
    % enable all user interfaces related to the 'combine' option
    for i=1:len
        set(eval(['handles.text',num2str(i)]),'Enable','On');
        set(eval(['handles.edit',num2str(i)]),'Enable','On');
        set(eval(['handles.popupmenu',num2str(i)]),'Enable','On');
    end
end

% --------------------------------------------------------------------
% pushbutton_OK_Callback: Combine selected waveforms
% --------------------------------------------------------------------
function varargout = pushbutton_OK_Callback(h, eventdata, handles, varargin)
global SELECTED_DATA_COMBINE
global WAVEFORMS
global DATAWINDOW

% get relevant parameters of the selected data
len = size(SELECTED_DATA_COMBINE,2);
TSB = SELECTED_DATA_COMBINE(1).TSB;
DI = SELECTED_DATA_COMBINE(1).DI;
Npts = SELECTED_DATA_COMBINE(1).Npts;

switch get(handles.radiobutton_GA,'Value')
case 0      % Combine waveforms according to the popupmenus' and edit boxes' settings
    Combdata = zeros(1,Npts);
    for i=1:len         % consider all selected waveforms
        % determine selected sign for combination
        switch get(eval(['handles.popupmenu',num2str(i)]),'Value')
        case 1
            Vorzeichen = 1;
        case 2
            Vorzeichen = -1;
        end
        % Add waveform with chosen sign and factor to combined data
        Combdata = Combdata + Vorzeichen*str2num(get(eval(['handles.edit',num2str(i)]),'String'))*SELECTED_DATA_COMBINE(i).data;
    end
    % determine number for the resulting waveform, resulting in the name 'Combination_(number)'
    Combnumber=1;
    i=1;
    while i<=length(WAVEFORMS)
        if strcmp(['Combination_',num2str(Combnumber)],char(WAVEFORMS(i).name))
            Combnumber=Combnumber+1;
            i=0;
        end
        i=i+1;
    end
    
    % add new waveform the variable WAVEFORM
    NewWaveForm(['Combination_',num2str(Combnumber)],Npts,TSB,DI,Combdata,'single')
    datawindowhandles = guihandles(DATAWINDOW);
    guidata(DATAWINDOW, datawindowhandles);
    % update listbox in main window
    waveforms('update_listbox',datawindowhandles);
    
case 1      % calculate mean of selected waveforms
    data = zeros(len,Npts);
    for i=1:len
        data(i,:) = SELECTED_DATA_COMBINE(i).data;
    end
    
    % calculate mean
    GA = squeeze(mean(data,1));
    
    % determine number for the resulting waveform, resulting in the name 'Mean_(number)'
    GAnumber=1;
    i=1;
    while i<=length(WAVEFORMS)
        if strcmp(['Mean_',num2str(GAnumber)],char(WAVEFORMS(i).name))
            GAnumber=GAnumber+1;
            i=0;
        end
        i=i+1;
    end
    
    % add new waveform the variable WAVEFORM
    NewWaveForm(['Mean_',num2str(GAnumber)],Npts,TSB,DI,GA,'single')
    datawindowhandles = guihandles(DATAWINDOW);
    guidata(DATAWINDOW, datawindowhandles);
    
    % update listbox in main window
    waveforms('update_listbox',datawindowhandles);
end
close;

% --------------------------------------------------------------------
% pushbutton_Cancel_Callback: Close combine window
% --------------------------------------------------------------------
function varargout = pushbutton_Cancel_Callback(h, eventdata, handles, varargin)
close;

