function parents = rouletteWheel(fitnesses)
    pop_size=length(fitnesses);
    
    parents = zeros(pop_size,1);
   
    %% 1. construir la ruleta
    roulette = cumsum(fitnesses)/sum(fitnesses); %Suma acumuluda 

    %% 2. hacer funcionar la ruleta generando num aleatorios y seleccionando porción correspondiente
    for i = 1:pop_size

        % Generamos un número aleatorio
        randNum = rand(); 
        
        % Buscamos el índice del individuo al que corresponde
        parents(i) = find(roulette >= randNum, 1);
    end

end
