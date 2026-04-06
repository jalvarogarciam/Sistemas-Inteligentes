function r=evalTab(tab)
%% debe recorrer el tablero y no encontrar 2 reinas en la misma fila,
%% columna y diagonal
%% si el operador aplicado es el intercambio colisiones en filas y columnas
%% nunca se producirán, por tanto las importantes son en diagonal
%% Suponiendo que cada Reina ocupa una columna diferente, se suman las
%% colisiones en diagonal y en fila
r=0;
[~, n] = size(tab);
for i=1:n-1
    for j=i+1:n
         r=r+ (abs(tab(i)-tab(j))==abs(i-j))+(tab(i)==tab(j));
    end
end


max_conflicts = sum(1:n-1);
r = max_conflicts - r;
%%% Maximización del problema, 

%r=-1*r;  %% Maximiza el problema, pero además en ciertos problemas los valores deben ser positivos, 
            %% por tanto le sumamos el número máximo de ataques posibles,
            %% así 0 conflictos significa la máxima evaluación
            
end