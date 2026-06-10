function caracteristicas = filtrar_senales_banco(segmentos)
% -------------------------------------------------------------------------
% Descripción:
%   Esta función recorre una estructura jerárquica de señales EEG segmentadas
%   y aplica un banco de filtros para cada segmento, extrayendo la energía en
%   cada banda de frecuencia definida por dichos filtros. También calcula la
%   energía total del segmento original (sin filtrar).
%
% Entradas:
%   - segmentos - Estructura con señales EEG, con la forma:
%               segmentos.paciente.hora.canal.segmento = vector de señal (1D)
%
% Salidas:
%   - caracteristicas - Estructura con la misma jerarquía que `segmentos`,
%                     incluyendo la energía total del segmento y la energía por
%                     cada filtro en cada banda, con la forma:
%                     caracteristicas.paciente.hora.canal.segmento.banda.filtro = energía
% -------------------------------------------------------------------------

    %bancos_filtros = struct();
    %bancos_filtros.b2 = banco_filtros(2);
    %bancos_filtros.b4 = banco_filtros(4);
    bancos_filtros.b5 = banco_filtros(5);
    %bancos_filtros.b8 = banco_filtros(8);
    caracteristicas = struct();
    nombres_pacientes = fieldnames(segmentos);
    for p = 1:length(nombres_pacientes)
        pid = nombres_pacientes{p};
        nombres_horas = fieldnames(segmentos.(pid));
        for h = 1:length(nombres_horas)
            hid = nombres_horas{h};
            nombres_canales = fieldnames(segmentos.(pid).(hid));
            for ch = 1:length(nombres_canales)
                chid = nombres_canales{ch};
                nombres_segmentos = fieldnames(segmentos.(pid).(hid).(chid));
                for s = 1:length(nombres_segmentos)
                    sid = nombres_segmentos{s};
                    nombres_bancos = fieldnames(bancos_filtros);
                    caracteristicas.(pid).(hid).(chid).(sid).energia_total = sum((segmentos.(pid).(hid).(chid).(sid)).^2);
                    for b = 1:length(nombres_bancos)
                        bid = nombres_bancos{b};
                        for f = 1:length(bancos_filtros.(bid))
                            nombre_filtro = sprintf("f%d", f);
                            a = filter(bancos_filtros.(bid)(f), segmentos.(pid).(hid).(chid).(sid));
                            caracteristicas.(pid).(hid).(chid).(sid).(bid).(nombre_filtro) = sum(a.^2);
                        end
                    end
                end
            end
        end
    end
