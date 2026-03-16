function p = penalization(x)
    p = 0;

    if x(1)+x(2)-x(3)+x(4)+x(5) >= 1
        p = p + 70;
    end
    if x(1) + x(2) - x(4) + 2*x(5) >= 2
        p = p + 70;
    end
    if -x(2) + x(4) + x(5) <= 1
        p = p + 100;
    end
    if x(2) + x(3) + x(5) <= 2
        p = p + 100;
    end
end



f = @(x) 20*x(1) + 25*x(2) - 30*x(3) - 45*x(4) + 40*x(5)
c = @(c) f(x) + penalization(x)

c([0,0,1,0,1])