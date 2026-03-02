function [x, c]=localSearch(N)
    %% N = number of Queens
    %% X = final assignment and C = Overall Cost


    %% 1. Initializations 
    x = randperm(N); % Generamos un estado inicial aleatorio (permutación)
    c = fCost(x);    % Calculamos su coste inicial
    

    %% 2. Search loop
    itera = 0;
    max_iter = inf; % Añadimos un límite de operaciones por si se atasca en un mínimo local 

    % La condición de parada principal es que el coste sea 0 (solución encontrada)
    while (c > 0) && (itera < max_iter)
        
        % Siguiente variable a considerar (1, 2, 3... N, 1, 2...)
        currentVar = mod(itera, N) + 1; 

        % Buscamos el mejor sucesor intercambiando la reina 'currentVar'
        [x,c] = bestSucc(x, currentVar);  		%% Best Successor 
        
        itera = itera + 1;
    end
    
end

