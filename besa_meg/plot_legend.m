function varargout = plot_legend(varargin)
% --------------------------------------------------------------------
% plot legend window
% This gui is without any callbacks; entries of the corresponding text fields (the legend) are set
% when the 'plot' button in the main window is pressed
% --------------------------------------------------------------------

global PLOTWINDOW
global PLOTFIGURE

if nargin == 0  % LAUNCH GUI
    
	fig = openfig(mfilename,'reuse','invisible');
    set(fig,'Color',get(0,'DefaultUicontrolBackgroundColor'));
    % Generate a structure of handles to pass to callbacks, and store it. 
	handles = guihandles(fig);
	guidata(fig, handles);
        
	if nargout > 0
		varargout{1} = fig;
	end

elseif ischar(varargin{1}) % INVOKE NAMED SUBFU

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
