# EEG Epilepsy Seizure Detection

Automated epileptic seizure detection system from EEG signals using temporal feature extraction, adaptive percentile thresholds, and weighted multi-channel fusion. Developed as part of the *Biomedical Signal Processing*  course at UPNA (Biomedical Engineering, Spring 2025).
.

---

## Features

**Multi-stage Detection Pipeline** — Complete workflow from raw EEG to clinical decision support:
- Data import from CHB-MIT scalp EEG database
- Signal filtering (bandpass + notch at 60 Hz)
- Temporal feature extraction (Energy, Variance, RMS, Zero‑Crossings, ARV)
- Adaptive per‑channel thresholding using percentiles
- Weighted multi‑channel fusion based on clinical relevance of electrodes
- Seizure event detection with configurable minimum duration

**Dual Processing Approaches** — Two independent methods implemented:

### Method 1: Temporal Features + Adaptive Thresholds (main1.m)
- Window‑based analysis with configurable duration and overlap
- Five statistical parameters per window
- Percentile‑based thresholds (88% for Energy/Variance, 84% for RMS, 85% for ARV)
- Zero‑crossing exclusion range: 10–70th percentile
- Channel weighting: 1.5× for relevant channels, 0.5× for noisy channels, 1× for neutral
- Minimum seizure duration: 10 seconds (configurable)

### Method 2: Frequency‑Band Analysis (main2.m)
- 2‑second signal segmentation
- 5‑band filter bank (0.5–40 Hz range)
- Energy ratio calculation: `E1 / (E2+E3+E4+E5)`
- Variance‑based classification using sliding windows (±100 segments)
- Logical AND across channels with configurable active channel threshold

**Performance Metrics** — Built‑in evaluation functions:
- Sensitivity at hour level and individual seizure level (60‑second tolerance margin)
- Specificity (true negatives / total non‑seizure seconds)
- Per‑patient and global metrics
- Excel export of ground truth and detection results

**Visualization Suite** — Comprehensive plotting functions:
- Time‑domain signals with crisis hours highlighted (green/red)
- FFT spectrum analysis
- Periodogram (standard, Welch, averaged)
- Spectrogram (time‑frequency representation)
- Multi‑channel overlay plots

---

## Repository Structure
```
├── config.m # Configuration template for EEG seizure detection
├── run_all.m # Master script: Run full seizure detection pipeline
├── main1.m # Primary pipeline (temporal features)
├── main2.m # Secondary pipeline (frequency bands)
│
├── cargar_datos_edf.m # Import EDF files → nested struct
├── extraer_crisis_anotada.m # Parse CHB-MIT summary files → ground truth
├── filtrar_senales.m # Bandpass (0.5–60 Hz) + notch (60 Hz)
├── filtrar60hz.m # Lowpass + notch at 16/32 Hz (alt method)
├── filtrar_senales_banco.m # 5‑band filter bank
├── segmentar_senal.m # Split signals into fixed‑duration segments
│
├── extraer_parametros.m # Energy, variance, RMS, ZC, ARV per window
├── deteccion_eventos.m # Apply percentile thresholds per channel
├── detectar_crisis_multicanal_duracion_ponderado.m # Weighted multi‑channel fusion
│
├── crisis_segmentos.m # Ratio = E1 / (E2+E3+E4+E5)
├── clasificacion_segmentos.m # Variance‑based classification (±N segments)
├── and_logico_canales.m # Logical AND across channels (threshold)
├── parametros_ratios.m # Mean/var of ratios (crisis vs non‑crisis)
│
├── calcular_sensibilidad.m # Sensitivity (hour + seizure level)
├── calcular_especificidad.m # Specificity (second‑by‑second)
├── exportar_struct_a_excel.m # Export nested structs to .xlsx
│
├── graficar_canales_paciente.m # Time‑domain plots (crisis highlighted)
├── graficar_fft_paciente.m # FFT spectrum per hour
├── graficar_periodograma_paciente.m # Standard periodogram
├── graficar_periodograma_welch_paciente.m # Welch's method
├── graficar_periodograma_promediado_paciente.m # Averaged periodogram
├── graficar_espectrograma_paciente.m # Spectrogram (time+frequency)
├── plot_mult_curves.m # Overlay multiple channels
│
├── banco_filtros.m # Generate n bandpass filters (0.5–40 Hz)
├── dep.m # Power spectral density (FFT-based)
├── periodograma.m # Basic periodogram
├── periodog_avg.m # Averaged periodogram
├── periodog_welch.m # Welch’s averaged modified periodogram
├── Proyecto_EEG_epilepsy.pdf # Final memory
│
├── .gitignore # MATLAB‑specific ignore rules
└── README.md
```

> **Note:** The dataset (CHB-MIT) is not included. Place `datos_edf2/` and `resumenes/` folders in the root directory before running.

---

## Dependencies

- **MATLAB R2019b or higher** (uses `designfilt`, `edfread`, `edfinfo` from Signal Processing Toolbox)
- **Signal Processing Toolbox**
- **Statistics and Machine Learning Toolbox** (for `prctile`)
- **MATLAB Support for EDF files** (or install from File Exchange)

---

## Dataset

CHB-MIT scalp EEG database from PhysioNet: https://physionet.org/content/chbmit/1.0.0/

Organise as:
```
├── datos_edf2/
│ ├── chb01/
│ │ ├── chb01_01.edf
│ │ └── ...
│ └── ...
└── resumenes/
├── chb01-summary.txt
└── ...
```

---

## main1.m

- Load patients 1–24 from `datos_edf2/`

- Extract ground truth from `resumenes/`

- Generate time/frequency plots (example: patient 5)

- Filter signals

- Extract temporal parameters (4‑second windows, 50% overlap)

- Detect events with percentile thresholds

- Perform weighted multi‑channel fusion

- Calculate and display sensitivity + specificity

---

## main2.m

- Load patient 5 only (configurable)

- Apply alternative filtering (lowpass + notch at 16/32 Hz)

- Segment into 2‑second windows

- Apply 5‑band filter bank

- Compute energy ratios

- Classify using variance threshold (±100 segments, threshold = 1100)

- Apply logical AND across channels (threshold = 10 active channels)

---

## Performance Results

Based on evaluation across 14 patients (excluding noisy/conflictive cases):

| Metric | Value |
|---|---|
| Global sensitivity (hour‑level) | 84.75% |
| Global sensitivity (seizure‑level) | 81.82% |
| Global specificity | ~97–98% (range: 93–99%) |

**Per‑patient sensitivity examples:**

- Patients with 100% sensitivity: #2, #5, #7, #9, #11, #19, #22, #23

- Patients with lower sensitivity (<60%): #3 (57%), #18 (50%), #20 (57%)

**Per‑patient specificity examples:**

- Range: 93.27% (patient 9) to 99.12% (patient 1)

> Results are not directly comparable to Shoeb (2009) who achieved 0.96 using machine learning classifiers. This project focuses on interpretable, non‑ML methods.

---

## Technical Highlights

**Nested Data Structure** — Uniform organisation: `pacientes.pX.hY.chZ.sW = signal_vector`. All functions traverse this structure consistently.

**Percentile‑Based Thresholding** — Adaptive per‑patient/per‑channel thresholds using `prctile()` to handle inter‑patient variability without manual tuning.

**Weighted Multi‑Channel Fusion** — Clinical knowledge embedded via channel weights:

- Relevant channels (F7-T7, F8-T8, FP1-F3, FP2-F4, FZ-CZ, P7-O1, P8-O2): weight = 1.5

- Noisy channels (FP1-F7, FP2-F8, FT9-FT10, CZ-PZ): weight = 0.5

- Neutral channels: weight = 1.0

**Dynamic Seizure Detection Threshold** — `umbral = 0.4 * sum(pesos)` ensures scaling with number of available channels.

**Configurable Sensitivity Margin** — 60‑second tolerance window for matching detected seizures with ground truth (accounts for annotation inaccuracies).

**Second‑by‑Second Specificity** — Converts seizures to binary vectors (1 = seizure, 0 = normal) at 1 Hz resolution for precise FP/TN counting.

**Excel Export** — Nested structs converted to flat tables with `mat2str` for matrix fields (e.g., `inicios_fin`).

---

## Known Limitations

**Computational Cost** — Processing all 24 patients with 4‑second windows and 50% overlap requires significant RAM/time. Consider reducing patient range or increasing window size.

**Artifact Contamination** — Muscle (30–300 Hz), eye blink (1–3 Hz), and motion artifacts overlap spectrally with EEG. Not filtered to avoid information loss.

**Patient Exclusion** — Patients 13, 15, and those with incomplete annotations or different naming conventions were excluded.

**Non‑Stationarity** — EEG properties change rapidly during seizures. Fixed‑length windows may not capture all dynamics.

**No ML Component** — Unlike state‑of‑the‑art approaches, this system does not use neural networks or classifiers, limiting performance ceiling.

---

## Results export and visualisation

After running `main1.m`, Excel files are saved to the `analisis/` folder:

- `crisis_anotadas.xlsx` — Ground truth seizures per patient/hour

- `crisis_detectadas.xlsx` — Detected seizures (requires adding export call)

To export detections:
```
    exportar_struct_a_excel(crisis_detectadas, 'crisis_detectadas.xlsx');
```

All visualisation functions follow the same pattern:

```
    graficar_canales_paciente(pacientes, nombres_canales, paciente_id, horas_crisis, canales, fs)
    graficar_fft_paciente(pacientes, nombres_canales, paciente_id, horas_crisis, canales, fs)
    graficar_periodograma_paciente(pacientes, nombres_canales, paciente_id, horas_crisis, canales, fs)
```
**Color coding**: Green = normal hour, Red = hour containing seizure(s).

---

## Authors

- **Íñigo Aguirre**
- **Javier Becerril**
- **Paula Crespo**
- **Cristina García**
- **Izaskun Martín**
- **César Ruiz**

*Students of Biomedical Engineering — Universidad Pública de Navarra (UPNA)*

---

## References

1. Shoeb, A. (2009). Application of machine learning to epileptic seizure prediction (Doctoral dissertation, MIT).

2. Scharfman, H. E. (2007). The neurobiology of epilepsy. Current Neurology and Neuroscience Reports.

3. Mora López-Tercero, I. (2013). Detección de crisis epilépticas a partir de señales EEG mediante índices basados en el algoritmo de Lempel-Ziv (Tesis, UPC).

4. Goldberger, A. et al. (2000). PhysioBank, PhysioToolkit, and PhysioNet. Circulation 101(23):e215–e220.

---

## License

The CHB-MIT dataset is subject to PhysioNet’s open data policies.