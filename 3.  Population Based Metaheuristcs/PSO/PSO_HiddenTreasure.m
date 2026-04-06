clc; clear;

% 1. DATOS INICIALES (k=0)
S =[22.2135, 12.0427; 26.1881, 19.7741; 20.9158, 10.7442; 22.7604, 12.3982; 21.8738, 10.3611;
     23.7841, 12.8367; 17.6520,  9.2159; 25.5818,  8.4024; 34.4546,  9.6090; 24.6263, 10.4131];

pop_size = size(S, 1);
V = zeros(pop_size, 2); % Velocidad inicial es 0 para todos

% Evaluamos la posición inicial
feval = pso_eval(S);


% 2. PARÁMETROS DEL PSO
w = 0.8;  % Inercia
cp = 0.7; % Influencia personal (pbest)
cg = 0.8; % Influencia global (gbest)

% 3. INICIALIZAR MEMORIAS (Pbest y Gbest)
pbest_pos = S;          % Al principio, su mejor posición es donde nacieron
pbest_val = feval;      % Y su mejor nota es la inicial

[gbest_val, best_idx] = min(pbest_val);
gbest_pos = pbest_pos(best_idx, :);

% 4. BUCLE PRINCIPAL DEL PSO
max_iteraciones = 50; 
log_gbest = zeros(max_iteraciones, 1); % Para guardar cómo mejora el líder

fprintf('Iniciando el enjambre. Gbest inicial: %.4f\n', gbest_val);

for k = 1:max_iteraciones
    for i = 1:pop_size
        
        % A. Tiramos los dados (r_p y r_g aleatorios entre 0 y 1 para cada partícula)
        rp = rand(); 
        rg = rand();
        
        % B. ACTUALIZAR VELOCIDAD (La fórmula completa de la diapositiva)
        V(i, :) = w * V(i, :) ...
                + cp * rp * (pbest_pos(i, :) - S(i, :)) ...
                + cg * rg * (gbest_pos - S(i, :));
                
        % C. ACTUALIZAR POSICIÓN
        S(i, :) = S(i, :) + V(i, :);
        
        % D. EVALUAR NUEVA POSICIÓN
        nuevo_feval = pso_eval(S(i, :));
        
        % E. ACTUALIZAR PBEST (Memoria personal)
        if nuevo_feval > pbest_val(i)
            pbest_val(i) = nuevo_feval;
            pbest_pos(i, :) = S(i, :);
        end
        
        % F. ACTUALIZAR GBEST (Memoria global del enjambre)
        if nuevo_feval > gbest_val
            gbest_val = nuevo_feval;
            gbest_pos = S(i, :);
            fprintf('Iteración %2d: ¡Nuevo tesoro encontrado! Valor: %.4f en X=%.2f, Y=%.2f\n', ...
                    k, gbest_val, gbest_pos(1), gbest_pos(2));
        end
    end
    
    % Guardamos el récord actual para verlo luego en una gráfica si queremos
    log_gbest(k) = gbest_val;
end

fprintf('\nBúsqueda terminada.\n');
fprintf('EL TESORO ESTÁ EN: X = %.4f, Y = %.4f (Valor máximo encontrado = %.4f)\n', ...
        gbest_pos(1), gbest_pos(2), gbest_val);