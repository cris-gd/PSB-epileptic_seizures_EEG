function [P,f]= periodograma(x,fs,N)

% -------------------------------------------------------------------------
% PERIODOGRAMA
% Se calcula el periodograma de la señal x, utilizándose una FFT de N muestras
% 
% Entradas:
%   - x: señal de entrada
%   - fs: frecuencia de muestreo
%   - N: longitud de la FFT usada (Nos quedaremos con N/2 muestras
%        frecuenciales
% Salidas: 
%   - P: periodograma calculado
%   - f: conjunto de frecuencias equiespaciadas donde se calcula P
% -------------------------------------------------------------------------

L= length(x);
N=max(N,L);
if rem(N,2)==1
    N=N+1;                   % N par
end                            
if size(x,2)==1
    x= x';
end
X= fft(x,N);
P= (abs(X(1:N/2).^2))/L;        % Nos quedamos con la primera mitad del periodo espectral
delta_f= fs/N; 
f= 0: delta_f:fs/2-delta_f;
% figure, plot(f,10*log10(P)), grid