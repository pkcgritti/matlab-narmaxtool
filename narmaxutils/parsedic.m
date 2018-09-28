function X = parsedic(Y, U, E, RD, basevector, N, p, nt, cfuncs)
    X = ones(N+1-p, nt);
    for i = 1:nt
        for j = 1:length( RD{i} )
            lag = str2double( RD{i}(j).lag );
            index = str2double( RD{i}(j).index );
            if isnan(index)
                index = 1;
            end
            switch RD{i}(j).term
                case 'y'
                    Xcolumn = Y(basevector-lag, index);
                case 'u'
                    Xcolumn = U(basevector-lag, index);
                case 'e'
                    Xcolumn = E(basevector-lag, index);
                otherwise
                    Xcolumn = ones(size(basevector));
            end
            if ~isempty ( RD{i}(j).function )
                fidx = cellfun ( @(x) strcmp( RD{i}(j).function, x{1} ), cfuncs);
                if ~any( fidx )
                    error('Function %s not founded in the function handlers', RD{i}(j).function);
                else
                    X(:, i) = X(:, i).*cfuncs{fidx}{2}(Xcolumn);
                end
            else
                X(:, i) = X(:, i).*Xcolumn;
            end
        end
    end
end
