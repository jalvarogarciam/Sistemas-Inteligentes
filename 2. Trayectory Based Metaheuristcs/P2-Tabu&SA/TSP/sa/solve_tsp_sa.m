function [ best_tour , best_dist , log ] = solve_tsp_sa ( coords , max_time)
%% Inputs :
% coords - Nx2 matrix of (x,y) city coordinates
% max_time - time budget in seconds ( double )
%
%% Outputs :
% best_tour - 1xn vector , permutation of city indices (1.. n)
% best_dist - double , total tour distance
% log - 1xK vector , best distance at each SA iteration

% --- FIJAR LA SEMILLA ALEATORIA ---
rng(1234);
%% 1. Initializations 
    tic;                 % Tomamos el tiempo inicial para no pasarnos

    T_inicial = 1000000;          % Temperatura inicial
    T = T_inicial;
    T_min = 1;
    
    N = size(coords, 1);                            % Numero de ciudades
    distances = generate_distances_matrix(coords);  % Matriz de distancias

    % Estado en cada momento (puede ser peor que el mejor)
    current_tour = randperm(N);         
    current_dist = fDist(current_tour, distances);
    
    % Mejor estado obtenido en todo el algoritmo (record)
    best_tour = current_tour;                        % Estado inicial aleatorio
    best_dist = current_dist;        % Coste inicial

    log = [];                                       % Registro de las mejores distancias
    
    %% 2. Search loop
    % Paramos si se supera el tiempo
    while (toc < max_time)
  
        % Generamos un nuevo sucesor aleatorio y calculamos su coste
        new_tour = randomSuccessor2opt(current_tour);
        new_dist = fDist(new_tour, distances);

        % Calculamos la diferencia de coste (Delta E)
        deltaE = new_dist - current_dist;

        % Si es MEJOR (o igual), lo aceptamos siempre
        if deltaE <= 0
            current_tour = new_tour;
            current_dist = new_dist;
            
            % Actualizamos nuestra mejor ruta si la actual es mejor
            if current_dist < best_dist
                best_tour = current_tour;
                best_dist = current_dist;
            end
            
        % Si es PEOR, lo aceptamos con una probabilidad que depende de la Temperatura
        else
            if rand() < exp(-deltaE / T)
                current_tour = new_tour;
                current_dist = new_dist;
            end
        end
        
        % Enfriamos el sistema en función del tiempo que nos quede
        frac = toc / max_time; % Va de 0.0 (inicio) a 1.0 (fin del tiempo)
        T = T_inicial * (T_min / T_inicial)^frac; 
        %{ 
        La temperatura baja exponencialmente desde T_inicial hasta T_min
        de forma perfectamente sincronizada con tu reloj.
        %}   


        % Registramos la mejor distancia en cada iteración
        log = [log best_dist];
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


function new_tour = randomSuccessor(tour)

    N = length(tour);

    % Seleccionamos la primera ciudad 
    opciones = [1:N];
    i = opciones(randi(N));

    % Seleccionamos la segunda ciudad 
    opciones = [1:i-1, i+1:N]; % (Nos aseguramos de que j!=i)
    j = opciones(randi(N-1));
    
    % creamos la nueva versión del tour con las ciudades intercambiadas
    new_tour = tour;
    new_tour(i) = tour(j);
    new_tour(j) = tour(i);
end


function new_tour = randomSuccessor2opt(tour)

    N = length(tour);

    % Seleccionamos la primera ciudad 
    opciones = 1:N-1; 
    i = opciones(randi(N-1));

    % Seleccionamos la segunda ciudad 
    opciones = i+1:N; 
    j = opciones(randi(N-i));
    
    % Cogemos el segmento desde i hasta j y le damos la vuelta entera
    new_tour = tour;
    new_tour(i:j) = flip(tour(i:j)); 
    
end