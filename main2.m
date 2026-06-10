% -------------------------------------------------------------------------
% Método alternativo: Bandas frecuenciales
% -------------------------------------------------------------------------
clear all; close all; clc;
%% 1- Cargar archivos, filtrarlos y sacar segmentos

[pacientes, nombres_canales] = cargar_datos_edf('datos_edf2', [5 5]);
filtrada = filtrar60hz(pacientes);
clear pacientes; clear nombres_canales;
conjunto_segmentos = segmentar_senal(filtrada, 2);
clear filtrada;

%% 2- Filtrar con bancos de filtros

caracs_filtrada_banco = filtrar_senales_banco(conjunto_segmentos);

%% 3- Detección de crisis

segmentos_crisis = crisis_segmentos(caracs_filtrada_banco);

%% 4- Clasificación de segmentos

clasificacion10 = clasificacion_segmentos(segmentos_crisis, 100, 1100);

%% 5- And lógico de canales

and_logico = and_logico_canales(clasificacion10, 10);

%% * GT crisis con duraciones (para comparar con el ground truth)
% [crisis_struct duraciones] = extraer_crisis_anotada('resumenes', [1 25]);

%% * Varianza y media de vectores ratios (para ajustar umbral de varianza)
% params_pacientes = parametros_ratios(segmentos_crisis, crisis_struct);