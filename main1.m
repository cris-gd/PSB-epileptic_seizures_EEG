close all; clear all; clc;
%% 1- Cargar los datos

carpeta = 'datos_edf2'; 
[pacientes, nombres_canales] = cargar_datos_edf(carpeta, [1,24]);

%% 2-  Extraer ground truth

[crisis_anotadas,duraciones] = extraer_crisis_anotada('resumenes', [1,24]);

% exportar ground-truth a excel
exportar_struct_a_excel(crisis_anotadas, 'crisis_anotadas.xlsx');

%% 3- Visualizar en tiempo

% ejemplo con paciente 5, que tiene crisis en horas 6, 13, 16, 17, 22
% visualizar solo los 4 canales de electrodos más importantes: 2,5,9,14
graficar_canales_paciente(pacientes, nombres_canales, 5, [6 13 16 17 22], [2,5,9,14]);

% visualizar los canales de una hora de un paciente
plot_mult_curves(pacientes, 'p5', 'h13', 2000);
%% 4- Visualizar en frecuencia

fs=256;
% ejemplo paciente 5 con canales 2,5,9,14 para las horas 6, 13, 16, 17, 22
graficar_fft_paciente(pacientes, nombres_canales, 5, [6 13 16 17 22], [2 5 9 14], fs);

%% 5- Periodograma

fs = 256;
graficar_periodograma_paciente(pacientes, nombres_canales, 5, [6 13 16 17 22], [2 5 9 14], fs);

%% 6- Periodograma welch

fs = 256;
graficar_periodograma_welch_paciente(pacientes, nombres_canales, 5, [6 13 16 17 22], [2 5 9 14], fs);

%% 7- Espectrograma

fs = 256;
graficar_espectrograma_paciente(pacientes, nombres_canales, 5, [6 13 16 17 22], [2 5 9 14], fs);

%% 8- Filtrar señales

senales_filtradas = filtrar_senales(pacientes);

% ejemplo con paciente 5, que tiene crisis en horas 6, 13, 16, 17, 22
% visualizar solo los 4 canales de electrodos más importantes: 2,5,9,14
graficar_canales_paciente(senales_filtradas, nombres_canales, 5, [6 13 16 17 22], [2,5,9,14]);
graficar_fft_paciente(senales_filtradas, nombres_canales, 5, [6 13 16 17 22], [2 5 9 14], fs);

%% 9- Extraer parámetros

fs=256;
seg_ventana = 4;
solapamiento = 0.5;
[parametros,medias] = extraer_parametros(senales_filtradas, fs, seg_ventana, solapamiento);

%% 10- Detectar eventos

umbrales.energia = 88;
umbrales.varianza = 88;
umbrales.rms = 84;
umbrales.zc = [10 70];
umbrales.arv = 85;

detecciones = deteccion_eventos(parametros, umbrales);
%% 11- Depurar detección

% Parámetros
seg_ventana=2;
min_duracion_crisis = 10;      % Mínimo 10 segundos

crisis_detectadas = detectar_crisis_multicanal_duracion_ponderado(detecciones, seg_ventana, min_duracion_crisis, nombres_canales);
%% 12- Analizar resultados

[global_sens_hora, global_sens_crisis, sens_hora_individual, sens_crisis_individual] = calcular_sensibilidad(crisis_detectadas, crisis_anotadas, 60);

[especificidad_global, especificidades_por_paciente] = calcular_especificidad(crisis_detectadas, crisis_anotadas, duraciones);

