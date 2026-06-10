function clasificacion = clasificacion_segmentos(ratios, num_segmentos, umbral_varianza)
% -------------------------------------------------------------------------
% Descripción:
%   Clasifica segmentos de señales según la varianza de sus ratios espectrales
%
% Entradas:
%   - ratios: estructura con los ratios espectrales organizados por 
%             paciente -> hora -> canal -> segmento      
%   - num_segmentos: número de segmentos a cada lado del segmento 
%                    central a considerar                     
%   - umbral_varianza: valor umbral para determinar si un segmento tiene crisis
%   
%   Salida:
%   - clasificacion: estructura donde cada segmento contiene un valor lógico:
%                       true: segmento crisis (varianza > umbral)
%                       false: segmento sano (varianza <= umbral)
% -------------------------------------------------------------------------
clasificacion = struct();
nombres_pacientes = fieldnames(ratios);
for p = 1:length(nombres_pacientes)
    pid = nombres_pacientes{p};
    nombres_horas = fieldnames(ratios.(pid));
    for h = 1:length(nombres_horas)
        hid = nombres_horas{h};
        nombres_canales = fieldnames(ratios.(pid).(hid));
        for ch = 1:length(nombres_canales)
            chid = nombres_canales{ch};
            nombres_segmentos = fieldnames(ratios.(pid).(hid).(chid));
            for s = 1:length(nombres_segmentos)
                sid = nombres_segmentos{s};
                vector_ratios = [];
                if s - num_segmentos <= 0
                    for l = 0:2*num_segmentos
                        sid2 = nombres_segmentos{s + l};
                        vector_ratios = [vector_ratios ratios.(pid).(hid).(chid).(sid2).ratio_bandas];
                    end
                elseif s + num_segmentos >= length(nombres_segmentos)
                    for l = -2*num_segmentos:0
                        sid2 = nombres_segmentos{s + l};
                        vector_ratios = [vector_ratios ratios.(pid).(hid).(chid).(sid2).ratio_bandas];
                    end
                elseif (s - num_segmentos > 0) && (s + num_segmentos < length(nombres_segmentos))
                    for l = -num_segmentos:num_segmentos
                        sid2 = nombres_segmentos{s + l};
                        vector_ratios = [vector_ratios ratios.(pid).(hid).(chid).(sid2).ratio_bandas];
                    end
                end
                varianza = var(vector_ratios);
                if varianza > umbral_varianza
                    clasificacion.(pid).(hid).(chid).(sid) = true;
                else
                    clasificacion.(pid).(hid).(chid).(sid) = false;
                end
            end
        end
    end
end