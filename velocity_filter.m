%% velocity filter to examine if the velocity of each response exceed threshold during alpha(pre), during or omega(post) period
function [filtered, result]= velocity_filter(data, params) 
    prebuffer = params.prebuffer; % alpha period
    postbuffer = params.postbuffer; % omega period depends on the input
    tol = params.threshs(1); %threshold value for position, not used in this pipeline
    pre_thresh = params.threshs(2)/params.fs; % horizontal eye velocity threshold for alpha
    dur_thresh = params.threshs(3)/params.fs; % horizontal eye velocity threshold for during
    post_thresh = params.threshs(4)/params.fs; % horizontal eye velocity threshold for omega
    pre_thresh_rest = params.threshs(5)/params.fs; % vertical eye velocity threshold for alpha
    dur_thresh_rest = params.threshs(6)/params.fs; % vertical eye velocity threshold for during
    post_thresh_rest = params.threshs(7)/params.fs; %vertical eye velocity threshold for omega

    %% extract data
    ehp_left_3d = data.ehp_left;
    ehp_right_3d = data.ehp_right;
    evp_left_3d = data.evp_left;
    evp_right_3d = data.evp_right;
    %% see if data has ehv_left, this may happen when velocity goes before. currently since extract goes before, no need to do if
    % extract_segments

    if isfield(data, 'ehv_left')
    ehv_left_3d = data.ehv_left;
    ehv_right_3d = data.ehv_right;
    evv_left_3d = data.evv_left;
    evv_right_3d = data.evv_right;

    else
        ehv_left_3d = cell(size(ehp_left_3d,1),1);
        ehv_right_3d = cell(size(ehp_left_3d,1),1);
        evv_left_3d = cell(size(ehp_left_3d,1),1);
        evv_right_3d = cell(size(ehp_left_3d,1),1);

        for i = 1:size(evp_right_3d,1)
            ehv_left_3d{i} = gradient(ehp_left_3d{i});
            ehv_right_3d{i} = gradient(ehp_right_3d{i});
            evv_left_3d{i} = gradient(evp_left_3d{i});
            evv_right_3d{i} = gradient(evp_right_3d{i});
        end
    end
%% filter based on eye velocity
% initialize the data
    slope_pre_H_move = zeros(size(ehp_left_3d,1),2); %  eye horizontal velocity prior to stimulus
    slope_pre_rest = zeros(size(ehp_left_3d,1),2); %  rest of the eye velocity prior to stimulus
    slope_dur_H_move = zeros(size(ehp_left_3d,1),2); % eye horizontal velocity during stimulus
    slope_dur_rest = zeros(size(ehp_left_3d,1),2); % rest of the eye velocity during stimulus
    slope_post_H_move = zeros(size(ehp_left_3d,1),2); % eye horizontal velocity after stimulus
    slope_post_rest = zeros(size(ehp_left_3d,1),2); % rest of the eye velocity after stimulus
    % check velocity for ehp/evp left/right for alpha/during/omega
    for i = 1: size(ehp_right_3d,1) 
        slope_pre_H_move(i, 1) = max(abs(ehv_left_3d{i}(1:prebuffer-2)));
        slope_pre_H_move(i, 2) = max(abs(ehv_right_3d{i}(1:prebuffer-2)));
        slope_pre_rest(i, 1) = max(abs(evv_left_3d{i}(1:prebuffer-2)));
        slope_pre_rest(i, 2) = max(abs(evv_right_3d{i}(1:prebuffer-2)));
        if max(ehv_left_3d{i}(prebuffer:end-postbuffer)) < 0.1
            slope_dur_H_move(i, 1) = max(abs(ehv_left_3d{i}(prebuffer:end-postbuffer)));
        else
            slope_dur_H_move(i, 1) = dur_thresh;
        end
        if max(ehv_right_3d{i}(prebuffer:end-postbuffer)) < 0.1
            slope_dur_H_move(i, 2) = max(abs(ehv_right_3d{i}(prebuffer:end-postbuffer)));
        else
            slope_dur_H_move(i, 2) = dur_thresh;
        end
        slope_dur_rest(i, 1) = max(abs(evv_left_3d{i}(prebuffer:end-postbuffer)));
        slope_dur_rest(i, 2) = max(abs(evv_right_3d{i}(prebuffer:end-postbuffer)));
        slope_post_H_move(i, 1) = max(abs(gradient(ehp_left_3d{i}(end-postbuffer:end))));
        slope_post_H_move(i, 2) = max(abs(gradient(ehp_right_3d{i}(end-postbuffer:end))));
        slope_post_rest(i, 1) = max(abs(gradient(evp_left_3d{i}(end-postbuffer:end))));
        slope_post_rest(i, 2) = max(abs(gradient(evp_right_3d{i}(end-postbuffer:end))));
    end
    %Filter 1 and filter 2 do check ehp and evp separately followed by a
    %integrated filter to check if the response satisfy both ehp/evp
    %velocity requirement        
        [filter1, ~] = find(slope_pre_H_move < pre_thresh & slope_dur_H_move < dur_thresh &  slope_post_H_move < 0.8);
        [filter2, ~] = find(slope_pre_rest < pre_thresh_rest & slope_dur_rest < dur_thresh_rest & slope_post_rest < 0.8);
    if isempty(filter1) ~= 1 & isempty(filter2) ~=1 & size(filter1,1) > 2 & size(filter2,1) > 2
        total_filter = [filter1; filter2];
        t = tabulate(total_filter);
        primary_filter = t(t(:,2)==4, 1).';%remained index of the response (Hence, multiple responses within a trial)
        
        temp = 1:size(evp_right_3d,1); %the index of reponse before velocity filter
        removed = setdiff(temp, primary_filter); %removed index of reponse after velocity filter
    else 
        primary_filter = [];
        removed = [];
    end
    %% store data of removed reponse for further analysis
    filtered.ehp_left = ehp_left_3d(removed);
    filtered.ehp_right = ehp_right_3d(removed);
    filtered.evp_left = evp_left_3d(removed);
    filtered.evp_right = evp_right_3d(removed);
    filtered.ehv_left = ehv_left_3d(removed);
    filtered.ehv_right = ehv_right_3d(removed);
    filtered.evv_left = evv_left_3d(removed);
    filtered.evv_right = evv_right_3d(removed);
    filtered.list = removed;
    %% store data of remained response for position filter
    result.ehp_left = ehp_left_3d(primary_filter);
    result.ehp_right = ehp_right_3d(primary_filter);
    result.evp_left = evp_left_3d(primary_filter);
    result.evp_right = evp_right_3d(primary_filter);
    result.ehv_left = ehv_left_3d(primary_filter);
    result.ehv_right = ehv_right_3d(primary_filter);
    result.evv_left = evv_left_3d(primary_filter);
    result.evv_right = evv_right_3d(primary_filter);
    result.list = primary_filter;
end
