function espectros = espectros_segmentos(segmentos)
% -------------------------------------------------------------------------
% Descripción:
%   Esta función recorre una estructura jerárquica que contiene señales EEG
%   segmentadas por paciente, hora, canal y segmento. Para cada segmento,
%   calcula la Transformada Rápida de Fourier (FFT) y normaliza el resultado 
%   dividiendo entre su valor máximo.
%
% Entrada:
%   - segmentos - Estructura con forma:
%               segmentos.paciente.hora.canal.segmento = vector de señal (1D)
%
% Salida:
%   - espectros - Estructura con la misma jerarquía, donde cada segmento contiene
%               su espectro de Fourier normalizado (vector complejo).
% -------------------------------------------------------------------------
    espectros = struct();
    nombres_pacientes = fieldnames(segmentos);
    for p = 1:length(nombres_pacientes)
        nombres_horas = fieldnames(segmentos.(nombres_pacientes{p}));
        for h = 1:length(nombres_horas)
            nombres_canales = fieldnames(segmentos.(nombres_pacientes{p}).(nombres_horas{h}));
            for ch = 1:length(nombres_canales)
                nombres_segmentos = fieldnames(segmentos.(nombres_pacientes{p}).(nombres_horas{h}).(nombres_canales{ch}));
                for s = 1:length(nombres_segmentos)
                    l = length(segmentos.(nombres_pacientes{p}).(nombres_horas{h}).(nombres_canales{ch}).(nombres_segmentos{s}));
                    X = fft(segmentos.(nombres_pacientes{p}).(nombres_horas{h}).(nombres_canales{ch}).(nombres_segmentos{s}), l + 1);
                    espectros.(nombres_pacientes{p}).(nombres_horas{h}).(nombres_canales{ch}).(nombres_segmentos{s}) = X/max(X);
                end
            end
        end
    end