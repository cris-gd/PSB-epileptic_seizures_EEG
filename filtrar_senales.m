function senales_filtradas = filtrar_senales(pacientes)
% -------------------------------------------------------------------------
% FUNCION: filtrar_senales
%
% Descripción:
%   Filtra las señales EEG por paciente, hora y canal. Aplica:
%   - Filtro pasabanda (frecuencias útiles)
%   - Filtro de rechazo 60 Hz
%
% Entradas:
%   - pacientes: estructura generada por cargar_datos_edf
%
% Salida:
%   - senales_filtradas: estructura con la misma organización, pero con los
%     datos ya filtrados
% -------------------------------------------------------------------------

% Filtros definidos
pasobanda = designfilt('bandpassiir', ...
    'FilterOrder', 4, ...
    'HalfPowerFrequency1', 0.5, ...
    'HalfPowerFrequency2', 60, ...
    'SampleRate', 256, ...
    'DesignMethod', 'butter');
rechazo_60hz = designfilt('bandstopiir', ...
    'FilterOrder', 4, ...
    'HalfPowerFrequency1', 59, ...
    'HalfPowerFrequency2', 61, ...
    'SampleRate', 256);

% Inicializar estructura de salida
senales_filtradas = struct();

% Recorrer toda la estructura de pacientes
pacientes_ids = fieldnames(pacientes);

for p = 1:length(pacientes_ids)
    pid = pacientes_ids{p};  % Ej: 'p1'
    horas = fieldnames(pacientes.(pid));

    for h = 1:length(horas)
        hora_id = horas{h};  % Ej: 'h3'
        canales = fieldnames(pacientes.(pid).(hora_id));

        for c = 1:length(canales)
            canal_id = canales{c};  % Ej: 'FP1_F3'
            signal = pacientes.(pid).(hora_id).(canal_id);

            % Aplicar filtros
            x = filtfilt(pasobanda, signal);
            y = filtfilt(rechazo_60hz, x);

            % Guardar resultado
            senales_filtradas.(pid).(hora_id).(canal_id) = y;
        end
    end
end
end
