function [CC,MSE] = LM_testModel(model,stimOpt,EEGopt,opt,type)
%
% LM_testModel
% Part of the Linear Model (LM) package.
% Author: Octave Etard
%
if numel(stimOpt) == 1
    switch type
        case 'forward'
            [CC,MSE] = LM_forward_testModel(model,stimOpt,EEGopt,opt);
        case 'backward'
            [CC,MSE] = LM_backward_testModel(model,stimOpt,EEGopt,opt);
    end
    return;
end

sizeStim = size(stimOpt);
nSub = size(EEGopt,ndims(EEGopt));

if sizeStim(end) == 1
    sizeStim = sizeStim(1:(end-1));
end

assert( all( size(EEGopt) == [sizeStim,nSub] ),...
    'stimOpt & EEGopt dimensions do not match!');

nStimLoad = numel(stimOpt);

if 1 < nStimLoad && numel(opt.nStimPerFile) == 1
    % expands
    nStimPerFile = opt.nStimPerFile * ones(nStimLoad,1);
else
    nStimPerFile = opt.nStimPerFile;
end

% number of points to use to measure correlation / MSE
nPntsPerf = opt.nPntsPerf;
nPerfSize = numel(nPntsPerf);

%% Preallocation
CC = cell(nPerfSize,nStimPerFile,nStimLoad);
MSE = cell(nPerfSize,nStimPerFile,nStimLoad);


%%
idxEEGopt = nStimLoad * ((1:nSub)-1);

for iStimulus = 1:nStimLoad
    
    opt.nStimPerFile = nStimPerFile(iStimulus);
    
    switch type
        case 'forward'
            [CC(:,:,iStimulus),MSE(:,:,iStimulus)] = LM_forward_testModel(model,...
                stimOpt(iStimulus),...
                EEGopt(idxEEGopt + iStimulus),...
                opt);
            
        case 'backward'
            [CC(:,:,iStimulus),MSE(:,:,iStimulus)] = LM_backward_testModel(model,...
                stimOpt(iStimulus),...
                EEGopt(idxEEGopt + iStimulus),...
                opt);
    end
end
CC = reshape(CC,[nPerfSize,nStimPerFile,sizeStim]);
MSE = reshape(CC,[nPerfSize,nStimPerFile,sizeStim]);

end
%
%