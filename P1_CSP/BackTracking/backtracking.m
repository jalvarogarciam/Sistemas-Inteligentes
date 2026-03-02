function [x, success] = backtracking(x, k)
%% x: current assignment vector
%% k: current column index to process
%% success: boolean flag indicating if a valid solution was found

    success = false;
    
    % Base Case: All queens have been placed successfully
    if k == length(x)+1
        success = true;
    else
        % Search Loop: Try every value for queen k
        val = 1;
        while (val <= length(x)) && ~success
            % Check if the assignment is consistent
            if is_safe(x, k, val)
                x(k) = val; % Tentative assignment
                
                % Recursive call for the next variable
                [x, success] = backtracking(x, k+1);
                if ~success
                    x(k) = 0;
                end
                

            end
            val = val + 1;
        end
    end
end


function safe = is_safe(x, col, fil)
%% x: vector de N reinas
%% col: columna en la que se va a poner la reina
%% fil: fila en la que se va a poner la reina
    
    safe = 1; % Por defecto, asumimos que está a salvo
    
    % SOLO miramos las columnas anteriores, donde ya hay reinas puestas
    cols_ocupadas = 1:(col - 1);
    reinas_colocadas = x(cols_ocupadas);

    % Comprobamos si hay reina en la misma fila
    if any(reinas_colocadas == fil)
        safe = 0;
        return; % si ya falla, salimos para no hacer más cálculos
    end

    % Comprobamos si hay reina en la misma diagonal
    if any(abs(cols_ocupadas - col) == abs(fil - reinas_colocadas))
        safe = 0;
        return;
    end

end