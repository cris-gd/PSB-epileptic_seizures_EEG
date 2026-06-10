function plot_mult_curves(pacientes, paciente_id, hora_id, separation)
% -------------------------------------------------------------------------
% Descripción: 
%   Muestra los diferentes canales EEG para un paciente y hora dados
%
% Entradas:
%   - pacientes: estructura con señales EEG (de cargar_datos_edf)
%   - paciente_id: string con el paciente seleccionado, por ejemplo 'p1'
%   - hora_id: string con la hora escogida, por ejemplo 'h3'
%   - separation: separación vertical entre canales
%
% Ejemplo de uso:
%   plot_mult_curves_struct(pacientes, 'p1', 'h3', 2000)
% -------------------------------------------------------------------------

    if ~isfield(pacientes, paciente_id) || ~isfield(pacientes.(paciente_id), hora_id)
        error('Paciente u hora no válidos.');
    end

    canales = fieldnames(pacientes.(paciente_id).(hora_id));
    N = length(canales);  % Número de canales

    figure
    hold on
    grid on
    title(sprintf('Señales EEG de %s - %s', paciente_id, hora_id))
    xlabel('Tiempo (muestras)')
    ylabel('Amplitud (con separación)')

    for i = 1:N
        ch_id = canales{i};
        senal = pacientes.(paciente_id).(hora_id).(ch_id);
        plot(senal + (i-1)*separation);  % Curva desplazada verticalmente
    end

    hold off
end
