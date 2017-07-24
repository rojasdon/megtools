function de(data, offset, max_scale, grid, color)
% function de(data, max_scale, offset, grid, color)
% data - time by channel
% max_scale - 2 element vector - max zoom for x (time) and y
% offset - channel offsets (1 by number_of_channels)
% grid - 'on' or 'off' (default: 'on')
% color - number_of_channels by 3 (default: random colors)
%
% Copyleft 2011, eugene.kronberg@ucdenver.edu

if nargin < 2 || isempty(offset)
    offset = zeros(1,size(data,2));
end
if nargin < 3 || isempty(max_scale)
    max_scale = [size(data,1)/10 10];
end
if nargin < 4 || isempty(grid)
    grid = 'on';
end
if nargin < 5
    color = rand(size(data,2), 3);
end

%slider width (pixels)
slider_width = 10;

%create figure
fig = figure( ...
    'IntegerHandle', 'off', ...
    'NumberTitle', 'off', ...
    'Name', 'Data Viewer', ...
    'MenuBar', 'none', ...
    'ResizeFcn', @figResize);
fig_pos = get(fig, 'Position');
Xpan = uicontrol(fig, ...
    'Style', 'Slider', ...
    'Units', 'pixels', ...
    'Position', [
        slider_width
        0
        fig_pos(3) - 2 * slider_width
        slider_width], ...
    'Value', .5, ...
    'CallBack', @cbXpan);
Xzoom = uicontrol(fig, ...
    'Style', 'Slider', ...
    'Units', 'pixels', ...
    'Position', [
        slider_width
        fig_pos(4) - slider_width
        fig_pos(3) - 2 * slider_width
        slider_width], ...
    'Value', .5, ...
    'CallBack', @cbXzoom);
Ypan = uicontrol(fig, ...
    'Style', 'Slider', ...
    'Units', 'pixels', ...
    'Position', [
        fig_pos(3) - slider_width
        slider_width
        slider_width
        fig_pos(4) - 2 * slider_width], ...
    'Value', .5, ...
    'CallBack', @cbYpan);
Yzoom = uicontrol(fig, ...
    'Style', 'Slider', ...
    'Units', 'pixels', ...
    'Position', [
        0
        slider_width
        slider_width
        fig_pos(4) - 2 * slider_width], ...
    'Value', .5, ...
    'CallBack', @cbYzoom);
ax_pos = [
    slider_width
    slider_width
    fig_pos(3) - 2 * slider_width
    fig_pos(4) - 2 * slider_width];
x = 1:size(data,1);
XLim = [min(x), max(x)];
XMean = mean(XLim);
XHalf = diff(XLim)/2;
XShift = XMean;
XScale = 1;
YLim = [min(data(:)) + min(offset), max(data(:)) + max(offset)];
% YLim = [min(offset), max(offset)];
YMean = mean(YLim);
YHalf = diff(YLim)/2;
YShift = YMean;
YScale = 1;
%the only axes user sees
Ax = axes( ...
    'Units', 'pixels', ...
    'Position', ax_pos, ...
    'Parent', fig, ...
    'XLim', XLim, ...
    'YLim', [-1 1], ...
    'XTickLabe', [], ...
    'YTickLabe', [], ...
    'XGrid', grid, ...
    'YGrid', grid);
n = size(data,2);
ax = zeros(1,n);%axes handles
ln = zeros(1,n);%line handles
for ii = 1:n
    ax(ii) = axes( ...
        'Units', 'pixels', ...
        'Position', ax_pos, ...
        'Parent', fig, ...
        'XLim', XLim, ...
        'Ylim', YLim - offset(ii), ...
        'Visible', 'off', ...
        'HitTest', 'off', ...
        'HandleVisibility', 'off', ...
        'Units', 'pixels');
    ln(ii) = line(x, data(:,ii), 'Parent', ax(ii), 'Color', color(ii,:));
end
    function figResize(varargin)
        fig_pos = get(fig, 'Position');
        set(Xpan, 'Position', [
            slider_width
            0
            fig_pos(3) - 2 * slider_width
            slider_width]);
        set(Xzoom, 'Position', [
            slider_width
            fig_pos(4) - slider_width
            fig_pos(3) - 2 * slider_width
            slider_width]);
        set(Ypan, 'Position', [
            fig_pos(3) - slider_width
            slider_width
            slider_width
            fig_pos(4) - 2 * slider_width]);
        set(Yzoom, 'Position', [
            0
            slider_width
            slider_width
            fig_pos(4) - 2 * slider_width]);
        set(Ax, 'Position', [
            slider_width
            slider_width
            fig_pos(3) - 2 * slider_width
            fig_pos(4) - 2 * slider_width]);
        set(ax, 'Position', [
            slider_width
            slider_width
            fig_pos(3) - 2 * slider_width
            fig_pos(4) - 2 * slider_width]);
    end
    function cbXpan(varargin)
        XShift = XMean + diff(XLim) * (get(Xpan, 'Value') - .5);
        setXLim
    end
    function cbXzoom(varargin)
        XScale = max_scale(1)^(2*get(Xzoom, 'Value') - 1);
        setXLim
    end
    function setXLim
        x_lim = XShift + [-XHalf XHalf] / XScale;
        set(ax, 'XLim', x_lim)
    end
    function cbYpan(varargin)
        YShift = YMean + diff(YLim) * (get(Ypan, 'Value') - .5);
        setYLim
    end
    function cbYzoom(varargin)
        YScale = max_scale(2)^(2*get(Yzoom, 'Value') - 1);
        setYLim
    end
    function setYLim
        y_lim = YShift + [-YHalf YHalf] / YScale;
        for syl=1:n
            set(ax(syl), 'YLim', y_lim - offset(syl))
        end
    end
end