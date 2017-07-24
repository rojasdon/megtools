function type = findtype(var)

if isa(var, 'char'); type = 'char'; return; end; 
if isa(var, 'int8'); type = 'int8'; return; end; 
if isa(var, 'int16'); type = 'int16'; return; end; 
if isa(var, 'int32'); type = 'int32'; return; end; 
if isa(var, 'int64'); type = 'int64'; return; end; 
if isa(var, 'uint8'); type = 'uint8'; return; end; 
if isa(var, 'uint16'); type = 'uint16'; return; end; 
if isa(var, 'uint32'); type = 'uint32'; return; end; 
if isa(var, 'uint64'); type = 'uint64'; return; end; 
if isa(var, 'single'); type = 'single'; return; end; 
if isa(var, 'double'); type = 'double'; return; end; 
    
end