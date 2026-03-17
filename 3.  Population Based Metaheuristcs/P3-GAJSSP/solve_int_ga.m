function [best_sol, best_cost, log, num_gens] = solve_int_ga(machines, times, time_limit)

[njobs, nmachines] = size(machines);

% --- 1. Compute number of operations per job ---
n_ops = sum(machines > 0, 2)'; % vector 1xj donde dice el numero de operaciones que tiene cada trabajo
N_op = sum(n_ops); % total operations

% --- 2. Build base chromosome (unshuffled) ---
base =[];
for j = 1:njobs
    base =[base, repmat(j, 1, n_ops(j))];
end

% --- 3. Initialise population ---
pop_size = 50;
pop = zeros(pop_size, N_op);
for i = 1:pop_size
    pop(i,:) = base(randperm(N_op));
end
fitnesses = evalPop(pop, machines, times);

best_cost = Inf;
best_sol = base;
log = [];
num_gens = 0;
t_start = tic;

while toc(t_start) < time_limit - 0.5
    num_gens = num_gens + 1;
        
      
    % --- 5. Selection ---
    k = round(pop_size*0.03); % Tamaño de los subgrupos a seleccionar en el torneo
    parentsIdxs = tournament(fitnesses, k);

    % --- 6. Crossover---
    childs = crossover_jox(pop, parentsIdxs);
    
    % --- 7. Mutation ---
    pMut = 0.35; % Probabilidad de mutación para cada gen
    childs = mutate(childs, pMut);


    % --- 8. Replacement & Evaluation of the new gen ---
    [pop, fitnesses] = elitism(pop, childs, fitnesses, machines, times);
    
    % Si hemos llegado a una mejor solución que la actual, lo registramos
    [best_fitness, bestIdx] = max(fitnesses);
    if best_cost > 1 / best_fitness
        best_cost = 1 / best_fitness;
        best_sol = pop(bestIdx, :);
    end

    % --- 9. Update best ---
    log(end+1) = best_cost;
end

end



function fitnesses = evalPop(pop, machines, times)

    [pop_size, ~] = size(pop);

    fitnesses = zeros(1, pop_size);

    % Recorremos la población para evaluar todos los indivíduos
    for i = 1:pop_size

        fitnesses(i) = 1/makespan(pop(i, :), machines, times);
    
    end
end

function cMax = makespan(chromosome, machines, times)
    [njobs, nmachines] = size(machines);

    job_time = zeros(1, njobs);
    machine_time = zeros(1, nmachines);
    op_count = zeros(1, njobs);

    for i = 1:length(chromosome)
        j = chromosome(i);

        op_count(j) = op_count(j) + 1;
        
        k = op_count(j);

        m = machines(j, k);

        d = times(j, k);

        s = max(job_time(j), machine_time(m));

        job_time(j) = s + d;

        machine_time(m) = s+d;
    end

    cMax = max(job_time);
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



function childs = crossover_jox(pop, parentsIdxs)
    
    [pop_size, n] = size(pop);
    childs = zeros(pop_size, n);
    
    % Cruzamos cada pareja del bucle, lo recorremos de 2 en 2
    for i = 2:2:length(parentsIdxs)
        
        % Cogemos los padres
        father = pop(parentsIdxs(i-1), :);
        mother = pop(parentsIdxs(i), :);

        % Seleccionamos aleatoriamente un trabajo 'job' del padre
        job = father (round(length(father)/2));

        % Localizamos las posiciones diferentes a job en cada padre
        not_jobIdxs = [find(father~=job); find(mother~=job)];

        % Creamos los 2 hijos
        childx = father;
        childx(not_jobIdxs(1, :)) = mother(not_jobIdxs(2, :));

        childy = mother;
        childy(not_jobIdxs(2,:)) = father(not_jobIdxs(1, :));

        childs(i-1, :) = childx;
        childs(i, :)   = childy;
    end
end


function childs = mutate(childs, pMut)
    
    [pop_size, n] = size(childs);

    % Para cada hijo, decidimos si se muta o no de forma independiente
    for i = 1:pop_size

        % El azar y la probabilidad deciden si se muta
        if rand() < pMut   
            % Seleccionamos 2 posiciones diferentes al azar
            idx = randperm(n, 2); j = idx(1); k = idx(2); 

            % Las intercambiamos
            childs(i, [j,k]) = childs(i, [k, j]); 
        end
    
    end
    
        
end


function [new_pop, new_fitnesses] = elitism(pop, childs, fitnesses, machines, times)
    
 
    % 1. Mezclamos los indivíduos
    pop = [pop; childs]; % Mezclamos los indivíduos (los concatenamos)
    

    % 2. Ordenamos los indivíduos en fundión de su fitness

    % Aprovechamos los que ya teníamos calculados y evaluamos los nuevos
    fitnesses = [fitnesses evalPop(childs, machines, times)];

    [~, bestIdxs] = maxk(fitnesses, length(fitnesses)/2); % Nos quedamos solo con los indices



    % 3. Nos quedamos con los mejores y deshechamos los peores
    new_fitnesses = fitnesses(bestIdxs);
    new_pop = pop(bestIdxs, :);


end


function [new_pop, new_fitnesses] = ponderedElitism(pop, childs, parents_fitnesses, machines, times)
    
    pop_size = size(pop, 1);
 
    % 1. Mezclamos los indivíduos
    parents_percentaje = 0.3;

    % 2. Ordenamos los indivíduos en fundión de su fitness

    childs_fitnesses = evalPop(childs, machines, times);

    [~, bestParentsIdxs] = maxk(childs_fitnesses, round(pop_size*(1-parents_percentaje)));
    [~, bestChildsIdxs]  = maxk(parents_fitnesses, round(pop_size*parents_percentaje));



    % 3. Nos quedamos con los mejores y deshechamos los peores
    new_fitnesses = [childs_fitnesses(bestChildsIdxs), parents_fitnesses(bestParentsIdxs)];
    new_pop = [childs(bestChildsIdxs, :); pop(bestParentsIdxs, :)];
    new_pop = new_pop(1:pop_size, :);


end
