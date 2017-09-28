function [ pathLoss ] = GeneratePathLoss( sys,icell,UEi )
% Generate LOS distance

siteIndex = ceil(icell/3);
cellPos = sys.siteLocation(siteIndex,:);
uePos = UEi.pos;
distance3D = norm(cellPos-uePos);
%distance2D = norm(cellPos(1:2)-uePos(1:2));

% NLOS pathloss PL = alpha+10*beta*1og10(d)
% According to the reference paper, alpha = 72, beta = 2.92

pathLoss = 32.4 + 20*log10(sys.freq/(10^9))+31.9*log10(distance3D);

end

