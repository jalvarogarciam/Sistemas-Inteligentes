function [x, success] = backtracking_AC3(x, k, dominios)
    % x: Tablero actual
    % k: Columna actual
    % dominios: cell array con las filas posibles para cada columna
    
    N = length(x);
    success = false;
    
    % Si es la primera llamada y no hay dominios, los inicializamos a 1:N
    if nargin < 3
        dominios = repmat({1:N}, 1, N);
        % Pasamos un primer filtro inicial
        [dominios, ~] = AC3_NReinas(N, dominios); 
    end

    % Caso base: hemos llegado al final
    if k == N + 1
        success = true;
        return;
    end

    % En lugar de probar de 1 a N, SOLO probamos los valores que el AC-3 
    % nos ha dejado vivos en la lista de la reina k:
    valores_posibles = dominios{k};
    
    for val = valores_posibles
        x(k) = val; % Ponemos la reina
        
        % COPIA de dominios para no estropear el original si tenemos que volver atrás
        nuevos_dominios = dominios;
        
        % Como acabamos de fijar la reina k en la fila 'val', su dominio ahora es SOLO 'val'
        nuevos_dominios{k} = val;
        
        % --- ¡AQUÍ ESTÁ LA MAGIA! PROPAGAMOS HACIA ADELANTE ---
        [nuevos_dominios, esConsistente] = AC3_NReinas(N, nuevos_dominios);
        
        % Si el AC3 dice que el tablero sigue teniendo solución (no hay dominios vacíos)
        if esConsistente
            % Llamada recursiva a la siguiente columna
            [x, success] = backtracking_AC3(x, k+1, nuevos_dominios);
            if success
                return; % Si encontró solución, salimos
            end
        end
        
        % Si el AC-3 dijo "imposible" o el camino recursivo falló, quitamos la reina y probamos otra
        x(k) = 0;
    end
end