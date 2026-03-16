function [reducido, dominios] = ReducirDominio(Xi, Xj, dominios, restricciones)
% Elimina de D(Xi) los valores vi que NO tienen soporte en D(Xj)

    reducido = false;
    Di = dominios{Xi};
    Dj = dominios{Xj};

    if isempty(Di) || isempty(Dj)
        return;
    end

    keep = true(size(Di));

    for a = 1:numel(Di)
        vi = Di(a);
        soportado = false;

        for b = 1:numel(Dj)
            vj = Dj(b);
            if restricciones(Xi, vi, Xj, vj)
                soportado = true;
                break;
            end
        end

        if ~soportado
            keep(a) = false;
            reducido = true;
        end
    end

    if reducido
        dominios{Xi} = Di(keep);
    end
end