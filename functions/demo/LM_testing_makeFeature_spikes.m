
function feature = LM_testing_makeFeature_spikes(dur,Fs,tISI,jitter)

nPnts = ceil(dur*Fs)+1;
tMax = (nPnts-1)/Fs; % making sure tMax & nPnts match exactly

tEvents = (tISI:tISI:(tMax-tISI))';
nEvents = numel(tEvents);
% adding jitter
tEvents = tEvents + jitter*(2*rand(nEvents,1)-1);
idxEvents = round(tEvents*Fs) + 1;

feature = zeros(nPnts,1);
feature(idxEvents) = 1;

end
%
%