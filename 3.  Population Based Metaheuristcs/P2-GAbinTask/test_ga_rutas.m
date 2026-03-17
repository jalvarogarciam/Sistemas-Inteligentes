clc; clear; close all;
fclose('all');

%% =========================================================
%  run_ga_meopt.m
%  Ejecuta solve_bin_ga sobre todos los archivos de la
%  carpeta instances/ y exporta gráficas de resultados.
%  Time limit fijo: 15 segundos por instancia.
% =========================================================

%% 1. BUSCAR TODOS LOS ARCHIVOS DE PRUEBA
carpeta_resultados = 'resultados_ga';
if ~exist(carpeta_resultados, 'dir'), mkdir(carpeta_resultados); end

archivos = dir('instances/meopt_*.txt');

if isempty(archivos)
    error('No se encontraron archivos meopt_*.txt en instances/. Comprueba la ruta.');
end

fprintf('Se han detectado %d archivos de prueba.\n\n', length(archivos));

nombres_archivos  = {};
costes_finales    = zeros(1, length(archivos));
num_gens_total    = zeros(1, length(archivos));
todos_los_logs    = {};
time_limit        = 15;   % segundos fijo para todas las instancias

%% 2. ESTILO PARA EXPORTAR PNG LEGIBLE
    function fijar_estilo(fig)
        fig.Color = [1 1 1];
        axs = findall(fig, 'Type', 'axes');
        for k = 1:length(axs)
            ax = axs(k);
            ax.Color        = [1    1    1   ];
            ax.XColor       = [0    0    0   ];
            ax.YColor       = [0    0    0   ];
            ax.GridColor    = [0.15 0.15 0.15];
            ax.Title.Color  = [0    0    0   ];
            ax.XLabel.Color = [0    0    0   ];
            ax.YLabel.Color = [0    0    0   ];
            ax.FontSize     = 11;
            ax.FontName     = 'Helvetica';
        end
    end

%% 3. BUCLE PRINCIPAL
for i = 1:length(archivos)
    nombre        = archivos(i).name;
    carpeta       = archivos(i).folder;
    ruta_completa = fullfile(carpeta, nombre);
    nombres_archivos{i} = nombre;

    % --- Leer instancia ---
    fid = fopen(ruta_completa, 'r');
    if fid == -1
        fprintf('[ERROR] No se pudo abrir %s\n', ruta_completa);
        continue;
    end

    % Línea 1: n_segmentos (agrupados) y n_datos (puntos reales del trayecto)
    n_seg   = fscanf(fid, '%d', 1);   % e.g. 7  — número de segmentos agrupados
    n_datos = fscanf(fid, '%d', 1);   % e.g. 568 — número de puntos de datos

    % Líneas 2-7: vectores de longitud n_datos
    dist   = fscanf(fid, '%f', n_datos)';   % distancias   [m]
    slope  = fscanf(fid, '%f', n_datos)';   % pendientes   [rad]
    speed  = fscanf(fid, '%f', n_datos)';   % velocidades  [m/s]
    time_s = fscanf(fid, '%f', n_datos)';   % tiempos      [s]
    accel  = fscanf(fid, '%f', n_datos)';   % aceleraciones [m/s²]
    bin0   = fscanf(fid, '%f', n_datos)';   % solución inicial binaria (ignorada)

    % Línea 8: parámetros del vehículo (20 valores útiles + ceros de relleno)
    params = fscanf(fid, '%f', 20)';

    fclose(fid);

    % Usar n_datos como dimensión real del problema
    n = n_datos;

    fprintf('======================================================\n');
    fprintf('Procesando : %s  (%d puntos, %d segmentos)  —  %d s\n', ...
            nombre, n, n_seg, time_limit);

    % --- Llamada al solver GA ---
    [best_sol, best_cost, log_costes, num_gens] = ...
        solve_bin_ga(dist, slope, speed, time_s, accel, bin0, params, time_limit);

    costes_finales(i)  = best_cost;
    num_gens_total(i)  = num_gens;
    todos_los_logs{i}  = log_costes;

    n_sel = sum(best_sol);
    fprintf('-> Completado | Coste: %.4f kgCO2 | Iter: %d | Seg. EV: %d/%d\n', ...
            best_cost, num_gens, n_sel, n);

    % --- Calcular costes por segmento para la gráfica ---
    Costes = zeros(n, 1);
    for jj = 1:n
        Costes(jj) = segment_kgCO2(dist(jj), slope(jj), speed(jj), ...
                                    time_s(jj), accel(jj), params);
    end

    % -------------------------------------------------------
    %  FIGURA POR INSTANCIA: convergencia + perfil de solución
    % -------------------------------------------------------
    fig = figure('Color','w','Position',[100 100 1100 430],'Visible','off');

    % -- Subplot 1: Convergencia --
    subplot(1,2,1);
    plot(log_costes, 'b-', 'LineWidth', 1.8);
    xlabel('Iteración');
    ylabel('Mejor coste (kgCO2)');
    title(sprintf('Convergencia GA — %s', strrep(nombre,'_','\_')));
    grid on;

    % -- Subplot 2: Perfil de segmentos seleccionados vs descartados --
    subplot(1,2,2);
    distAcum = [0, cumsum(dist/1000)];   % km acumulados
    hold on;

    for jj = 1:n
        if best_sol(jj) == 1
            color_seg = [0.2 0.6 1.0];   % azul = eléctrico
        else
            color_seg = [0.9 0.3 0.3];   % rojo = ICE
        end
        fill([distAcum(jj) distAcum(jj+1) distAcum(jj+1) distAcum(jj)], ...
             [0 0 Costes(jj) Costes(jj)], color_seg, ...
             'EdgeColor','none', 'FaceAlpha', 0.7);
    end

    xlabel('Distancia acumulada (km)');
    ylabel('Coste segmento (kgCO2)');
    title(sprintf('Modos de conducción — Coste total: %.4f kgCO2', best_cost));
    h1 = fill(nan, nan, [0.2 0.6 1.0], 'EdgeColor','none');
    h2 = fill(nan, nan, [0.9 0.3 0.3], 'EdgeColor','none');
    legend([h1 h2], {'Eléctrico (xi=1)','ICE (xi=0)'}, 'Location','best');
    grid on;

    fijar_estilo(fig);
    nombre_png = fullfile(carpeta_resultados, strrep(nombre, '.txt', '.png'));
    exportgraphics(fig, nombre_png, 'Resolution', 150, 'BackgroundColor','white');
    close(fig);
end

%% 4. RESUMEN EN CONSOLA
fprintf('\n======================================================\n');
fprintf('              RESUMEN ALGORITMO GENÉTICO              \n');
fprintf('======================================================\n');
fprintf('%-35s  %12s  %8s\n','Archivo','Coste (kgCO2)','Iter.');
fprintf('%s\n', repmat('-',1,60));
for i = 1:length(archivos)
    fprintf('%-35s  %12.4f  %8d\n', ...
        nombres_archivos{i}, costes_finales(i), num_gens_total(i));
end
fprintf('======================================================\n');

%% 5. GRÁFICA COMPARATIVA — todas las instancias
if length(archivos) > 1
    fig = figure('Color','w','Position',[100 100 850 450],'Visible','off');
    hold on;
    colores  = lines(length(archivos));
    leyendas = {};
    for i = 1:length(archivos)
        plot(todos_los_logs{i}, 'Color', colores(i,:), 'LineWidth', 1.6);
        leyendas{end+1} = strrep(nombres_archivos{i}, '_', '\_');
    end
    xlabel('Iteración');
    ylabel('Mejor coste (kgCO2)');
    title('Convergencia comparativa — Algoritmo Genético');
    legend(leyendas, 'Location','northeast','FontSize',9);
    grid on;
    fijar_estilo(fig);
    exportgraphics(fig, fullfile(carpeta_resultados,'convergencia_comparativa.png'), ...
                   'Resolution',150,'BackgroundColor','white');
    close(fig);
    fprintf('Gráfica comparativa guardada en %s/convergencia_comparativa.png\n', carpeta_resultados);
end

%% 6. GRÁFICA DE BARRAS — coste final por instancia
fig = figure('Color','w','Position',[100 100 700 400],'Visible','off');
nombres_cortos = cellfun(@(x) strrep(strrep(x,'meopt_',''),'.txt',''), ...
                          nombres_archivos, 'UniformOutput', false);
bar(costes_finales, 'FaceColor', [0.2 0.5 0.8], 'EdgeColor','none');
set(gca, 'XTickLabel', nombres_cortos, 'XTick', 1:length(archivos));
xtickangle(25);
ylabel('Coste final (kgCO2)');
title('Coste final por instancia — Algoritmo Genético');
grid on; box off;
fijar_estilo(fig);
exportgraphics(fig, fullfile(carpeta_resultados,'barras_costes.png'), ...
               'Resolution',150,'BackgroundColor','white');
close(fig);
fprintf('Gráfica de barras guardada en %s/barras_costes.png\n', carpeta_resultados);

%% 7. INSTANCIA MÁS COSTOSA — convergencia individual
[~, idx_harder] = max(costes_finales);
fig = figure('Color','w','Position',[100 100 700 380],'Visible','off');
plot(todos_los_logs{idx_harder}, 'r-', 'LineWidth', 2);
xlabel('Iteración'); ylabel('Mejor coste (kgCO2)');
title(sprintf('Convergencia — Instancia más costosa: %s', ...
      strrep(nombres_archivos{idx_harder},'_','\_')));
grid on;
fijar_estilo(fig);
exportgraphics(fig, fullfile(carpeta_resultados,'convergencia_harder.png'), ...
               'Resolution',150,'BackgroundColor','white');
close(fig);
fprintf('Convergencia de la instancia más costosa guardada en %s/convergencia_harder.png\n\n', ...
        carpeta_resultados);