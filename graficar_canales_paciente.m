function graficar_canales_paciente(pacientes, nombres_canales, paciente_id, horas_crisis, canales_a_graficar)
% -------------------------------------------------------------------------
% Descripción:
%   Graficar en tiempo señales EEG de un paciente para los canales
%   especificados y resaltando las horas con crisis. Ahora se adapta
%   dinámicamente al número de horas registradas.
%   
% Entradas:
%   - pacientes: estructura con datos
%   - nombres_canales: etiquetas electrodos de canales
%   - pacientes_id: número del paciente
%   - horas_crisis: vector de horas con crisis
%   - canales_a_graficar: vector con índices de canales a graficar
% Ejemplo de uso:
% graficar_canales_paciente(pacientes, nombres_canales, 18, [29 30 31 35], [2,5,9,14]);
% -------------------------------------------------------------------------
    nombre_paciente = sprintf('p%d', paciente_id);

    % verificar que el paciente existe en ambas estructuras
    if ~isfield(pacientes, nombre_paciente) || ~isfield(nombres_canales, nombre_paciente)
        fprintf('Paciente %d no encontrado en las estructuras.\n', paciente_id);
        return;
    end

    datos_paciente = pacientes.(nombre_paciente);
    etiquetas_paciente = nombres_canales.(nombre_paciente);
    horas_registradas = fieldnames(datos_paciente);

    % Obtener los nombres reales de los canales de la primera hora disponible
    primera_hora = horas_registradas{1};
    canales_disponibles = fieldnames(datos_paciente.(primera_hora));
    num_canales = length(canales_disponibles);

    % Obtener etiquetas reales de los canales
    etiquetas_reales = cell(1, num_canales);
    for ch = 1:num_canales
        canal_key = sprintf('ch%d', ch);
        if isfield(etiquetas_paciente.(primera_hora), canal_key)
            etiquetas_reales{ch} = etiquetas_paciente.(primera_hora).(canal_key);
        else
            etiquetas_reales{ch} = canal_key; % Usar chX como fallback
        end
    end

    % Validar canales solicitados
    canales_validos = ismember(canales_a_graficar, 1:num_canales);
    if ~all(canales_validos)
        fprintf('Advertencia: Canales no válidos. Canales disponibles (1-%d):\n', num_canales);
        for ch = 1:num_canales
            fprintf('%d: %s\n', ch, etiquetas_reales{ch});
        end
        canales_a_graficar = canales_a_graficar(canales_validos);
        if isempty(canales_a_graficar)
            return;
        end
    end

    for ch_idx = 1:length(canales_a_graficar)
        ch = canales_a_graficar(ch_idx);
        canal_key = sprintf('ch%d', ch);
        figura = figure(ch); clf;
        set(figura, 'Name', sprintf('Paciente %d - Canal %d (%s)', paciente_id, ch, etiquetas_reales{ch}));

        % Calcular distribución óptima de subplots
        num_horas = length(horas_registradas);
        filas = ceil(sqrt(num_horas));
        columnas = ceil(num_horas/filas);
        
        for h_idx = 1:num_horas
            hora_key = horas_registradas{h_idx};
            hora_num = str2double(regexprep(hora_key, 'h', ''));

            if isfield(datos_paciente.(hora_key), canal_key)
                y = datos_paciente.(hora_key).(canal_key);
                t = (1:length(y)) / 256; % Asumiendo frecuencia de muestreo de 256 Hz

                subplot(filas, columnas, h_idx);

                % Color según si es crisis o no
                color = [0.2 0.6 0.2]; % Verde para no crisis
                if ismember(hora_num, horas_crisis)
                    color = [0.8 0.2 0.2]; % Rojo para crisis
                end

                plot(t, y, 'Color', color, 'LineWidth', 0.5);
                title(sprintf('Hora %d', hora_num));
                xlabel('Tiempo (s)');
                ylabel('Amplitud (μV)');
                grid on;
            end
        end

        sgtitle(sprintf('Paciente %d - Canal %d: %s', paciente_id, ch, etiquetas_reales{ch}), 'FontWeight', 'bold');
    end
end
% function graficar_canales_paciente(pacientes, nombres_canales, paciente_id, horas_crisis, canales_a_graficar)
% % -------------------------------------------------------------------------
% % Descripción:
% %   Graficar en tiempo señales EEG de un paciente para los canales
% %   especificados y resaltando las horas con crisis
% %   
% % Entradas:
% %   - pacientes: estructura con datos
% %   - nombres_canales: etiquetas electrodos de canales
% %   - pacientes_id: número del paciente
% %   - horas_crisis: vector de horas con crisis
% %   - canales_a_graficar: vector con índices de canales a graficar
% % -------------------------------------------------------------------------
% 
% % forma de emplear: ejemplo: para el paciente 18 con crisis en horas 29, 30, 31, 35:
% %graficar_canales_paciente(pacientes, nombres_canales, 18, [29 30 31 35], [2,5,9,14]);
% 
%     nombre_paciente = sprintf('p%d', paciente_id);
% 
%     % verificar que el paciente existe en ambas estructuras
%     if ~isfield(pacientes, nombre_paciente) || ~isfield(nombres_canales, nombre_paciente)
%         fprintf('Paciente %d no encontrado en las estructuras.\n', paciente_id);
%         return;
%     end
% 
%     datos_paciente = pacientes.(nombre_paciente);
%     etiquetas_paciente = nombres_canales.(nombre_paciente);
%     horas = fieldnames(datos_paciente);
% 
%     % Obtener los nombres reales de los canales de la primera hora disponible
%     primera_hora = horas{1};
%     canales_disponibles = fieldnames(datos_paciente.(primera_hora));
%     num_canales = length(canales_disponibles);
% 
%     % Obtener etiquetas reales de los canales
%     etiquetas_reales = cell(1, num_canales);
%     for ch = 1:num_canales
%         canal_key = sprintf('ch%d', ch);
%         if isfield(etiquetas_paciente.(primera_hora), canal_key)
%             etiquetas_reales{ch} = etiquetas_paciente.(primera_hora).(canal_key);
%         else
%             etiquetas_reales{ch} = canal_key; % Usar chX como fallback
%         end
%     end
% 
%     % Validar canales solicitados
%     canales_validos = ismember(canales_a_graficar, 1:num_canales);
%     if ~all(canales_validos)
%         fprintf('Advertencia: Canales no válidos. Canales disponibles (1-%d):\n', num_canales);
%         for ch = 1:num_canales
%             fprintf('%d: %s\n', ch, etiquetas_reales{ch});
%         end
%         canales_a_graficar = canales_a_graficar(canales_validos);
%         if isempty(canales_a_graficar)
%             return;
%         end
%     end
% 
%     for ch_idx = 1:length(canales_a_graficar)
%         ch = canales_a_graficar(ch_idx);
%         canal_key = sprintf('ch%d', ch);
%         figura = figure(ch); clf;
%         set(figura, 'Name', sprintf('Paciente %d - Canal %d (%s)', paciente_id, ch, etiquetas_reales{ch}));
% 
%         idx_subplot = 1;
%         for i = 1:length(horas)
%             hora_key = horas{i};
%             hora_num = str2double(regexprep(hora_key, 'h', ''));
% 
%             if isfield(datos_paciente.(hora_key), canal_key)
%                 y = datos_paciente.(hora_key).(canal_key);
%                 t = (1:length(y)) / 256; % Asumiendo frecuencia de muestreo de 256 Hz
% 
%                 subplot(2, 4, idx_subplot);
% 
%                 % Color según si es crisis o no
%                 color = [0.2 0.6 0.2]; % Verde para no crisis
%                 if ismember(hora_num, horas_crisis)
%                     color = [0.8 0.2 0.2]; % Rojo para crisis
%                 end
% 
%                 plot(t, y, 'Color', color, 'LineWidth', 0.5);
%                 title(sprintf('Hora %d', hora_num));
%                 xlabel('Tiempo (s)');
%                 ylabel('Amplitud (μV)');
%                 grid on;
% 
%                 idx_subplot = idx_subplot + 1;
% 
%                 if idx_subplot > 8
%                     break; % máximo 8 subplots por figura
%                 end
%             end
%         end
% 
%         sgtitle(sprintf('Paciente %d - Canal %d: %s', paciente_id, ch, etiquetas_reales{ch}), 'FontWeight', 'bold');
%     end
% end
