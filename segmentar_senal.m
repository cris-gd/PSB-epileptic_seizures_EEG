function segmentos = segmentar_senal(pacientes, t_segmento)
% -------------------------------------------------------------------------
% Descripción:
%   Divide las señales EEG de cada canal en segmentos de igual duración,
%   organizándolos en una estructura jerárquica
%
% Entradas:
%   - pacientes: estructura con señales EEG filtradas en forma
%                paciente -> hora -> canal
%   - t_segmento: duración deseada para cada segmento (en segundos)
%
% Salida:
%   - segmentos: estructura con nivel adicional que contiene los segmentos:
%                paciente -> hora -> canal -> segmento
% -------------------------------------------------------------------------
    segmentos = struct();
    nombres_pacientes = fieldnames(pacientes);
    for p = 1:length(nombres_pacientes)
        nombres_horas = fieldnames(pacientes.(nombres_pacientes{p}));
        for h = 1:length(nombres_horas)
            nombres_canales = fieldnames(pacientes.(nombres_pacientes{p}).(nombres_horas{h}));
            for ch = 1:length(nombres_canales)
                I = 0;
                fin = false;
                while ~fin
                    nombre_segmento = sprintf("s%d", I + 1);
                    if (256 * t_segmento * (I + 1)) < length(pacientes.(nombres_pacientes{p}).(nombres_horas{h}).(nombres_canales{ch}))
                        tramo = pacientes.(nombres_pacientes{p}).(nombres_horas{h}).(nombres_canales{ch})((1 + I*256*t_segmento):256*t_segmento*(I + 1));
                        I = I + 1;
                    else
                        tramo = pacientes.(nombres_pacientes{p}).(nombres_horas{h}).(nombres_canales{ch})((1 + 256*I*t_segmento):end);
                        fin = true;
                    end
                    segmentos.(nombres_pacientes{p}).(nombres_horas{h}).(nombres_canales{ch}).(nombre_segmento) = tramo;
                end
            end
        end
    end
    