clear all
clc
%% plotting code is for plotting figure about ipsi ehp/ehv purpose
load("Refined_Data2.mat");
prebuffer = 100;
postbuffer = 150;

for i=1:length(Refined_Data2)
    temp = Refined_Data2{i};
    figure;
    subplot(3,2,1)
    plot(temp.timeframe, temp.ipsi_ehp_avg,'DisplayName', sprintf('%0.2d uA %i ms %i Hz',temp.current, temp.dur, temp.freq));
    x_plot = [temp.timeframe, fliplr(temp.timeframe)]; 
    y1_plot = [temp.CI_ipsi_ehp_lower, fliplr(temp.CI_ipsi_ehp_upper)];
    fill(x_plot, y1_plot, 1, 'FaceColor', 'r','FaceAlpha',0.6, 'EdgeColor','none', 'DisplayName', '95% CI');%fill the confidence interval with color

    subplot(3,2,2)
    plot(temp.timeframe, temp.contra_ehp_avg,'DisplayName', sprintf('%0.2d uA %i ms %i Hz',temp.current, temp.dur, temp.freq));
    x_plot = [temp.timeframe, fliplr(temp.timeframe)]; 
    y1_plot = [temp.CI_contra_ehp_lower, fliplr(temp.CI_contra_ehp_upper)];
    fill(x_plot, y1_plot, 1, 'FaceColor', 'r','FaceAlpha',0.6, 'EdgeColor','none', 'DisplayName', '95% CI');%fill the confidence interval with color


    % plot all ipsilateral eye horizontal position from one processed BR file
    subplot(3,2,3)   
    plot(temp.timeframe, 1000*temp.ehv_ipsi,'DisplayName', sprintf('%0.2d uA %i ms %i Hz',temp.current, temp.dur, temp.freq))
    
    % plot the mean and confidence interval of ipsilateral eye horizontal
    % position
    subplot(3,2,4)
    plot(temp.timeframe, temp.ipsi_ehp_avg,'DisplayName', sprintf('%0.2d uA %i ms %i Hz',temp.current, temp.dur, temp.freq));
    x_plot = [temp.timeframe, fliplr(temp.timeframe)]; 
    y1_plot = [temp.CI_ipsi_ehv_lower, fliplr(temp.CI_ipsi_ehv_upper)];
    fill(x_plot, 1000*y1_plot, 1, 'FaceColor', 'r','FaceAlpha',0.6, 'EdgeColor','none', 'DisplayName', '95% CI');%fill the confidence interval with color
    
    % plot all eye horizontal velocity from one processed BR file
    subplot(3,2,5)
    plot(temp.timeframe, 1000*temp.ehv_contra,'DisplayName', sprintf('%0.2d uA %i ms %i Hz',temp.current, temp.dur, temp.freq));
    
    % plot the mean and confidence interval of ipsilateral eye horizontal
    % velocity 
    subplot(3,2,6)
    plot(temp.timeframe, 1000*temp.contra_ehv_avg,'DisplayName', sprintf('%0.2d uA %i ms %i Hz',temp.current, temp.dur, temp.freq));
    y2_plot = [temp.CI_contra_ehv_lower, fliplr(temp.CI_contra_ehv_upper)];
    fill(x_plot, 1000*y2_plot, 1, 'FaceColor', 'y','FaceAlpha',0.6, 'EdgeColor','none', 'DisplayName', '95% CI');%fill the confidence interval with color
    
    subplot(3,2,1)
    xline(0, '--r', 'DisplayName','Stimulus onset');
    if temp.dur == 50
        xline(50, 'k--', 'DisplayName',"50ms");
    end
    if temp.dur == 100
        xline(100, 'k--', 'DisplayName',"100ms");
    end
    if temp.dur == 200
        xline(200, 'k--', 'DisplayName',"200ms");
    end
    legend;
    if temp.dur == 200
        axis([-50 300 -30 10]);
    elseif temp.dur == 100
        axis([-50 200 -30 10]);
    else
        axis([-50 150 -30 10]);
    end
    caption = sprintf('aveg ipsi eye horziontal position n=%d',size(temp.ehp_ipsi,1));
    title(caption,'Fontsize',12);
    xlabel("time (ms)")
    ylabel("Eye Horizontal Position (deg)")
    
    subplot(3,2,2)
    xline(0, '--r', 'DisplayName','Stimulus onset');
    if temp.dur == 50
        xline(50, 'k--', 'DisplayName',"50ms");
    end
    if temp.dur == 100
        xline(100, 'k--', 'DisplayName',"100ms");
    end
    if temp.dur == 200
        xline(200, 'k--', 'DisplayName',"200ms");
    end
    legend;
    if temp.dur == 200
        axis([-50 300 -30 10]);
    elseif temp.dur == 100
        axis([-50 200 -30 10]);
    else
        axis([-50 150 -30 10]);
    end
    caption = sprintf('aveg contra eye horziontal position n=%d',size(temp.ehp_contra,1));
    title(caption,'Fontsize',12);
    xlabel("time (ms)")
    ylabel("Eye Horizontal Position (deg)")

    subplot(3,2,3)
    xline(0, '--r', 'DisplayName','Stimulus onset'); %mark the timeframe of the onset of the pulse
    if temp.dur == 50 %mark the timeframe of end of the pulse
        xline(50, 'k--', 'DisplayName',"50ms");
    end
    if temp.dur == 100
        xline(100, 'k--', 'DisplayName',"100ms");
    end
    if temp.dur == 200
        xline(200, 'k--', 'DisplayName',"200ms");
    end
    legend;
    if temp.dur == 200
        axis([-50 300 -600 600]);
    elseif temp.dur == 100
        axis([-50 200 -600 600]);
    else
        axis([-50 150 -600 600]);
    end
    caption = sprintf('ipsi eye horziontal velocity n=%d',size(temp.ehv_ipsi,1));
    title(caption,'Fontsize',12);
    xlabel("time (ms)")
    ylabel("Eye Horizontal Velocity (deg/s)")
    box off
    
    subplot(3,2,4)
    xline(0, '--r', 'DisplayName','Stimulus onset');
    if temp.dur == 50
        xline(50, 'k--', 'DisplayName',"50ms");
    end
    if temp.dur == 100
        xline(100, 'k--', 'DisplayName',"100ms");
    end
    if temp.dur == 200
        xline(200, 'k--', 'DisplayName',"200ms");
    end
    legend;
    if temp.dur == 200
        axis([-50 300 -600 600]);
    elseif temp.dur == 100
        axis([-50 200 -600 600]);
    else
        axis([-50 150 -600 600]);
    end
    [~,max_vel1] = min(temp.ipsi_ehv_avg(prebuffer:end));
    xline(temp.timeframe(prebuffer)+max_vel1, 'b--', 'DisplayName',sprintf('Max velocity at t=%ims', temp.timeframe(prebuffer)+max_vel1));
    sign_changes = diff(sign(gradient(temp.ipsi_ehv_avg(prebuffer+max_vel1:end))));
    if any(sign_changes) ~= 0;
        zero_crossings_indices = find(sign_changes ~= 0);
        xline(temp.timeframe(prebuffer)+max_vel1+zero_crossings_indices(1), 'g--','DisplayName',sprintf('return at t=%ims', temp.timeframe(prebuffer)+max_vel1+zero_crossings_indices(1)));
        rough = find(zero_crossings_indices > temp.dur - max_vel1);
        if rough(1) ~= 1
            xline(temp.timeframe(prebuffer)+max_vel1+zero_crossings_indices(rough(1)-1), 'g--','DisplayName',sprintf('return delay at t=%ims', temp.timeframe(prebuffer)+max_vel1+zero_crossings_indices(rough(1)-1)));
        end
        xline(temp.timeframe(prebuffer)+max_vel1+zero_crossings_indices(rough(1)), 'g--','DisplayName',sprintf('rough at t=%ims', temp.timeframe(prebuffer)+max_vel1+zero_crossings_indices(rough(1))));
    end
    legend;
    if temp.dur == 200
        axis([-50 300 -600 600]);
    elseif temp.dur == 100
        axis([-50 200 -600 600]);
    else
        axis([-50 150 -600 600]);
    end
    caption = sprintf('aveg ipsi eye horziontal velocity n=%d',size(temp.ehv_contra,1));
    title(caption,'Fontsize',12);
    xlabel("time (ms)")
    ylabel("Eye Horizontal Velocity (deg/s)");
    box off
    
    subplot(3,2,5)
    xline(0, '--r', 'DisplayName','Stimulus onset');
    if temp.dur == 50 
        xline(50, 'k--', 'DisplayName',"50ms");
    end
    if temp.dur == 100
        xline(100, 'k--', 'DisplayName',"100ms");
    end
    if temp.dur == 200
        xline(200, 'k--', 'DisplayName',"200ms");
    end
    legend;
    if temp.dur == 200
        axis([-50 300 -600 600]);
    elseif temp.dur == 100
        axis([-50 200 -600 600]);
    else
        axis([-50 150 -600 600]);
    end
    caption = sprintf('contra eye horziontal velocity n=%d',size(temp.ehv_contra,1));
    title(caption,'Fontsize',12);
    xlabel("time (ms)")
    ylabel("Eye Horizontal Velocity (deg/s)");
    box off
    
    
    subplot(3,2,6)
    xline(0, '--r', 'DisplayName','Stimulus onset');
    if temp.dur == 50
        xline(50, 'k--', 'DisplayName',"50ms");
    end
    if temp.dur == 100
        xline(100, 'k--', 'DisplayName',"100ms");
    end
    if temp.dur == 200
        xline(200, 'k--', 'DisplayName',"200ms");
    end
    [~,max_vel2] = min(temp.contra_ehv_avg(prebuffer:end));
    xline(temp.timeframe(prebuffer)+max_vel2, 'b--', 'DisplayName',sprintf('Peak velocity at t=%ims', temp.timeframe(prebuffer)+max_vel2));
    if any(sign_changes) ~= 0;
        xline(temp.timeframe(prebuffer)+max_vel1+zero_crossings_indices(1), 'g--','DisplayName',sprintf('return at t=%ims', temp.timeframe(prebuffer)+max_vel1+zero_crossings_indices(1)));
        if rough(1) ~= 1
            xline(temp.timeframe(prebuffer)+max_vel1+zero_crossings_indices(rough(1)-1), 'g--','DisplayName',sprintf('return delay at t=%ims', temp.timeframe(prebuffer)+max_vel1+zero_crossings_indices(rough(1)-1)));
        end
        xline(temp.timeframe(prebuffer)+max_vel1+zero_crossings_indices(rough(1)), 'g--','DisplayName',sprintf('rough at t=%ims', temp.timeframe(prebuffer)+max_vel1+zero_crossings_indices(rough(1))));
    end
    legend;
    if temp.dur == 200
        axis([-50 300 -600 600]);
    elseif temp.dur == 100
        axis([-50 200 -600 600]);
    else
        axis([-50 150 -600 600]);
    end
    caption = sprintf('aveg contra eye horziontal velocity n=%d',size(temp.ehv_contra,1));
    title(caption,'Fontsize',12);
    xlabel("time (ms)")
    ylabel("Eye Horizontal Velocity (deg/s)");
    figurename = sprintf('File number=%d velocity plot',temp.number);
    savefig(figurename);
    close all
end

