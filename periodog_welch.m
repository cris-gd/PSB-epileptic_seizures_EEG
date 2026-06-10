function [P,f]= periodog_welch(x,M,win_type,fs,N)
% -------------------------------------------------------------------------
% PERIODOG_WELCH
% Se calcula el periodograma de la señal x en secciones de tamaño M sin 
% solapar. Después se promedian estos periodogramas.
% 
% Entradas:
%   - x: señal de entrada
%   - M: longitud (nº muestras) de las secciones de la señal
%   - win_type: window type (rectangular,hanning, hamming)
%   - fs: frecuencia de muestreo          
%   N: longitud de la FFT usada. (Nos quedaremos con N/2 muestras
%    frecuenciales)
%
% Salidas:
%   - P: periodograma promediado
%   - f: conjunto de frecuencias equiespaciadas donde se calcula P
% -------------------------------------------------------------------------

switch win_type
    case 'hamming'
        win= hamming(M);
    case 'hann'
        win= hann(M);
    otherwise
            win= rectwin(M);
end
U= sum(win.^2)/M;       % Factor de normalización

L=length(x);
N=max(N,L);
if rem(N,2)==1                                     
    N=N+1;                  % N par
end

[p,q]=size(x);
if p==1
  x=x';					% siempre vectores columna
end

Falta=rem(L,M);
x=[x;zeros(Falta,1)];			% relleno con ceros

N_tramas=L/M;
for i=1: N_tramas;
   xi= x((i-1)*M+1: M*i);			% seccion i
   P_interv(i,:)= 1/U*periodograma(xi.*win,fs,N);
end
if i==1
    P= P_interv;
else
    P= sum(P_interv)/N_tramas;
end

delta_f= fs/N; 
f= 0: delta_f:fs/2-delta_f;

