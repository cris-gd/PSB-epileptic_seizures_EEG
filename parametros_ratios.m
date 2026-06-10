function params = parametros_ratios(segmentos_crisis, crisis_struct)
% -------------------------------------------------------------------------
% Descripción:
%   Analiza los ratios espectrales de segmentos EEG, calculando medias y varianzas
%   diferenciando entre períodos de crisis y no crisis
%
% Entradas:
%   - segmentos_crisis: estructura con ratios espectrales organizadosen
%                       paciente -> hora -> canal -> segmento
%   - crisis_struct: estructura con información temporal de las crisis
%                    'inicios' y 'fines' puestos en  paciente -> hora                
%                         
% Salidas: 
%   - params: estructura con estadísticas calculadas:
%             - media_crisis: media de ratios durante crisis
%             - media_no_crisis: media de ratios fuera de crisis
%             - var_crisis: varianza de ratios durante crisis
%             - var_no_crisis: varianza de ratios fuera de crisis
% -------------------------------------------------------------------------
    params = struct();
    vector_ratios_crisis = [];
    vector_ratios_no_crisis = [];
    media_crisis = 0;
    media_no_crisis = 0;
    var_crisis = 0;
    var_no_crisis = 0;

    nombres_pacientes = fieldnames(segmentos_crisis);
    for p = 1:length(nombres_pacientes)
        pid = nombres_pacientes{p};
        nombres_horas = fieldnames(segmentos_crisis.(pid));
        for h = 1:length(nombres_horas)
            hid = nombres_horas{h};
            nombres_canales = fieldnames(segmentos_crisis.(pid).(hid));
            x = crisis_struct.(pid).(hid).inicios;
            y = crisis_struct.(pid).(hid).fines;
            for i = 1:length(x)
                inicio = floor(x(i) / 2);
                final = ceil(y(i) / 2);
                for ch = 1:length(nombres_canales)
                    chid = nombres_canales{ch};
                    nombres_segmentos = fieldnames(segmentos_crisis.(pid).(hid).(chid));
                    for s = 1:length(nombres_segmentos)
                        sid = nombres_segmentos{s};
                        ratio = segmentos_crisis.(pid).(hid).(chid).(sid).ratio_bandas;
                        if (s >= inicio) && (s <= final)
                            vector_ratios_crisis = [vector_ratios_crisis ratio];
                        else
                            vector_ratios_no_crisis = [vector_ratios_no_crisis ratio];
                        end
                    end
                end
            end
        end
    end
    media_crisis = mean(vector_ratios_crisis);
    media_no_crisis = mean(vector_ratios_no_crisis);
    var_crisis = var(vector_ratios_crisis);
    var_no_crisis = var(vector_ratios_no_crisis);
    params.media_crisis = media_crisis;
    params.media_no_crisis = media_no_crisis;
    params.var_crisis = var_crisis;
    params.var_no_crisis = var_no_crisis;