function offs=crossover_ox(p,f1,f2)
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

offs = zeros(2,n);
offs(1,f1:f2)=p(1,f1:f2);
offs(2,f1:f2)=p(2,f1:f2);
 

 



 p1=1;
 while p1<=2
     p2=mod(p1,2)+1;
     j=f2+1;  
     k=f2+1;  
     while j~=f1
        %% conflicts checking
        offs(p1,j)=p(p2,k);
        k=mod(k,n)+1;
        j=mod(j,n)+1;
     end
     p1=p1+1;
 end
 
 offs
 