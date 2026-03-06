function [ best_tour , best_dist , log ] = solve_tsp_sa ( coords , max_time)
%% Inputs :
% coords - Nx2 matrix of (x,y) city coordinates
% max_time - time budget in seconds ( double )
%
%% Outputs :
% best_tour - 1xn vector , permutation of city indices (1.. n)
% best_dist - double , total tour distance
% log - 1xK vector , best distance at each SA iteration

%% 1. Initializations 
    tic;                 % Tomamos el tiempo inicial para no pasarnos

    T = 1000000;          % Temperatura inicial
    T_min = 0.00001;     % Temperatura mínima (parada)
    alpha = 0.99;        % Factor de enfriamiento
    
    N = size(coords, 1);                            % Numero de ciudades
    distances = generate_distances_matrix(coords);  % Matriz de distancias

    % Estado en cada momento (puede ser peor que el mejor)
    current_tour = randperm(N);         
    current_dist = fDist(current_tour, distances);
    
    % Mejor estado obtenido en todo el algoritmo (record)
    best_tour = current_tour;                        % Estado inicial aleatorio
    best_dist = current_dist;        % Coste inicial

    log = [];                                       % Registro de las mejores distancias
    
    itera = 0;           % Contador general de iteraciones

    %% 2. Search loop
    % Paramos si la Temperatura es muy baja o se supera el tiempo
    while (T > T_min) && (toc < max_time)
  
        % Siguiente columna a considerar (1, 2, ... N, 1, 2 ...)
        ciudad = mod(itera, N) + 1; 

        % Generamos un nuevo sucesor aleatorio y calculamos su coste
        new_tour = randomSuccessor(current_tour, ciudad);
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
        
        % Enfriamos el sistema
        T = alpha * T;
        
        % Sumamos una iteración
        itera = itera + 1;
        
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


function new_tour = randomSuccessor(tour, i)

    % Seleccionamos la ciudad a intercambiar
    N = length(tour);
    opciones = [1:(i-1), (i+1):N];
    j = opciones(randi(N-1));
    
    % creamos la nueva versión del tour con las ciudades intercambiadas
    new_tour = tour;
    new_tour(i) = tour(j);
    new_tour(j) = tour(i);
end


