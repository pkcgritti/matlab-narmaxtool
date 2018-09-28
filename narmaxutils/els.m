function [theta, Yp, E, equation] = els(Y, U, ry, ru, re, delta)
%ELS Extended Least Squares Algorithm
% 
% Used to estimate models with noise terms. It is based on the classical
% Least Squares algorithm, but it iterates until the conditions given below
% are't satisfied.
%
% 1 . sum<m=1:n>|theta_m<s> - theta_m<s-1>|/|theta_m<s>| <= delta1
% 2 . sum<k=p:N>|r<s>(k) - r<s-1>(k)|^2 <= delta2
%
% ::INPUTS::
%
%   Y    : System output
%
%   U    : System inputs
%
%   order: [ry ru re] defining the order of the regressors. It can be used
%   to define a set of regressor to use.
%
%   delta: Define the stop criteria for equations 1 and 2
%
% ::OUTPUTS::
%   
%   theta   : Vector containing the models coefficients/
%   Yp      : The model 1 step ahead prediction/
%   E       : The model noise.
%   equation: The identified model in char format. (Only if nargout > 3)

%% Arguments verification
%   Check if Y is column vector. If not, transpose the matrix.
%   Check if order argument is a row vector of size 3.
%   Check if U is column vector(matrix). If not, transpose it.
%   Check if Y and U have the same number of samples.
    if ~isrow(Y) && ~iscolumn(Y)
        error('There is a problem with the system output `Y`');
    else   
        if isrow(Y)
            Y = Y';
        end
        
        N = length(Y);
        Usize = size(U);
        
        if Usize(1) < Usize(2)
            Usize = Usize(end:-1:1);
            U = U';
        end
        
        if Usize(1) ~= N
            error('The number of samples in Y and U must be the same');
        end
        inputs = Usize(2);
        clear Usize;
    end
%% Initialization
    
%   Max lag for each kind of output
    ny = max(ry);
    nu = max(ru);
    ne = max(re);
    
%   Constant defining the dataloss of the model
    p = max([ny nu ne]) + 1;
    
    basevector = (p:N)';
    T  = Y(basevector);
    if isscalar(ry)
        if ry == 0
            ry = [];
        end
    end
    if isempty(ry)
        RY = [];
    else
        RY = Y(repmat(basevector, 1, length(ry)) - repmat(ry, length(basevector), 1));
    end
    if isscalar(ru)
        if ru == 0
            ru = [];
        end
    end
    if isempty(ru)
        RU = [];
    else
        RU = U(repmat(basevector, 1, length(ru)) - repmat(ru, length(basevector), 1));
    end
    
    X = [RY RU];
    theta = pinv(X'*X)*X'*T;
    
    if isempty(re)
        Yp = [zeros(p-1, 1); X*theta];
        E  = Y - Yp;
        equation = 'null';
        return;
    end
    E = [zeros(p-1, 1); (T - X*theta)];
    RE = E(repmat(basevector, 1, length(re)) - repmat(re, length(basevector), 1));
    X = [RY RU RE];
    
    theta = pinv(X'*X)*X'*T;
    
%% Main loop

    for i = 1:10
        E = [zeros(p-1, 1); (T-X*theta)];
        RE = E(repmat(basevector, 1, length(re)) - repmat(re, length(basevector), 1));
        X = [RY RU RE];
        theta = pinv(X'*X)*X'*T;
    end

    narx = length(ry) + length(ru);
    Yp = [zeros(p-1, 1); X(:,1:narx)*theta(1:narx)];
    E  = Y - Yp;
    equation = 'null';
end