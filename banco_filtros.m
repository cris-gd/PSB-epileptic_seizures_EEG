function filtros = banco_filtros(n)
    % ---------------------------------------
    % Crea n filtros entre 0.5 y 40 Hz (componente señales alfa, beta, etc.)
    % n: numero de filtros que se quieren crear
    % ---------------------------------------
    filtros = [];
    for i = 1:n
        dif = (40 - 0.5)*2 / n;
        filtro = designfilt('bandpassiir','FilterOrder',20,'PassbandFrequency1', ...
            (0.5 + (i - 1)*dif)/256,'PassbandFrequency2',(0.5 + i*dif)/256,'PassbandRipple',1);
        filtros = [filtros filtro];
    end
