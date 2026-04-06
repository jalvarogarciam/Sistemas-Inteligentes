function fitnesses = eval_rastrigin(pop)
    % pop es una matriz de tamaño [N_individuos, D_dimensiones]
    % fitnesses devuelve un vector columna de tamaño[N_individuos, 1]
    
    D = size(pop, 2);
    
    % sum(..., 2) suma por filas. Evalúa a toda la población sin bucles.
    fitnesses = 10 * D + sum(pop.^2 - 10 * cos(2 * pi * pop), 2);
end