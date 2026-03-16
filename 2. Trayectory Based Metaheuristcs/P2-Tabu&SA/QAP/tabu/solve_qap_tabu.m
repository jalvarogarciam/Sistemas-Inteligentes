
function [ best_perm , best_cost , log ] = solve_qap_tabu (F , D , max_time)
 %% Inputs :
 % F - NxN flow matrix
 % D - NxN distance matrix
 % max_time - time budget in seconds ( double )
 %
 %% Outputs :
 % best_perm - 1xn vector , permutation assigning facilities to locations 
 % best_cost - double , total QAP objective value 
 % log - 1xk vector , best cost at each SA iteration

 % --- FIJAR LA SEMILLA PARA REPRODUCIBILIDAD ---
rng(1234); 

%% 1. INICIALIZACIÓN
    tic; 

    N = size(F, 1);
    
    % Estado Inicial aleatorio
    current_perm = randperm(N);
    current_cost = qap_cost(F, D, current_perm);

    % Mejor estado, donde registraremos la mejor solución encontrada en cada momento
    best_perm = current_perm;
    best_cost = current_cost;
    log = zeros(1, 1000000);

    % En QAP la matriz es muy densa, un buen tiempo de castigo es N/2
    ternure = round(N / 2); 
    
    % Matriz Tabú NxN. Guarda el "castigo" de intercambiar la facultad i con la j
    tabu = zeros(N, N); 
    
    iter = 0;

    %% 2. BUCLE DE BÚSQUEDA TABÚ
    while toc < max_time
        iter = iter + 1;

        local_best_cost = inf;
        best_movement = [0,0];

        % Exploramos todos los intercambios posibles entre 2 facultades
        for i = 1:N-1
            for j = i+1:N
                
                %{
                 Evaluamos cómo quedaría el mapa si intercambiamos los edificios
                 de la facultad i y la facultad j
                %}
                temp_perm = current_perm;
                temp_perm(i) = current_perm(j);
                temp_perm(j) = current_perm(i);
                
                % Calculamos el coste de esta nueva asignación
                new_cost = qap_cost(F, D, temp_perm);
                
                %{
                 Comprobamos si las facultades i y j tienen prohibido moverse
                 Si tenían prohibido moverse pero el nuevo coste supera al
                 mejor obtenido, lo permitimos.
                %}
                is_tabu = tabu(i, j) >= iter && (new_cost > best_cost);


                % Si no es tabú y es el mejor de esta ronda, lo registramos
                if ~is_tabu && (new_cost < local_best_cost)
                    local_best_cost = new_cost;
                    best_movement = [i, j];
                end
            end
        end

        
        if best_movement(1) ~= 0
            % Intercambiamos físicamente las dos facultades
            current_perm([best_movement(1) best_movement(2)]) = current_perm([best_movement(2) best_movement(1)]);

            
            % Actualizamos el coste actual
            current_cost = local_best_cost;

            % Castigamos a estas dos facultades en la Lista Negra
            tabu(best_movement(1), best_movement(2)) = iter + ternure;
            tabu(best_movement(2), best_movement(1)) = iter + ternure;

            % Si hemos encontrado una solución mejor, lo registramos
            if current_cost < best_cost
                best_cost = current_cost;
                best_perm = current_perm;
            end
        else
            % Si todos los movimientos del mundo son tabú, vaciamos la lista
            tabu = zeros(N, N);
        end

        % Guardamos el récord para la gráfica de convergencia
        if iter <= length(log)
            log(iter) = best_cost;
        else
            % Si superamos la estimación, ampliamos el buffer un poco más
            log = [log, zeros(1, 2*length(log))]; 
            log(iter) = best_cost;
        end

    end
    % Recortamos el vector log para eliminar los ceros sobrantes
    log = log(1:iter);
end




function cost = qap_cost(F, D, perm)
    %{
    Calcula el coste total del QAP.
     D(perm, perm) reordena la matriz de distancias según qué facultad 
     está en qué edificio. Luego se multiplica elemento a elemento (.*)
     por el flujo, y se suma todo.
    %}
    % Este truco me lo contó gemini, mi función para calcular coste era más chapucera...
    cost = sum(sum(F .* D(perm, perm)));
end