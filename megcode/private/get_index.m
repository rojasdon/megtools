function index = get_index(arr,val)
% function to return index of nearest array value
% will return index of nearest rounded down value (e.g., if arr = 1:2:10 and
% val = 2, then index will = 1, not 2. This behavior is only dramatic for
% whole numbers

% FIXME: can change this behavior to default modifiable by arg

% prevent NAN evaluation errors
if isnan(val)
  error('Value to search for must not be nan!')
end

% simplify search
arr = arr(:);

if val<max(arr)
  [junk, index] = min(abs(arr(:) - val));
else
  [junk, tmpind] = max(flipud(arr));
  index = length(arr) + 1 - tmpind;
end

end