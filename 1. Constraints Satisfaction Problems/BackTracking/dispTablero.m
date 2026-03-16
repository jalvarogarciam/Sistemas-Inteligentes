function [ val ] = dispTablero(t)
%function [ val ] = dispTablero(t)
% muestra las reinas en el tablero


NReinas = length(t);
for R = 1:NReinas
    col=t(R); %% contiene la columna de la reina R
    for j=1:col-1
        fprintf('-  ');
    end
    fprintf('R%d ',R);
    for j = col+1:NReinas
            fprintf('-  ');
    end
    fprintf('\n');
end

