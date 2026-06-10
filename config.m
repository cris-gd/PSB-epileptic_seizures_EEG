%% Configuration template for EEG seizure detection

% Dataset paths
carpeta_datos = 'datos_edf2';
carpeta_resumenes = 'resumenes';
rango_pacientes = [1, 24];

% Analysis parameters
fs = 256;                    % Sampling frequency (fixed for CHB-MIT)
seg_ventana = 4;             % Window duration (seconds)
solapamiento = 0.5;          % Overlap (0–1)

% Detection thresholds (percentiles)
umbrales.energia = 88;
umbrales.varianza = 88;
umbrales.rms = 84;
umbrales.zc = [10 70];
umbrales.arv = 85;

% Post-processing
min_duracion_crisis = 10;    % Minimum seizure duration (seconds)
margen_sensibilidad = 60;     % Tolerance for sensitivity (seconds)

% Channel weights (override defaults if needed)
% Default: relevant=1.5, noisy=0.5, neutral=1.0