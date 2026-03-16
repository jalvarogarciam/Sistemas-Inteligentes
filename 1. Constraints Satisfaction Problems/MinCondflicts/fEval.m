function e = fEval(x)
%% x: complete assignment
%% e: total number of diagonal conflicts
    N = length(x);
    e = 0;
    for i = 1:N-1
        for j = i+1:N
            % Check only diagonal constraint: |Qi - Qj| == |i - j| 
            if abs(x(i) - x(j)) == abs(i - j)
                e = e + 1;
            end
        end
    end
end