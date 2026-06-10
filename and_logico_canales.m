function and_logico = and_logico_canales(clasificacion, num_canales)
% -------------------------------------------------------------------------
%
% Descripción:
%   Esta función toma una estructura de clasificaciones binarias (0/1) por canal
%   y decide si un segmento debe considerarse "positivo" (1) si más de
%   `num_canales` canales están clasificados como 1. 
%
% Entradas:
%   - clasificacion: estructura organizada como
%       clasificacion.pX.hY.chZ.sW = 0 o 1
%     donde:
%       - pX: paciente
%       - hY: hora
%       - chZ: canal
%       - sW: segmento
%   - num_canales: umbral mínimo de canales que deben tener valor 1
%
% Salidas:
%   - and_logico: estructura organizada como
%       and_logico.pX.hY.sW = true/false
%     indicando si el segmento cumple la condición de canal lógico.
% -------------------------------------------------------------------------

and_logico = struct();
nombres_pacientes = fieldnames(clasificacion);
for p = 1:length(nombres_pacientes)
    pid = nombres_pacientes{p};
    nombres_horas = fieldnames(clasificacion.(pid));
    for h = 1:length(nombres_horas)
        hid = nombres_horas{h};
        nombres_segmentos = fieldnames(clasificacion.(pid).(hid).ch1);
        for s = 1:length(nombres_segmentos)
            sid = nombres_segmentos{s};
            nombres_canales = fieldnames(clasificacion.(pid).(hid));
            vector_clasif = [];
            for ch = 1:length(nombres_canales)
                chid = nombres_canales{ch};
                c = clasificacion.(pid).(hid).(chid).(sid);
                if c
                    vector_clasif = [vector_clasif 1];
                end
            end
            and_logico.(pid).(hid).(sid) = sum(vector_clasif) > num_canales;
        end
    end
end

end