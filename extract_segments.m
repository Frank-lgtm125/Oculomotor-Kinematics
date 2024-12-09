%% extract segments with prebuffer and postbuffer from the data and store in a cell 
function [output, timeframe] = extract_segments(sample, params)
    prebuffer  = params.prebuffer; %prebuffer value from input params
    postbuffer = params.postbuffer; %postbuffer value from input params
    if isfield(sample.Data, 'ehp_left_3d')
        ehp_left_3d = sample.Data.ehp_left_3d.'; %value from Data.ehp_left_3d
        ehp_right_3d = sample.Data.ehp_right_3d.';%value from Data.ehp_right_3d
        evp_left_3d = sample.Data.evp_left_3d.'; %value from Data.evp_left_3d
        evp_right_3d = sample.Data.evp_right_3d.'; %value from Data.evp_right_3d
    else 
        ehp_left_3d = sample.Data.ehp_corrected.'; %value from Data.ehp_left_3d
        ehp_right_3d = sample.Data.ehp_corrected.';%value from Data.ehp_right_3d
        evp_left_3d = sample.Data.evp_corrected.'; %value from Data.evp_left_3d
        evp_right_3d = sample.Data.evp_corrected.'; %value from Data.evp_right_3d
    end
    segments_data = struct2cell(sample.Data.segments); %cell value from sample.Data.segments
    segments = segments_data{1}; %extract segments value
    n = size(segments,1); %count # of stimulus
    
    %% initializ untrimmed cell %segments are not identical, should be trimmed later
    ehp_left_3d_untrimmed = cell(n,1);
    ehp_right_3d_untrimmed = cell(n,1); 
    evp_left_3d_untrimmed = cell(n,1);
    evp_right_3d_untrimmed = cell(n,1);
    timeframe_untrimmed = cell(n,1);

    %% store ehp_left/right, evp_left/right value into untrimmed cell
    for i = 1:n
        start_idx = segments(i, 1);  % Start index of the current segment
        end_idx = segments(i, 2);    % End index of the current segment
        ehp_left_3d_untrimmed{i} = ehp_left_3d(start_idx-prebuffer:end_idx+postbuffer);
        ehp_right_3d_untrimmed{i} = ehp_right_3d(start_idx-prebuffer:end_idx+postbuffer);
        evp_left_3d_untrimmed{i} = evp_left_3d(start_idx-prebuffer:end_idx+postbuffer);
        evp_right_3d_untrimmed{i} = evp_right_3d(start_idx-prebuffer:end_idx+postbuffer);
        timeframe_untrimmed{i} = [start_idx-prebuffer:end_idx+postbuffer] - start_idx;
    end


    %% initialize trimmed cell
    ehv_left_3d = cell(n,1);
    ehv_right_3d = cell(n,1);
    evv_left_3d = cell(n,1);
    evv_right_3d = cell(n,1);

    %% apply trim function to trim ehp/evp for left/right values during each
    %%segment and store them into output.
    output.ehp_left = trim_cell_data(ehp_left_3d_untrimmed);
    output.ehp_right = trim_cell_data(ehp_right_3d_untrimmed);
    output.evp_left = trim_cell_data(evp_left_3d_untrimmed);
    output.evp_right = trim_cell_data(evp_right_3d_untrimmed);
    timeframe = trim_cell_data(timeframe_untrimmed);
    timeframe = timeframe{:,:};
    
    %% calculate velocity from position, gradient function
    for i = 1:n
        ehv_left_3d{i} = gradient(output.ehp_left{i});
        ehv_right_3d{i} = gradient(output.ehp_right{i});
        evv_left_3d{i} = gradient(output.evp_left{i});
        evv_right_3d{i} = gradient(output.evp_right{i});
    end
    %% store value into output
    output.ehv_left = ehv_left_3d;
    output.ehv_right = ehv_right_3d;
    output.evv_left = evv_left_3d;
    output.evv_right = evv_right_3d;
end

%% helper function to trim the segments so that they are identical in length (time)
function trimmed = trim_cell_data(dataCell)
    minLength = min(cellfun(@length, dataCell));
    trimmed = dataCell;
    for i = 1: length(dataCell)
        trimmed{i} = trimmed{i}(1:minLength);
    end
end

