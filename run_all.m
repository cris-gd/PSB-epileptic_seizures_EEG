%% Master script: Run full seizure detection pipeline
clear; close all; clc;

fprintf('=== EEG Epilepsy Seizure Detection ===\n');
fprintf('Loading configuration...\n');
run('config.m');  % Load custom parameters

fprintf('Step 1/6: Loading EDF data...\n');
[pacientes, nombres_canales] = cargar_datos_edf(carpeta_datos, rango_pacientes);

fprintf('Step 2/6: Extracting ground truth...\n');
[crisis_anotadas, duraciones] = extraer_crisis_anotada(carpeta_resumenes, rango_pacientes);

fprintf('Step 3/6: Filtering signals...\n');
senales_filtradas = filtrar_senales(pacientes);

fprintf('Step 4/6: Extracting temporal parameters...\n');
[parametros, medias] = extraer_parametros(senales_filtradas, fs, seg_ventana, solapamiento);

fprintf('Step 5/6: Detecting events per channel...\n');
detecciones = deteccion_eventos(parametros, umbrales);

fprintf('Step 6/6: Multi-channel fusion and seizure detection...\n');
crisis_detectadas = detectar_crisis_multicanal_duracion_ponderado(...
    detecciones, seg_ventana, min_duracion_crisis, nombres_canales);

fprintf('Evaluating performance...\n');
[sens_horas, sens_crisis, sens_h_ind, sens_c_ind] = calcular_sensibilidad(...
    crisis_detectadas, crisis_anotadas, margen_sensibilidad);
[especificidad_global, especificidades_paciente] = calcular_especificidad(...
    crisis_detectadas, crisis_anotadas, duraciones);

fprintf('\n=== RESULTS ===\n');
fprintf('Global sensitivity (hour-level): %.2f%%\n', sens_horas * 100);
fprintf('Global sensitivity (seizure-level): %.2f%%\n', sens_crisis * 100);
fprintf('Global specificity: %.2f%%\n', especificidad_global * 100);

fprintf('\nExporting results to Excel...\n');
exportar_struct_a_excel(crisis_anotadas, 'ground_truth.xlsx');
exportar_struct_a_excel(crisis_detectadas, 'detected_seizures.xlsx');

fprintf('Done.\n');