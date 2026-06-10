function filtrada = filtrar60hz(pacientes)
% -------------------------------------------------------------------------
% Descripción:
%   Eliminar interferencias de línea (60Hz) y sus armónicos 
%   principales (16Hz y 32Hz en este contexto) mediante filtros IIR
% Entrada:
%   - pacientes: estructura que contiene los datos EEG crudos en formato
%                paciente -> hora -> canal
% Salida:
%   - filtrada: estructura con misma organización que la entrada pero con
%                las señales filtradas
% -------------------------------------------------------------------------
    filtrada = struct();
    filtro_rechazo60 = designfilt('lowpassiir','NumeratorOrder',20, ...
        'DenominatorOrder',20,'HalfPowerFrequency',80/256);
    filtro_rechazo16 = designfilt('bandstopiir','FilterOrder',20, ...
        'PassbandFrequency1',31.99/256,'PassbandFrequency2',32.01/256, ...
        'PassbandRipple',1);
    filtro_rechazo32 = designfilt('bandstopiir','FilterOrder',20, ...
        'PassbandFrequency1',63.99/256,'PassbandFrequency2',64.01/256, ...
        'PassbandRipple',1);
    nombres_pacientes = fieldnames(pacientes);
    for p = 1:length(nombres_pacientes)
        nombres_horas = fieldnames(pacientes.(nombres_pacientes{p}));
        for h = 1:length(nombres_horas)
            nombres_canales = fieldnames(pacientes.(nombres_pacientes{p}).(nombres_horas{h}));
            for ch = 1:length(nombres_canales)
                filtrada60 = filter(filtro_rechazo60, pacientes.(nombres_pacientes{p}).(nombres_horas{h}).(nombres_canales{ch}));
                filtrada16 = filter(filtro_rechazo16, filtrada60);
                filtrada.(nombres_pacientes{p}).(nombres_horas{h}).(nombres_canales{ch}) = filter(filtro_rechazo32, filtrada16);
            end
        end
    end