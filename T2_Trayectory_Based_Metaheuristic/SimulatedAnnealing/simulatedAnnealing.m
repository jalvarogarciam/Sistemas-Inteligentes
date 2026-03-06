function [x, C_current, itera] = simulatedAnnealing(N)
    %% N = number of Queens
    
    %% 1. Initializations 
    T = 100000;          % Temperatura inicial
    T_min = 0.00001;     % Temperatura mínima (parada)
    alpha = 0.95;        % Factor de enfriamiento
    
    x = randperm(N);     % Estado inicial aleatorio
    C_current = fEval(x);% Coste inicial (usamos fEval o fCost, como se llame tu función)
    
    itera = 0;           % Contador general de iteraciones

    %% 2. Search loop
    % Paramos si la Temperatura es muy baja O si hemos encontrado el coste perfecto (0)
    while (T > T_min) && (C_current > 0)
  
        % Siguiente columna a considerar (1, 2, ... N, 1, 2 ...)
        columna = mod(itera, N) + 1; 

        % Generamos un nuevo sucesor aleatorio y RECOGEMOS su coste directamente
        [new_x, C_new] = randomSuccessor(x, columna);

        % Calculamos la diferencia de coste (Delta E)
        deltaE = C_new - C_current;

        % Si es MEJOR (o igual), lo aceptamos siempre
        if deltaE <= 0
            x = new_x;
            C_current = C_new;
            
        % Si es PEOR, lo aceptamos con una probabilidad que depende de la Temperatura
        else
            p = exp(-deltaE / T); % Probabilidad de aceptación
            if rand() < p         % Tiramos los dados (rand da un número entre 0 y 1)
                x = new_x;        % ¡Aceptamos el estado peor para escapar de mínimos locales!
                C_current = C_new;
            end
        end
        
        % Enfriamos el sistema (reducimos la temperatura)
        T = alpha * T;
        
        % Sumamos una iteración
        itera = itera + 1;
    end
    
    % Imprimimos los resultados finales
    fprintf('SA Terminado: Coste = %d | Iteraciones = %d | Temp Final = %.6f\n', C_current, itera, T);
    
end
