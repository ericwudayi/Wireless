function [ smallScale ] = GenerateSmallScale( ch,celli,uei )
% Generate small scale parameters for generating scatters' positions.
% small scale parameters: PathDelay, subpathAoA,AoD,EoA,EoD.

BS = celli; UE = uei;

clusterN = ch.NLOSClusterNum;
smallScale.clusterNum = ch.NLOSClusterNum;


%Generate central angle of AoA AoD 
smallScale.centralAoD = unifrnd(-180,180,1, clusterN); %in respect to the global coordination
smallScale.centralAoA = unifrnd(-180,180,1, clusterN); %in respect to the global coordination

%*calculate ""LOS"" as EoD and EoA*
% EoD and EoA (definition: the included angle to +Z)
% -90 < atand <90
smallScale.centralEoD =90+ atand((BS.pos(3)-UE.pos(3)) / norm([BS.pos(1)-UE.pos(1), BS.pos(2)-UE.pos(2)]));% in respect to the antenna array facing angle
smallScale.centralEoA = 180 - smallScale.centralEoD; % EoA = 180-EoD

% Generate subpath angles
    ray_offset_angle_range = [0.0447 -0.0447 0.1413 -0.1413 0.2492 -0.2492 0.3715 -0.3715 0.5129 -0.5129 0.6797 -0.6797 0.8844 -0.8844 1.1481 -1.1481 1.5195 -1.5195 2.1551 -2.1551];
    ZoDrmsSpread = 3/8 * 10^(-3.1*norm(BS.pos(1:2)-UE.pos(1:2))/1000+0.2);
    %ray_offset_angle_range = zeros(1,20);%debug
for i = 1:clusterN 
        smallScale.subpathAoA(i,:) = smallScale.centralAoA(i) + ch.UErmsAngularSpread.Horiz * ray_offset_angle_range;
        smallScale.subpathAoD(i,:) = smallScale.centralAoD(i) + ch.BSrmsAngularSpread.Horiz * ray_offset_angle_range;
        
end

for i = 1:clusterN
    smallScale.subpathEoA(i,:) = smallScale.centralEoA + ch.UErmsAngularSpread.Vert * ray_offset_angle_range;
    smallScale.subpathEoD(i,:) = smallScale.centralEoD + ZoDrmsSpread * ray_offset_angle_range;

end
%generate power and delay
r_dly = ch.r_dly;
SigmaDS = ch.SigmaDS;
R1 = unifrnd(0,1,1,clusterN); 
delay_unsort = -r_dly * SigmaDS * log(R1);
PathDelay = sort(delay_unsort - min (delay_unsort));

P_correct = 10.^(-randn(1,clusterN).*ch.PerPathShadow/10);

smallScale.perPathShadowTerm = P_correct;

P_pw = exp((1-r_dly).*PathDelay./(r_dly*SigmaDS)).*P_correct; % PathDelay¡ô, P_pw¡õ (but still effect of P_correct)
PathPw = P_pw./sum(P_pw);

smallScale.PathDelay = PathDelay;
smallScale.PathPw = PathPw;


end

