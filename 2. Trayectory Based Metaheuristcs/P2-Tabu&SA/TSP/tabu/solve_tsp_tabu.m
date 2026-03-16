function [ best_tour , best_dist , log ] = solve_tsp_tabu ( coords, max_time )
%% Inputs :
% coords - Nx2 matrix of (x,y) city coordinates
% max_time - time budget in seconds ( double )
%
%% Outputs :
% best_tour - 1xn vector , permutation of city indices (1.. n)
% best_dist - double , total tour distance
% log - 1xK vector , best distance at each SA iteration

    tic;                 % Tomamos el tiempo inicial para no pasarnos

    %% 1. Initializations

    N = size(coords, 1);                            % Numero de ciudades
    distances = generate_distances_matrix(coords);  % Matriz de distancias

    ternure = round(N/3);  % Tiempo de castigo para cada intercambio entre ciudades, en función del número de ciudades
    tabu = zeros(N,N);     % Matriz en la que registramos los intercambios entre ciudades i, j

    % Estado en cada momento
    current_tour = randperm(N);         
    current_dist = fDist(current_tour, distances);
    
    % Mejor estado obtenido en todo el algoritmo (record)
    best_tour = current_tour;        % Estado inicial aleatorio
    best_dist = current_dist;        % Coste inicial

    log = [];            % Registro de las mejores distancias
    


    iter = 0;           % Contador general de iteraciones

    %% 2. Search loop
    % Paramos si la Temperatura es muy baja o se supera el tiempo
    while (toc < max_time)
        iter = iter +1;

        best_neighbor_dist = inf;
        best_move = [0, 0];
        
        % EXPLORACIÓN DEL VECINDARIO (Todos los Swaps posibles)
        for i = 1:N-1
            for j = i+1:N
    
                % Calculamos el coste del vecino (Intercambio de ciudades en pos i y j)
                new_tour = current_tour;
                new_tour(i) = current_tour(j); new_tour(j) = current_tour(i);
                new_dist = fDist(new_tour, distances);
    
                % Miramos si dicho intercambio es tabu
                is_tabu = tabu(current_tour(i), current_tour(j)) > iter;
    
                % Si mejora nuestro mejor tour, ignoramos si es tabu o no
                if (new_dist < best_neighbor_dist || ~is_tabu )
                    best_neighbor_dist = new_dist;
                    best_move = [i, j];
                
                end
    
            end
        end
    
        % APLICAR EL MEJOR MOVIMIENTO ENCONTRADO
        if best_move(1) ~= 0

            city_i = current_tour(best_move(1));
            city_j = current_tour(best_move(2));
            
            % Hacemos el swap
            current_tour([i, j]) = current_tour([j, i]);
            current_dist = best_neighbor_dist;
            
            % Actualizamos la lista tabú para estas dos ciudades
            tabu(city_i, city_j) = iter + tenure;
            tabu(city_j, city_i) = iter + tenure;
            
            % ¿Es el mejor global?
            if current_dist < best_dist
                best_dist = current_dist;
                best_tour = current_tour;
            end
        end
        

        % Sumamos una iteración
        iter = iter + 1;
        
        % Registramos la mejor distancia en cada iteración
        log = [log best_dist];
    end
        
end





function distances = generate_distances_matrix(coords)
%% Inputs :
% coords - Nx2 matrix of (x,y) city coordinates
%
%% Outputs :
% distances - NxN matrix where each distance(i, j) is the euclidean
% distance between the city i and j
    
    euclidean_dist = @(a, b) sqrt((a(1) - b(1))^2 + (a(2) - b(2))^2);

    N = size(coords, 1);
    distances = zeros(N);
    
    for i = 1:N
        for j = 1:N 
            a =[coords(i,1), coords(i,2)];
            b = [coords(j,1), coords(j,2)];

            distances(i, j) = euclidean_dist(a, b);
        end
    end

end



function dist = fDist(tour, distances)
    dist = 0;
    for i = 1:length(tour)-1 %recorremos el tour entero
        % vamos sumando la distancia de cada ciudad con su ciudad posterior
        dist = dist + distances(tour(i), tour(i+1)); 
    end
    % Sumamos el coste de volver a la ciudad de origen
    dist = dist + distances(tour(end), tour(1));
end


function succesors = 