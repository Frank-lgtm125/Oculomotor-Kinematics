%% Oculomotor Data Processing Pipeline
% Description: Main entry point for processing ocular kinematic data.
% Author: Chengfeng Liu
% Date: 2024-11-04

clear; clc; close all;

%% 1. Configuration & Hyperparameters
% Add paths for subfolders (Assuming 'functions' contains pipeline.m, etc.)
addpath(genpath('functions')); 

p = struct();
p.fs          = 1000;      
p.prebuffer   = 100;       
p.postbuffer  = 150;       
p.cf1         = 125;       
p.cf2         = 75;        
p.flag        = 1;         
p.min_trials  = 5;         
p.session     = "Caesar-session-2"; 
p.threshs     = [45, 300, 600, 800, 300, 300, 800];
% Plotting limits: [xmin, xmax, ymin, ymax]
p.plot.x_lim    = [-50, 150];    % X-axis for all plots
p.plot.y_pos    = [-10, 10];     % Y-axis for Position plots
p.plot.y_vel    = [-200, 700];   % Y-axis for Velocity plots

%% 2. File Initialization
dataDir = uigetdir(pwd, 'Please select the folder containing your .mat files');
if isequal(dataDir, 0)
    error('Pipeline:UserCancelled', 'Folder selection was cancelled by user.');
end
dataPattern = fullfile(dataDir, '*uA.mat'); 
fileList = dir(dataPattern);
numFiles = length(fileList);

if numFiles == 0
    error('Pipeline:NoFilesFound', 'No files matching "%s" were found.', dataPattern);
end

processedDataRaw = cell(numFiles, 1);
removedDataRaw   = cell(numFiles, 1);

fprintf('==========================================\n');
fprintf('Starting pipeline for session: %s\n', p.session);
fprintf('Found %d valid .mat files to process.\n', numFiles);
fprintf('==========================================\n');

%% 3. Core Processing Loop
for i = 1:numFiles
    fileName = fileList(i).name;
    filePath = fullfile(dataDir, fileName); 
    
    fprintf('--> Processing [%d/%d]: %s\n', i, numFiles, fileName);
    
    % --- Metadata Extraction ---
    meta = str2double(regexp(fileName, '\d+', 'match'));
    
    % --- Pipeline Execution ---
    % Now capturing the 'errStatus' returned by your pipeline's try-catch
    [removed, output, errStatus] = pipeline(filePath, p, p.session);
    
    % --- Robust Data Packaging ---
    if errStatus == 1
        % If an error occurred inside the pipeline, we skip this file
        fprintf('    [SKIP] Exception caught in pipeline for %s. Moving to next file.\n', fileName);
        continue; 
    end

    % Only package data if it passed the pipeline and isn't empty
    if ~isempty(output) && isfield(output, 'list') && ~isempty(output.list)
        processedDataRaw{i} = attach_metadata(output, meta);
    end
    
    if ~isempty(removed) && isfield(removed, 'list') && ~isempty(removed.list)
        removedDataRaw{i} = attach_metadata(removed, meta);
    end
end

%% 4. Data Refinement & Filtering
% Remove empty cells (including those skipped by errStatus)
processedData = processedDataRaw(~cellfun('isempty', processedDataRaw));
removedData   = removedDataRaw(~cellfun('isempty', removedDataRaw));

if isempty(processedData)
    warning('No data was successfully processed. Check your thresholds or input files.');
else
    fprintf('Performing statistical analysis (Mean & 95%% CI)...\n');
    refinedDataAll = post_process(processedData);

    % Reliability Check: Enforce minimum trial threshold
    isValid = cellfun(@(x) ~isempty(x) && size(x.ehp_left, 1) >= p.min_trials, refinedDataAll);
    refinedDataFinal = refinedDataAll(isValid);

    %% 5. Export Results
    % Save to a dedicated results folder 
    resDir = 'results';
    if ~exist(resDir, 'dir'), mkdir(resDir); end
    
    savePath = fullfile(resDir, sprintf("results_%s.mat", p.session));
    save(savePath, "processedData", "removedData", "refinedDataFinal");
    fprintf('Data exported to: %s\n', savePath);
    
    %% 6. Visualization (NEW)
    % Call the plotting function to generate PNGs for all refined files
    plot_session_results(refinedDataFinal, p);
end

%% --- Helper Functions ---
function obj = attach_metadata(obj, meta)
    obj.number  = meta(1);
    obj.density = meta(2);
    obj.dur     = meta(3);
    obj.freq    = meta(4);
    obj.current = meta(5);
    obj.is_current_steering = (meta(4) ~= 0);
end
