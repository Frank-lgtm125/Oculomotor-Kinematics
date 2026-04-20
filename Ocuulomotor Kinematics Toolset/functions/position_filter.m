%% remove data with saccades, blinking, and off primary positions and apply offset

function [filtered, result] = position_filter(data, params) 
    
    % load parameters from structure
    prebuffer = params.prebuffer; 
    tol = params.threshs(1); % position threshold for initial ehp/evp
    
    % input signal extraction
    ehp_l = data.ehp_left; ehp_r = data.ehp_right;
    evp_l = data.evp_left; evp_r = data.evp_right;
    num_trials = size(ehp_l, 1);

    %% 1. ensure velocity data exists
    if isfield(data, 'ehv_left')
        ehv_l = data.ehv_left; ehv_r = data.ehv_right;
        evv_l = data.evv_left; evv_r = data.evv_right;
    else
        % calculate gradient if velocity field is missing
        ehv_l = cellfun(@gradient, ehp_l, 'UniformOutput', false);
        ehv_r = cellfun(@gradient, ehp_r, 'UniformOutput', false);
        evv_l = cellfun(@gradient, evp_l, 'UniformOutput', false);
        evv_r = cellfun(@gradient, evp_r, 'UniformOutput', false);
    end
    
    %% 2. baseline correction (Offset Removal)
    % pre-allocate containers
    ehp_l_corr = cell(num_trials, 1); ehp_r_corr = cell(num_trials, 1);
    evp_l_corr = cell(num_trials, 1); evp_r_corr = cell(num_trials, 1);
    bias_flags = false(num_trials, 1); % track trials exceeding position tolerance

    for i = 1:num_trials
        % calculate bias from the mean of 20ms window prior to stimulus
        b_ehp_l = mean(ehp_l{i}((prebuffer-20):prebuffer));
        b_ehp_r = mean(ehp_r{i}((prebuffer-20):prebuffer));
        b_evp_l = mean(evp_l{i}((prebuffer-20):prebuffer));
        b_evp_r = mean(evp_r{i}((prebuffer-20):prebuffer));
        
        % apply offset correction
        ehp_l_corr{i} = ehp_l{i} - b_ehp_l;
        ehp_r_corr{i} = ehp_r{i} - b_ehp_r;
        evp_l_corr{i} = evp_l{i} - b_evp_l;
        evp_r_corr{i} = evp_r{i} - b_evp_r;

        % check if the initial position (bias) is within acceptable range
        if abs(b_ehp_l) > tol || abs(b_ehp_r) > tol || ...
           abs(b_evp_l) > tol || abs(b_evp_r) > tol
            bias_flags(i) = true; % mark for removal
        end
    end

    %% 3. split trials into filtered (removed) and result (remained)
    pass_idx = find(~bias_flags);
    fail_idx = find(bias_flags);

    % packaging remained data
    result.ehp_left  = ehp_l_corr(pass_idx);
    result.ehp_right = ehp_r_corr(pass_idx);
    result.evp_left  = evp_l_corr(pass_idx);
    result.evp_right = evp_r_corr(pass_idx);
    result.ehv_left  = ehv_l(pass_idx);
    result.ehv_right = ehv_r(pass_idx);
    result.evv_left  = evv_l(pass_idx);
    result.evv_right = evv_r(pass_idx);
    result.list      = pass_idx;

    % packaging removed data
    filtered.ehp_left  = ehp_l_corr(fail_idx);
    filtered.ehp_right = ehp_r_corr(fail_idx);
    filtered.evp_left  = evp_l_corr(fail_idx);
    filtered.evp_right = evp_r_corr(fail_idx);
    filtered.ehv_left  = ehv_l(fail_idx);
    filtered.ehv_right = ehv_r(fail_idx);
    filtered.evv_left  = evv_l(fail_idx);
    filtered.evv_right = evv_r(fail_idx);
    filtered.list      = fail_idx;
end
