function [S,bestCost] = bestSucc (x,q)
%%	x is a complete assignment
%%	q is the queen to consider in order to generate new successors only by exchanging values of this queen with the rest of queens
%%	S the best successor and cost

    N = length(x);
    bestCost = inf; % Inicializamos a infinito
    S = x;          % Por defecto, el mejor sucesor es quedarse igual
    
    % Generamos sucesores intercambiando 'q' con el resto de reinas 'j'
    for j = [1:q-1, q+1:N]
        
        % Generamos un sucesor intercambiando q por otra reina
        suc = x;
        suc(q) = x(j);
        suc(j) = x(q);
        
        % Evaluamos el coste de este nuevo estado
        c = fCost(suc);
        
        % Si mejora el coste (o lo iguala y nos ayuda a movernos)
        if c < bestCost
            bestCost = c;
            S = suc;
        end
        
    end
end 