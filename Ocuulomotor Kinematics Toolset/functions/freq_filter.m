%% apply low-pass filter to both position and velocity data
function output = freq_filter(data, params)
    % extract position data from input
    h_p_l = data.ehp_left; h_p_r = data.ehp_right;
    v_p_l = data.evp_left; v_p_r = data.evp_right;
    
    %% 1. filter position data
    % using cellfun to apply lowpass filter efficiently
    output.ehp_left  = cellfun(@(x) lowpass(x, params), h_p_l, 'UniformOutput', false);
    output.ehp_right = cellfun(@(x) lowpass(x, params), h_p_r, 'UniformOutput', false);
    output.evp_left  = cellfun(@(x) lowpass(x, params), v_p_l, 'UniformOutput', false);
    output.evp_right = cellfun(@(x) lowpass(x, params), v_p_r, 'UniformOutput', false);

    %% 2. calculate and filter velocity data
    % gradient is applied before filtering to capture dynamic response
    output.ehv_left  = cellfun(@(x) lowpass(gradient(x), params), h_p_l, 'UniformOutput', false);
    output.ehv_right = cellfun(@(x) lowpass(gradient(x), params), h_p_r, 'UniformOutput', false);
    output.evv_left  = cellfun(@(x) lowpass(gradient(x), params), v_p_l, 'UniformOutput', false);
    output.evv_right = cellfun(@(x) lowpass(gradient(x), params), v_p_r, 'UniformOutput', false);

    %% 3. carry over metadata
    if isfield(data, 'list')
        output.list = data.list;
    end
end

%% helper function to apply 51st-order FIR filter with Hamming window
function filtered_signal = lowpass(signal, params)
    %% filter parameters configuration
    % select cutoff frequency based on pipeline stage (params.fc)
    cutoff = params.fc; 
    fs = params.fs;     % 1000 Hz sampling frequency
    order = 51;         % 51st-order FIR filter

    %% filter design
    % normalize cutoff frequency (cutoff / Nyquist)
    wn = cutoff / (fs / 2); 

    % design FIR filter with Hamming window
    fir_coeffs = fir1(order, wn, 'low', hamming(order + 1));

    %% apply zero-phase filtering
    % filtfilt ensures zero phase distortion, crucial for kinematic timing
    filtered_signal = filtfilt(fir_coeffs, 1, signal);
end
