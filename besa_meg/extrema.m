function varargout = extrema(varargin)
% --------------------------------------------------------------------
% gui for calculating extrema of selected waveforms
% --------------------------------------------------------------------

global SELECTED_DATA_EXTREMA
global EX_TSB       % time sweep begins of selected data
global EX_T_END     % time sweep ends of selected data
if nargin == 0  % LAUNCH GUI
    fig = openfig(mfilename,'reuse','invisible');
    set(fig,'Color',get(0,'DefaultUicontrolBackgroundColor'));
	
    % Generate a structure of handles to pass to callbacks
	handles = guihandles(fig);
    guidata(fig,handles);
    
    % set figure layout
    set_figure_layout(handles);
    
    % Determine time sweep begins and time sweep ends of selected data
    len = size(SELECTED_DATA_EXTREMA,2);
    EX_TSB = zeros(1,len);
    EX_T_END = zeros(1,len);
    for i=1:len
        EX_TSB(i)=SELECTED_DATA_EXTREMA(i).TSB;
        EX_T_END(i)=SELECTED_DATA_EXTREMA(i).TSB+(SELECTED_DATA_EXTREMA(i).Npts-1)*SELECTED_DATA_EXTREMA(i).DI;
    end
    
       
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
% checkbox_minimum_Callback
% --------------------------------------------------------------------
function varargout = checkbox_minimum_Callback(h, eventdata, handles, varargin)
global EX_TSB
global EX_T_END
global SELECTED_DATA_EXTREMA
if get(handles.checkbox_minimum,'Value')                % checkbox has been switched on
    set(handles.pushbutton_Find,'Enable','On');         % enable 'Find' button
    
    % if no miniumum and maximum time point has been set, set to default values 
    % (i. e. to the maximum time range that is included in all selected waveforms)
    if isempty(get(handles.edit_minmin,'String'))
        set(handles.edit_minmin,'String',num2str((round(max(EX_TSB)*100))/100));    
    end
    if isempty(get(handles.edit_minmax,'String'))
        set(handles.edit_minmax,'String',num2str((round(min(EX_T_END)*100))/100));
    end
    % if more than one waveform is selected, enable 'calculate mean' checkbox and related ui's
    if size(SELECTED_DATA_EXTREMA,2)>1
        set(handles.checkbox_mean,'Enable','On'); 
        set(handles.popupmenu_ci,'Enable','On');
        set(handles.text_ci,'Enable','On');
    end
else                                                    % checkbox has been switched off
    % if masimum checkbox is also off, disable 'Find' and 'calculate mean' buttons and related ui's
    if get(handles.checkbox_maximum,'Value')==0
        set(handles.pushbutton_Find,'Enable','Off');
        set(handles.checkbox_mean,'Enable','Off');
        set(handles.popupmenu_ci,'Enable','Off');
        set(handles.text_ci,'Enable','Off');
    end
    % clear corresponding edit fields
    set(handles.edit_minmin,'String','');
    set(handles.edit_minmax,'String','');
end


% --------------------------------------------------------------------
% checkbox_maximum_Callback
% --------------------------------------------------------------------
function varargout = checkbox_maximum_Callback(h, eventdata, handles, varargin)
global EX_TSB
global EX_T_END
global SELECTED_DATA_EXTREMA
if get(handles.checkbox_maximum,'Value')                % checkbox has been switched on
    set(handles.pushbutton_Find,'Enable','on');         % enable 'Find' button

    % if no miniumum and maximum time point has been set, set to default values 
    % (i. e. to the maximum time range that is included in all selected waveforms)
    if isempty(get(handles.edit_maxmin,'String'))
        set(handles.edit_maxmin,'String',num2str((round(max(EX_TSB)*100))/100));
    end
    if isempty(get(handles.edit_maxmax,'String'))
        set(handles.edit_maxmax,'String',num2str((round(min(EX_T_END)*100))/100));
    end
    % if more than one waveform is selected, enable 'calculate mean' checkbox and related ui's
    if size(SELECTED_DATA_EXTREMA,2)>1
        set(handles.checkbox_mean,'Enable','On'); 
        set(handles.popupmenu_ci,'Enable','On');
        set(handles.text_ci,'Enable','On');
    end
else                                                    % checkbox has been switched off
    % if masimum checkbox is also off, disable 'Find' and 'calculate mean' buttons and related ui's
    if get(handles.checkbox_minimum,'Value')==0
        set(handles.pushbutton_Find,'Enable','off');
        set(handles.checkbox_mean,'Enable','Off');        
        set(handles.popupmenu_ci,'Enable','Off');
        set(handles.text_ci,'Enable','Off');
    end
    % clear corresponding edit fields
    set(handles.edit_maxmin,'String','');
    set(handles.edit_maxmax,'String','');
end

% --------------------------------------------------------------------
% text_files_Callback (empty)
% --------------------------------------------------------------------
function varargout = text_files_Callback(h, eventdata, handles, varargin)


% --------------------------------------------------------------------
% pushbutton_Find_Callback: Find minima and maxima of selected waveforms in the chosen time range
% --------------------------------------------------------------------
function varargout = pushbutton_Find_Callback(h, eventdata, handles, varargin)
global PLOTAXES                 % handle of axes in plot window
global DATAWINDOW               % handle of main window
global SELECTED_DATA_EXTREMA    % selected data
global LEGENDWINDOW             % handle of legend window
global WAVEFORMS                % imported data
global COLORORDER               % current color order for plots
global DATA_SAVE_EXTREMA        % data to be saved when pressing the save button in the extrema gui

% determine number of selected waveforms
len = size(SELECTED_DATA_EXTREMA,2);

% choose alpha for bootstrap routine depending on the chosen confidence limit (cmp. Efron/Tibshirani) and set text in gui accordingly
switch get(handles.popupmenu_ci,'Value')
case 1
    alpha = 1.645;
    set(handles.text_files,'String',{char(SELECTED_DATA_EXTREMA.name); ' '; 'mean:'; '90% confidence interval:'});
case 2
    set(handles.text_files,'String',{char(SELECTED_DATA_EXTREMA.name); ' '; 'mean:'; '95% confidence interval:'});
    alpha = 1.960;
end

% Search for minimum
if get(handles.checkbox_minimum,'Value')
    minimum_ind = zeros(1,len);
    minimum_amp = zeros(1,len);
    minimum_lat = zeros(1,len);
    for i=1:len
        % get data to be analyzed
        datapoints = SELECTED_DATA_EXTREMA(i).data;
        if strcmp(char(SELECTED_DATA_EXTREMA(i).type),'boot')       % if data has a confidence interval, take only the mean (1st component)
            datapoints = squeeze(datapoints(1,:));
        end
        
        % determine start and stop index for search depending on the chosen time interval
        startindex = ceil((str2num(get(handles.edit_minmin,'String'))-SELECTED_DATA_EXTREMA(i).TSB)/SELECTED_DATA_EXTREMA(i).DI+1);
        stopindex = floor((str2num(get(handles.edit_minmax,'String'))-SELECTED_DATA_EXTREMA(i).TSB)/SELECTED_DATA_EXTREMA(i).DI+1);
        
        % determine minimum amplitude and index
        [minimum_amp(i),minimum_ind(i)] = min(datapoints(startindex:stopindex));
        minimum_lat(i) = (startindex-1)*SELECTED_DATA_EXTREMA(i).DI+SELECTED_DATA_EXTREMA(i).TSB+(minimum_ind(i)-1)*SELECTED_DATA_EXTREMA(i).DI;
    end
    
    % display results on the screen
    mean_min = ''; thetalo_min = ''; thetahi_min = ''; 
    if get(handles.checkbox_mean,'Value')   % calculate mean and confidence interval of minimum amplitude and latency if desired
        [mean_min, thetalo_min, thetahi_min] = boot_ci_alpha([minimum_lat; minimum_amp]',alpha);
        % display rounded results on the screen
        set(handles.text_latmin,'String',{char({char(num2str(round(minimum_lat'*100)/100))}); ''; char(num2str(round(mean_min(1)*100)/100)); ...
                ['[' num2str(round(thetalo_min(1)*100)/100) '; ' num2str(round(thetahi_min(1)*100)/100) ']']});
        set(handles.text_ampmin,'String',{char({char(num2str(round(minimum_amp'*100)/100))}); ''; char(num2str(round(mean_min(2)*100)/100)); ...
                ['[' num2str(round(thetalo_min(2)*100)/100) '; ' num2str(round(thetahi_min(2)*100)/100) ']']});
    else                                    
        % display only minimum without mean
        set(handles.text_latmin,'String',char(num2str(round(minimum_lat'*100)/100))); 
        set(handles.text_ampmin,'String',char(num2str(round(minimum_amp'*100)/100)));    
    end
else            % clear information about minimum amplitude and latency if minimum checkbox was not checked 
    set(handles.text_latmin,'String','');
    set(handles.text_ampmin,'String','');
end

% Search for maximum
if get(handles.checkbox_maximum,'Value')
    maximum_ind = zeros(1,len);
    maximum_amp = zeros(1,len);
    maximum_lat = zeros(1,len);
    for i=1:len
        % get data to be analyzed
        datapoints = SELECTED_DATA_EXTREMA(i).data;
        if strcmp(char(SELECTED_DATA_EXTREMA(i).type),'boot')       % if data has a confidence interval, take only the mean (1st component)
            datapoints = squeeze(datapoints(1,:));
        end
        
        % determine start and stop index for search depending on the chosen time interval        
        startindex = ceil((str2num(get(handles.edit_maxmin,'String'))-SELECTED_DATA_EXTREMA(i).TSB)/SELECTED_DATA_EXTREMA(i).DI+1);
        stopindex = floor((str2num(get(handles.edit_maxmax,'String'))-SELECTED_DATA_EXTREMA(i).TSB)/SELECTED_DATA_EXTREMA(i).DI+1);
        
        % determine maximum amplitude and index        
        [maximum_amp(i),maximum_ind(i)] = max(datapoints(startindex:stopindex));
        maximum_lat(i) = (startindex-1)*SELECTED_DATA_EXTREMA(i).DI+SELECTED_DATA_EXTREMA(i).TSB+(maximum_ind(i)-1)*SELECTED_DATA_EXTREMA(i).DI;
    end
    
    % display results on the screen
    mean_max = ''; thetalo_max = ''; thetahi_max = '';
    if get(handles.checkbox_mean,'Value')   % calculate mean and confidence interval of minimum amplitude and latency if desired
        [mean_max, thetalo_max, thetahi_max] = boot_ci_alpha([maximum_lat; maximum_amp]',alpha);
        % display rounded results on the screen
        set(handles.text_latmax,'String',{char({char(num2str(round(maximum_lat'*100)/100))}); ''; char(num2str(round(mean_max(1)*100)/100)); ...
                ['[' num2str(round(thetalo_max(1)*100)/100) '; ' num2str(round(thetahi_max(1)*100)/100) ']']});
        set(handles.text_ampmax,'String',{char({char(num2str(round(maximum_amp'*100)/100))}); ''; char(num2str(round(mean_max(2)*100)/100)); ...
                ['[' num2str(round(thetalo_max(2)*100)/100) '; ' num2str(round(thetahi_max(2)*100)/100) ']']});
    else
        % display only maximum without mean
        set(handles.text_latmax,'String',char(num2str(round(maximum_lat'*100)/100)));
        set(handles.text_ampmax,'String',char(num2str(round(maximum_amp'*100)/100))); 
    end
else            % clear information about minimum amplitude and latency if minimum checkbox was not checked 
    set(handles.text_latmax,'String','');
    set(handles.text_ampmax,'String','');
end

% set global variable DATA_SAVE_EXTREMA with all information that is to be saved when pushing the 'Save' button
DATA_SAVE_EXTREMA.maxmax = get(handles.edit_maxmax,'String');
DATA_SAVE_EXTREMA.maxmin = get(handles.edit_maxmin,'String');
DATA_SAVE_EXTREMA.minmax = get(handles.edit_minmax,'String');
DATA_SAVE_EXTREMA.minmin = get(handles.edit_minmin,'String');
DATA_SAVE_EXTREMA.latmin = char({'[ms]'; char(get(handles.text_latmin,'String'))});
DATA_SAVE_EXTREMA.ampmin = char({'[nAm]'; char(get(handles.text_ampmin,'String'))});
DATA_SAVE_EXTREMA.latmax = char({'[ms]'; char(get(handles.text_latmax,'String'))});
DATA_SAVE_EXTREMA.ampmax = char({'[nAm]'; char(get(handles.text_ampmax,'String'))});
DATA_SAVE_EXTREMA.checkbox_minimum = get(handles.checkbox_minimum,'Value');
DATA_SAVE_EXTREMA.checkbox_maximum = get(handles.checkbox_maximum,'Value');
DATA_SAVE_EXTREMA.name = char({''; char(get(handles.text_files,'String'))});

% get handles of main window
handles_datawindow = guihandles(DATAWINDOW);
guidata(DATAWINDOW,handles_datawindow);
% update listbox in main window
waveforms('update_listbox',handles_datawindow);
% mark waveforms that were selected for the search for extrema
index = zeros(1,size(SELECTED_DATA_EXTREMA,2));
for i=1:size(SELECTED_DATA_EXTREMA,2)
    index(i)=strmatch(char(SELECTED_DATA_EXTREMA(i).name),char(WAVEFORMS.name),'exact');
end
set(handles_datawindow.listbox,'Value',index)

% Plot selected waveforms and enable the appropriate buttons in the main window
waveforms('pushbutton_Plot_Callback',h, eventdata,handles_datawindow,varargin);
waveforms('set_button_enabling',handles_datawindow);

% reset current color
ColIndex=1;

% sort waveforms so that waveforms with confidence data are plotted before those without confidence interval (so that 
% the circles to be drawn appear in the color of the corresponding waveform)
bootindices = strmatch('boot',char(SELECTED_DATA_EXTREMA.type),'exact');
nonbootindices = strmatch('single',char(SELECTED_DATA_EXTREMA.type),'exact');
indices = [bootindices;nonbootindices];

% Draw maxima and minima as circles
for i=indices'
    if get(handles.checkbox_minimum,'Value')
        plot(PLOTAXES,minimum_lat(i),minimum_amp(i),'o','Color',COLORORDER(1+mod(ColIndex-1,max(size(COLORORDER))),:));
    end
    if get(handles.checkbox_maximum,'Value')
        plot(PLOTAXES,maximum_lat(i),maximum_amp(i),'o','Color',COLORORDER(1+mod(ColIndex-1,max(size(COLORORDER))),:)); 
    end
    ColIndex=ColIndex+1;
end

% Enable 'Save' button 
set(handles.pushbutton_Save,'Enable','on');
% bring legend window to the top 
figure(LEGENDWINDOW);
% return to Extrema gui
figure(handles.figure_Extrema);

% --------------------------------------------------------------------
% pushbutton_Save_Callback
% --------------------------------------------------------------------
function varargout = pushbutton_Save_Callback(h, eventdata, handles, varargin)
global DATA_SAVE_EXTREMA        % selected data

name = DATA_SAVE_EXTREMA.name;
latmin = DATA_SAVE_EXTREMA.latmin;
ampmin = DATA_SAVE_EXTREMA.ampmin;
latmax = DATA_SAVE_EXTREMA.latmax;
ampmax = DATA_SAVE_EXTREMA.ampmax;

% determine number of lines to be saved (this may include mean and confidence interval entries if selected)
len = max(size(latmin,1),size(latmax,1));

% determine length of the different colums in the text box of the extrema windows
widname = size(char(name),2);
widlatmin = size(char(latmin),2);
widampmin = size(char(ampmin),2);
widlatmax = size(char(latmax),2);
widampmax = size(char(ampmax),2);

% open gui for selecting a name of the file to save the data in
[filename,pathname] = uiputfile('extrema.txt','Save extrema');
if filename == 0
    return;
end
[pathstr,basename,ext,versn] = fileparts(filename);

% append extension '.txt' if not already existent
if isempty(strmatch(ext,'.txt','exact'))
    filename = [filename,'.txt'];
end

% Save data
if isempty(strmatch(name,'','exact'))
    fid = fopen([pathname,filename],'w');
    % distinguish whether minima and/or maxima ar to be saved?
    switch DATA_SAVE_EXTREMA.checkbox_minimum - DATA_SAVE_EXTREMA.checkbox_maximum
    case -1   % Nur Maximum
        fprintf(fid,'Search for maximum between %s and %s ms.\r\n',DATA_SAVE_EXTREMA.maxmin,DATA_SAVE_EXTREMA.maxmax);
        for i=1:widname+floor((widlatmax+7)/2)
            fprintf(fid,' ');
        end
        fprintf(fid,'Maximum\r\n');
        for i=1:len
            fprintf(fid,'%s   %s   %s\r\n',char(name(i,:)),char(latmax(i,:)),char(ampmax(i,:)));
        end
    case 0    % Minimum and Maximum
        fprintf(fid,'Search for minimum between %s and %s ms.\r\n',DATA_SAVE_EXTREMA.minmin,DATA_SAVE_EXTREMA.minmax);
        fprintf(fid,'Search for maximum between %s and %s ms.\r\n',DATA_SAVE_EXTREMA.maxmin,DATA_SAVE_EXTREMA.maxmax);
        space = '';
        for i=1:-3+widlatmin+widampmin+floor((widlatmax+7)/2)-floor((widlatmin+7)/2)
            space=[space ' '];
        end
        for i=1:widname+floor((widlatmin+7)/2)
            fprintf(fid,' ');
        end
        fprintf(fid,'Minimum %s Maximum\r\n',space);
        for i=1:len
            fprintf(fid,'%s   %s   %s   %s   %s\r\n',char(name(i,:)),char(latmin(i,:)),char(ampmin(i,:)),char(latmax(i,:)),char(ampmax(i,:)));
        end
    case 1    % Ninimum only
        fprintf(fid,'Search for minimum between %s and %s ms.\r\n',DATA_SAVE_EXTREMA.minmin,DATA_SAVE_EXTREMA.minmax);
        for i=1:widname+floor((widlatmin+7)/2)
            fprintf(fid,' ');
        end
        fprintf(fid,'Minimum\r\n');
        for i=1:len
            fprintf(fid,'%s   %s   %s\r\n',char(name(i,:)),char(latmin(i,:)),char(ampmin(i,:)));
        end
    end
    fclose(fid);
end



% --------------------------------------------------------------------
% pushbutton_Cancel_Callback: close extrema window
% --------------------------------------------------------------------
function varargout = pushbutton_Cancel_Callback(h, eventdata, handles, varargin)
close

% --------------------------------------------------------------------
% text_minlat_Callback (empty)
% --------------------------------------------------------------------
function varargout = text_minlat_Callback(h, eventdata, handles, varargin)


% --------------------------------------------------------------------
% text_ampmin_Callback (empty)
% --------------------------------------------------------------------
function varargout = text_ampmin_Callback(h, eventdata, handles, varargin)


% --------------------------------------------------------------------
% text_latmax_Callback (empty)
% --------------------------------------------------------------------
function varargout = text_latmax_Callback(h, eventdata, handles, varargin)


% --------------------------------------------------------------------
% text_ampmax_Callback (empty)
% --------------------------------------------------------------------
function varargout = text_ampmax_Callback(h, eventdata, handles, varargin)


% --------------------------------------------------------------------
% edit_minmin_Callback: lower time limit for search for minimum
% --------------------------------------------------------------------
function varargout = edit_minmin_Callback(h, eventdata, handles, varargin)
global EX_TSB               % time sweep begins of selected data
global EX_T_END             % time sweep ends of selected data
set(handles.checkbox_minimum,'Value',1);
checkbox_minimum_Callback(h, eventdata, handles, varargin);
% check whether entered value is a number and within the time interval included in all selected waveforms; if not, set to minimum value
if isempty(str2num(get(handles.edit_minmin,'String'))) | (str2num(get(handles.edit_minmin,'String')) < max(EX_TSB))...
        | (str2num(get(handles.edit_minmin,'String')) > min(EX_T_END))
    set(handles.edit_minmin,'String',num2str((round(max(EX_TSB)*100))/100));
end

% --------------------------------------------------------------------
% edit_minmax_Callback: upper time limit for search for minimum
% --------------------------------------------------------------------
function varargout = edit_minmax_Callback(h, eventdata, handles, varargin)
global EX_TSB               % time sweep begins of selected data
global EX_T_END             % time sweep ends of selected data
set(handles.checkbox_minimum,'Value',1);
checkbox_minimum_Callback(h, eventdata, handles, varargin);
% check whether entered value is a number and within the time interval included in all selected waveforms; if not, set to maximum value
if isempty(str2num(get(handles.edit_minmax,'String'))) | (str2num(get(handles.edit_minmax,'String')) > min(EX_T_END))...
        | (str2num(get(handles.edit_minmax,'String')) < max(EX_TSB))
    set(handles.edit_minmax,'String',num2str((round(min(EX_T_END)*100))/100));
end

% --------------------------------------------------------------------
% edit_maxmin_Callback: lower time limit for search for maximum
% --------------------------------------------------------------------
function varargout = edit_maxmin_Callback(h, eventdata, handles, varargin)
global EX_TSB               % time sweep begins of selected data
global EX_T_END             % time sweep ends of selected data
set(handles.checkbox_maximum,'Value',1);
checkbox_maximum_Callback(h, eventdata, handles, varargin);
% check whether entered value is a number and within the time interval included in all selected waveforms; if not, set to minimum value
if isempty(str2num(get(handles.edit_maxmin,'String'))) | (str2num(get(handles.edit_maxmin,'String')) < max(EX_TSB))...
        | (str2num(get(handles.edit_maxmin,'String')) > min(EX_T_END))
    set(handles.edit_maxmin,'String',num2str((round(max(EX_TSB)*100))/100));
end

% --------------------------------------------------------------------
% edit_maxmax_Callback: upper time limit for search for maximum
% --------------------------------------------------------------------
function varargout = edit_maxmax_Callback(h, eventdata, handles, varargin)
global EX_TSB               % time sweep begins of selected data
global EX_T_END             % time sweep ends of selected data
set(handles.checkbox_maximum,'Value',1);
checkbox_maximum_Callback(h, eventdata, handles, varargin);
% check whether entered value is a number and within the time interval included in all selected waveforms; if not, set to maximum value
if isempty(str2num(get(handles.edit_maxmax,'String'))) | (str2num(get(handles.edit_maxmax,'String')) > min(EX_T_END))...
        | (str2num(get(handles.edit_maxmax,'String')) < max(EX_TSB))
    set(handles.edit_maxmax,'String',num2str((round(min(EX_T_END)*100))/100));
end


% --------------------------------------------------------------------
% checkbox_mean_Callback (empty)
% --------------------------------------------------------------------
function varargout = checkbox_mean_Callback(h, eventdata, handles, varargin)


% --------------------------------------------------------------------
% popupmenu_ci_Callback: popupmenu for confidence limit (empty) 
% --------------------------------------------------------------------
function varargout = popupmenu_ci_Callback(h, eventdata, handles, varargin)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% subfunctions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% --------------------------------------------------------------------
% Set figure layout
% --------------------------------------------------------------------
function set_figure_layout(handles)
global SELECTED_DATA_EXTREMA
len = size(SELECTED_DATA_EXTREMA,2);
wid = 0;
for i=1:len
    if length(SELECTED_DATA_EXTREMA(i).name) > wid
        wid = length(SELECTED_DATA_EXTREMA(i).name);
    end
end
wid=max(wid,19);

set(handles.figure_Extrema,'Visible','Off','Units','Characters','Position',[10 10 1.35*wid+78 1.08*len+17]);
movegui(handles.figure_Extrema,'northwest');
set(handles.text_files,'String',{char(SELECTED_DATA_EXTREMA.name); ' '; 'mean:'; 'confidence interval:'},'Units','Characters','Position',[2 1.5 wid+13 1.08*len+3.1]);
set(handles.checkbox_minimum,'Value',0,'Units','Characters','Position',[2 1.08*len+14.7 14 2]);
set(handles.checkbox_maximum,'Value',0,'Units','Characters','Position',[2 1.08*len+12.6 14 2]);
set(handles.text_interval_min,'Units','Characters','Position',[16 1.08*len+15.25 13 1]);
set(handles.text_interval_max,'Units','Characters','Position',[16 1.08*len+13.15 13 1]);
set(handles.edit_minmin,'String','','Units','Characters','Position',[30 1.08*len+15 10 1.4]);
set(handles.edit_maxmin,'String','','Units','Characters','Position',[30 1.08*len+12.9 10 1.4]);
set(handles.edit_minmax,'String','','Units','Characters','Position',[43 1.08*len+15 10 1.4]);
set(handles.edit_maxmax,'String','','Units','Characters','Position',[43 1.08*len+12.9 10 1.4]);
set(handles.text_minusmin,'Units','Characters','Position',[41 1.08*len+15.2 1.5 1]);
set(handles.text_minusmax,'Units','Characters','Position',[41 1.08*len+13.1 1.5 1]);
set(handles.checkbox_mean,'Enable','Off','Value',0,'Units','Characters','Position',[2 1.08*len+10 60 1.1]);
set(handles.text_ci,'Enable','Off','Position',[5 1.08*len+8 27 1.3]);
set(handles.popupmenu_ci,'Enable','Off','Position',[32 1.08*len+8.2 10 1.3]);
set(handles.text_Maximum,'Units','Characters','Position',[1.35*wid+58 1.08*len+6 11 1]);
set(handles.text_Minimum,'Units','Characters','Position',[1.35*wid+19 1.08*len+6 11 1]);
set(handles.text_minms,'Units','Characters','Position',[1.35*wid+13 1.08*len+5 5 1]);
set(handles.text_minnAm,'Units','Characters','Position',[1.35*wid+31 1.08*len+5 6 1]);
set(handles.text_maxms,'Units','Characters','Position',[1.35*wid+52 1.08*len+5 5 1]);
set(handles.text_maxnAm,'Units','Characters','Position',[1.35*wid+70 1.08*len+5 6 1]);
set(handles.text_latmin,'String','','Units','Characters','Position',[1.35*wid 1.5 18 1.08*len+3.1]);
set(handles.text_ampmin,'String','','Units','Characters','Position',[1.35*wid+19 1.5 18 1.08*len+3.1]);
set(handles.text_latmax,'String','','Units','Characters','Position',[1.35*wid+39 1.5 18 1.08*len+3.1]);
set(handles.text_ampmax,'String','','Units','Characters','Position',[1.35*wid+58 1.5 18 1.08*len+3.1]);
set(handles.pushbutton_Cancel,'Units','Characters','Position',[1.35*wid+65 1.08*len+11.6 11 1.6]);
set(handles.pushbutton_Save,'Enable','off','Units','Characters','Position',[1.35*wid+65 1.08*len+13.2 11 1.6]);
set(handles.pushbutton_Find,'Enable','off','Units','Characters','Position',[1.35*wid+65 1.08*len+14.8 11 1.6]);
set(handles.frame1,'Units','Characters','Position',[1 0.5 1.35*wid+76 1.08*len+7]);
set(handles.figure_Extrema,'Visible','On');