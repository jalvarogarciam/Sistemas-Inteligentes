clc
%% 1. Initializations
N = 8;                  % Number of Queens 
x = zeros(1, N);        % Initial assignment (empty board) 
currentCol = 1;         % Start searching from the first column 
dispTablero(x)
fprintf('Solving the %d-Queens problem using Backtracking...\n', N);

%% 2. Search execution
% The state is built by making a consistent assignment at each step
[solution, success] = backtracking(x, currentCol); 

%% 3. Output results
if success
    fprintf('Solution found for N=%d:\n', N); 
    disp(solution);
    
    % Optional: Visual verification of constraints
    dispTablero(solution); 
else
    fprintf('No solution exists for N=%d.\n', N);
end