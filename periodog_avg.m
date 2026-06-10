function [P, f]= periodog_avg(x,interv,fs,N)
% -------------------------------------------------------------------------
% PERIODOGRAMA
% Se calcula el periodograma de la señal x en las secciones dadas por los
% intervalos recogidos en interv. Después se promedian estos periodogramas
% 
% Entradas:
% - x: señal de entrada
% - interv: intervalos en los que se calcula el periodograma de la señal
% - fs: frecuencia de muestreo
% Salidas:
% - N: longitud de la FFT usada. (Nos quedaremos con N/2 muestras
%    frecuenciales)
% - P: periodograma promediado
% -------------------------------------------------------------------------

L= length(x);
N=max(N,L);
if rem(N,2)==1
    N=N+1;                   % N par
end 
N_interv= size(interv,1);
aux = zeros(1,N/2);
for i=1: N_interv
    xi= x(interv(i,1): interv(i,2));
    [P_interv, f]= periodograma(xi,fs,N);
    aux = aux+P_interv;
end
P= aux/N_interv;