function M = numberofterms(ny, nu, ne, nl, nc)
    n = ny + nu + ne;
    if nargin > 4
        n = n + nc;
    end
    
    M = 1;
    for l = 1:nl
        M = M*(n+l);
    end
    
    M = M/factorial(nl);
end