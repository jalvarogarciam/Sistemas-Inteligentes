function [x, steps, ok] = min_conflicts_search(x, MAX_ITERA)
% MIN_CONFLICTS_SEARCH (N-Queens, representación permutación)
% x(i) = fila de la reina i (columna i), y x es una permutación 1..N
% Intercambio de dos columnas (mantiene filas únicas)

    ok = (fEval(x) == 0); % Comprobamos si por casualidad ya es solución
    steps = 0;
    N = numel(x);

    while (steps < MAX_ITERA)  && ~ok
        % Selección aleatoria de una variable en conflicto
        conflicted = get_conflicted_vars(x);

        % Si la lista de conflictos está vacía, es que ya hemos ganado
        if isempty(conflicted)
            ok = true;
            break;
        end


        % Elegimos una reina conflictiva al azar (v)
        v = conflicted(randi(numel(conflicted)));
        
        % Elegir con quién intercambiar para minimizar conflictos (w)
        w = find_min_conflict_swap(x, v);

        % Intercambio 
        if w ~= v
            temp = x(v);
            x(v) = x(w);
            x(w) = temp;
        end

        steps = steps + 1;
        ok = (fEval(x) == 0);
    end
end