function [pacientes, nombres_canales] = cargar_datos_edf(carpeta_base, rango_pacientes)
% -------------------------------------------------------------------------
% Descripción:
%   Crea un struct con formato paciente -> hora -> métricas
%   de los datos sacados a partir de leer archivos EDF (formato chbXX)
%
% Entradas:
%   - carpeta_base: ruta base donde se encuentran las subcarpetas de los pacientes.
%   - rango_pacientes: vector [inicio, fin] con los IDs de pacientes a cargar.
%
% Salidas:
%   - pacientes: estructura que contiene los datos de señales organizados por paciente,
%                hora y canal (pX.hY.chZ).
%   - nombres_canales: estructura con las etiquetas de los canales correspondientes.
% -------------------------------------------------------------------------
    % Inicialización
    pacientes = struct();
    nombres_canales = struct();

    % Recorrer el rango de pacientes
    for paciente_id = rango_pacientes(1):rango_pacientes(2)
        subcarpeta = fullfile(carpeta_base, sprintf('chb%02d', paciente_id));
        if ~isfolder(subcarpeta)
            fprintf('Advertencia: No se encontró la carpeta para chb%02d\n', paciente_id);
            continue;
        end

        archivos = dir(fullfile(subcarpeta, '*.edf'));

        for i = 1:length(archivos)
            archivo = archivos(i).name;

            tokens = regexp(archivo, 'chb(\d+)_([0-9]+)\.edf', 'tokens');
            if isempty(tokens), continue; end

            paciente_id_archivo = str2double(tokens{1}{1});
            hora = str2double(tokens{1}{2});

            fichero = fullfile(subcarpeta, archivo);
            try
                data = edfread(fichero, 'DataRecordOutputType', 'vector');
                info = edfinfo(fichero);
            catch
                fprintf('Error leyendo archivo EDF: %s\n', fichero);
                continue;
            end

            paciente_key = sprintf('p%d', paciente_id_archivo);
            hora_key = sprintf('h%d', hora);

            if ~isfield(pacientes, paciente_key)
                pacientes.(paciente_key) = struct();
                nombres_canales.(paciente_key) = struct();
            end
            pacientes.(paciente_key).(hora_key) = struct();
            nombres_canales.(paciente_key).(hora_key) = struct();

            ch_index = 1;
            for j = 1:info.NumSignals
                label = info.SignalLabels{j};
                if strcmp(label, '-') || isempty(label) || strcmp(label, '.'), continue; end

                field_name = matlab.lang.makeValidName(['SignalLabel' num2str(j) '_' strrep(label, '-', '_')]);

                try
                    canal_data = vertcat(data.(field_name){:});
                    canal_key = sprintf('ch%d', ch_index);

                    pacientes.(paciente_key).(hora_key).(canal_key) = canal_data;
                    nombres_canales.(paciente_key).(hora_key).(canal_key) = label;

                    ch_index = ch_index + 1;
                catch
                    fprintf('Error leyendo canal %s en archivo %s\n', label, archivo);
                end
            end
        end
    end
end
