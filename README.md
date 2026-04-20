markdown
# Oculomotor-Kinematic Analysis Toolset

[![MATLAB](https://shields.io)](https://mathworks.com)
[![License](https://shields.io)](https://opensource.org)

A high-performance, modular MATLAB pipeline designed for the end-to-end processing of oculomotor kinematic data. This toolset automates the transition from noisy raw recordings to publication-quality statistical insights by integrating advanced signal filtering, multi-stage kinematic validation, and automated batch visualization.

## 📌 Project Overview
Oculomotor research often grapples with low Signal-to-Noise Ratios (SNR) due to blinks, saccades, and physiological artifacts. This pipeline addresses these challenges by implementing a standardized workflow that ensures data integrity through rigorous artifact rejection and baseline normalization.

## 📂 Modular Architecture
The repository follows a decoupled software design to allow for easy maintenance and expansion of individual algorithms:
```text
.
├── main.m                 # Central Entry Point (Execution Script)
├── functions/             # Core Algorithm Modules
│   ├── pipeline.m         # Workflow Coordinator (with try-catch robustness)
│   ├── extract_segments.m # Data parsing & Boundary Protection
│   ├── freq_filter.m      # Zero-phase FIR Filtering engine
│   ├── position_filter.m  # Baseline Correction & Offset Removal
│   ├── velocity_filter.m  # Multi-period Velocity Validation
│   ├── post_process.m     # Statistical Analytics (Mean & 95% CI)
│   └── plot_session_results.m # High-Resolution Batch Visualization Engine
└── README.md
请谨慎使用此类代码。
🛠 Workflow & Methodology
The toolset follows a 6-step rigorous processing flow:
Segment Extraction: Isolates points of interest from raw files using customizable pre/post buffers with index boundary protection.
Primary Filtering: Applies a 51st-order FIR low-pass filter (


) using a Hamming window. Zero-phase digital filtering is utilized to eliminate group delay.
Kinematic Validation: Implements multi-stage thresholding across specific trial phases:

 period (Pre-pulse): Absolute velocity 

.
During pulse: 

 (Ipsi) / 

 (Contra) to filter blinks.

 period (Post-pulse): 

 (Saccade limit).
Baseline Correction: Automatically calculates the mean position 20ms prior to pulse onset to eliminate sensor drift (
 alignment).
Secondary Smoothing: Final refinement using a 

 low-pass filter to enhance SNR for fine-grained analysis (Ref: Cullen et al., 2013).
Reliability Filtering: Enforces a minimum trial threshold (default 
) to ensure the statistical significance of each session.
⚙️ Parameter Configuration (Structure p)
Centralized configuration in main.m allows for rapid adaptation to different experimental protocols:
Parameter	Default	Description
p.fs	1000	Sampling frequency (Hz)
p.min_trials	5	Minimum valid trials required per session
p.threshs	[45, 300, ...]	Global threshold array (Position/Velocity)
p.plot.x_lim	[-50, 150]	Standardized X-axis for plotting (ms)
p.plot.y_pos	[-10, 10]	Y-axis range for Position subplots (deg)
p.plot.y_vel	[-200, 700]	Y-axis range for Velocity subplots (deg/s)
📊 Visualization & Export
Batch PNG Generation: Automatically exports 300 DPI high-resolution PNGs for every valid session.
Statistical Overlays: Simultaneously visualizes individual trial trajectories, ensemble averages, and shaded 95% t-confidence intervals (CI).
Structured I/O: Analysis results (.mat) and figures are organized into an auto-generated results/ directory for seamless data management.
🚀 How to Use
Clone the Repository: git clone https://github.com
Run Main: Open main.m in MATLAB and press F5.
Select Data: An interactive dialog will prompt you to select your data folder.
Review: Check the results/ folder for processed data and visualization reports.
📖 References
Van Horn MR, Waitzman DM, Cullen KE. Vergence neurons identified in the rostral superior colliculus code smooth eye movements in 3D space. J Neurosci. 2013.
