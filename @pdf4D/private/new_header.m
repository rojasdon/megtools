function header = new_header(pdf)

%header = new_header
%
%Creates MSI pdf header

%Revision 1.0  12/11/08  eugene.kronberg@uchsc.edu

% if nargin ~= 1
%     error('Wrong number of input arguments');
% end

%create dftk_header_data
header = struct( ...
    'header_data', new_header_data(pdf), ...
    'epoch_data', {{}}, ...
    'channel_data', {{}}, ... %no channels
    'event_data', {{new_event_data(pdf)}}, ...
    'header_tail', zeros(0,1, 'uint8'));