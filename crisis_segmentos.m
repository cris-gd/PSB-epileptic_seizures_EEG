function segmentos_crisis = crisis_segmentos(caracteristicas_segmentos)
% -------------------------------------------------------------------------
% Definición:
%   Analiza las características espectrales de segmentos de EEG y detectar
%   los patrones de actividad epiléptica
%
% Entradas:
%   - caracteristicas_segmentos: estructura con las características
%                                espectrales en formato 
%                                paciente -> hora -> canal -> segmento
%
% Salida:
%   - segmentos_crisis: estructura con dos campos adicionales por segmento:
%                       - ratio_bandas: valor calculado (f1/(f2+f3+f4+f5))
%                       - crisis: booleano que indica si el segmento
%                                 cumple criterios de crisis
%                                 (true si 6 < ratio_bandas < 8)
% -------------------------------------------------------------------------

    segmentos_crisis = struct();
    nombres_pacientes = fieldnames(caracteristicas_segmentos);
    for p = 1:length(nombres_pacientes)
        pid = nombres_pacientes{p};
        nombres_horas = fieldnames(caracteristicas_segmentos.(pid));
        for h = 1:length(nombres_horas)
            hid = nombres_horas{h};
            nombres_canales = fieldnames(caracteristicas_segmentos.(pid).(hid));
            for ch = 1:length(nombres_canales)
                chid = nombres_canales{ch};
                nombres_segmentos = fieldnames(caracteristicas_segmentos.(pid).(hid).(chid));
                for s = 1:length(nombres_segmentos)
                    sid = nombres_segmentos{s};
                    banda1 = caracteristicas_segmentos.(pid).(hid).(chid).(sid).b5.f1;
                    banda2 = caracteristicas_segmentos.(pid).(hid).(chid).(sid).b5.f2;
                    banda3 = caracteristicas_segmentos.(pid).(hid).(chid).(sid).b5.f3;
                    banda4 = caracteristicas_segmentos.(pid).(hid).(chid).(sid).b5.f4;
                    banda5 = caracteristicas_segmentos.(pid).(hid).(chid).(sid).b5.f5;
                    ratio_bandas = banda1 / (banda2 + banda3 + banda4 + banda5);
                    segmentos_crisis.(pid).(hid).(chid).(sid).ratio_bandas = ratio_bandas;
                    segmentos_crisis.(pid).(hid).(chid).(sid).crisis = (ratio_bandas < 8) && (ratio_bandas > 6);
                end
            end
        end
    end