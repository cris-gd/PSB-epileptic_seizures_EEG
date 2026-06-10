function [parametros, medias] = extraer_parametros(senales_filtradas, fs, seg_ventana, solapamiento)
% -------------------------------------------------------------------------
% Descripción:
%   Esta función extrae cinco parámetros característicos (energía, varianza,
%   RMS, cruces por cero y ARV) de señales EEG segmentadas por paciente, 
%   hora y canal. 
%   Los parámetros se calculan por ventanas de tiempo con solapamiento.
%
% Entradas:
%   - senales_filtradas: estructura {paciente}{hora}{canal} con las señales
%   - fs: frecuencia de muestreo de las señales
%   - seg_ventana: duración de la ventana en segundos para análisis
%   - solapamiento: proporción (0–1) de solapamiento entre ventanas
%
% Salidas:
%   - parametros: estructura con matrices 5xN (una fila por parámetro)
%   - medias: estructura con medias de cada parámetro por canal (1x5)
% -------------------------------------------------------------------------

long_ventana = fs * seg_ventana;
parametros = struct();
medias = struct();

pacientes_ids = fieldnames(senales_filtradas);

for p = 1:length(pacientes_ids)
    pid = pacientes_ids{p};
    horas = fieldnames(senales_filtradas.(pid));

    for h = 1:length(horas)
        hora_id = horas{h};
        canales = fieldnames(senales_filtradas.(pid).(hora_id));

        for c = 1:length(canales)
            canal_id = canales{c};
            signal = senales_filtradas.(pid).(hora_id).(canal_id);

            % Asegurar que la señal sea columna
            if isrow(signal)
                signal = signal';
            end

            % Padding por si no termina justo en múltiplo
            if mod(length(signal), long_ventana) ~= 0
                padding = long_ventana * ceil(length(signal)/long_ventana) - length(signal);
                signal(end+1:end+padding) = signal(end);
            end

            % Cálculo de ventanas
            paso = round(long_ventana * (1 - solapamiento));
            total_muestras = length(signal);
            indices_inicio = 1:paso:(total_muestras - long_ventana);

            % Inicializar vectores para todos los parámetros (ahora 5)
            energia = zeros(1, length(indices_inicio));
            varianza = zeros(1, length(indices_inicio));
            rms_val = zeros(1, length(indices_inicio));
            cero_cruces = zeros(1, length(indices_inicio));
            arv_val = zeros(1, length(indices_inicio));  % Nuevo parámetro ARV

            for w = 1:length(indices_inicio)
                idx = indices_inicio(w);
                segmento = signal(idx : idx + long_ventana - 1);

                % Cálculo de parámetros existentes
                energia(w) = sum(segmento.^2);
                varianza(w) = var(segmento);
                rms_val(w) = rms(segmento);
                cero_cruces(w) = sum(diff(sign(segmento)) ~= 0);

                % Cálculo del ARV (nuevo parámetro)
                arv_val(w) = mean(abs(segmento));  % Fórmula ARV
            end

            % Guardar resultados (ahora matriz 5xN)
            matriz_params = [energia; varianza; rms_val; cero_cruces; arv_val];
            matriz_medias = mean(matriz_params, 2)';  % fila: 1x5

            parametros.(pid).(hora_id).(canal_id) = matriz_params;
            medias.(pid).(hora_id).(canal_id) = matriz_medias;
        end
    end
end
end

