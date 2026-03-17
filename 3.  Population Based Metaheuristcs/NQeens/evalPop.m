function fitnesses = evalPob(pop)

[pop_size, ~] = size(pop);

fitnesses = zeros(pop_size,1);

for i=1:pop_size
    fitnesses(i) = evalTab(pop(i,:));
end

end

