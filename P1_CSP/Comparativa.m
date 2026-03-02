clc;

%% Comparativa_NReinas.m

N = 4:2:16; % Probar tableros de 4x4 hasta 20x20
tiempos = zeros(4, length(N));
%% Prueba rápida (1 vuelta con cada estrategia y N)
for i = 1:length(N)
    n = N(i);
    
   
    % 1. Backtracking Simple
    x = zeros(1, n);        % Initial assignment (empty board) 
    tic; 
    backtracking(x, 1);
    tiempos(1,i) = toc;
    
    % 2. Backtracking + AC3 
    tic; 
    x = zeros(1, n);        % Initial assignment (empty board)
    backtracking_AC3(x,1)
    tiempos(2,i) = toc;
    
    % 3. Busqueda Local
    tic
    localSearch(n);
    tiempos(3,i)=toc;
    
    % % 4. Mínimos Conflictos
    x = randperm(n);
    tic; 
    min_conflicts_search(x, 10000)
    tiempos(4,i) = toc;

end
disp(tiempos)
plot(N, tiempos, '-o', 'LineWidth', 2);
legend('Backtracking', 'BT + AC3', 'Local', 'Min-Conflicts');
xlabel('Número de Reinas (N)'); 
ylabel('Tiempo (s)');
title('Comparativa de Algoritmos: N-Reinas');
grid on;