function [ model ] = narmax( Y, U, varargin )
%NARMAX Creates a NARMAX Model
%   Since Matlab class support is not yet fully of resources, this
%   implementation handles the object as a structure.

%% Properties
    model.Identifier = [];        % Identifier
    model.ProcessTerms = [];      % All the process terms.
    model.NoiseRelatedTerms = []; % All the noise related terms.
    model.CustomTerms     = [];   % Custom terms defined by the user.
    model.ProcessTheta = []; % Theta for process parameters.
    model.NoiseTheta   = []; % Theta for noise related process.
    model.CustomFunctions = [];   % Custom functions {'Name', @funcHandler}
    model.Data = [];              % Handle the dataset
    model.EstimationConfigurations.MaxLength = 750;
    model.EstimationConfigurations.Randomly = true;
    model.EstimationConfigurations.MinDiff = 0;
    model.Type = 'MISO';
%% Constructor
    if isempty(Y)
        error('Y must be non empty');
    end
    if isrow(Y)
        Y = Y';
    end
    if ~isempty(U)
        Usize = size(U);
        if Usize(1) < Usize(2)
            U = U';
            Usize = Usize(end:-1:1);
        end
        if Usize(1) ~= size(Y, 1)
            error('Y and U must have the same length');
        end
        clear Usize;
    end

    model.Data.SystemOutput = Y;
    if nargin > 2
        model.Data.SystemOutputName = varargin{1};
    else
        model.Data.SystemOutputName = {'System Output'};
    end
    model.Data.OutputSize = 1;

    model.Data.SystemInputs = U;
    model.Data.SystemInputsName = [];
    model.Data.InputSize = size(U, 2);
    model.Data.SystemInputsName = cell(model.Data.InputSize, 1);

    for i = 1:model.Data.InputSize
        model.Data.SystemInputsName{i} = sprintf('Input %d', i);
        model.Data.TransportDelay(i) = 0;
    end

    if nargin > 3
    if iscell(varargin{2})
        N = length(varargin{2});
        M = min(N, model.Data.InputSize);
        model.Data.SystemInputsName(1:M) = varargin{2}(1:M);
    else
        for i = 4:2:nargin
            model.Data.SystemInputsName{varargin{i-2}} = varargin{i-1};
        end
    end
    end
end

