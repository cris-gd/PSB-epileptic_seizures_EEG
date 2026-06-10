function [linea vector_ratios_crisis vector_ratios_no_crisis] = cuenta_crisis(segmentos_crisis)
%-------------------------------------------------------------------------
% Descripción:
%   Esta función recorre una estructura jerárquica que contiene información
%   segmentada de señales EEG de múltiples pacientes, horas y canales. 
%   Extrae los valores del campo 'ratio_bandas' de ciertos segmentos seleccionados 
%   (en este caso, los segmentos con índices entre 1498 y 1517, inclusive el 1498 
%   y exclusivo el 1518), y los clasifica como *no crisis*.
%
% Entradas:
%   - segmentos_crisis - Estructura anidada con la forma:
%                      segmentos_crisis.paciente.hora.canal.segmento.ratio_bandas
%
% Salidas:
%   - linea - Cadena vacía (posiblemente usada para depuración; sin utilidad clara aquí).
%   - vector_ratios_crisis - Vector vacío (actualmente no se llena en la función).
%   - vector_ratios_no_crisis - Vector con los valores de 'ratio_bandas' para los
%                             segmentos seleccionados (IDs entre 1498 y 1517).
% -------------------------------------------------------------------------
    numero_crisis = struct();
    vector_ratios_crisis = [];
    vector_ratios_no_crisis = [];
    linea = "";
    nombres_pacientes = fieldnames(segmentos_crisis);
    for p = 1:length(nombres_pacientes)
        pid = nombres_pacientes{p};
        nombres_horas = fieldnames(segmentos_crisis.(pid));
        for h = 1:length(nombres_horas)
            hid = nombres_horas{h};
            nombres_canales = fieldnames(segmentos_crisis.(pid).(hid));
            for ch = 1:length(nombres_canales)
                chid = nombres_canales{ch};
                nombres_segmentos = fieldnames(segmentos_crisis.(pid).(hid).(chid));
                crisis = 0;
                for s = 1:length(nombres_segmentos)
                    sid = nombres_segmentos{s};
                    if s >= 1498 && s < 1518
                        vector_ratios_no_crisis = [vector_ratios_crisis segmentos_crisis.(pid).(hid).(chid).(sid).ratio_bandas];
                    end
                end
                disp(linea);
                linea = "";
            end
        end
    end