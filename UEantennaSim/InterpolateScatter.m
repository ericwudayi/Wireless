function [ dynamicSmallScale ] = InterpolateScatter( ch, channeli,uei )
% Generate temporal (pathDelay, pathPw, and UsedAoD,EoD,AoA,EoA)

   
UE = uei;

scatterT1 = channeli.scatter1; 
scatterT2 = channeli.scatter2;

  


UEScatterPos = [scatterT1.UEScatterPos;scatterT2.UEScatterPos]; % (4*20, 3)

subpathArrived = bsxfun(@minus, UEScatterPos, UE.pos);

UsedEoA = 90-bsxfun(@atan2, subpathArrived(:,3),rssq(subpathArrived(:,1:2),2)).*180./pi;
UsedAoA = bsxfun(@atan2, subpathArrived(:,2),subpathArrived(:,1)).*180./pi;


% update pathDelay
B2S_Dist = [scatterT1.B2SDist;scatterT2.B2SDist];   % (4*20, 1)
BSS2UES_Dist = [scatterT1.BSS2UESDist;scatterT2.BSS2UESDist];   % (4*20, 1)
S2UE_Dist = sqrt(sum(bsxfun(@minus,UEScatterPos(:,:),UE.pos).^2,2)); % update s2ue distance% (4*20, 1)
Cell2UE_Dist = B2S_Dist+BSS2UES_Dist + S2UE_Dist;   % (4*20, 1)
%dynamicSmallScale.Cell2UE_Dist = Cell2UE_Dist; 
%dynamicSmallScale.S2UE_Dist = S2UE_Dist;

Cell2UE_Dist = reshape(Cell2UE_Dist,ch.NLOSClusterNum*ch.NLOSsubpathNum,2);

mean_Dist = zeros(ch.NLOSClusterNum,2);

for numCluster = 1:ch.NLOSClusterNum

mean_Dist(numCluster,:) = mean(Cell2UE_Dist(((numCluster-1)*ch.NLOSsubpathNum+1):(numCluster*ch.NLOSsubpathNum),:));
%dynamicSmallScale.pathDelay(((numCluster-1)*ch.NLOSsubpathNum+1):(numCluster*ch.NLOSsubpathNum)) = (Cell2UE_Dist(((numCluster-1)*ch.NLOSsubpathNum+1):(numCluster*ch.NLOSsubpathNum),1)-min_Dist)/(3*10^8);
end


delay_unnormal = mean_Dist ./ (3*(10^8));
PathDelay = bsxfun(@minus,delay_unnormal,min(delay_unnormal));

r_dly = ch.r_dly;
SigmaDS = ch.SigmaDS;

s1P_pw = exp((1-r_dly).*(PathDelay(:,1).')./(r_dly*SigmaDS)).*scatterT1.perPathShadowTerm;

s1PathPw = s1P_pw./sum(s1P_pw);

s2P_pw = exp((1-r_dly).*(PathDelay(:,2).')./(r_dly*SigmaDS)).*scatterT2.perPathShadowTerm;

s2PathPw = s2P_pw./sum(s2P_pw);

scatterPwRatio = norm(UE.endPoint - UE.pos) / norm(UE.endPoint - UE.startPoint);
    %debug
    %scatterPwRatio = 0.7;
dynamicSmallScale.pathPw = [s1PathPw.*scatterPwRatio ; s2PathPw .*(1-scatterPwRatio)];

dynamicSmallScale.subpathEoA = UsedEoA;
dynamicSmallScale.subpathAoA = UsedAoA;

end

