function[gbest_pos, gbest_val, convergence_curve] = run_pso(obj_func, N, D, max_iter, lb, ub)
    % Parámetros de entrada:
    % obj_func : Función a minimizar (eval_rastrigin o eval_ackley)
    % N        : Tamaño del enjambre (population size)
    % D        : Dimensiones del problema (10 o 30)
    % max_iter : Número máximo de iteraciones
    % lb, ub   : Límites inferior y superior (Lower/Upper bounds)

    
    %% 1. PARÁMETROS DEL PSO 
    c1 = 1.5;     
    c2 = 1.5;     
    Vmax = 0.2 * (ub - lb); % Clamping (20% del dominio)
    
    %% 2. INICIALIZACIÓN
    positions = lb + (ub - lb) * rand(N, D);
    velocities = zeros(N, D);
    
    pbest_pos = positions;
    pbest_val = obj_func(positions);
    
    [gbest_val, gbest_idx] = min(pbest_val); 
    gbest_pos = pbest_pos(gbest_idx, :);
    
    convergence_curve = zeros(1, max_iter);
    
    %% 3. BUCLE PRINCIPAL
    iter = 1;
    while iter <= max_iter
        
        r1 = rand(N, D);
        r2 = rand(N, D);
        
        % Inercia adaptativa
        w = 0.9 - 0.5 * (iter / max_iter);
        
        % --- A. ACTUALIZACIÓN DE VELOCIDAD ---
        velocities = w * velocities + ...
                     c1 * r1 .* (pbest_pos - positions) + ...
                     c2 * r2 .* (gbest_pos - positions); 
        
        velocities = min(max(velocities, -Vmax), Vmax);
        
        % --- B. ACTUALIZACIÓN DE POSICIÓN ---
        positions = positions + velocities;
        
        % --- C. CONTROL DE LÍMITES (Bound handling) ---
        fuera_inf = positions < lb;
        fuera_sup = positions > ub;
        
        positions(fuera_inf) = lb;
        positions(fuera_sup) = ub;
        velocities(fuera_inf | fuera_sup) = 0; 
        
        % --- D. EVALUACIÓN (Batch) ---
        current_val = obj_func(positions);
        
        % --- E. ACTUALIZAR PBEST ---
        mejora = current_val < pbest_val; 
        pbest_val(mejora) = current_val(mejora);
        pbest_pos(mejora, :) = positions(mejora, :);
        
        % --- F. ACTUALIZAR GBEST ---
        [min_val_actual, min_idx_actual] = min(pbest_val);
        if min_val_actual < gbest_val
            gbest_val = min_val_actual;
            gbest_pos = pbest_pos(min_idx_actual, :);
        end
        
        % --- G. SEGUIMIENTO Y CRITERIO DE ÉXITO ---
        convergence_curve(iter) = gbest_val;
        
        if gbest_val < 1e-3
            convergence_curve(iter:end) = gbest_val;
            break;
        end
        
        iter = iter + 1;
    end
end