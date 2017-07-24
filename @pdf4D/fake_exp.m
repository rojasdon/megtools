function fake_exp(obj) %#ok<INUSD>

% FAKE_EXP fake_exp(obj)
% create fake Exp~* files for import

%get path to pdf4D
exp_path = fullfile(fileparts(mfilename('fullpath')), 'Exp');

%prompt for patient dir
pat_dir = uigetdir(get_data_path, 'Select Patient Directory');
if ~ischar(pat_dir)
    return
end

%get od and patient id
[od, patid] = fileparts(pat_dir);

%create Exp~patient
copyfile(fullfile(exp_path, 'Exp~Patient'), ...
    fullfile(od, ['Exp~' patid]));

%look for all scans
scan_dir = dir(pat_dir);
for scan = 1:length(scan_dir)
    if ~scan_dir(scan).isdir || scan_dir(scan).name(1)=='.'
        continue
    end
    %create Exp~scan
    copyfile(fullfile(exp_path, 'Exp~Scan'), ...
        fullfile(pat_dir, ['Exp~' scan_dir(scan).name]));
    %full scan path
    full_scan_dir = fullfile(pat_dir, scan_dir(scan).name);
    %loop for all sessions
    session_dir = dir(full_scan_dir);
    for session = 1:length(session_dir)
        if ~session_dir(session).isdir || session_dir(session).name(1)=='.'
            continue
        end
        %fix session name
        session_name = fix_session_name(full_scan_dir, session_dir(session).name);
        %create Exp~session
        copyfile(fullfile(exp_path, 'Exp~Session'), ...
            fullfile(full_scan_dir, ['Exp~' session_name]));
        %full session path
        full_session_dir = fullfile(full_scan_dir, session_name);
        %loop for all runs
        run_dir = dir(full_session_dir);
        for run = 1:length(run_dir)
            if ~run_dir(run).isdir || run_dir(run).name(1)=='.'
                continue
            end
            %create Exp~session
            copyfile(fullfile(exp_path, 'Exp~Run'), ...
                fullfile(full_session_dir, ['Exp~' run_dir(run).name]));
            %full session path
            full_run_dir = fullfile(full_session_dir, run_dir(run).name);
            %loop for all runs
            pdf_dir = dir(full_run_dir);
            for pdf = 1:length(pdf_dir)
                if pdf_dir(pdf).isdir || ...
                        strcmp(pdf_dir(pdf).name, 'config') || ...
                        strcmp(pdf_dir(pdf).name, 'hs_file') || ...
                        strcmp(pdf_dir(pdf).name(1:4), 'Exp~') || ...
                        ~ispdf(fullfile(full_run_dir, pdf_dir(pdf).name))
                    continue
                end
                %create Exp~pdf
                copyfile(fullfile(exp_path, 'Exp~PDF'), ...
                    fullfile(full_run_dir, ['Exp~' pdf_dir(pdf).name]));
            end            
        end
    end
end

function new_name = fix_session_name(scan_dir, old_name)
new_name = regexprep(old_name,'@','@_');
new_name = regexprep(new_name,'%','@-');
if ~strcmp(new_name, old_name)
    movefile(fullfile(scan_dir, old_name), fullfile(scan_dir, new_name));
end