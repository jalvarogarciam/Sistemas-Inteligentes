clear; close all;

%% 1. CONFIGURACIÓN DEL EXPERIMENTO
N_runs = 100;          % Múltiples ejecuciones independientes (min 100)
pop_size = 50;         % Mismo tamaño de población para PSO y GA
max_iter = 500;        % Iteraciones máximas
dims =[10, 30];        % Dimensiones a evaluar

% Definimos las 2 funciones
problemas = {
    struct('nombre', 'Rastrigin', 'func', @eval_rastrigin, 'lb', -5.12, 'ub', 5.12),
    struct('nombre', 'Ackley',    'func', @eval_ackley,    'lb', -32.768, 'ub', 32.768)
};

%% 2. BUCLE DE EXPERIMENTACIÓN
fprintf('INICIANDO EXPERIMENTOS (100 runs por configuración)...\n');
fprintf('========================================================\n');

for p_idx = 1:length(problemas)
    prob = problemas{p_idx};
    
    % Creamos una figura grande para cada función (Rastrigin / Ackley)
    fig = figure('Name', sprintf('Resultados - %s', prob.nombre), 'Position',[100, 100, 1200, 500], 'Color', 'w');
    
    for d_idx = 1:length(dims)
        D = dims(d_idx);
        fprintf('Evaluando %s en D = %d ...\n', prob.nombre, D);
        
        % Matrices para guardar todo el historial (100 runs x max_iter)
        curvas_pso = zeros(N_runs, max_iter);
        curvas_ga  = zeros(N_runs, max_iter);
        
        % Tiempos y éxitos
        exitos_pso = 0; exitos_ga = 0;
        
        for run = 1:N_runs
            % --- Ejecutar PSO ---
            [~, val_pso, curva_pso] = run_pso(prob.func, pop_size, D, max_iter, prob.lb, prob.ub);
            curvas_pso(run, :) = curva_pso;
            if val_pso < 1e-3, exitos_pso = exitos_pso + 1; end
            
            % --- Ejecutar GA ---
            [~, val_ga, curva_ga] = run_ga(prob.func, pop_size, D, max_iter, prob.lb, prob.ub);
            curvas_ga(run, :) = curva_ga;
            if val_ga < 1e-3, exitos_ga = exitos_ga + 1; end
        end
        
        % --- CÁLCULOS ESTADÍSTICOS ---
        % Curva media de los 100 intentos
        media_pso = mean(curvas_pso, 1);
        media_ga  = mean(curvas_ga, 1);
        
        % Fitness final (última columna)
        final_pso = curvas_pso(:, end);
        final_ga  = curvas_ga(:, end);
        
        % Imprimir resumen en consola
        fprintf('  [PSO] Éxito: %3d%% | Media Final: %.2e | Std: %.2e\n', exitos_pso, mean(final_pso), std(final_pso));
        fprintf('  [GA]  Éxito: %3d%% | Media Final: %.2e | Std: %.2e\n\n', exitos_ga, mean(final_ga), std(final_ga));
        
        % --- DIBUJAR GRÁFICAS ---
        % 1. Curva de Convergencia Media (Usamos semilogy porque los valores bajan mucho)
        subplot(2, 2, d_idx);
        semilogy(media_pso, 'b-', 'LineWidth', 2); hold on;
        semilogy(media_ga, 'r-', 'LineWidth', 2);
        % Línea del criterio de éxito
        yline(1e-3, 'k--', 'Success Criterion (10^{-3})', 'LabelHorizontalAlignment', 'left');
        
        title(sprintf('%s (D=%d) - Convergence', prob.nombre, D));
        xlabel('Iterations'); ylabel('Mean Best Fitness (log scale)');
        legend('PSO', 'GA', 'Location', 'northeast'); grid on;
        
        % 2. Boxplot de Robustez (Para ver la varianza entre los 100 runs)
        subplot(2, 2, d_idx + 2);
        boxplot([final_pso, final_ga], 'Labels', {'PSO', 'GA'});
        set(gca, 'YScale', 'log'); % Eje Y logarítmico
        title(sprintf('Robustness (100 runs)'));
        ylabel('Final Fitness'); grid on;
    end
    drawnow;
end
fprintf('¡EXPERIMENTOS COMPLETADOS!\n');