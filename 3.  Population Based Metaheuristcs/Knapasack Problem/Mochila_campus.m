
%%% DATOS DEL  PROBLEMA
%%Datos Mochila de Clase
clear all
Pesos=[     150   100   400    180  500  1500  500    450   380   250   250   80  20  60   45  200];
Beneficios=[10    10     7     2     3     8     5     9     3     5     7     4   8  10   8    9];
cMax=2500;  %%Capacidad maxima permitida 2,5 kg
Minimo=90;  %%Beneficio minimo deseado


function [mejorFitness mejorIndividuo ] = MochilaAG( weigths, benefits)

    % poblacion inicial
    Nobj = length(weigths);  %% Número de objetos

    Nind = 8;  %% Número de individuos de la población (empezamos con uno bajo para controlar el proceso)
    pobActual = GenPob(Nind, Nobj);
    Fitness=EvalPob(pobActual,Pesos,Beneficios,cMax);
    
    MAXGEN = 3;  %% Número máximo de generaciones que se iterará
    mejorIndividuo=zeros(MAXGEN,Nobj);
    mejorFitness=zeros(MAXGEN,1);
    Pcross=0.9;
    Pmut=0.1;
    
    gen = 1;                     
    while (gen < MAXGEN)  %% Añadir condiciones de parada
        
        % Buscamos el mejor individuo para registrarlo
        [mejorFitness(gen), i] = max(Fitness);
        mejorIndividuo(gen,:) = pobActual(i,:);
        
        %% Seleccionar los mejores candidatos
        k=3;
        Parejas = Torneo(Fitness,k);

        Parejas = reshape(Parejas, Nind/2, 2);
        
        %% Cruzar
        pobCross=Cruce(pobActual, Parejas, Pcross);
        
        %% Mutar  
        pobMut = Mutacion(pobCross,Pmut);
        fitMut=EvalPob(pobMut,Pesos,Beneficios,cMax);
        
        %% Reemplazar
        [pobActual,Fitness]=Reemplazo(pobMut,pobActual,fitMut,Fitness);
        
        
        gen=gen+1;
    end

end
gen
max(mejorFitness)


function nenes = Cruce(pobActual, Parejas, Pcross)
    
    nenes = zeros(1,height(pobActual));

    for i = 1:height(Parejas)
        Papito = pobActual(Parejas(i,1));
        Mamita = pobActual(Parejas(i,2));

        % Realizar el cruce de los padres
        puntoCruce = randi([1, length(Papito)-1]); % Seleccionar un punto de cruce
        nenes(2*i-1, :) = [Papito(1:puntoCruce), Mamita(puntoCruce+1:end)]; % Crear el hijo
        nenes(2*i, :) = [Mamita(1:puntoCruce), Papito(puntoCruce+1:end)]; % Crear el otro hijo
    end

end

function parejas = Torneo(Fitness, k)

    Nind = length(Fitness);

    % Parejas contiene los índices de los mejores indivíduos de cada subconjunto de k indivíduos
    parejas = zeros(1,Nind);
    
    % Seleccionamos Nind grupos de k elementos diferentes para seleccionars los mejores
    for i = 1:Nind
        indices = randperm(N,k); % Seleccionamos k indices de indivíduos

        [~, indiceMejor] = max(Fitness(indices)); % Vemos cual corresponde al mejor indivíduo
        
        parejas(i) = indices(indiceMejor); % Lo guardamos
    end
    
end

