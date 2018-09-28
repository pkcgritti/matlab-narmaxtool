function [ indexes, err, Q, A, G] = ols(y, X, terms, D, QL, AL, GL, EL)
%OLS Summary of this function goes here
%   Detailed explanation goes here
    A = zeros(terms);
    indexes = zeros(terms, 1);
    err = zeros(terms, 1);
    [N, M] = size(X);
    sigma = y'*y;
    Q = zeros(N, terms);
    G = zeros(terms, 1);
    KE = 0;
    
    if M < terms
        error('Insufficient regressors');
    end
    
    if nargin > 3
        iters = 13;
        sters = 35;
        errrs = 20;
        fprintf('\t%-*s%-*s%-*s%-*s\n', iters, 'Iteration', sters, 'Selected Terms', errrs, 'err', errrs, 'sumerr');
    end
    s = 1;
    for m = 1:M
        q = X(:, m);
        if nargin > 4
            for r = 1:size(QL,2)
                q = q - X(:,m)'*QL(:,r)/( QL(:,r)'*QL(:,r) )*QL(:, r);
            end
            KE = EL;
        end
        g = (y'*q)/(q'*q);
        ERR = g^2 * (q'*q) / sigma;
        if ERR > err(s)
            indexes(s) = m;
            err(s) = ERR;
            G(s) = g;
        end
    end
    if nargin > 3
        fprintf('\t%-*d%-*s%-*.4f%-*.4f\n', iters, s, sters, D{indexes(s)}, errrs, err(s), errrs, KE + sum(err(1:s)));
    end
    s = 2;
    Q(:,1) = X(:, indexes(1));
    A(1,1) = 1;
    
    while s <= terms
        for m = 1:M
            if all( m ~= indexes )
                q = X(:, m);
                for r = 1:s-1
                    q = q - X(:, m)'*Q(:,r)/(Q(:,r)'*Q(:,r))*Q(:,r);
                end
                g = (y'*q)/(q'*q);
                ERR = g^2 * (q'*q) / sigma;
                if ERR > err(s)
                    indexes(s) = m;
                    err(s) = ERR;
                    qs = q;
                    G(s) = g;
                end
            end
        end
        
        for r = 1:s-1
            A(r,s) = (Q(:,r)'*X(:,indexes(s))) / (Q(:,r)'*Q(:,r));
        end
        A(s,s) = 1;
        Q(:,s) = qs;
        if nargin > 3
            fprintf('\t%-*d%-*s%-*.4f%-*.4f\n', iters, s, sters, D{indexes(s)}, errrs, err(s), errrs, KE + sum(err(1:s)));
        end
        s = s + 1;
    end


end

