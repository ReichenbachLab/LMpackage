function [XtX,Xty] = LM_backward_crossMatrices(stimOpt,EEGopt,opt)
%
% LM_backward_crossMatrices
% Part of the Linear Model (LM) package.
% Author: Octave Etard
%
minLag = opt.minLag;
maxLag = opt.maxLag;
nLags = maxLag - minLag + 1;

nChan = opt.nChan;
nStimPerFile = opt.nStimPerFile;
nFeatures = opt.nFeatures;

nSub = numel(EEGopt);

if nStimPerFile == 1
    opt.sumStim = true; % equivalent
end

unpad = opt.unpad.do;


%% Preallocation
s = [];
if ~opt.sumStim
    s = nStimPerFile;
end
if ~opt.sumSub
    s = [s,nSub];
end

% XtX will require 8 * (nLags*nChan)^2 (* nStimPerFile) (* nSub) bytes of memory
XtX = zeros([nLags*nChan,nLags*nChan,s],'double');
Xty = zeros([nLags*nChan,nFeatures,s],'double');


%% Loading feature representation for all stimuli
% feature sould be a matrix of size [~,nFeatures] or cell with nStimuli
% elements containing matrices of size [~,nFeatures]
feature = opt.getStimulus(stimOpt);

if ~iscell(feature)
    feature = {feature};
end


%% Precompute feature FFT of each stimulus (same for all subjects)
nx = nan(nStimPerFile,1);
mY = cell(nFeatures,1);
n_mY = nan(nStimPerFile,1);
Ytop = cell(nStimPerFile,1);
Ybottom = cell(nStimPerFile,1);

for iStimulus = 1:nStimPerFile
    nx(iStimulus) = size(feature{iStimulus},1);
    nFFT = 2^nextpow2( nx(iStimulus) + nLags - 1 );
    
    opt.iB = 1;
    opt.nx = nx(iStimulus);
    
    if unpad
        opt.unpad = LM_laggedDims(nx(iStimulus),1,nx(iStimulus),minLag,maxLag);
        opt.unpad.do = true;
    end
    
    [feature{iStimulus},mY{iStimulus},n_mY(iStimulus),...
        Ytop{iStimulus},Ybottom{iStimulus}] = LM_computeYFFT(feature{iStimulus},minLag,maxLag,nFFT,opt);
end


%% Making Xty for each subject & stimulus
for iSub = 1:nSub
    % response should be a matrix of size [~,nOut]
    % iB should be an array with nStimuli elements containing the index
    % of stimulus onset in response
    [response,iB] = opt.getResponse(EEGopt(iSub));
    
    for iStimulus = 1:nStimPerFile
        
        if unpad
            opt.unpad = LM_laggedDims(nx(iStimulus),1,nx(iStimulus),minLag,maxLag);
            opt.unpad.do = true;
        end
        
        [XtX_,xF,mX_,Xtop,Xbottom] = LM_laggedXtX(response((1:nx(iStimulus))+iB(iStimulus)-1,:),minLag,maxLag,opt);
        
        Xty_ = LM_laggedXty(xF,feature{iStimulus},minLag,maxLag,...
            mX_,Xtop,Xbottom,...
            true,mY{iStimulus},n_mY(iStimulus),...
            Ytop{iStimulus},Ybottom{iStimulus},...
            opt);
        
        if opt.sumSub
            if opt.sumStim
                XtX = XtX + XtX_;
                Xty = Xty + Xty_;
            else
                XtX(:,:,iStimulus) = XtX(:,:,iStimulus) + XtX_;
                Xty(:,:,iStimulus) = Xty(:,:,iStimulus) + Xty_;
            end
        else
            if opt.sumStim
                XtX(:,:,iSub) = XtX(:,:,iSub)  + XtX_;
                Xty(:,:,iSub) = Xty(:,:,iSub)  + Xty_;
            else
                XtX(:,:,iStimulus,iSub) = XtX(:,:,iStimulus,iSub) + XtX_;
                Xty(:,:,iStimulus,iSub) = Xty(:,:,iStimulus,iSub) + Xty_;
            end
        end
    end
end
%
%
end
%
%