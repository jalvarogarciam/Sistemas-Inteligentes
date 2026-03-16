clc
%% 1. Initializations
N = 50;                  % Number of Queens 
x = zeros(1, N);        % Initial assignment (empty board) 
dispTablero(x)
fprintf('Solving the %d-Queens problem using LocalSearch...\n', N);

%% 2. Search execution
% The state is built by making a consistent assignment at each step
solution = simulatedAnnealing(N); 

%% 3. Output results
if fCost(solution) == 0
    fprintf('Solution found for N=%d:\n', N); 
    disp(solution);
    
    % Optional: Visual verification of constraints
    dispTablero(solution); 
else
    fprintf('No solution exists for N=%d.\n', N);
end