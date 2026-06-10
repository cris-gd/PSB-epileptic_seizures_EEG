function [sens_horas, sens_crisis, sens_individual_horas, sens_individual_crisis] = calcular_sensibilidad(crisis_info, crisis_anotadas, margen_segundos)
% -------------------------------------------------------------------------
% Calcula la sensibilidad del sistema de detección de crisis epilépticas.
%
% Salidas:
%   - sens_horas: sensibilidad a nivel de hora (proporción de horas con crisis correctamente detectadas)
%   - sens_crisis: sensibilidad a nivel de crisis (proporción de crisis reales correctamente detectadas)
%   - sens_individual_horas: sensibilidad por paciente a nivel de hora
%   - sens_individual_crisis: sensibilidad por paciente a nivel de crisis
%
% Entradas:
%   - crisis_info: estructura con las crisis detectadas
%   - crisis_anotadas: estructura con las crisis reales anotadas
%   - margen_segundos: margen de tolerancia para considerar una detección como correcta (por defecto: 60s)
% -------------------------------------------------------------------------

    if nargin < 3
        margen_segundos = 60;  % margen de tolerancia por defecto
    end

    %Incialización de contadores globales
    TP_horas = 0;
    total_horas_con_crisis = 0;

    TP_crisis = 0;
    total_crisis_reales = 0;

    % Estructuras para almacenar sensibilidad por paciente
    sens_individual_horas = struct();
    sens_individual_crisis = struct();

    pacientes_ids = fieldnames(crisis_anotadas);

    for p = 1:length(pacientes_ids)
        pid = pacientes_ids{p};

        TP_horas_paciente = 0;
        total_horas_con_crisis_paciente = 0;

        TP_crisis_paciente = 0;
        total_crisis_reales_paciente = 0;

        if isfield(crisis_info, pid)
            horas = fieldnames(crisis_anotadas.(pid));
            for h = 1:length(horas)
                hora_id = horas{h};
                real_data = crisis_anotadas.(pid).(hora_id);

                if real_data.hay_crisis && isfield(real_data, 'inicios') && isfield(real_data, 'fines')
                    inicios_reales = real_data.inicios;
                    fines_reales = real_data.fines;
                    num_crisis_validas = min(length(inicios_reales), length(fines_reales));
                    total_crisis_reales = total_crisis_reales + num_crisis_validas;
                    total_crisis_reales_paciente = total_crisis_reales_paciente + num_crisis_validas;

                    % --- Sensibilidad por hora ---
                    total_horas_con_crisis = total_horas_con_crisis + 1;
                    total_horas_con_crisis_paciente = total_horas_con_crisis_paciente + 1;

                    crisis_detectadas = [];
                    if isfield(crisis_info.(pid), hora_id) && isfield(crisis_info.(pid).(hora_id), 'inicios_fin')
                        crisis_detectadas = crisis_info.(pid).(hora_id).inicios_fin;
                    end
                    if ~isempty(crisis_detectadas)
                        TP_horas = TP_horas + 1;
                        TP_horas_paciente = TP_horas_paciente + 1;
                    end

                    % --- Sensibilidad por crisis ---
                    for i = 1:num_crisis_validas
                        inicio_real = inicios_reales(i);
                        fin_real = fines_reales(i);
                        match_encontrado = false;

                        for j = 1:size(crisis_detectadas, 1)
                            inicio_detectada = crisis_detectadas(j,1);
                            fin_detectada = crisis_detectadas(j,2);

                            if (inicio_real <= fin_detectada + margen_segundos) && ...
                               (fin_real >= inicio_detectada - margen_segundos)
                                match_encontrado = true;
                                break;
                            end
                        end

                        if match_encontrado
                            TP_crisis = TP_crisis + 1;
                            TP_crisis_paciente = TP_crisis_paciente + 1;
                        end
                    end
                end
            end
        end

        % Guardar sensibilidad individual por paciente
        if total_horas_con_crisis_paciente > 0
            sens_individual_horas.(pid) = TP_horas_paciente / total_horas_con_crisis_paciente;
        else
            sens_individual_horas.(pid) = NaN;
        end

        if total_crisis_reales_paciente > 0
            sens_individual_crisis.(pid) = TP_crisis_paciente / total_crisis_reales_paciente;
        else
            sens_individual_crisis.(pid) = NaN;
        end
    end

    % Cálculos finales globales
    if total_horas_con_crisis > 0
        sens_horas = TP_horas / total_horas_con_crisis;
    else
        sens_horas = NaN;
    end

    if total_crisis_reales > 0
        sens_crisis = TP_crisis / total_crisis_reales;
    else
        sens_crisis = NaN;
    end
end

