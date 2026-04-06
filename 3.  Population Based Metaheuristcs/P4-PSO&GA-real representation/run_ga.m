function[best_pos, best_val, convergence_curve] = run_ga(eval_func, N, D, max_iter, lb, ub)
    % N        : Tamaño de la población (Debe ser par)
    % D        : Dimensiones (10 o 30)
    % obj_func : Función a MINIMIZAR (eval_rastrigin o eval_ackley)

    %% 1. PARÁMETROS DEL GA CONTINUO
    p_mut = 0.1;                 % Probabilidad de mutación por gen (10%)
    sigma_ini = 0.1 * (ub - lb); % Salto grande al principio
    sigma_fin = 1e-5;            % Salto microscópico al final
    if mod(N, 2) ~= 0, N = N + 1; end 
    % Asegurarnos de que N es par para poder hacer parejas exactas


    %% 2. INICIALIZACIÓN
    % Matriz de población [N x D] con números reales entre lb y ub
    pop = lb + (ub - lb) * rand(N, D);
    
    % Evaluación inicial
    fitnesses = eval_func(pop); 
    
    % Buscar el mínimo inicial
    [best_val, best_idx] = min(fitnesses);
    best_pos = pop(best_idx, :);
    
    convergence_curve = zeros(1, max_iter);

    %% 3. BUCLE EVOLUTIVO
    iter = 1;
    while iter <= max_iter
        
        % --- A. SELECCIÓN POR TORNEO ---
        k = round(N*0.03); % Tamaño de los subgrupos a seleccionar en el torneo
        parentsIdxs = tournament(fitnesses, k);

        
        % --- B. CRUCE ARITMÉTICO (Real-valued Crossover) ---
        childs = crossover(pop, parentsIdxs);


        % --- C. MUTACIÓN GAUSSIANA (Real-valued Mutation) ---
        % Mutación Gaussiana adaptativa (se va apagando con el tiempo)
        sigma = sigma_ini - (sigma_ini - sigma_fin) * (iter / max_iter); % Varianza de la mutación gaussiana
        childs = mutate(childs, p_mut, sigma);

        % --- D. BOUND HANDLING (Control de límites) ---
        % Controlamos que no se salgan del mapa
        childs = max(min(childs, ub), lb);


        % --- E. Elitismo total y evaluación de la nueva generación ---
        [pop, fitnesses] = elitism(pop, childs, fitnesses, eval_func);


        % --- F. ACTUALIZAR EL MEJOR GLOBAL ---
        [min_val_actual, min_idx_actual] = min(fitnesses);
        if min_val_actual < best_val
            best_val = min_val_actual;
            best_pos = pop(min_idx_actual, :);
        end
        
        % Guardamos para la gráfica
        convergence_curve(iter) = best_val;
        
        % H. CRITERIO DE ÉXITO (Sección 2.5 del PDF)
        if best_val < 1e-3
            convergence_curve(iter:end) = best_val;
            break;
        end


        iter = iter + 1;
    end
end

function parentsIdxs = tournament(fitnesses, k)
% fitnesses: vector fila (1 x pop_size) con las notas
% k: tamaño del torneo

    pop_size = length(fitnesses);

    % 1. Generamos todos los torneos
    %{ 
     Creamos una matriz de[k filas x pop_size columnas] donde cada columna 
     representa un torneo independiente con k participantes (indices).
    %}
    torneos_idx = randi(pop_size, k, pop_size);


    % 2. OBTENER LAS NOTAS DE LOS COMPETIDORES
    %{
     Sustituimos los índices por sus respectivos valores de fitness.
     La matriz resultante sigue siendo de [k x pop_size].
    %}
    torneos_fitness = fitnesses(torneos_idx);


    % 3. Buscamos los ganadores de cada enfrentamiento
    %{
     min(...,[], 1) busca el mínimo por columnas. Es decir, 
     nos dice quién ganó en cada una de las pop_size columnas.
     'ganadores_fila' guarda en qué fila (1 a k) estaba el ganador.
    %}
    [~, ganadores] = min(torneos_fitness,[], 1);


    % 4. Extraer los índices reales de los ganadores en la población
    %{
     Convertimos la fila del ganador a su posición lineal en la matriz
     para poder extraer su índice original de la matriz 'torneos_idx'.
    %}
    indices_lineales = ganadores + (0 : pop_size - 1) * k;
    parentsIdxs = torneos_idx(indices_lineales);

end
    




function childs = crossover(pop, parentsIdxs)

    [N, D] = size(pop);
    parents = pop(parentsIdxs,:);
    
    % Separamos en Madres (pares) y Padres (impares)
    fathers = parents(1:2:end, :);
    mothers = parents(2:2:end, :);
    
    % Factor de cruce aleatorio alpha entre 0 y 1 para cada gen
    alpha = rand(N/2, D);
    
    % Hijos: combinación lineal de los padres
    childs1 = alpha .* fathers + (1 - alpha) .* mothers;
    childs2 = (1 - alpha) .* fathers + alpha .* mothers;
    
    % Juntamos a los hijos en la nueva población
    childs = [childs1; childs2];
end


function childs = mutate(childs, p_mut, sigma)
    [N, D] = size(childs);

    % Tiramos los dados para cada gen de la matriz entera [N x D]
    mascara_mut = rand(N, D) < p_mut;
    
    % Generamos ruido gaussiano randn() SOLO donde la máscara es 1
    num_mutaciones = sum(mascara_mut(:));
    ruido = sigma * randn(num_mutaciones, 1);
    
    % Aplicamos el ruido
    childs(mascara_mut) = childs(mascara_mut) + ruido;
    
        
end


function [new_pop, new_fitnesses] = elitism(pop, childs, fitnesses, eval_func)
    
 
    % 1. Mezclamos los indivíduos
    pop = [pop; childs]; % Mezclamos los indivíduos (los concatenamos)
    

    % 2. Ordenamos los indivíduos en función de su fitness

    % Aprovechamos los que ya teníamos calculados y evaluamos los nuevos
    fitnesses = [fitnesses; eval_func(childs)];

    [~, bestIdxs] = mink(fitnesses, length(fitnesses)/2); % Nos quedamos solo con los indices

    % 3. Nos quedamos con los mejores y deshechamos los peores
    new_fitnesses = fitnesses(bestIdxs);
    new_pop = pop(bestIdxs, :);


end
