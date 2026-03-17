function PobActual =  GenPob(pop_size,queens_number)
    PobActual=zeros(pop_size, queens_number);
    for i=1:pop_size
        PobActual(i,:)=randperm(queens_number);
    end
end

