# MATLAB Requirements

## Required Software

| Component | Version | Notes |
|-----------|---------|-------|
| **MATLAB** | R2019b or higher | R2020a, R2021b, R2022a, R2023b, R2024b all compatible |
| **Operating System** | Windows 10/11, macOS, or Linux | Platform-independent code |

---

## Required Toolboxes

| Toolbox | Minimum Version | Purpose |
|---------|----------------|---------|
| **Signal Processing Toolbox** | 8.3+ | `designfilt`, `filter`, `filtfilt`, `periodogram`, `spectrogram`, `fft` |
| **Statistics and Machine Learning Toolbox** | 11.6+ | `prctile`, `var`, `mean`, `std` |

> ⚠️ **Important:** Both toolboxes are **required**. The code will not run without them.

---

## Optional Toolboxes (Not Required)

| Toolbox | Purpose |
|---------|---------|
| **Parallel Computing Toolbox** | Speed up patient processing (not implemented, but usable) |
| **MATLAB Report Generator** | Generate PDF reports from analysis results |

---

## External Functions Required

### EDF File Reading

The code uses `edfread` and `edfinfo`. In MATLAB R2020b and later, these functions are **built-in** (part of Signal Processing Toolbox).

For older MATLAB versions, install from File Exchange:
```matlab
% If using MATLAB R2019a or older:
% Download from: https://www.mathworks.com/matlabcentral/fileexchange/31900-edfread
% Or use the built-in version check:
if ~exist('edfread', 'file')
    error('EDFREAD not found. Use MATLAB R2020b+ or install from File Exchange');
end