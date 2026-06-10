function exportar_struct_a_excel(datos_struct, nombre_archivo)
% -------------------------------------------------------------------------
% Descripción:
%   Convierte un struct con formato paciente -> hora -> métricas
%   (como crisis_info) en una tabla y lo guarda en un archivo Excel
%   dentro de la carpeta "analisis".
%
% Entradas:
%   - datos_struct: estructura con campos por paciente y hora
%   - nombre_archivo: nombre del archivo Excel (string, con '.xlsx')
%
% Salidas:
%   - documento de excel
% -------------------------------------------------------------------------

    fila = 1;
    salida = {};

    pacientes = fieldnames(datos_struct);

    for p = 1:length(pacientes)
        pid = pacientes{p};
        horas = fieldnames(datos_struct.(pid));

        for h = 1:length(horas)
            hora = horas{h};
            info = datos_struct.(pid).(hora);

            salida{fila, 1} = pid;
            salida{fila, 2} = hora;

            % Manejar campos dinámicos de info (num_crisis, duracion_total, etc.)
            campos_info = fieldnames(info);
            for k = 1:length(campos_info)
                campo = campos_info{k};
                valor = info.(campo);

                if isnumeric(valor) && isvector(valor)
                    salida{fila, 2 + k} = valor;
                elseif isnumeric(valor) && ismatrix(valor)
                    salida{fila, 2 + k} = mat2str(valor);
                else
                    salida{fila, 2 + k} = string(valor);
                end
            end
            fila = fila + 1;
        end
    end

    % Construir cabecera dinámica
    cabecera = {'Paciente', 'Hora'};
    if ~isempty(pacientes)
        encontrado = false;
        for p = 1:length(pacientes)
            pid = pacientes{p};
            horas = fieldnames(datos_struct.(pid));
            if ~isempty(horas)
                ejemplo_info = fieldnames(datos_struct.(pid).(horas{1}));
                for i = 1:length(ejemplo_info)
                    cabecera{end+1} = ejemplo_info{i};
                end
                encontrado = true;
                break;
            end
        end
        if ~encontrado
            warning('No se encontraron datos en el struct para generar cabecera.');
        end
    end

    % Convertir a tabla
    T = cell2table(salida, 'VariableNames', cabecera);

    % Asegurar carpeta "analisis"
    carpeta = 'analisis';
    if ~exist(carpeta, 'dir')
        mkdir(carpeta);
    end

    % Guardar Excel en carpeta analisis
    ruta_completa = fullfile(carpeta, nombre_archivo);
    writetable(T, ruta_completa);

    fprintf('Archivo Excel guardado en: %s\n', ruta_completa);
end

