function crisis_info = detectar_crisis_multicanal_duracion_ponderado(matriz_evaluacion, seg_ventana, min_duracion_crisis, nombres_canales)
% -------------------------------------------------------------------------
% Descripción:
%   Detecta periodos de crisis epilépticas en múltiples canales de EEG,
%   aplicando una suma ponderada de canales según su relevancia.
%   Se usa un umbral dinámico para decidir si hay crisis.
%
% Entradas:
%   - matriz_evaluacion: estructura con vectores binarios por canal indicando crisis detectadas
%   - seg_ventana: duración de las ventanas (en segundos)
%   - min_duracion_crisis: duración mínima (en ventanas) para considerar una crisis válida
%   - nombres_canales: nombres reales de cada canal, para aplicar ponderaciones
%
% Salida:
%   - crisis_info: estructura con número de crisis, duración total e inicios/finales por paciente y hora
% -------------------------------------------------------------------------

crisis_info = struct();
pacientes_ids = fieldnames(matriz_evaluacion);

% Definir categorías de canales por relevancia
canales_relevantes = {'F7-T7','F8-T8','T7','T8','P7-O1','P8-O2','FP1-F3','FP2-F4','FZ-CZ'};
canales_ruidosos   = {'FP1-F7','FP2-F8','FT9-FT10','CZ-PZ'};

for p = 1:length(pacientes_ids)
    pid = pacientes_ids{p};
    crisis_info.(pid) = struct();
    horas = fieldnames(matriz_evaluacion.(pid));

    for h = 1:length(horas)
        hora_id = horas{h};
        canales = fieldnames(matriz_evaluacion.(pid).(hora_id));
        nombres = nombres_canales.(pid).(hora_id);

        % Preparar matriz binaria y vector de pesos
        canal_binarios = {};
        pesos = zeros(1, length(canales));
        long_max = 0;

        for c = 1:length(canales)
            canal_id = canales{c};
            vec = matriz_evaluacion.(pid).(hora_id).(canal_id);
            canal_binarios{end+1} = vec;
            long_max = max(long_max, length(vec));

            % Determinar peso según el nombre del canal
            nombre_canal = lower(nombres.(canal_id)); % pasar a minúsculas por si acaso

            if any(contains(canales_relevantes, nombre_canal))
                pesos(c) = 1.5;  % importante
            elseif any(contains(canales_ruidosos, nombre_canal))
                pesos(c) = 0.5;  % ruidoso
            else
                pesos(c) = 1.0;  % neutral
            end
        end

        % Construir matriz binaria (relleno con ceros si hace falta)
        bin_matrix = zeros(length(canal_binarios), long_max);
        for k = 1:length(canal_binarios)
            vec = canal_binarios{k};
            bin_matrix(k, 1:length(vec)) = vec * pesos(k);  % Aplicamos peso aquí
        end

        % Suma ponderada de actividad
        suma_ponderada = sum(bin_matrix,1);

        % Estimar umbral dinámico (ej. equivalente a 55% de la suma de pesos)
        umbral = 0.4 * sum(pesos);
        unificado = suma_ponderada >= umbral;

        % Detectar inicios y finales de crisis
        crisis_vec = zeros(1, length(unificado));
        i = 1;
        while i <= length(unificado)
            if unificado(i)
                ini = i;
                while i <= length(unificado) && unificado(i)
                    i = i + 1;
                end
                duracion = i - ini;
                if duracion >= min_duracion_crisis
                    crisis_vec(ini:i-1) = 1;
                end
            else
                i = i + 1;
            end
        end

        % Extraer eventos (inicios, finales, duraciones)
        diff_vec = diff([0 crisis_vec 0]);
        inicios = find(diff_vec == 1);
        finales = find(diff_vec == -1) - 1;
        inicios_seg = inicios * seg_ventana;
        finales_seg = finales * seg_ventana;
        duraciones_seg = (finales - inicios + 1) * seg_ventana;

        % Guardar resultados
        crisis_info.(pid).(hora_id).num_crisis = length(inicios);
        crisis_info.(pid).(hora_id).duracion_total = sum(duraciones_seg);
        crisis_info.(pid).(hora_id).inicios_fin = [inicios_seg', finales_seg'];
    end
end
end
