function [ narmaxmodel, estIdxs, results, theta ] = frols(narmaxmodel, order, nterms, iterations)
%FROLS Forward regression with Orthogonal Least Squares algorithm
%   The frols algorithm implements a structure detections algorithm for
%   systems. It uses the error reduction ratio (ERR) to select one
%   regressor at time, and returns the n best `nterms` as a model structure
%   result.
%
%   <Input variables>
%       narmaxmodel
%           An narmax object containing the dataset
%       order [ny, nu, ne, nl]
%           Specifiec the maximum lags to use from each signal (this is,
%           from system output, system input(s)). The last term `nl`
%           selects the maximum power of the regressors.
%       nterms
%           Maximum number of regressors to fit and rank. It is a vector
%           with 2 elements. The first one refers to the maximum number of
%           non-error regressors, and the seconds one to the number of
%           error regressors.
%       uoffset
%           If specified, applies an offset in U first regressor, i.e., u[k-uoffset-1]
%       customterms
%           A cell array of strings specifying custom regressors. If it
%           uses external functions, those must be specified in
%           customfunctions.
%       customfunctions
%           A cell array containing a tuple of cell registers. The first
%           field must contain the function name alias, and the second a
%           function handler.
%       
%   <Output variables>
%       narmaxmodel
%           Return the fitted model
%       results
%           Returns a table with the algorithm results.

    ny = order(1);
    nu = order(2);
    ne = order(3);
    nl = order(4);
    offset = narmaxmodel.Data.TransportDelay;
    cterms = narmaxmodel.CustomTerms;
    cfuncs = narmaxmodel.CustomFunctions;
    results = [];
    
    %% Pattern to parse the dictionary
    pattern = '(?<function>[a-zA-Z0-9]*)\(?(?<term>[yue])(?<index>[0-9]*)\(k-(?<lag>[0-9]+)||(?<term>constant)';

    %% Load datasets
    fprintf('Loading datasets ');
 
    Y = narmaxmodel.Data.SystemOutput;
    U = narmaxmodel.Data.SystemInputs;
    N = length(Y);
    fprintf('. . . OK\n');
    
    %% Create dictionary
    fprintf('Creating dictionary ');
    [D, nt] = generatedictionary(ny, nu, ne ,nl, size(U,2), offset, cterms);   % Dictionary
    RD = cellfun(@(x) regexp(x, pattern, 'names'), D, 'UniformOutput', false); % Parsed Dictionary
    errorIdxs = cellfun(@(x) any( arrayfun (@(y) strcmp(y.term, 'e'),x)),RD);  % Parsed error idx
    
    %% Move error regressors to another dicionary
    DE = D(errorIdxs);
    RDE = RD(errorIdxs);
    D(errorIdxs) = [];
    RD(errorIdxs) = [];
    nte = length(DE);
    nt = nt - nte;
    
    %% Allocate spaces
    p = max(cellfun(@(x)max(arrayfun(@(y)max(str2double(y.lag)),x)),RD)) + 1;  % Get dataloss
    
    Xe = ones(N + 1 - p, nte);                                                 % Error regressors
    fprintf('. . . OK\n');
    
    %% Create regressor matrix and select proper examples
    fprintf('Creating regressor matrix ');
    basevector = (p:length(Y))';
    T = Y(basevector, :);
    %TU = U(basevector, :);
    fprintf('. . . OK\n');
    
    X = parsedic(Y, U, [], RD, basevector, N, p, nt, cfuncs);
    
%     if size(TU,2) > 1
%         [includeIdxs, ~] = find( [zeros(1,size(TU,2)); diff(TU)] ~= 0 );
%     else
%         includeIdxs = find( [0; diff(TU)] ~= 0 );
%     end
%     if narmaxmodel.EstimationConfigurations.MinDiff ~= 0
%         usefullIdxs = (find ( ( diff (T).^2 ) > narmaxmodel.EstimationConfigurations.MinDiff ))';
%     else
%         usefullIdxs = 1:length(T);
%     end
%     
%     for j = 1:length(includeIdxs)
%         if ~any( usefullIdxs == includeIdxs(j) )
%             usefullIdxs = [usefullIdxs includeIdxs(j)];
%         end
%     end
%     usefullIdxs = sort(usefullIdxs);
    usefullIdxs = 1:length(T);
    
    estL = narmaxmodel.EstimationConfigurations.MaxLength;
    NB   = length(usefullIdxs);
    if estL > NB
        estL = NB;
    end
  
    if narmaxmodel.EstimationConfigurations.Randomly
        rIdxs = randperm(NB);
        estIdxs = usefullIdxs(rIdxs(1:estL));
    else
        estIdxs = usefullIdxs(1:estL);
    end
    
    %% Main loop and control variables initialization
    
    fprintf('Initializing OLS\n\n');
    [indexes, err, QL, AL, GL] = ols(T(estIdxs), X(estIdxs,:), nterms(1), D);
    theta = AL\GL;
    EL = sum(err);
    [indexes, srtidx] = sort(indexes);
    err = err(srtidx);
    theta = theta(srtidx);
    fprintf('\nDone ...\n\n');
    Terms = D(indexes);
    ERR   = err;
    
    R = T-X(:,indexes)*theta;
    E = [zeros(p-1,1); R];
    ertheta = [];
    ETerms = [];
    ererr = [];
    if ne ~= 0 && nterms(2) ~= 0
        
        lambda   = 1;
        P        = 10e5*eye(length(theta) + nterms(2));
        ThetaRLS = [theta;zeros(nterms(2),1)];
        
        if iterations > length(T)
            iterations = length(T);
        end
        
        for iter = 1:iterations
            
            Xe = parsedic(Y, U, E, RDE, basevector, N, p, nte, cfuncs);
           
            if iter == 1
                fprintf('Initializing OLS for errors\n\n');
                [erindexes, ererr] = ols(R(estIdxs), Xe(estIdxs,:), nterms(2), DE, QL, AL, GL, EL);
                fprintf('\nDone ...\n\n');
                [erindexes, srtidx] = sort(erindexes);
                ererr = ererr(srtidx);
                ETerms = DE(erindexes);
            end
            
            ATheta = ThetaRLS;
            AE = E;
            
%             % Abordagem recursiva
%             Xk = [X(iter, indexes) Xe(iter, erindexes)];
%             K = P*Xk'/(lambda + Xk*P*Xk');
%             P = 1/lambda*(P - K*Xk*P);
%             ThetaRLS = ThetaRLS + K*(T(iter) - Xk*ThetaRLS);
%             R = T - X(:,indexes)*ThetaRLS(1:length(theta));
%             E = [zeros(p-1,1); R];
%             if ~mod(iter, 10)
%                 fprintf('Estimating the residuals (%d iteration)\n', iter);
%             end
     
            % Em batela
            Xk = [X(estIdxs, indexes) Xe(estIdxs, erindexes)];
            ThetaRLS = pinv(Xk)*T(estIdxs);
            R = T - [X(:, indexes) Xe(:, erindexes)]*ThetaRLS;
            E = [zeros(p-1,1); R];
            
            SE = var(E-AE);
            ST = var(ATheta - ThetaRLS);
            fprintf('Sum of Diff Squared: Error = %.4e; Theta = %.4e\n', SE, ST);
            if SE < 1e-16 && ST < 1e-16
                break           
            end
        end
        Xe = parsedic(Y, U, E, RDE, basevector, N, p, nte, cfuncs);
        R = T-[X(:,indexes) Xe(:,erindexes)]*ThetaRLS;
        E = [zeros(p-1,1); R];
        theta = ThetaRLS(1:length(theta));
        ertheta = ThetaRLS(length(theta)+1:end);
    end
    
    
    narmaxmodel.ProcessTerms = Terms;
    narmaxmodel.NoiseRelatedTerms = ETerms;
    narmaxmodel.ProcessTheta = theta;
    narmaxmodel.NoiseTheta = ertheta;
    
    results.Terms  = Terms;
    results.ERR    = ERR;
    results.ETerms = ETerms;
    results.ERERR  = ererr;
    results.E      = E;
    results.U      = U;
    %for iter = 1:iterations 
    %    for t = 1:nterms(2) % Select error regressors (identify error)
    %    end
    %end
    %rmpath('narmaxutils/');
end

