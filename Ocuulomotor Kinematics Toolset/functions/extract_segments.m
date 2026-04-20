function [output, timeframe] = extract_segments(sample, params)
    % EXTRACT_SEGMENTS - Isolates eye movement segments with pre/post buffers
    % and calculates velocity via numerical gradient.

    pre  = params.prebuffer;
    post = params.postbuffer;
    data = sample.Data;

    %% 1. Data Field Selection (Ipsi/Contra & H/V)
    % Using conditional mapping to simplify extraction
    if isfield(data, 'ehp_left_3d')
        h_l = data.ehp_left_3d.';  h_r = data.ehp_right_3d.';
        v_l = data.evp_left_3d.';  v_r = data.evp_right_3d.';
    else 
        % Fallback for corrected data formats
        h_l = data.ehp_corrected.'; h_r = data.ehp_corrected.';
        v_l = data.evp_corrected.'; v_r = data.evp_corrected.';
    end

    segments = data.segments.stimulus; % Direct access assuming table/struct
    num_stim = size(segments, 1);
    sig_len  = length(h_l);

    %% 2. Synchronized Extraction & Velocity Computation
    % Pre-allocate cell arrays for performance
    p_l_raw = cell(num_stim, 1); p_r_raw = cell(num_stim, 1);
    v_l_raw = cell(num_stim, 1); v_r_raw = cell(num_stim, 1);
    t_raw   = cell(num_stim, 1);

    for i = 1:num_stim
        t_start = segments(i, 1);
        t_end   = segments(i, 2);
        
        % Defensive indexing to prevent out-of-bounds errors
        idx = max(1, t_start - pre) : min(sig_len, t_end + post);
        
        % Extract Position
        p_l_raw{i} = h_l(idx); 
        p_r_raw{i} = h_r(idx);
        v_l_raw{i} = v_l(idx); 
        v_r_raw{i} = v_r(idx);
        
        % Relative timeframe (aligned to pulse onset at 0ms)
        t_raw{i} = (idx - t_start); 
    end

    %% 3. Alignment & Trimming
    % Ensure all segments have identical length for matrix-based downstream analysis
    output.ehp_left  = trim_cell_data(p_l_raw);
    output.ehp_right = trim_cell_data(p_r_raw);
    output.evp_left  = trim_cell_data(v_l_raw);
    output.evp_right = trim_cell_data(v_r_raw);
    
    time_trimmed     = trim_cell_data(t_raw);
    timeframe        = cell2mat(time_trimmed(1)); % Convert first cell to array as reference

    %% 4. Velocity Calculation (Gradient)
    % Vectorized gradient application across cells
    output.ehv_left  = cellfun(@gradient, output.ehp_left,  'UniformOutput', false);
    output.ehv_right = cellfun(@gradient, output.ehp_right, 'UniformOutput', false);
    output.evv_left  = cellfun(@gradient, output.evp_left,  'UniformOutput', false);
    output.evv_right = cellfun(@gradient, output.evp_right, 'UniformOutput', false);
end

%% Helper: Efficient Cell Trimming
function trimmed = trim_cell_data(dataCell)
    % Finds the global minimum length and truncates all cells accordingly
    minLen  = min(cellfun(@length, dataCell));
    trimmed = cellfun(@(x) x(1:minLen), dataCell, 'UniformOutput', false);
end
