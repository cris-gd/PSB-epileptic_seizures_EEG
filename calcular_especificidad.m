function [especificidad_global, especificidades_por_paciente] = calcular_especificidad(crisis_info, crisis_anotadas, duraciones)
    % -------------------------------------------------------------------------
    % Calcula la especificidad del sistema de detección de crisis epilépticas.
    %
    % Salidas:
    %   - especificidad_global: especificidad global (proporción de intervalos sin crisis correctamente detectados como negativos)
    %   - especificidades_por_paciente: especificidad individual por paciente (proporción de intervalos sin crisis correctamente detectados como negativos)
    %
    % Entradas:
    %   - crisis_info: estructura con las crisis detectadas
    %   - crisis_anotadas: estructura con las crisis reales anotadas
    %   - duraciones: estructura con la duración total de cada hora de cada paciente
    % -------------------------------------------------------------------------
    
    % Inicializar variables
    especificidades_por_paciente = struct();
    TN_global = 0;
    FP_global = 0;

    pacientes_ids = fieldnames(crisis_anotadas);

    for p = 1:length(pacientes_ids)
        pid = pacientes_ids{p};
        TN_paciente = 0;
        FP_paciente = 0;

        if isfield(crisis_info, pid)
            horas = fieldnames(crisis_anotadas.(pid));

            for h = 1:length(horas)
                hora_id = horas{h};
                real_data = crisis_anotadas.(pid).(hora_id);

                if isfield(real_data, 'hay_crisis') && isfield(real_data, 'inicios') && isfield(real_data, 'fines')
                    inicios_reales = real_data.inicios;
                    fines_reales = real_data.fines;
                    
                    % Validar tamaños compatibles
                    num_crisis_reales = min(length(inicios_reales), length(fines_reales));
                    if num_crisis_reales == 0
                        continue;
                    end

                    if isfield(duraciones, pid) && isfield(duraciones.(pid), hora_id)
                        total_segundos = duraciones.(pid).(hora_id);
                    else
                        total_segundos = 3600; % valor por defecto
                    end

                    vector_crisis_real = zeros(1, total_segundos);
                    for i = 1:num_crisis_reales
                        inicio_real = max(1, inicios_reales(i));
                        fin_real = min(total_segundos, fines_reales(i));
                        if inicio_real <= fin_real
                            vector_crisis_real(inicio_real:fin_real) = 1;
                        end
                    end

                    vector_crisis_detectada = zeros(1, total_segundos);
                    if isfield(crisis_info.(pid), hora_id) && isfield(crisis_info.(pid).(hora_id), 'inicios_fin')
                        crisis_detectadas = crisis_info.(pid).(hora_id).inicios_fin;
                        for i = 1:size(crisis_detectadas, 1)
                            inicio_detectada = max(1, crisis_detectadas(i, 1));
                            fin_detectada = min(total_segundos, crisis_detectadas(i, 2));
                            if inicio_detectada <= fin_detectada
                                vector_crisis_detectada(inicio_detectada:fin_detectada) = 1;
                            end
                        end
                    end

                    TN_paciente = TN_paciente + sum(vector_crisis_real == 0 & vector_crisis_detectada == 0);
                    FP_paciente = FP_paciente + sum(vector_crisis_real == 0 & vector_crisis_detectada == 1);
                end
            end
        end

        % Guardar especificidad por paciente
        total_negativos = TN_paciente + FP_paciente;
        if total_negativos > 0
            especificidades_por_paciente.(pid) = TN_paciente / total_negativos;
        else
            especificidades_por_paciente.(pid) = NaN;
        end

        % Acumular para especificidad global
        TN_global = TN_global + TN_paciente;
        FP_global = FP_global + FP_paciente;
    end

    % Calcular especificidad global
    if (TN_global + FP_global) > 0
        especificidad_global = TN_global / (TN_global + FP_global);
    else
        especificidad_global = NaN;
    end
end







