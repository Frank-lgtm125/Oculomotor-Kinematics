%% post-process the data (calculate mean and confidence interval for all metrics)
function output = post_process(processed_data)
    alpha = 0.05; % significance level for 95% confidence interval
    num_files = size(processed_data, 1);
    output = cell(num_files, 1);

    for i = 1:num_files
        temp = processed_data{i};
        
        % convert cell arrays to matrices for bulk calculation
        % using professional naming for ipsilateral/contralateral groups
        try
            % Horizontal & Vertical Position (Ipsi/Contra)
            hp_i = cell2mat(temp.ehp_left);  vp_i = cell2mat(temp.evp_left);
            hp_c = cell2mat(temp.ehp_right); vp_c = cell2mat(temp.evp_right);

            % Horizontal & Vertical Velocity (Ipsi/Contra)
            hv_i = cell2mat(temp.ehv_left);  vv_i = cell2mat(temp.evv_left);
            hv_c = cell2mat(temp.ehv_right); vv_c = cell2mat(temp.evv_right);
        catch
            % Skip if conversion fails (e.g., inconsistent segment lengths)
            output{i} = []; continue;
        end

        %% 1. statistical analysis for Position data
        % using a helper to avoid redundant code
        temp = run_stats(temp, hp_i, 'ipsi_ehp',  alpha);
        temp = run_stats(temp, vp_i, 'ipsi_evp',  alpha);
        temp = run_stats(temp, hp_c, 'contra_ehp', alpha);
        temp = run_stats(temp, vp_c, 'contra_evp', alpha);

        %% 2. statistical analysis for Velocity data
        temp = run_stats(temp, hv_i, 'ipsi_ehv',  alpha);
        temp = run_stats(temp, vv_i, 'ipsi_evv',  alpha);
        temp = run_stats(temp, hv_c, 'contra_ehv', alpha);
        temp = run_stats(temp, vv_c, 'contra_evv', alpha);

        output{i} = temp;
    end
end

%% Helper: internal function to execute stats and assign fields dynamically
function s = run_stats(s, data, prefix, alpha)
    [avg, lower, upper] = regular_confidence_interval(data, alpha);
    s.([prefix, '_avg'])   = avg;
    s.([prefix, '_lower']) = lower;
    s.([prefix, '_upper']) = upper;
end

%% regular t-distribution based confidence interval
function [mean_data, ci_lower, ci_upper] = regular_confidence_interval(data, alpha)
    % data: n*m matrix (n trials, m timepoints)
    n_trials = size(data, 1);
    mean_data = mean(data, 1);
    
    % SEM calculation
    sem = std(data, 0, 1) / sqrt(n_trials); 
    
    % T-statistic for 95% CI
    t_stat = tinv(1 - alpha/2, n_trials - 1);
    
    % Calculate the margin of error (MOE)
    % Note: Professional CI uses t_stat * sem, not 2 * sem
    margin_of_error = t_stat * sem;
    
    ci_lower = mean_data - margin_of_error;
    ci_upper = mean_data + margin_of_error;
end
