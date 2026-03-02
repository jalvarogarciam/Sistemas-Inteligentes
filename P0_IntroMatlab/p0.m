% =========================================================================
% Práctica 0 - Método Directo de la Rigidez (17/02/2026)
% Hecho por José Álvaro García Márquez 
% =========================================================================


clear; clc; close all;


%{
Implementa la matriz de rigidez elemental en ejes locales, dada su elasticidad "E",
inercia "I", área "A" y longitud "L" (ecuación 2 del pdf).
%}
function Klocal = Klocal(E,A,I,L)
    Klocal=[
       E*A/L,             0,            0, -E*A/L,          0,               0 ; 
           0,  12*E*I/(L^3),  6*E*I/(L^2),      0, -12*E*I/(L^3),   6*E*I/(L^2);
           0,   6*E*I/(L^2),      4*E*I/L,      0,  -6*E*I/(L^2),       2*E*I/L;
      -E*A/L,             0,            0,  E*A/L,             0,            0 ;
           0, -12*E*I/(L^3), -6*E*I/(L^2),      0,  12*E*I/(L^3),  -6*E*I/(L^2);
           0,   6*E*I/(L^2),      2*E*I/L,      0,  -6*E*I/(L^2),      4*E*I/L  
    ];
end





%{
Implementa la matriz de rotación completa, dado su ángulo "alpha" en
radianes (ecuaciones 3 y 4 del pdf)
%}
function LD = LD(alpha)

    %Ecuación 3, matriz lambda 3x3
    lambda = [
         cos(alpha), sin(alpha), 0;
        -sin(alpha), cos(alpha), 0;
                  0,          0, 1
    ];
    
    %Ecuación 4, matriz LD 6x6 por bloques
    LD = [
            lambda, zeros(3, 3);
        zeros(3,3),      lambda
    ];  
end



%{
Implementa la matriz de rigidez elemental en ejes globales, dada su elasticidad "E",
inercia "I", área "A", longitud "L" y "alpha" en radianes (ecuación 5 del pdf).
%}
function Kglobal = Kglobal(E, A, I, L, alpha)
    Kglobal = (LD(alpha))' * Klocal(E, A, I, L) * LD(alpha);
end




%{
Implementa la matriz global del sistema para los 3 nudos del pórtico (9x9), 
dada su elasticidad "E", inercia "I", área "A" y longitud "L" (ecuación 6 del pdf).
%}
function Ksys = Ksys(E, A, I, L)
    %{
    Se calcula la matriz Kglobal de cada barra, y dentro de ellas
    encontramos las matrices respectivas de nudo a nudo
    %}

    % Barra 1: Conecta Nodo 1 y Nodo 2
    Kglobal1 = Kglobal(E, A, I, L, 0); % El ángulo es 0, ya que está en horizontal
    % Barra 2: Conecta Nodo 2 y Nodo 3
    Kglobal2 = Kglobal(E, A, I, L, 3*pi/2); % El ángulo es 3pi/2 (270º), ya que está en vertical
    
    %{
    Se calculan las submatrices cuadradas 3x3 Keij, donde e es la barra, 
    y j e i son los correspondiente nudos
    %}
    K111 = Kglobal1(1:3, 1:3);
    K112 = Kglobal1(1:3, 4:6);
    K121 = Kglobal1(4:6, 1:3);
    K122 = Kglobal1(4:6, 4:6);
    K222 = Kglobal2(1:3, 1:3);
    K223 = Kglobal2(1:3, 4:6);
    K232 = Kglobal2(4:6, 1:3);
    K233 = Kglobal2(4:6, 4:6);
    
    % Se cacula la matriz global del sistema
    Ksys = [
              K111,      K112, zeros(3,3);
              K121, K122+K222,       K223;
        zeros(3,3),      K232,       K233
    ];
end









% =========================================================================
% MAIN
% =========================================================================


%% 1. DEFINICIÓN DE PARÁMETROS (Datos del enunciado)
A = 100;        % Área (mm^2)
I = 10000;      % Momento de inercia (mm^4)
L = 1000;       % Longitud de cada barra (mm)
E = 70000;      % Módulo de Young (N/mm^2 = MPa)
P = 1000;       % Carga exterior (N)


%% 2. Construcción de la matriz global del sistema para los 3 nudos del pórtico (9x9)
K_sys = Ksys(E, A, I, L);


%% 3. IMPOSICIÓN DE CONDICIONES DE CONTORNO
% Nudos 1 y 3 están empotrados (no se mueven). Por tanto, índices 1:3 y 7:9 son 0.
% Los grados de libertad libres (N) son los del Nodo 2 (índices 4:6).

% Matriz K_NN es el sub-bloque correspondiente al Nodo 2
K_NN = K_sys(4:6, 4:6);

% Vector de fuerzas en el Nodo 2. 
%F_N = [0; -P; 0]; % (x=0, y=-P (hacia abajo), giro=0)
% Con carga horizontal P
F_N = [P; -P; 0]; % (x=P, y=-P (hacia abajo), giro=0)

%% 4. ENSAMBLAJE Y RESOLUCIÓN DEL SISTEMA
% Resolvemos desplazamientos del Nodo 2 (Ecuación 8 simplificada, ya que u_D es cero)
u_N = inv(K_NN) * F_N; 


fprintf('--- Desplazamientos en el Nodo 2 --\n');
fprintf('u2: %f mm\n', u_N(1));
fprintf('v2: %f mm\n', u_N(2));
fprintf('θ2: %f rad\n\n', u_N(3));


%% 5. CÁLCULO DE REACCIONES (Nudos 1 y 3)
% Creamos el vector completo de desplazamientos (9x1)
U_total = zeros(9, 1);
U_total(4:6) = u_N; % Insertamos los que acabamos de calcular

% Multiplicamos para obtener todas las fuerzas/reacciones
Fuerzas_Totales = K_sys * U_total;

fprintf('--- Reacciones en el Nudo 1 --\n');
fprintf('Rx: %f N\n', Fuerzas_Totales(1));
fprintf('Ry: %f N\n', Fuerzas_Totales(2)); 
fprintf('Mz: %f N*mm\n\n', Fuerzas_Totales(3));

fprintf('--- Reacciones en el Nudo 3 --\n');
fprintf('Rx: %f N\n', Fuerzas_Totales(7));
fprintf('Ry: %f N\n', Fuerzas_Totales(8));
fprintf('Mz: %f N*mm\n\n', Fuerzas_Totales(9));




%% 6. GRÁFICO DE LA DEFORMADA (Factor = 500)
f_escala = 500;

% Coordenadas originales de los nudos (x, y)
X_orig = [0, L, L];
Y_orig = [L, L, 0];

% Coordenadas deformadas
X_def = X_orig + [U_total(1), U_total(4), U_total(7)] * f_escala;
Y_def = Y_orig + [U_total(2), U_total(5), U_total(8)] * f_escala;

figure('Name', 'Deformada del Pórtico', 'Color', 'w');
plot(X_orig, Y_orig, 'b-o', 'LineWidth', 2, 'MarkerFaceColor', 'b'); hold on;
plot(X_def, Y_def, 'r--o', 'LineWidth', 2, 'MarkerFaceColor', 'r');

legend('Estructura Original', ['Estructura Deformada (x' num2str(f_escala) ')']);
title('Deformada de la Estructura');
xlabel('X (mm)'); ylabel('Y (mm)');
axis equal; grid on;


% --- Calculamos un margen para que no salga la gráfica en los bordes ---
margen = 0.2 * L; 
% Buscamos los topes de nuestro dibujo (el mínimo y máximo de X e Y)
x_min = min([X_orig, X_def]);
x_max = max([X_orig, X_def]);
y_min = min([Y_orig, Y_def]);
y_max = max([Y_orig, Y_def]);
% Asignamos los nuevos límites a la gráfica añadiendo el margen
xlim([x_min - margen, x_max + margen]);
ylim([y_min - margen, y_max + margen]);
