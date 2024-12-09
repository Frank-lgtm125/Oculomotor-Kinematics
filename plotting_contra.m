clear all
clc
%% plotting code is for plotting figure about contra ehp/ehv purpose
load("Refined_Data2.mat");

for i=1:length(Refined_Data2)
    temp = Refined_Data2{i};
    figure;
    % plot all contralateral eye horizontal position from one processed BR file
    subplot(2,2,1)
        
    plot(temp.timeframe, temp.ehp_contra,'DisplayName', sprintf('%0.2d uA %i ms %i Hz',temp.current, temp.dur, temp.freq));
    
   % plot the mean and confidence interval of contralateral eye horizontal
   % position
    subplot(2,2,2)
    plot(temp.timeframe, temp.contra_ehp_avg,'DisplayName', sprintf('%0.2d uA %i ms %i Hz',temp.current, temp.dur, temp.freq));
    x_plot = [temp.timeframe, fliplr(temp.timeframe)]; 
    y1_plot = [temp.CI_contra_ehp_lower, fliplr(temp.CI_contra_ehp_upper)];
    fill(x_plot, y1_plot, 1, 'FaceColor', 'r','FaceAlpha',0.6, 'EdgeColor','none', 'DisplayName', '95% CI');%fill the confidence interval with color
  
    % plot all eye horizontal velocity from one processed BR file    
    subplot(2,2,3)
    plot(temp.timeframe, 1000*temp.ehv_contra,'DisplayName', sprintf('%0.2d uA %i ms %i Hz',temp.current, temp.dur, temp.freq));
    
   % plot the mean and confidence interval of contralateral eye horizontal
   % velocity 
    subplot(2,2,4)
    plot(temp.timeframe, 1000*temp.contra_ehv_avg, 'DisplayName', sprintf('%0.2d uA %i ms %i Hz',temp.current, temp.dur, temp.freq));
    
    y3_plot = [temp.CI_contra_ehv_lower, fliplr(temp.CI_contra_ehv_upper)];
    fill(x_plot, 1000*y3_plot, 1, 'FaceColor', 'y','FaceAlpha',0.6, 'EdgeColor','none', 'DisplayName', '95% CI');%fill the confidence interval with color

    subplot(2,2,1)
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
        axis([-50 300 -30 10]);
    else
        axis([-50 150 -30 10]);
    end
    caption = sprintf('contra eye horziontal position n=%d',size(temp.ehp_contra,1));
    title(caption,'Fontsize',12);
    xlabel("time (ms)")
    ylabel("Eye Horizontal Position (deg)")
    
    subplot(2,2,2)
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
    else
        axis([-50 150 -30 10]);
    end
    caption = sprintf('aveg contra eye horziontal position n=%d',size(temp.ehp_contra,1));
    title(caption,'Fontsize',12);
    xlabel("time (ms)")
    ylabel("Eye Horizontal Position (deg)")

    subplot(2,2,3)
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
    else
        axis([-50 150 -600 600]);
    end
    caption = sprintf('contra eye horziontal velocity n=%d',size(temp.ehv_contra,1));
    title(caption,'Fontsize',12);
    ylabel("Eye Horizontal Velocity (deg/s)");


    subplot(2,2,4)
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
    [~,max_vel] = min(temp.contra_ehv_avg);
    xline(temp.timeframe(1)+max_vel, 'b--', 'DisplayName',sprintf('Max velocity at t=%ims', temp.timeframe(1)+max_vel));
    legend;
    if temp.dur == 200
        axis([-50 300 -600 600]);
    else
        axis([-50 150 -600 600]);
    end
    caption = sprintf('aveg contra eye horziontal velocity n=%d',size(temp.ehv_contra,1));
    title(caption,'Fontsize',12);
    ylabel("Eye Horizontal Velocity (deg/s)");
    figurename = sprintf('File number=%d contra plot',temp.number);
    savefig(figurename);
    close all
end

