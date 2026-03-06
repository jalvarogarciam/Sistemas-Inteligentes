clear; clc;

N = 6;

fprintf('===== PRUEBA AC3 N-Reinas (N=%d) =====\n\n', N);

%% 1) Inicializar dominios completos
dom = repmat({1:N}, 1, N);

%% 2) Fijar una reina (ejemplo)
dom{1} = 2;

%% 3) Ejecutar AC3
[dominios, consistente] = AC3_NReinas(N, dom)
