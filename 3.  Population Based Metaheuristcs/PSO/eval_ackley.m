function fitnesses = eval_ackley(pop)
    % pop es una matriz de tamaño [N_individuos, D_dimensiones]
    % fitnesses es un vector columna de tamaño[N_individuos, 1]
    
    D = size(pop, 2);
    
    % Sumamos las X al cuadrado por cada individuo (por filas)
    sum_sq = sum(pop.^2, 2);
    
    % Sumamos los cosenos por cada individuo
    sum_cos = sum(cos(2 * pi * pop), 2);
    
    % Aplicamos la fórmula de Ackley 
    term1 = -20 * exp(-0.2 * sqrt(sum_sq / D));
    term2 = -exp(sum_cos / D);
    fitnesses = term1 + term2 + 20 + exp(1);
end