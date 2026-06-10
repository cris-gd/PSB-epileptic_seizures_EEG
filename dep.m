function DEP = dep(secuencia)
    % ---------------------------------------------------------------------
    % Densidad Espectral de potencia
    % X: espectro de la senal x
    % ---------------------------------------------------------------------
    l = length(secuencia);
    X = fft(secuencia, l + 1);
    DEP = abs(X).^2;