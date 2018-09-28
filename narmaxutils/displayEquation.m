function displayEquation( narmaxModel )
%DISPLAYEQUATION Prints the equation of a NARMAX model
    nProcessVariables = length(narmaxModel.ProcessTheta);
    nNoiseVariables = length(narmaxModel.NoiseTheta);
    equation = sprintf('\ty(k) =');
    
    disp(' ');
    disp('Model equation');
    disp(' ');
    
    for i = 1:nProcessVariables
        switch i
            case 1
                format = '%s %e %s +';
            case nProcessVariables
                format = '%s\n\t\t%e %s';
            otherwise
                format = '%s\n\t\t%e %s +';
        end
        equation = sprintf( ...
            format, ...
            equation, ...
            narmaxModel.ProcessTheta(i), ...
            narmaxModel.ProcessTerms{i} ...
        );
    end
    
    for i = 1:nNoiseVariables
        switch i
            case 1
                format = '%s +\n\t\t%e %s';
            case nNoiseVariables
                format = '%s\n\t\t%e %s';
            otherwise
                format = '%s\n\t\t%e %s +';
        end
        equation = sprintf( ...
            format, ...
            equation, ...
            narmaxModel.NoiseTheta(i), ...
            narmaxModel.NoiseRelatedTerms{i} ...
        );
    end
    
    disp(equation);
end

