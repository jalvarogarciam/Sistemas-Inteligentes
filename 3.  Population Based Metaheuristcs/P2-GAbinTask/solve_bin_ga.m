function [ best_sol , best_cost , log , num_gens ] = solve_bin_ga ( dist , slope , speed , time_s , accel , bus_stop , params, time_limit )
%% Inputs
% dist 1 × N Segment distances [m]
% slope 1 × N Slope angles [rad]
% speed 1 × N Segment speeds [m/s]
% time s 1 × N Segment durations [s]
% accel 1 × N Segment a yccelerations [m/s2]
% bus_stop 1 × N 1 = recharge point (battery refills to SoEmax), 0 = normal
% params 1 × N Physical constants (first 20 entries; remainder are 0)
% time limit 1 × 1 Time budget [s] (15)

%% Output
% best_sol 1 × N Binary chromosome of the best solution found
% best_cost 1 × 1 Total CO2 emissions [kgCO2] of best sol
% log 1 × K Best cost found at each generation (convergence trace)
% num_gens 1 × 1 Total number of generations completed

    t_start = tic;
    
    n = length ( dist ) ;               % Número de segmentos de la ruta
    SoE_max = params (8) ;              % Máximo nivel de batería para el camión
    CO2_factor = params(12);            % Factor de conversión para pasar de kgCO2 a Kwh

    % Precalculamos el coste en CO2 / kwh para cada segmento
    segmentsCost = zeros(n, 2); % (co2, kwh);(co2, kwh)...
    for i = 1:n
        co2 = segment_kgCO2(dist(i), slope(i), speed(i), time_s(i), accel(i), params);
        segmentsCost(i, 1) = co2;
        segmentsCost(i, 2) = (co2 / CO2_factor) / 3600; 
    end
    
    
    % --- 2. Initialise population ---
    pop_size = 100;
    pop = rand(pop_size, n) < 0.01; % Solo un 5% de '1s' (eléctrico) al principio
    
    % La mejor solución inicial es no usar el motor eléctrico
    [best_sol, best_fit] = evalInd(zeros (1 , n ), segmentsCost, SoE_max);
    best_cost = 1/best_fit;
    
    log = [];
    num_gens = 0;
    
    
    while toc( t_start ) < time_limit - 0.01
        num_gens = num_gens + 1;

        % --- 3. Evaluate population
        [pop, fitnesses] = evalPop(pop, segmentsCost, SoE_max);
        
        
        % Si hemos llegado a una mejor solución que la actual, lo registramos
        [best_fitness, bestIdx] = max(fitnesses);
        if best_cost > 1 / best_fitness
            best_cost = 1 / best_fitness;
            best_sol = pop(bestIdx, :);
        end
        

        % --- 4. Selection
        k = round(length(fitnesses)*0.3); % Tamaño de los subgrupos a seleccionar en el torneo
        parentsIdxs = tournament(fitnesses, k);

        % --- 5. Crossover
        childs = crossover2points(pop, parentsIdxs);

        % --- 6. Mutation
        
        pMut = 1/n; % Probabilidad de mutación para cada gen
        childs = mutate(childs, pMut);

        % --- 7. Elitism :
        pop = combineGenerations(pop, childs, fitnesses, segmentsCost, SoE_max);

        
        % --- 8. Update best ---
        if num_gens <= length(log)
            log(num_gens) = best_cost;
        else
            log = [log, zeros(1, 2*length(log))]; % Resize
            log(num_gens) = best_cost;
        end

    end
    % Recortamos el vector log para eliminar los ceros sobrantes
    log = log(1:num_gens);
end



%{
Evalúa (cuanto mayor, mejor) un indivíduo, asignando un valor inversamente 
proporcional al sumatorio de los costes en CO2/kwh para cada tramo. 
Además los corrige, de tal forma que no admite individuos irreales 
(que rompan la restricción de la batería). Si se acaba la batería, pasa a combustión. 
La nueva población de indivíduos corregidos es devuelta como primer parámetro 
'new_pop', y el vector fila 'fitnesses', como segúndo parámetro, consistente 
en el conjunto de la evaluación individual de cada elemento de 'pop'.
%}
function [new_ind, fitness] = evalInd(ind, segmentsCost, SoE_max)

        kgCO2 = 0;       % Acumilador de Co2, inicialmente no ha emitido CO2
        SoE = SoE_max;   % Kwh de batería, inicilmente la tiene al máximo
        
        new_ind = ind;

        for i = 1:length(new_ind)

            if new_ind(i) == 1 % Está en eléctrico
                
                % Actualizamos el valor de la batería
                SoE = SoE - segmentsCost(i,2); 

            else % Está en combustión

                % Sumamos la emisión de ese tramo
                kgCO2 = kgCO2 + segmentsCost(i,1);
            end

            % Si inclumple la restricción de la batería, lo forzamos a cambiar a combustión
            if SoE < 0 
                SoE = 0;
                new_ind(i:end) = 0; % Pasamos a combustión 
            end

        end

        fitness = 1/kgCO2; % Registramos la evaluación del indivíduo
end




%{
Evalúa (cuanto mayor, mejor) una población indivíduo a indivíduo, asignando a 
cada uno un valor inversamente proporcional al sumatorio de los costes en CO2/kwh
para cada tramo. Además de evaluar estos indivíduos, los corrige,
de tal forma que no admite individuos irreales (que rompan la restricción
de la batería).  Si se acaba la batería, pasa a combustión.
La nueva población de indivíduos corregidos es devuelta
como primer parámetro 'new_pop', y el vector fila 'fitnesses', como segúndo
parámetro, consistente en el conjunto de la evaluación individual de cada
elemento de 'pop'.
%}
function [new_pop, fitnesses] = evalPop(pop, segmentsCost, SoE_max)
    % pop: Matriz de (pop_size x N) con 0s y 1s (1 = Eléctrico, 0 = Combustión)
    % segmentsCosts: Vector columna (N x 2) con el coste de CO2 y Kwh de cada tramo, de la forma (CO2, KWH)

    pop_size = height(pop);

    fitnesses = zeros(1, pop_size);
    new_pop = pop;

    % Recorremos la población para evaluar todos los indivíduos
    for i = 1:pop_size
        
        [new_pop(i, :), fitnesses(i)] = evalInd(pop(i, :), segmentsCost, SoE_max);
    
    end
end



function parentsIdxs = tournament(fitnesses, k)

    pop_size = length(fitnesses);

    % Contiene los índices de los mejores indivíduos de cada subconjunto de k indivíduos
    parentsIdxs = zeros(1,pop_size);
    
    % Seleccionamos tantos grupos de k elementos diferentes como indivíduos, para seleccionars los mejores
    for i = 1:pop_size

        % Seleccionamos k indices de indivíduos
        indices = randperm(pop_size,k); 
        
        % Vemos cual corresponde al mejor indivíduo
        [~, bestIdx] = max(fitnesses(indices)); 
        
        % Lo guardamos
        parentsIdxs(i) = indices(bestIdx); 
    end
    
end



function childs = crossover2points(pop, parentsIdxs)

        
    [pop_size, n] = size(pop);
    childs = zeros(pop_size, n);
    
    % Cruzamos cada pareja del bucle, lo recorremos de 2 en 2
    for i = 2:2:length(parentsIdxs)

        father = pop(parentsIdxs(i-1), :);
        mother = pop(parentsIdxs(i), :);

        % Seleccionamos 2 puntos de cruce completamente aleatorios en cada cruce
        cpts = sort(randperm(n, 2));

        % Creamos los 2 hijos
        childs(i-1, :) = [father(1:cpts(1)), mother(cpts(1)+1:cpts(2)), father(cpts(2)+1:end)]; % Más parecido al padre
        childs(i, :)   = [mother(1:cpts(1)), father(cpts(1)+1:cpts(2)), mother(cpts(2)+1:end)]; % Más parecido a la madre
    end

end

function mutated_childs = mutate(childs, pMut)
    
    % Creamos la matriz de la máscara de mutación, del mismo tamaño que childs
    % llena de 0s y 1s que indican si se muta o no.
    mascara_mutacion = rand(size(childs)) < pMut; % El azar y la probabilidad deciden si se muta
    
    % Aplicamos la mutación solo donde la máscara tiene un 1,
    % usando un xor, que invierte los bits de childs si mascara_mutacion es 1.
    mutated_childs = xor(childs, mascara_mutacion);
    
end

function elite = combineGenerations(pop, childs, popFitness, segmentsCost, SoE_max)
    elite = childs; % La generación de los hijos toma presencia

    parentsAmount = round(size(elite, 1) * 0.3); % Cantidad de padres en la nueva poblacion

    % Seleccionamos los mejores padres a mezclar
    [parentsFitnesses, parentsIdx] = maxk(popFitness, parentsAmount); 

    % Los introducimos al principio de la población, siempre y cuando se mejore cada indivíduo
    for i = 1:parentsAmount
        parent = pop(parentsIdx(i), :);
        parentFitness = parentsFitnesses(i);

        [~, childFitness ] = evalInd(elite(i,:), segmentsCost, SoE_max);

        if (parentFitness > childFitness)
            elite(i,:) = parent;
        end
    end

    
end
