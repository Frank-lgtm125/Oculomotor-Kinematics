# Oculomotor-Kinematic Analysis Pipeline

[![MATLAB](https://shields.io)](https://mathworks.com)
[![License](https://shields.io)](LICENSE)

This pipeline provides a robust framework for processing and analyzing eye movement data. It is specifically designed to remove artifacts, improve the **Signal-to-Noise Ratio (SNR)**, and quantify kinematic parameters from raw horizontal/vertical ocular responses.

## 📌 Overview
Raw eye movement data (ipsilateral/contralateral) often contains significant noise. This Matlab-based pipeline automates the extraction, filtering, and validation of eye movement segments to ensure high-quality data for subsequent analysis.

## 🛠 Workflow & Methodology

The core logic is implemented in `main.m`, following a 6-step rigorous processing flow:

1.  **Segment Extraction**: Isolates points of interest from `.BR` files.
2.  **Primary Filtering**: Applies a 51st-order FIR low-pass filter ($f_c = 125\text{Hz}$) with a **Hamming window**. Zero-phase digital filtering is used to eliminate group delay.
3.  **Velocity Validation**: Multi-stage thresholding across different periods:
    *   **$\alpha$ period (Pre-pulse)**: $< 300^\circ/s$
    *   **During pulse**: $< 600^\circ/s$ (Ipsi) / $300^\circ/s$ (Contra)
    *   **$\omega$ period (Post-pulse)**: $< 800^\circ/s$ (Saccade limit)
    *   **Directional Check**: Positive velocity must be $< 100^\circ/s$ to ensure correct movement direction.
4.  **Position Check & Normalization**:
    *   Removes segments where $\alpha$ period position exceeds $45^\circ$.
    *   **Baseline Correction**: Calculates the mean position 20ms prior to pulse onset to set the start point to $0^\circ$.
5.  **Secondary Filtering**: Final smoothing using a $75\text{Hz}$ low-pass filter (Ref: *Van Horn et al., 2013*).
6.  **Reliability Filtering**: Only `.BR` files with $>5$ valid trials are retained.

## ⚙️ Parameter Configuration (Structure `p`)

The pipeline is controlled via a structure variable `p`. Below are the key parameters:


| Parameter | Default | Description |
| :--- | :--- | :--- |
| `p.fs` | 1000 | Sampling frequency (Hz) |
| `p.cf1` | 125 | Initial low-pass cutoff (Hz) |
| `p.cf2` | 75 | Post-processing cutoff (Hz) |
| `p.prebuffer` | 100 | $\alpha$ period length (ms) |
| `p.postbuffer` | 150 | $\omega$ period length (ms) |
| `p.threshs` | `[45, 300, ...]` | Array of position and velocity thresholds |

## 📊 Visualization
The repository includes dedicated scripts for data inspection:
*   `plotting.m`: Visualizes EHP/EHV for **ipsilateral** responses.
*   `plotting_contra.m`: Visualizes EHP/EHV for **contralateral** responses.
*   **Statistical Output**: Includes mean responses with a **95% t-confidence interval**.

## 📖 References
> Van Horn MR, Waitzman DM, Cullen KE. *Vergence neurons identified in the rostral superior colliculus code smooth eye movements in 3D space.*
