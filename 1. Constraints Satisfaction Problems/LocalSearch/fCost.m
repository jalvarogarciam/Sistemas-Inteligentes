function c=fCost(x)
    %% x is a complete assignment
    %% c is the total number of conflicts (only diagonal constraints)
    
    %{
    Debe recorrer el tablero y no encontrar 2 reinas en la misma fila, columna y diagonal
    Se considera una Reina por cada columna . Si el operador aplicado es el intercambio:
    colisiones en filas y columnas nunca se producirán, por tanto sólo se tienen en cuenta 
    las de la diagonal
    %}

    c = 0;
    N = length(x);

    % Comparamos cada reina con todas las reinas a su derecha
    for i = 1:(N-1)
        for j = (i+1):N
            % Hay conflicto diagonal si la distancia horizontal == distancia vertical
            if abs(x(i) - x(j)) == abs(i - j)
                c = c + 1;
            end
        end
    end
end