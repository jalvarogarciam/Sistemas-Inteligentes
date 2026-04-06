clc; clear;

% 1. DATOS DE LA ITERACIÓN 0
S0 =[22.2135, 12.0427;
      26.1881, 19.7741;
      20.9158, 10.7442;
      22.7604, 12.3982;
      21.8738, 10.3611;
      23.7841, 12.8367;
      17.6520,  9.2159;
      25.5818,  8.4024;
      34.4546,  9.6090;
      24.6263, 10.4131];

feval0 =[1.0643; 9.7224; 1.1140; 1.5916; 0.6512; 2.5606; 4.6998; 4.4246; 12.5320; 2.6911];

% Valores aleatorios dados en la tabla k=1
rg =[0.3402; 0.1398; 0.8329; 0.9399; 0.5252; 0.9216; 0.0623; 0.3040; 0.5987; 0.1252];

% 2. CONSTANTES
cg = 0.8;

% Identificamos al LÍDER GLOBAL (gbest) en k=0
[~, best_idx] = max(feval0);
gbest_pos = S0(best_idx, :);

% 3. CÁLCULOS PARA K=1
V1 = zeros(10, 2);
S1 = zeros(10, 2);
feval1 = zeros(10, 1);
pbest1_pos = zeros(10, 2);

fprintf('--- RESULTADOS PARA LA TABLA K=1 ---\n\n');
fprintf('P  | V1 (X, Y)             | S1 (X, Y)             | feval   | pbest (X, Y)\n');
fprintf('----------------------------------------------------------------------------------\n');

for i = 1:10
    % A. Calcular Velocidad (El término local es 0 en k=1)
    V1(i, :) = cg * rg(i) * (gbest_pos - S0(i, :));
    
    % B. Calcular Nueva Posición
    S1(i, :) = S0(i, :) + V1(i, :);
    
    % C. Llamar a la función evaluadora de la profe (pso_eval.p)
    % Nota: Si la función acepta el vector entero, usa pso_eval(S1(i,:)).
    % Si pide X e Y separados, usa pso_eval(S1(i,1), S1(i,2)). Modifícalo si te da error.
    feval1(i) = pso_eval(S1(i, :)); 
    
    % D. Actualizar el Pbest (Mejor personal histórico)
    if feval1(i) > feval0(i)
        pbest1_pos(i, :) = S1(i, :); % Ha mejorado, el pbest es la nueva posición
    else
        pbest1_pos(i, :) = S0(i, :); % Ha empeorado, el pbest se queda en la antigua
    end
    
    % Imprimimos la fila de la tabla
    fprintf('%2d | (%7.4f, %7.4f) | (%7.4f, %7.4f) | %7.4f | (%7.4f, %7.4f)\n', ...
        i, V1(i,1), V1(i,2), S1(i,1), S1(i,2), feval1(i), pbest1_pos(i,1), pbest1_pos(i,2));
end

% 4. NUEVO LÍDER PARA K=2
% Ahora buscaríamos el nuevo gbest para la siguiente iteración
[max_feval1, nuevo_lider_idx] = max(feval1);
if max_feval1 > feval0(best_idx)
    fprintf('\n¡Tenemos un NUEVO gbest para k=2! Es la partícula %d.\n', nuevo_lider_idx);
else
    fprintf('\nNinguna partícula ha superado el gbest. La partícula %d sigue siendo la líder.\n', best_idx);
end