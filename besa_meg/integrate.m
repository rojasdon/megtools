function varargout = integrate(varargin)
% --------------------------------------------------------------------
% gui for calculating area under selected waveforms
% --------------------------------------------------------------------

global SELECTED_DATA_INTEGRATE  % selected data
global INT_TSB                  % time sweep begins of selected waveforms
global INT_T_END                % time sweep ends of selected waveforms

if nargin == 0  % LAUNCH GUI
	fig = openfig(mfilename,'reuse');
    set(fig,'Color',get(0,'DefaultUicontrolBackgroundColor'));
    
	% Generate a structure of handles to pass to callbacks
	handles = guihandles(fig);
    guidata(fig,handles);

    % Determine time sweep begin and end of selected waveforms
    len = size(SELECTED_DATA_INTEGRATE,2);    
    INT_TSB = zeros(1,len);
    INT_T_END = zeros(1,len);
    for i=1:len
        INT_TSB(i)=SELECTED_DATA_INTEGRATE(i).TSB;
        INT_T_END(i)=SELECTED_DATA_INTEGRATE(i).TSB+(SELECTED_DATA_INTEGRATE(i).Npts-1)*SELECTED_DATA_INTEGRATE(i).DI;
    end
    
    % set figure layout
    set_figure_layout(handles);

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


% --------------------------------------------------------------------
% checkbox_absolute_Callback: use absolute values for calculating area (empty)
% --------------------------------------------------------------------
function varargout = checkbox_absolute_Callback(h, eventdata, handles, varargin)



% --------------------------------------------------------------------
% pushbutton_Cancel_Callback
% --------------------------------------------------------------------
function varargout = pushbutton_Cancel_Callback(h, eventdata, handles, varargin)
close


% --------------------------------------------------------------------
% pushbutton_Integrate_Callback: Calculate area under selected waveforms in the selected time interval
% --------------------------------------------------------------------
function varargout = pushbutton_Integrate_Callback(h, eventdata, handles, varargin)

global PLOTAXES                     % handle of axes in plot window
global DATAWINDOW                   % handle of main window
global SELECTED_DATA_INTEGRATE      % selected data
global LEGENDWINDOW                 % handle of legend window
global WAVEFORMS                    % imported data
global COLORORDER                   % current color order

% get handles of the main window
handles_datawindow = guihandles(DATAWINDOW);
guidata(DATAWINDOW,handles_datawindow);

% activate selected waveforms in listbox of the main window in order to plot them
waveforms('update_listbox',handles_datawindow);
index = zeros(1,size(SELECTED_DATA_INTEGRATE,2));
for i=1:size(SELECTED_DATA_INTEGRATE,2)
    index(i)=strmatch(char(SELECTED_DATA_INTEGRATE(i).name),char(WAVEFORMS.name),'exact');
end
set(handles_datawindow.listbox,'Value',index);

% enable buttons appropriately
waveforms('set_button_enabling',handles_datawindow);

% plot selected waveforms
waveforms('pushbutton_Plot_Callback',h, eventdata,handles_datawindow,varargin);

% Determine number of selected waveforms
len = size(SELECTED_DATA_INTEGRATE,2);
integral = zeros(1,len);

% set axes in plot window as current axes
axes(PLOTAXES)
hold on; 
ColIndex=1;

% order waveforms so that data with confidence intervals come first
bootindices = strmatch('boot',char(SELECTED_DATA_INTEGRATE.type),'exact');
nonbootindices = strmatch('single',char(SELECTED_DATA_INTEGRATE.type),'exact');
indices = [bootindices;nonbootindices];
for i=indices'
    % get data of selected waveforms
    datapoints = SELECTED_DATA_INTEGRATE(i).data;
    
    % if data contains confidence interval, take only the mean (first component) for calculating the area
    if strcmp(char(SELECTED_DATA_INTEGRATE(i).type),'boot')
        datapoints = squeeze(datapoints(1,:));
    end
    
    % Determine start and stop indices from selected time interval
    startindex = ceil((str2num(get(handles.edit_min,'String'))-SELECTED_DATA_INTEGRATE(i).TSB)/SELECTED_DATA_INTEGRATE(i).DI+1);
    stopindex = floor((str2num(get(handles.edit_max,'String'))-SELECTED_DATA_INTEGRATE(i).TSB)/SELECTED_DATA_INTEGRATE(i).DI+1);
    
    % calculate area under waveform
    if get(handles.checkbox_absolute,'Value')           % Absolute value integration
        for j=startindex:stopindex-1
            if sign(datapoints(j))==sign(datapoints(j+1))
                integral(i) = integral(i)+abs((datapoints(j)+datapoints(j+1))/2);
            else
                integral(i) = integral(i)+0.5*(datapoints(j)^2+datapoints(j+1)^2)/(abs(datapoints(j))+abs(datapoints(j+1)));
            end
        end
        integral(i) = integral(i)*SELECTED_DATA_INTEGRATE(i).DI;
    else                                                % signed value integration
        integral(i) = (stopindex-startindex+1)*SELECTED_DATA_INTEGRATE(i).DI*mean(datapoints(startindex:stopindex)) - ...
            0.5*SELECTED_DATA_INTEGRATE(i).DI*(datapoints(startindex)+datapoints(stopindex));
    end
    
    % Draw area under graph
    try         % Version 7.x or higher
        area('v6',[SELECTED_DATA_INTEGRATE(i).TSB+SELECTED_DATA_INTEGRATE(i).DI*(startindex-1):SELECTED_DATA_INTEGRATE(i).DI: ...
            SELECTED_DATA_INTEGRATE(i).TSB+SELECTED_DATA_INTEGRATE(i).DI*(stopindex-1)],datapoints(startindex:stopindex),...
            'FaceColor',COLORORDER(1+mod(ColIndex-1,max(size(COLORORDER))),:),'EdgeColor',COLORORDER(1+mod(ColIndex-1,max(size(COLORORDER))),:),'FaceAlpha',0.3,'EdgeAlpha',0.3);
    catch       % Version 6.x or lowers
        area([SELECTED_DATA_INTEGRATE(i).TSB+SELECTED_DATA_INTEGRATE(i).DI*(startindex-1):SELECTED_DATA_INTEGRATE(i).DI: ...
            SELECTED_DATA_INTEGRATE(i).TSB+SELECTED_DATA_INTEGRATE(i).DI*(stopindex-1)],datapoints(startindex:stopindex),...
            'FaceColor',COLORORDER(1+mod(ColIndex-1,max(size(COLORORDER))),:),'EdgeColor',COLORORDER(1+mod(ColIndex-1,max(size(COLORORDER))),:),'FaceAlpha',0.3,'EdgeAlpha',0.3);
    end
    ColIndex = ColIndex+1;
end

% display calculated values on the screen
set(handles.text_area,'String',char(num2str(round(integral'*100)/100)));

% enable Save button
set(handles.pushbutton_Save,'Enable','on');

% Place legend window on top 
figure(LEGENDWINDOW);

% switch back to area gui
figure(handles.figure_Integrate);

% --------------------------------------------------------------------
% pushbutton_Save_Callback: Save calculated values
% --------------------------------------------------------------------
function varargout = pushbutton_Save_Callback(h, eventdata, handles, varargin)

% get names of the selected waveforms
name = get(handles.text_files,'String');

% get calculated values
integral = get(handles.text_area,'String');

% determine number of selected waveforms and length of longest name
len = size(name,1);
wid = size(name,2);

% open gui for selecting a filename for saving
[filename,pathname] = uiputfile('integral.txt','Save integral');
if filename == 0
    return;
end

% get parts of the filename
[pathstr,basename,ext,versn] = fileparts(filename);

% if file extension is not '.txt', add that string to the file name
if isempty(strmatch(ext,'.txt','exact'))
    filename = [filename,'.txt'];
end

% save data to selected file
if isempty(strmatch(name,'','exact'))
    fid = fopen([pathname,filename],'w');
    % header line dependent on whether the absolute values has been used for the calculation or not
    switch  get(handles.checkbox_absolute,'Value')
    case 0
        fprintf(fid,'Integral over data between %s and %s ms.\r\n',DATA_SAVE_INTEGRATE.min,DATA_SAVE_INTEGRATE.max);
    case 1
        fprintf(fid,'Integral over absolute value of data between %s and %s ms.\r\n',get(handles.edit_min,'String'),get(handles.edit_max,'String'));
    end
    for i=1:wid+3
        fprintf(fid,' ');
    end
    fprintf(fid,'Integral [nAm*ms]\r\n');
    for i=1:len
        fprintf(fid,'%s       %8.2f \r\n',name(i,:),str2num(integral(i,:)));
    end
    fclose(fid);
end

% --------------------------------------------------------------------
% edit_min_Callback: edit lower limit of the time interval
% --------------------------------------------------------------------
function varargout = edit_min_Callback(h, eventdata, handles, varargin)
global INT_TSB
global INT_T_END

% check if a valid number has been edited, otherwise set to minimum allowed time point
if isempty(str2num(get(handles.edit_min,'String'))) | (str2num(get(handles.edit_min,'String')) < max(INT_TSB))...
        | (str2num(get(handles.edit_min,'String')) > min(INT_T_END))
    set(handles.edit_min,'String',num2str((round(max(INT_TSB)*100))/100));
end


% --------------------------------------------------------------------
% edit_max_Callback: edit upper limit of the time interval
% --------------------------------------------------------------------
function varargout = edit_max_Callback(h, eventdata, handles, varargin)
global INT_TSB
global INT_T_END

% check if a valid number has been edited, otherwise set to maximum allowed time point
if isempty(str2num(get(handles.edit_max,'String'))) | (str2num(get(handles.edit_max,'String')) > min(INT_T_END))...
        | (str2num(get(handles.edit_max,'String')) < max(INT_TSB))
    set(handles.edit_max,'String',num2str((round(min(INT_T_END)*100))/100));
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Subfunctions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --------------------------------------------------------------------
% Set figure layout
% ---------------------------------------------------------------------------------------
function set_figure_layout(handles)
global SELECTED_DATA_INTEGRATE
global INT_TSB
global INT_T_END

% Determine number of selected waveforms
len = size(SELECTED_DATA_INTEGRATE,2);

% Determine length of the longest name of the selected waveforms
wid = 0;
for i=1:len
    if length(SELECTED_DATA_INTEGRATE(i).name) > wid
        wid = length(SELECTED_DATA_INTEGRATE(i).name);
    end
end
% set wid at least to 25
wid = max(wid,25);

set(handles.figure_Integrate,'Visible','Off','Units','Characters','Position',[10 10 44+wid 1.08*len+8.5]);
movegui(handles.figure_Integrate,'northwest');
set(handles.text_files,'String',char(SELECTED_DATA_INTEGRATE.name),'Units','Characters','Position',[2 1 wid+18 1.08*len]);
set(handles.checkbox_absolute,'Value',1,'Units','Characters','Position',[2 1.08*len+6.2 25 2]);
set(handles.text_interval,'Units','Characters','Position',[2 1.08*len+5 20 1]);
set(handles.text_minus,'Units','Characters','Position',[33 1.08*len+5 2 1]);
set(handles.edit_min,'String',num2str((round(max(INT_TSB)*100))/100),'Units','Characters','Position',[22 1.08*len+4.8 10 1.4]);
set(handles.edit_max,'String',num2str((round(min(INT_T_END)*100))/100),'Units','Characters','Position',[36 1.08*len+4.8 10 1.4]);
set(handles.text_area,'String','','Units','Characters','Position',[24+wid 1 11 1.08*len]);
set(handles.text_nAmms,'Units','Characters','Position',[24+wid 1.08*len+2 15 1]);
set(handles.pushbutton_Cancel,'Units','Characters','Position',[32+wid 1.08*len+4 10 1.3]);
set(handles.pushbutton_Save,'Enable','off','Units','Characters','Position',[32+wid 1.08*len+5.3 10 1.3]);
set(handles.pushbutton_Integrate,'Units','Characters','Position',[32+wid 1.08*len+6.6 10 1.3]);
set(handles.frame1,'Units','Characters','Position',[1 0.5 42+wid 1.08*len+3]);
set(handles.figure_Integrate,'Visible','On');