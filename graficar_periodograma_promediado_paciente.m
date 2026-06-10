function graficar_periodograma_promediado_paciente(pacientes, nombres_canales, paciente_id, horas_crisis, canales_a_graficar, fs)
% -------------------------------------------------------------------------
% Descripción:
%   Grafica el periodograma de TODAS las horas registradas
%   de un paciente, resaltando las horas con crisis epilépticas
%
% Entradas:
%   - pacientes: estructura con datos EEG
%   - nombres_canales: estructura con etiquetas de electrodos
%   - paciente_id: número identificador del paciente
%   - horas_crisis: vector de horas con crisis
%   - canales_a_graficar: vector con índices de canales a graficar
%   - fs: frecuencia de muestreo en Hz
%
% Comentarios: 
%   - N es la duración en muestras de la señal
%   - durac es la duración de cada ventana de periodograma
%
% Ejemplo de uso:
% graficar_periodograma_paciente(pacientes, nombres_canales, 18, [29 30 31], [1 3 5], 256);
% -------------------------------------------------------------------------
    nombre_paciente = sprintf('p%d', paciente_id);
    
    % Verificar existencia del paciente en las estructuras
    if ~isfield(pacientes, nombre_paciente) || ~isfield(nombres_canales, nombre_paciente)
        fprintf('Paciente %d no encontrado en las estructuras.\n', paciente_id);
        return;
    end
    datos_paciente = pacientes.(nombre_paciente);
    etiquetas_paciente = nombres_canales.(nombre_paciente);
    horas_registradas = fieldnames(datos_paciente);
    
    % Convertir nombres de horas a números
    horas_numeros = cellfun(@(x) str2double(x(2:end)), horas_registradas);
    
    % Obtener etiquetas reales de los canales
    primera_hora = horas_registradas{1};
    canales_disponibles = fieldnames(datos_paciente.(primera_hora));
    num_canales = length(canales_disponibles);
    
    etiquetas_reales = cell(1, num_canales);
    for ch = 1:num_canales
        canal_key = sprintf('ch%d', ch);
        if isfield(etiquetas_paciente.(primera_hora), canal_key)
            etiquetas_reales{ch} = etiquetas_paciente.(primera_hora).(canal_key);
        else
            etiquetas_reales{ch} = canal_key;
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
    % Configuración para periodograma
    N = length(datos_paciente.(primera_hora).ch1); % Tamaño de la ventana
    durac=60*fs; %muestras que dura ventana a promediar
    
    % Crear figura para cada canal
    for ch_idx = 1:length(canales_a_graficar)
        ch = canales_a_graficar(ch_idx);
        canal_key = sprintf('ch%d', ch);
        figura = figure(ch); clf;
        set(figura, 'Name', sprintf('Paciente %d - Periodograma Canal %d (%s)', paciente_id, ch, etiquetas_reales{ch}));
        
        % Ajustar número de subplots según horas registradas
        num_subplots = length(horas_registradas);
        filas = ceil(sqrt(num_subplots));
        columnas = ceil(num_subplots/filas);
        
        for h_idx = 1:length(horas_registradas)
            hora_key = horas_registradas{h_idx};
            hora_num = str2double(hora_key(2:end));
            
            if isfield(datos_paciente.(hora_key), canal_key)
                % Obtener señal y calcular 
                signal = datos_paciente.(hora_key).(canal_key);
                
                interv = [];
                for i = 1:N/durac
                    left = 1 + (i-1)*N/durac;
                    right = i*N/durac;
                    interv = [interv;left right];
                end

                [Y, f] = periodog_avg(signal, interv, fs, durac);
                P2 = 2*abs(Y/durac);
                
                % Graficar
                subplot(filas, columnas, h_idx);
                
                % Cambiar color si es hora enferma
                if ismember(hora_num, horas_crisis)
                    plot(f, P2, 'r', 'LineWidth', 1.2); % Rojo para crisis
                else
                    plot(f, P2, 'g', 'LineWidth', 1.2); % verde para normales
                end
                
                title(sprintf('Hora %d', hora_num));
                xlabel('Frecuencia (Hz)');
                ylabel('|Amplitud|');
                xlim([0 fs/2]);
                grid on;
              
            end
        end
        
        sgtitle(sprintf('Periodograma promediado - Paciente %d - Canal %d: %s\n', ...
               paciente_id, ch, etiquetas_reales{ch}), ...
               'FontWeight', 'bold');
    end
end