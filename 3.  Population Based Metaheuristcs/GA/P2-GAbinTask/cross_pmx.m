function childs = cross_pmx(py,f1,f2)
%% This function will be an Impostor code, PMXcrossover or OXcrossover
%% p: two parents to cross, a parent per row
%% f1 & f2: crossover points
%% offs: two offsprings, a child per row

%% Follow the example and complete with the apropriate instructions
p = [1 2 3 4 5 6 7  8 9;  
     4 5 2 1 8 7 6  9 3]  ;
n=length(p);
f1=round(0.25*n); 
f2=round(0.75*n);

n=length(p);
 
 childs = zeros(2,n);

 %% Copy 
 childs(1,f1:f2)=p(2,f1:f2);
 childs(2,f1:f2)=p(1,f1:f2);

 centers = [p(1,f1:f2);p(2,f1:f2)];

 lateralIdxs = find(childs(1,:)==0); 
 
px=1;
while px<=2
    py=mod(px,2)+1;

    for j=lateralIdxs

        % Seleccionamos un candidato que no esté en el centro del hijo
        cand = p(px,j);
        while ismember(cand, childs(px, :))

            candIdx = find(centers(px,:) == cand);
            cand = centers(py,candIdx);

        end
        
        childs(px,j) = cand;
    end
    px=px+1;
end



 childs
%end