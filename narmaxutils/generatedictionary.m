function [D, terms] = generatedictionary( ny, nu, ne, nl, inputs, offset, customregs)
%GENERATEDICTIONARY Summary of this function goes here
%   Detailed explanation goes here
    if nargin > 6
        terms = numberofterms(ny, nu*inputs + length(customregs), ne, nl);
    else
        terms = numberofterms(ny, nu*inputs, ne, nl);
    end
    tidx = 2;
    D = cell(terms, 1);
    
    D{1} = 'constant';
    
    % Put Y regs into dictionary
    for i = 1:ny
        D{tidx} = sprintf('y%d(k-%d)', 1, i);
        tidx = tidx + 1;
    end
    
    for i = 1:inputs
        for j = 1:nu
            D{tidx} = sprintf('u%d(k-%d)', i, j+offset(i));
            tidx = tidx + 1;
        end
    end
    
    for i = 1:ne
        D{tidx} = sprintf('e%d(k-%d)', 1, i);
        tidx = tidx + 1;
    end
    
    if nargin > 6
        if ~isempty(customregs)
            for i = 1:length(customregs)
                if ischar(customregs{i})
                    D{tidx} = customregs{i};
                else
                    error('Custom regressor must be specified as a string');
                end
                tidx = tidx + 1;
            end
        end
    end
    pivot = tidx - 1;
    
    for l = 2:nl
        basevector =  2*ones(l, 1);
        while basevector(1) <= pivot
            for i = 1:l
                D{tidx} = strcat(D{tidx}, D{basevector(i)});
            end
            basevector(l) = basevector(l) + 1;
            for i = l:-1:1
                if basevector(i) > pivot
                    if i > 1
                        basevector(i-1) = basevector(i-1) + 1;
                        for j = i:l
                            basevector(j) = basevector(j-1);
                        end
                    end
                end
            end
            tidx = tidx + 1;
        end
    end
end

