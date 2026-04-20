function [removed, remained, error] = pipeline(file_path, params, session_name)
% PIPELINE - Core function for ocular kinematic data.
% Inputs:
%   file_path    - Full or relative path to the .mat file
%   params       - Parameter structure (p)
%   session_name - Identifier for the current session
% ---------------------------------------------------------
% Note: Metadata extraction is handled by the main script's attach_metadata function.
try
    %% 1. Data Loading & Parsing
    sample = load(file_path);
    [~, file_name, ~] = fileparts(file_path);
    
    % Robust metadata extraction using regex
    description = str2double(regexp(file_name, '\d+', 'match'));
    if length(description) < 4
        error('Filename format mismatch. Expected at least 4 numerical segments.');
    end
    
    % Metadata mapping (Note: ensure consistency with your naming convention)
    % number = description(1);
    % dur    = description(2); 
    % freq   = description(3); 
    % current = description(4); 

    %% 2. Step-wise Signal Processing
    p = params;
    
    % --- Stage 1: Segment Extraction ---
    p.fc = p.fc1; 
    [D0, timeframe] = extract_segments(sample, p);

    % --- Stage 2: Initial Filtering & Velocity Validation ---
    D1 = freq_filter(D0, p);
    [D1_removed, D1_remained] = velocity_filter(D1, p);
    
    % --- Stage 3: Position Validation & Secondary Filtering ---
    if ~isempty(D1_remained.ehp_left)
        % Position Check
        [D2_removed, D2_remained] = position_filter(D1_remained, p);
        
        % Final Smoothing (Stage 2 Cutoff)
        p.fc = p.fc2;
        remained = freq_filter(D2_remained, p);
        
        % Consolidate removed trials for record-keeping
        removed = D2_removed; 
        % (Optional: You could merge D1_removed and D2_removed here)
    else
        % Fallback if no trials pass velocity filter
        remained = D1_remained; 
        remained.ehp_left = []; % Clear explicit data while keeping structure
        removed  = D1_removed;
    end
    %% 3. Output Packaging
    remained.timeframe = timeframe;
    removed.timeframe  = timeframe;
    error = 0; % Success

catch ME
    % Catch-all for robust batch processing
    fprintf('   [ERROR] Failed to process %s: %s\n', file_name, ME.message);
    remained = [];
    removed  = [];
    error    = 1;  %report failure
end

end
