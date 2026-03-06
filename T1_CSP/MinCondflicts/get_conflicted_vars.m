function list = get_conflicted_vars(x)
% Devuelve índices de reinas con conflictos diagonales
    N = numel(x);
    inConflict = zeros(1, N);

    for i = 1:N-1
        for j = i+1:N
            if abs(x(i) - x(j)) == abs(i - j)
                inConflict(i) = inConflict(i) + 1;
                inConflict(j) = inConflict(j) + 1;
            end
        end
    end
    list = find(inConflict);
end