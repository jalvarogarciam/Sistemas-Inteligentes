clc; clear; close all;
fclose('all');



%% 1. BUSCAR TODOS LOS ARCHIVOS DE PRUEBA QAP
archivos = dir('../instances/qap_*.txt'); % Cambia esto si tus archivos se llaman distinto (ej: 'tai*.txt')

if isempty(archivos)
    error('No se encontraron archivos QAP. Asegúrate de que están en la misma carpeta.');
end

fprintf('Se han detectado %d archivos QAP.\n\n', length(archivos));

% --- CONFIGURACIÓN ---
tiempo_maximo = [5 10 20 30 60]; % Segundos por archivo

nombres_archivos = {};
costes_finales = zeros(1, length(archivos));

%% 2. BUCLE PARA PROCESAR CADA ARCHIVO AUTOMÁTICAMENTE
for i = 1:length(archivos)
    
    nombre = archivos(i).name;
    carpeta = archivos(i).folder;
    ruta_completa = fullfile(carpeta, nombre);
    
    nombres_archivos{i} = nombre;
    
    % --- LEER EL ARCHIVO QAP ---
    % El formato estándar QAPLIB es: N, seguido de matriz D, seguido de matriz F
    fid = fopen(ruta_completa, 'r');
    if fid == -1
        fprintf('Error grave: No se pudo abrir %s\n', ruta_completa);
        continue;
    end
    
    N = fscanf(fid, '%d', 1);                 
    % Leemos la Matriz 1 (Asumimos Distancias) de tamaño NxN
    D = fscanf(fid, '%f',[N, N])';      
    % Leemos la Matriz 2 (Asumimos Flujos) de tamaño NxN
    F = fscanf(fid, '%f', [N, N])';      
    fclose(fid); 
    
    fprintf('======================================================\n');
    fprintf('Procesando: %s (Tamaño %d) durante %d segundos...\n', nombre, N, tiempo_maximo(i));
    
    % --- EJECUTAR LA BÚSQUEDA TABÚ ---
    [best_perm, best_cost, log_costes] = solve_qap_tabu(F, D, tiempo_maximo(i));
    
    costes_finales(i) = best_cost; 
    fprintf('-> ¡Completado! Mejor coste QAP: %.2f\n', best_cost);
    
    if 0==0
        % --- DIBUJAR RESULTADOS VISUALES ---
        figure('Name', sprintf('Resultados QAP para %s', nombre), 'Color', 'w', 'Position',[100, 100, 1000, 450]);
        
        % Izquierda: Curva de Aprendizaje
        subplot(1, 2, 1);
        plot(log_costes, 'r-', 'LineWidth', 2);
        xlabel('Iteraciones'); ylabel('Coste Total');
        title(sprintf('Evolución Tabú - %s', nombre));
        grid on;
        
        % Derecha: Mapa de Calor de los Costes (Flujo * Distancia)
        subplot(1, 2, 2);
        % Calculamos la matriz de costes resultantes
        matriz_costes_final = F .* D(best_perm, best_perm);
        
        % Dibujamos un heatmap
        imagesc(matriz_costes_final);
        colormap('hot'); % Colores cálidos (negro/rojo = bien/bajo, blanco/amarillo = mal/alto)
        colorbar;
        title(sprintf('Heatmap de Costes (Total: %.0f)', best_cost));
        xlabel('Edificio Destino'); ylabel('Edificio Origen');
        
        drawnow; 
    end
end

%% 3. IMPRIMIR TABLA RESUMEN POR CONSOLA
fprintf('\n======================================================\n');
fprintf('                 RESUMEN DE EJECUCIÓN QAP             \n');
fprintf('======================================================\n');
for i = 1:length(archivos)
    fprintf(' Archivo: %-15s | Mejor Coste: %.2f\n', nombres_archivos{i}, costes_finales(i));
end
fprintf('======================================================\n');