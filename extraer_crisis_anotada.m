function [crisis_struct, duraciones] = extraer_crisis_anotada(carpeta_resumenes, rango_pacientes)
% -------------------------------------------------------------------------
% Descripción:
%   Procesa archivos con anotaciones (chbXX-summary.txt) para identificar periodos
%   de crisis epilépticas, sus tiempos de inicio/fin y duraciones de registro
%
% Entradas:
%   - carpeta_resumenes: ruta donde se encuentran los archivos de resumen
%   - rango_pacientes: vector [inicio, fin] con IDs de pacientes a procesar
%
% Salidas:
%   - crisis_struct: estructura con información de crisis (hay_crisis, inicios, fines)
%                    organizada por paciente (pX) y hora (hY)
%   - duraciones: estructura con duraciones totales de cada registro (en segundos)
% -------------------------------------------------------------------------

    crisis_struct = struct();
    duraciones = struct();

    for paciente_id = rango_pacientes(1):rango_pacientes(2)
        archivo_resumen = fullfile(carpeta_resumenes, sprintf('chb%02d-summary.txt', paciente_id));
        if ~isfile(archivo_resumen)
            fprintf('Advertencia: No se encontró el resumen para chb%02d\n', paciente_id);
            continue;
        end

        fileID = fopen(archivo_resumen, 'r');
        textData = textscan(fileID, '%s', 'Delimiter', '\n');
        fclose(fileID);
        textData = textData{1};

        paciente_key = sprintf('p%d', paciente_id);
        crisis_struct.(paciente_key) = struct();
        duraciones.(paciente_key) = struct();

        i = 1;
        while i <= length(textData)
            line = strtrim(textData{i});
            if startsWith(line, 'File Name:') 
                tokens = regexp(line, 'chb(\d+)_(\d+)\.edf', 'tokens');
                if isempty(tokens), i = i + 1; continue; end
                hora = str2double(tokens{1}{2});
                hora_key = sprintf('h%d', hora);

                % Reset variables por archivo
                hay_crisis = false;
                inicios = [];
                fines = [];
                start_time = NaN;
                end_time = NaN;
                seizure_count = 0;

                j = i + 1;
                while j <= length(textData) && ~startsWith(strtrim(textData{j}), 'File Name:')
                    linea2 = strtrim(textData{j});

                    if contains(linea2, 'File Start Time:')
                        time_str = extractAfter(linea2, 'File Start Time: ');
                        start_time = time_to_seconds(strtrim(time_str));
                    elseif contains(linea2, 'File End Time:')
                        time_str = extractAfter(linea2, 'File End Time: ');
                        end_time = time_to_seconds(strtrim(time_str));
                    elseif contains(linea2, 'Number of Seizures in File:')
                        seizure_count = sscanf(linea2, 'Number of Seizures in File: %d');
                        hay_crisis = seizure_count > 0;
                        %fprintf('Se encontraron %d crisis en este archivo.\n', seizure_count); % Depuración
                    elseif contains(linea2, 'Seizure') && hay_crisis
                        t_inicio = regexp(linea2, 'Seizure \d+ Start Time: (\d+)', 'tokens');
                        if ~isempty(t_inicio)
                            inicios(end+1) = str2double(t_inicio{1}{1});
                            %fprintf('Crisis inicio detectada en: %d\n', inicios(end)); % Depuración
                        end

                        t_fin = regexp(linea2, 'Seizure \d+ End Time: (\d+)', 'tokens');
                        if ~isempty(t_fin)
                            fines(end+1) = str2double(t_fin{1}{1});
                            %fprintf('Crisis fin detectado en: %d\n', fines(end)); % Depuración
                        end
                    end
                    j = j + 1;
                end

                crisis_struct.(paciente_key).(hora_key).hay_crisis = hay_crisis;
                crisis_struct.(paciente_key).(hora_key).inicios = inicios;
                crisis_struct.(paciente_key).(hora_key).fines = fines;
                crisis_struct.(paciente_key).(hora_key).num_crisis = length(inicios); % <--- NUEVO

                if ~isnan(start_time) && ~isnan(end_time)
                    duraciones.(paciente_key).(hora_key) = end_time - start_time;
                else
                    duraciones.(paciente_key).(hora_key) = 3600; % valor por defecto
                end
                i = j - 1;
            end
            i = i + 1;
        end
    end
end

function segundos = time_to_seconds(time_str)
% transforma cadenas de tiempo en formato HH:MM:SS o HH.MM.SS a segundos
    tokens = regexp(time_str, '(\d+)[.:](\d+)[.:](\d+)', 'tokens');
    if isempty(tokens)
        segundos = NaN;
    else
        t = str2double(tokens{1});
        segundos = t(1)*3600 + t(2)*60 + t(3);
    end
end

