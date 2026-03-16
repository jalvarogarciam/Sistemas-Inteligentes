clc; clear; close all;
fclose('all'); % <--- TRUCO 1: Cierra cualquier archivo que se haya quedado "pillado" en memoria

% --- FIJAR LA SEMILLA ALEATORIA ---
rng(1234); % Puedes poner el número que quieras (1234, 42, 0...)

%% 1. BUSCAR TODOS LOS ARCHIVOS DE PRUEBA
archivos = dir('../instances/tsp_*.txt'); 

if isempty(archivos)
    error('No se encontraron archivos. Asegúrate de que el script está en la misma carpeta que los .txt');
end

fprintf('Se han detectado %d archivos de prueba.\n\n', length(archivos));

% --- CONFIGURACIÓN ---
tiempo_maximo = [5 8 12 15 20]; 

nombres_archivos = {};
distancias_finales = zeros(1, length(archivos));

%% 2. BUCLE PARA PROCESAR CADA ARCHIVO AUTOMÁTICAMENTE
for i = 1:length(archivos)
    
    % --- TRUCO 2: RUTA ABSOLUTA ---
    % Sacamos el nombre y la carpeta exacta, y los unimos de forma segura
    nombre = archivos(i).name;
    carpeta = archivos(i).folder;
    ruta_completa = fullfile(carpeta, nombre);
    
    nombres_archivos{i} = nombre;
    
    % --- LEER EL ARCHIVO ---
    fid = fopen(ruta_completa, 'r');
    
    % Escudo por si falla el fopen
    if fid == -1
        fprintf('Error grave: No se pudo abrir %s\n', ruta_completa);
        continue; % Saltamos al siguiente archivo para que no pete el programa entero
    end
    
    N = fscanf(fid, '%d', 1);                 
    coords = fscanf(fid, '%f', [2, N])';      
    fclose(fid); % Cerramos el archivo inmediatamente
    
    fprintf('======================================================\n');
    fprintf('Procesando: %s (%d ciudades) durante %d segundos...\n', nombre, N, tiempo_maximo(i));
    
    [best_tour, best_dist, log_distancias] = solve_tsp_sa(coords, tiempo_maximo(i));
    
    distancias_finales(i) = best_dist; 
    fprintf('-> ¡Completado! Mejor distancia: %.2f\n', best_dist);
    
    % --- DIBUJAR RESULTADOS ---
    figure('Name', sprintf('Resultados para %s', nombre), 'Color', 'w', 'Position',[100, 100, 1000, 450]);
    
    % Izquierda: Curva de Aprendizaje
    subplot(1, 2, 1);
    plot(log_distancias, 'r-', 'LineWidth', 3);
    xlabel('Iteraciones'); ylabel('Distancia Total');
    title(sprintf('Evolución SA - %s', nombre));
    grid on;
    
    % Derecha: Mapa de la Ruta
    subplot(1, 2, 2);
    plot(coords(:,1), coords(:,2), 'ko', 'MarkerFaceColor', 'b', 'MarkerSize', 10); hold on;
    
    ruta_coords = coords(best_tour, :);
    ruta_coords =[ruta_coords; ruta_coords(1, :)]; 
    plot(ruta_coords(:,1), ruta_coords(:,2), 'r-', 'LineWidth', 1.5);
    
    title(sprintf('Ruta Final - Coste: %.2f', best_dist));
    xlabel('Coord X'); ylabel('Coord Y');
    grid on;
    
    drawnow; 
end

%% 3. IMPRIMIR TABLA RESUMEN POR CONSOLA
fprintf('\n======================================================\n');
fprintf('                 RESUMEN DE EJECUCIÓN                 \n');
fprintf('======================================================\n');
for i = 1:length(archivos)
    fprintf(' Archivo: %-15s | Mejor Distancia: %.2f\n', nombres_archivos{i}, distancias_finales(i));
end
fprintf('======================================================\n');