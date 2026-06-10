function detecciones = deteccion_eventos(parametros, umbrales)
% -------------------------------------------------------------------------
% FUNCION: deteccion_eventos_con_arv_percentil
%
% Descripción:
%   Aplica condiciones basadas en percentiles a parámetros por ventana y 
%   detecta eventos para cada canal, incluyendo ARV como percentil.
%
% Entradas:
%   - parametros: estructura de matriz 5xN (energía, varianza, RMS, ZC, ARV)
%   - umbrales: estructura con campos:
%       .energia  (percentil, ej. 90)
%       .varianza (percentil, ej. 90)
%       .rms      (percentil, ej. 90)
%       .zc       (rango, ej. [10 90])
%       .arv      (percentil, ej. 90) ← ahora también percentil
%
% Salida:
%   - detecciones: estructura con vectores binarios por canal
% -------------------------------------------------------------------------

detecciones = struct();
pacientes_ids = fieldnames(parametros);

for p = 1:length(pacientes_ids)
    pid = pacientes_ids{p};
    horas = fieldnames(parametros.(pid));

    for h = 1:length(horas)
        hora_id = horas{h};
        canales = fieldnames(parametros.(pid).(hora_id));

        for c = 1:length(canales)
            canal_id = canales{c};

            matriz_params = parametros.(pid).(hora_id).(canal_id);
            num_ventanas = size(matriz_params, 2);
            vec_eval = zeros(1, num_ventanas);

            % Calcular umbrales percentiles
            umbral_energia   = prctile(matriz_params(1,:), umbrales.energia);
            umbral_varianza  = prctile(matriz_params(2,:), umbrales.varianza);
            umbral_rms       = prctile(matriz_params(3,:), umbrales.rms);
            percentiles_zc   = prctile(matriz_params(4,:), [umbrales.zc(1), umbrales.zc(2)]);
            umbral_arv       = prctile(matriz_params(5,:), umbrales.arv);  % ← nuevo

            for i = 1:num_ventanas
                energia_ok   = matriz_params(1,i) >= umbral_energia;
                varianza_ok  = matriz_params(2,i) >= umbral_varianza;
                rms_ok       = matriz_params(3,i) >= umbral_rms;
                zc_val       = matriz_params(4,i);
                zc_ok        = zc_val < percentiles_zc(1) || zc_val > percentiles_zc(2);
                arv_ok       = matriz_params(5,i) >= umbral_arv;

                total_condiciones = energia_ok + varianza_ok + rms_ok + zc_ok + arv_ok;
                vec_eval(i) = total_condiciones >= 4;
            end

            detecciones.(pid).(hora_id).(canal_id) = vec_eval;
        end
    end
end
end
