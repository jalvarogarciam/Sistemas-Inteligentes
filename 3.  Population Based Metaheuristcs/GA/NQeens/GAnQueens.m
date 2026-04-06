function [ best_fit, best_sol ] = GAnQueens( n ,...
                                          pop_size, max_gens, pCross, pMut)
%GAnReinas Resuelve el problema de las n-reinas con un algoritmo genético
%  Necesita:
%    nReinas: número de reinas
%    NIND: número de individuos de cada generación
%    MAXGEN: número máximo de generaciones
%    pCross: probabilidad de Cruce
%    pMut: probabilidad de Mutación
%
%  Devuelve:
%    mejorFitness: vector con el mejor fitness de cada generación
%    mejorIndividuo: matriz que contiene la representación del mejor
%                    individuo de cada generación
%  Representación:
%    Se utiliza un vector con tantas posiciones como columnas tiene el
%    tablero. Cada valor del vector indica la fila en la que se encuentra
%    la reina en esa columna. NO se permiten valores repetidos en el vector
%

ValorObjetivo = sum(1:n-1);
fprintf('ValorObjetivo: %d\n',ValorObjetivo);

% poblacion inicial
pop = GenPob(pop_size,n);

best_fit = zeros(max_gens,1);
best_sol = zeros(max_gens,n);

gen = 1;                     
while (gen < max_gens) % RESTO DE CONDICIONES


    %% 1. EVALUACIÓN
    fitnesses = evalPop(pop);
    % Guardamos el mejor indivíduo de cada generación
    [best_fit(gen),bestIdx] = max(fitnesses);
    best_sol(gen,:) = pop(bestIdx,:);
    
    %% 2. SELECCIÓN
    parents = rouleteWheel(fitnesses);
    
    %% 3. CRUCE
    %% PMX y OX
    pobCross=Cruce(pop,Parejas,Pcross);
    
    %% MUTACIÓN
    %% Inversión Subcadena, y algún otro más
    pobMut = Mutacion(pobCross,Pmut);
    fitMut=evalPob(pobMut,Pesos,Beneficios,cMax);
    
    %% REEMPLAZO
    %% Libre elección
    [pop,fitnesses]=Reemplazo(pobMut,pop,fitMut,fitnesses);
        
    gen=gen+1;
end
gen
max(best_fit)    
    