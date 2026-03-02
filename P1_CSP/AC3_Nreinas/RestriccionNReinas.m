function ok = RestriccionNReinas(i, fi, j, fj)
% RestriccionesNReinas
    ok = (fi ~= fj) && (abs(fi - fj) ~= abs(i - j));
end