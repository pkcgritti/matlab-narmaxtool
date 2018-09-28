function generatesimfunc( model, filename, overwrite )
%GENERATESIMFUNC Summary of this function goes here
%   Detailed explanation goes here

ow = 0;
if nargin > 2
    ow = overwrite;
end

% Check filename
if ~strcmp(filename(end-1:end), '.m')
    funcname = filename;
    filename = [filename '.m'];
else
    funcname = filename(end-1:end);
end

% Check if file exists
if ~ow
fid = fopen(filename, 'r');
if fid ~= -1
    fclose(fid);
    switch questdlg(sprintf('Do you want to overwrite %s?', filename), 'File Exists')
        case 'Yes'
            delete(filaname);
            rehash;
        otherwise
            return
    end
end
end

% Get template
fid = fopen('simfunc.template', 'r');
template = fread(fid, 'uint8=>char')';
fclose(fid);

D = [model.ProcessTerms;model.NoiseRelatedTerms];
theta = [model.ProcessTheta;model.NoiseTheta];
cfuncs = model.CustomFunctions;


pattern = '(?<function>[a-zA-Z0-9]*)\(?(?<term>[yue])(?<index>[0-9]*)\(k-(?<lag>[0-9]+)||(?<term>constant)';
RD = cellfun(@(x) regexp(x, pattern, 'names'), D, 'UniformOutput', false);

initindex    = min(cellfun(@(x)max(arrayfun(@(y)min(str2double(y.lag)),x)),RD)) + 1;
partialindex = max(cellfun(@(x)max(arrayfun(@(y)max(str2double(y.lag)),x)),RD));

% replace function name
template = regexprep(template, '<functionName>', funcname);

% replace initindex
template = regexprep(template, '<initIndex>', sprintf('%d',initindex));

% replace partialindex
template = regexprep(template, '<partialIndex>', sprintf('%d', partialindex));

% replace theta
thetastr = ['[' sprintf('%+.18f\n\t\t\t\t', theta) ']'];
template = regexprep(template, '<coefficients>', thetastr);

% replate termlist
DG = cell(size(RD));
usedfunctions = [];
for i = 1:size(RD,1)
    DG{i} = '';
    append = '';
    for j = 1:length(RD{i})
        switch RD{i}(j).term
            case 'y'
                pstr = sprintf('Ys(k-%d)', str2double(RD{i}(j).lag));
            case 'u'
                pstr = sprintf('U(k-%d,%d)', str2double(RD{i}(j).lag), str2double(RD{i}(j).index));
            case 'e'
                pstr = sprintf('E(k-%d)', str2double(RD{i}(j).lag));
            case 'constant'
                pstr = '1';
        end
        if ~isempty(RD{i}(j).function)
            func = RD{i}(j).function;
            fidx = find ( cellfun( @(x) strcmp(x{1}, func), cfuncs ) );
            if isempty(fidx)
                error('Function %s not founded.', func);
            end
            if isempty(usedfunctions)
                usedfunctions = fidx;
                usedfunctionsmask = 1;
                ffidx = 1;
            else
                if any ( usedfunctions == fidx )
                    ffidx = find(usedfunctions == fidx);
                else
                    usedfunctions = [usedfunctions fidx];
                    ffidx = length(usedfunctions);
                end
            end
            pstr = sprintf('cfuncs{%d}(%s)', ffidx, pstr);
        end
        DG{i} = [DG{i} append pstr];
        append = '*';
    end
end
template = regexprep(template, '<termList>', sprintf('''%s''; ...\n\t\t\t\t', DG{:}));

% replace cfuncs
cfstr = '';
for i = 1:length(usedfunctions)
    cfstr = sprintf('%s%s; ...\n\t\t', cfstr, func2str(cfuncs{usedfunctions(i)}{2}));
end
if ~isempty(cfstr)
    cfstr = sprintf('cfuncs   = {%s};', cfstr);
end
template = regexprep(template, '<customFunctions>', cfstr);

% replace modelTerms
modelterms = ['[' sprintf('%s %s %s %s ...\n\t\t\t\t', DG{:}) ']'];
template = regexprep(template, '<modelTerms>', modelterms);

fid = fopen(filename, 'w');
fwrite(fid, template);
fclose(fid);

rehash;

end

