function varargout = plotwindow(varargin)
% --------------------------------------------------------------------
% gui for plot window
% This gui is without any callbacks; properties of its uicontrols and graphs to
% be plotted are set by the callback routine of the plot button in the main window.
% --------------------------------------------------------------------

global PLOTFIGURE   % handle of the plot window
global PLOTAXES     % handle of the axes in plot window

if nargin == 0  % LAUNCH GUI
    PLOTFIGURE = openfig(mfilename,'reuse');
    set(PLOTFIGURE,'Color',get(0,'DefaultUicontrolBackgroundColor'));

    % Generate a structure of handles to pass to callbacks, and store it. 
	handles = guihandles(PLOTFIGURE);
    guidata(PLOTFIGURE, handles);
    
    % Position window to the lower right corner of the screen
    set(0,'Units','characters');
    screensize = get(0,'ScreenSize');
    set(PLOTFIGURE,'Units','characters');
    set(PLOTFIGURE,'Position',[1 2 149 round(screensize(4)/2)-6.3]); 
    movegui(PLOTFIGURE,'southeast');
    pos = get(PLOTFIGURE,'Position');
    set(PLOTFIGURE,'Position',[pos(1) 2 149 round(screensize(4)/2)-6.3]); 
    set(PLOTFIGURE,'Units','normalized');
    
    % set global variable PLOTAXES to be the handle of the axes in the plot window
    PLOTAXES = handles.axes1;
    
    if nargout > 0
		varargout{1} = PLOTFIGURE;
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

