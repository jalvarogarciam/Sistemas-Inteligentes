function [dominios, esConsistente] = AC3_NReinas(N, dominios)
% AC3_NREINAS  AC-3 para N-Reinas (variables=columnas, valores=filas)
% dominios: cell(1,N), dominios{i} = filas posibles para la columna i
% Si no se pasa, se inicializa a 1:N.

    if nargin < 2 || isempty(dominios)
        dominios = repmat({1:N}, 1, N);
    end

    variables = 1:N;

    % Aristas: todos los pares dirigidos (Xi,Xj), i!=j
    aristas = zeros(N*(N-1), 2);
    t = 0;
    for i = 1:N
        for j = 1:N
            if i ~= j
                t = t + 1;
                aristas(t,:) = [i j];
            end
        end
    end

    restricciones =  @RestriccionNReinas;  % compatible(i,vi,j,vj)?

    cola = aristas;

    while ~isempty(cola)
        Xi = cola(1,1);
        Xj = cola(1,2);
        cola(1,:) = [];

        [reducido, dominios] = ReducirDominio(Xi, Xj, dominios, restricciones);

        if isempty(dominios{Xi})
            esConsistente = false;
            return;
        end

        if reducido
            % Re-encolar (Xk, Xi) para todo k != Xi y k != Xj
            for k = variables
                if k ~= Xi && k ~= Xj
                    cola = [cola; k Xi];
                end
            end
        end
    end

    esConsistente = true;
end