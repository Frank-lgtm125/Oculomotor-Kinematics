function plot_session_results(refinedData, p)
    %% 1. Directory Setup
    % Create a subfolder for figures to keep the workspace clean
    figDir = fullfile('results', 'figures', p.session);
    if ~exist(figDir, 'dir'), mkdir(figDir); end
    
    fprintf('Generating plots in: %s...\n', figDir);

    %% 2. Batch Plotting Loop
    for i = 1:length(refinedData)
        temp = refinedData{i};
        if isempty(temp), continue; end
        
        % Initialize figure with a professional size
        fig = figure('Name', sprintf('File %d', temp.number), 'Visible', 'off', 'Color', 'w');
        set(fig, 'Position', [100, 100, 800, 1000]);
        
        num_trials = size(temp.ehp_ipsi, 1);
        t = temp.timeframe;
        info_str = sprintf('%d uA, %d ms, %d Hz', temp.current, temp.dur, temp.freq);

        %% --- Subplot 1: All Trials (Position) ---
        subplot(2,2,1); hold on;
        plot(t, temp.ehp_ipsi, 'Color', [0.7 0.7 0.7]); % Gray lines for raw trials
        title(sprintf('Ipsi Eye Position (Individual Trials, n=%d)', num_trials));
        ylabel('Pos (deg)');

        %% --- Subplot 2: Average & CI (Position) ---
        subplot(2,2,2); hold on;
        fill_ci(t, temp.ipsi_ehp_avg, temp.CI_ipsi_ehp_lower, temp.CI_ipsi_ehp_upper, 'r');
        title('Average Ipsi Eye Position (95% CI)');
        ylabel('Pos (deg)');

        %% --- Subplot 3: All Trials (Velocity) ---
        subplot(2,2,3); hold on;
        plot(t, 1000 * temp.ehv_ipsi, 'Color', [0.7 0.7 0.7]);
        title('Ipsi Eye Velocity (Individual Trials)');
        ylabel('Vel (deg/s)');

        %% --- Subplot 4: Average & CI (Velocity) ---
        subplot(2,2,4); hold on;
        fill_ci(t, 1000 * temp.ipsi_ehv_avg, 1000 * temp.CI_ipsi_ehv_lower, 1000 * temp.CI_ipsi_ehv_upper, 'y');
        title('Average Ipsi Eye Velocity (95% CI)');
        ylabel('Vel (deg/s)');

        %% --- Unified Formatting (Axes, Xlines, Legends) ---
        for sp = 1:4
            subplot(2,2,sp);
            
            % Draw Stimulus Onset and Offset (Onset at 0, Offset at temp.dur)
            xline(0, '--r', 'LineWidth', 1.5, 'HandleVisibility', 'off');
            xline(temp.dur, '--k', 'LineWidth', 1, 'HandleVisibility', 'off');
            
            % Set standard axis limits from user-defined parameters
            % Use p.plot structure for flexibility
            if sp <= 2
                % Position subplots
                axis([p.plot.x_lim, p.plot.y_pos]);
            else
                % Velocity subplots
                axis([p.plot.x_lim, p.plot.y_vel]);
            end
            
            grid on; 
            set(gca, 'FontSize', 10); % Professional font sizing
            xlabel('Time (ms)');
        end

        %% 3. Save Figure
        fileName = fullfile(figDir, sprintf('File_%03d_Plot.png', temp.number));
        exportgraphics(fig, fileName, 'Resolution', 300);
        close(fig);
    end
    fprintf('Plotting complete.\n');
end

%% Internal Helper for CI Filling
function fill_ci(t, avg, lower, upper, colorStr)
    x_patch = [t, fliplr(t)];
    y_patch = [lower, fliplr(upper)];
    fill(x_patch, y_patch, 1, 'FaceColor', colorStr, 'FaceAlpha', 0.2, 'EdgeColor', 'none', 'HandleVisibility', 'off');
    plot(t, avg, 'Color', colorStr, 'LineWidth', 2, 'DisplayName', 'Average');
end
