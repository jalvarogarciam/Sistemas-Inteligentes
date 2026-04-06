clc; clear; close all;

%% 1. RASTRIGIN (Dominio: [-5.12, 5.12])

% Creamos una malla de 200x200 puntos
[x, y] = meshgrid(linspace(-5.12, 5.12, 1000));

% Calculamos Z (f(x,y)) para Rastrigin en d=2
z = 10*2 + (x.^2 - 10*cos(2*pi*x)) + (y.^2 - 10*cos(2*pi*y));

figure('Name', 'Rastrigin Function', 'Position',[100, 100, 1000, 450], 'Color', 'w');
subplot(1,2,1);
surf(x, y, z, 'EdgeColor', 'none'); 
colormap('turbo'); colorbar;
title('Rastrigin - 3D Surface'); xlabel('x_1'); ylabel('x_2'); zlabel('f(x)');

subplot(1,2,2);
contour(x, y, z, 50); % 50 líneas de nivel
colormap('turbo'); colorbar;
title('Rastrigin - Contour Plot'); xlabel('x_1'); ylabel('x_2'); axis square;

%% 2. ACKLEY (Dominio:[-32.768, 32.768])
[x, y] = meshgrid(linspace(-32.768, 32.768, 1000));

% Calculamos Z (f(x,y)) para Ackley en d=2
term1 = -20 * exp(-0.2 * sqrt((x.^2 + y.^2) / 2));
term2 = -exp((cos(2*pi*x) + cos(2*pi*y)) / 2);
z = term1 + term2 + 20 + exp(1);

figure('Name', 'Ackley Function', 'Position',[150, 150, 1000, 450], 'Color', 'w');
subplot(1,2,1);
surf(x, y, z, 'EdgeColor', 'none'); 
colormap('parula'); colorbar;
title('Ackley - 3D Surface'); xlabel('x_1'); ylabel('x_2'); zlabel('f(x)');

subplot(1,2,2);
contour(x, y, z, 50);
colormap('parula'); colorbar;
title('Ackley - Contour Plot'); xlabel('x_1'); ylabel('x_2'); axis square;