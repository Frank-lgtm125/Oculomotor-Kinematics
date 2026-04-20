# Oculomotor-Kinematic Analysis Toolset

[![MATLAB](https://shields.io)](https://mathworks.com)
[![License](https://shields.io)](https://opensource.org)

A high-performance, modular MATLAB pipeline designed for the end-to-end processing of oculomotor kinematic data. This toolset automates the transition from noisy raw recordings to publication-quality statistical insights by integrating advanced signal filtering, multi-stage kinematic validation, and automated batch visualization.

## 📌 Project Overview
Oculomotor research often grapples with low Signal-to-Noise Ratios (SNR) due to blinks, saccades, and physiological artifacts. This pipeline addresses these challenges by implementing a standardized workflow that ensures data integrity through rigorous artifact rejection and baseline normalization.

## 📂 Modular Architecture
The repository follows a decoupled software design to allow for easy maintenance and expansion of individual algorithms:

*   **main.m**: Central Entry Point (Execution Script)
*   **functions/**: Core Algorithm Modules
    *   **pipeline.m**: Workflow Coordinator (with try-catch robustness)
    *   **extract_segments.m**: Data parsing & Boundary Protection
    *   **freq_filter.m**: Zero-phase FIR Filtering engine
    *   **position_filter.m**: Baseline Correction & Offset Removal
    *   **velocity_filter.m**: Multi-period Velocity Validation
    *   **post_process.m**: Statistical Analytics (Mean & 95% CI)
    *   **plot_session_results.m**: High-Resolution Batch Visualization Engine

## 🛠 Workflow & Methodology
The toolset follows a 6-step rigorous processing flow:

1. **Segment Extraction**: Isolates points of interest from raw files using customizable pre/post buffers with index boundary protection.
2. **Primary Filtering**: Applies a 51st-order FIR low-pass filter (Cutoff: 125Hz) using a Hamming window. Zero-phase digital filtering is utilized to eliminate group delay.
3. **Kinematic Validation**: Implements multi-stage thresholding across specific trial phases:
    *   **Pre-pulse (Alpha)**: Absolute velocity < 300 deg/s.
    *   **During pulse**: < 600 deg/s (Ipsi) / 300 deg/s (Contra) to filter blinks.
    *   **Post-pulse (Omega)**: < 800 deg/s (Saccade limit).
4. **Baseline Correction**: Automatically calculates the mean position 20ms prior to pulse onset to eliminate sensor drift (0-degree alignment).
5. **Secondary Smoothing**: Final refinement using a 75Hz low-pass filter to enhance SNR (Ref: Cullen et al., 2013).
6. **Reliability Filtering**: Enforces a minimum trial threshold (default > 5) to ensure statistical significance.

## ⚙️ Parameter Configuration (Structure p)
Centralized configuration in main.m allows for rapid adaptation to different protocols:


| Parameter | Default | Description |
| :--- | :--- | :--- |
| p.fs | 1000 | Sampling frequency (Hz) |
| p.min_trials | 5 | Min valid trials required per session |
| p.plot.x_lim | [-50, 150] | Standardized X-axis for plotting (ms) |
| p.plot.y_pos | [-10, 10] | Y-axis range for Position subplots (deg) |
| p.plot.y_vel | [-200, 700] | Y-axis range for Velocity subplots (deg/s) |

## 📊 Visualization & Export
*   **Batch PNG Generation**: Automatically exports 300 DPI high-resolution PNGs for every valid session.
*   **Statistical Overlays**: Simultaneously visualizes individual trial trajectories, ensemble averages, and shaded 95% t-confidence intervals (CI).
*   **Structured I/O**: Analysis results (.mat) and figures are organized into an auto-generated "results" directory.

## 🚀 How to Use
1. **Clone the Repository**: `git clone https://github.com`
2. **Run Main**: Open `main.m` in MATLAB and press F5.
3. **Select Data**: An interactive dialog will prompt you to select your data folder.
4. **Review**: Check the `results/` folder for processed data and visualization reports.

## 📖 References
> Van Horn MR, Waitzman DM, Cullen KE. *Vergence neurons identified in the rostral superior colliculus code smooth eye movements in 3D space.* J Neurosci. 2013.
