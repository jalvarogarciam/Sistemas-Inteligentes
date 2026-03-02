function w = find_min_conflict_swap(x, v)
% Para una reina v, busca la reina w que al intercambiar x(v) y x(w)
% minimiza el número total de conflictos diagonales.
    
    N = numel(x);
    min_cost = inf;
    mejores_w =[]; % Lista para guardar los empates
    
    for i = 1:N
        % 1. Creamos un estado temporal intercambiando v e i
        temp_x = x;
        temp_x(v) = x(i);
        temp_x(i) = x(v);
        
        % 2. Evaluamos cuántos choques quedan si hacemos este cambio
        cost = fEval(temp_x);
        
        % 3. Comprobamos si es un nuevo récord o un empate
        if cost < min_cost
            min_cost = cost;
            mejores_w = i; % Nuevo récord, borramos la lista y guardamos este
        elseif cost == min_cost
            mejores_w = [mejores_w, i]; % Empate, lo añadimos a la lista
        end
    end
    
    %{
    Si hay varios movimientos que dan el mismo coste mínimo,
    elegimos uno al azar. Esto evita que se quede atascado moviendo
    dos reinas de un lado a otro infinitamente.
    %}
    w = mejores_w(randi(length(mejores_w)));
end