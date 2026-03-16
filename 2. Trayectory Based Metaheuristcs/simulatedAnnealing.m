function x = simulatedAnnealing(N)
    %% N = number of Queens
    %% X = final assignment 
    %% C = Overall Cost


    %% 1. Initializations 
    T = 1000; T_min = 0.001;
    x = randperm(N); % Generamos un estado inicial aleatorio (permutación)
    deltaE = @(current, new) fCost(new) - fCost(current);
    cool = @(T) 0.95 * T;
    

    %% 2. Search loop
    itera = 0;

    % La condición de parada principal es que el coste sea 0 (solución encontrada)
    while (T > T_min) && (fCost(x) > 0)
  
        % Siguiente variable a considerar (1, 2, 3... N, 1, 2...)
        itera = mod(itera, N) + 1; 

        %Generamos un nuevo sucesor aleatorio
        new = randomSuccessor(x, itera);

        if deltaE(x, new)
            x = new;
        else
            % Accept new with probability p
            p = exp(-deltaE(x, new) / T); % Calculate acceptance probability
            if p > rand
                x = new; % Accept new state
            end
        end
        
        T = cool(T);
        
        itera = itera + 1;
    end
    disp(fCost(x))
    disp(T)
    disp(itera)
    
end
