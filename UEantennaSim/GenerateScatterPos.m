function [ scatter ] = GenerateScatterPos( sys,smallScale,celli,uei )
% Generate scatters' positions using small scale parameters.
% small scale parameters: PathDelay, subpathAoA,AoD,EoA,EoD.

[NumPath,NumSubPath] = size(smallScale.subpathAoD);
MinUE2SDist = sys.MinUE2SDist;
DistRatio = 1;
MinBS2SDist = DistRatio*MinUE2SDist;
LightSpeed = 3*10^8;
%initialize fields
scatter = smallScale;
scatter.BSScatterPos = zeros(NumPath*NumSubPath,3);
scatter.UEScatterPos = zeros(NumPath*NumSubPath,3);
BSPos = celli.pos;
UEPos = uei.pos;
tmp_BSScatterPos = zeros(NumSubPath,3);
tmp_UEScatterPos = zeros(NumSubPath,3);
tmp_dist = zeros(NumSubPath,1);
%find base distance
%EoA need to regen
for isubpath = 1:NumSubPath
    direct_B2S = [ cosd(scatter.subpathAoD(1,isubpath))*sind(scatter.subpathEoD(1,isubpath))...
                   sind(scatter.subpathAoD(1,isubpath))*sind(scatter.subpathEoD(1,isubpath))...
                   cosd(scatter.subpathEoD(1,isubpath)) ];
    direct_U2S = [ cosd(scatter.subpathAoA(1,isubpath))*sind(scatter.subpathEoA(1,isubpath))...
                   sind(scatter.subpathAoA(1,isubpath))*sind(scatter.subpathEoA(1,isubpath))...
		           cosd(scatter.subpathEoA(1,isubpath))	];
    tmp_BSScatterPos(isubpath,:) = BSPos+MinBS2SDist*direct_B2S;
    tmp_UEScatterPos(isubpath,:) = UEPos+MinUE2SDist*direct_U2S;
    tmp_dist(isubpath,1) = norm(BSPos-tmp_BSScatterPos(isubpath,:))...
                          +norm(tmp_UEScatterPos(isubpath,:)-tmp_BSScatterPos(isubpath,:))...
                          +norm(tmp_UEScatterPos(isubpath,:)-UEPos);
end
[BaseDist, MaxDistIdx] = max(tmp_dist);
scatter.BSScatterPos(MaxDistIdx,:) = tmp_BSScatterPos(MaxDistIdx,:);
scatter.UEScatterPos(MaxDistIdx,:) = tmp_UEScatterPos(MaxDistIdx,:);

for iPath = 1:NumPath
   dist = BaseDist+scatter.PathDelay(iPath)*LightSpeed;
   for isubpath = 1:NumSubPath
      if (iPath ~= 1) || (isubpath ~= MaxDistIdx)

      direct_B2S = [ cosd( scatter.subpathAoD(iPath,isubpath))*sind(scatter.subpathEoD(iPath,isubpath))...
                     sind( scatter.subpathAoD(iPath,isubpath))*sind(scatter.subpathEoD(iPath,isubpath))...
                     cosd( scatter.subpathEoD(iPath,isubpath)) ];
      direct_U2S = [ cosd( scatter.subpathAoA(iPath,isubpath))*sind(scatter.subpathEoA(iPath,isubpath))...
                     sind( scatter.subpathAoA(iPath,isubpath))*sind(scatter.subpathEoA(iPath,isubpath))...
		             cosd( scatter.subpathEoA(iPath,isubpath)) ];
      coefA1 = DistRatio*norm(direct_B2S) + norm(direct_U2S);
      coefA2 = sum((BSPos-UEPos).^2);
      coefA3 = sum((BSPos-UEPos).*(DistRatio*direct_B2S-direct_U2S));
      coefA4 = sum((DistRatio*direct_B2S-direct_U2S).^2);
      coefA = coefA4-coefA1^2;
      coefB = 2*coefA3+2*coefA1*dist;
      coefC = coefA2-dist^2;
 
      root1 = (-coefB+sqrt(coefB^2-4*coefA*coefC))/(2*coefA);
      root2 = (-coefB-sqrt(coefB^2-4*coefA*coefC))/(2*coefA);

      UE2SDist = min(root1,root2);
      scatter.BSScatterPos((iPath-1)*NumSubPath+isubpath,:) = BSPos+DistRatio*UE2SDist*direct_B2S;  % (NumPath*NumSubPath, 3)
      scatter.UEScatterPos((iPath-1)*NumSubPath+isubpath,:) = UEPos+UE2SDist*direct_U2S;            % (NumPath*NumSubPath, 3)
      end
   end
end

scatter.B2SDist = sqrt( sum( bsxfun(@minus,scatter.BSScatterPos,BSPos).^2,2 ) );    % (2*20, 1)
scatter.BSS2UESDist = sqrt( sum( bsxfun(@minus, scatter.UEScatterPos, scatter.BSScatterPos).^2,2));





