function [ cellAntElementFieldPattern, ueAntElementFieldPattern ] = GenerateDynamicLOSAntElementGainPattern( sys, ch, channeli, celli,uei )
% Generate Ant gain  of each subpath.

% Step1 -- Generate "the included angle" between (Ant array boresight) and each (subpath)
% Step2 -- Take the angle in antennaGain.m

BSMaxAttenu = sys.cellMaxAttenuat;
ueMaxAttenu = sys.ueMaxAttenuat;

BSHPBW = sys.cellAntennaElementHPBW;
UEHPBW = sys.ueAntennaElementHPBW;
NumPath = ch.NLOSClusterNum;
NumSubPath = ch.NLOSsubpathNum;

% UE Ant element is Omni-directional.
%ueAntElementFieldPattern = ones(1,NumPath*NumSubPath*2);%(1, 4*20)
% UE side



cellHorizBoresight = celli.boresightAngle;
ueHorizBoresight = uei.BoresightAngle;
%**calculate the included angle between boresight and departure vector of each subpath
InclinationAngle = sys.cellAntennaInclinationAngle;
cellVertiBoresight = 90+InclinationAngle;

UsedAoD = channeli.subpathAoD;

UsedEoD = channeli.subpathZoD;

shiftAngleInd = find((UsedAoD-cellHorizBoresight) < -180);
UsedAoD(shiftAngleInd) = UsedAoD(shiftAngleInd) + 360;

shiftAngleInd = find((UsedAoD-cellVertiBoresight) > 180);
UsedAoD(shiftAngleInd) = UsedAoD(shiftAngleInd) - 360;

A_EH_cell = antennaGain(UsedAoD-cellHorizBoresight,BSHPBW,BSMaxAttenu); % (NumPath*NumSubPath*2, 1)
%please make sure UsedEoD-cellVertiBoresight will not exceed +-180
A_EV_cell = antennaGain(UsedEoD-cellVertiBoresight,BSHPBW,BSMaxAttenu); % (NumPath*NumSubPath*2, 1)
%disp("===============================================");
%disp(A_EH_cell);
%disp(A_EV_cell);
%pause;
tmpcellAntGainPattern3D = -min(-( A_EH_cell+A_EV_cell ), BSMaxAttenu);
tmpcellAntGainPattern3D = ( 10.^( tmpcellAntGainPattern3D/10 ) ).^0.5;


cellAntElementFieldPattern = tmpcellAntGainPattern3D.'; %(1, NumPath*NumSubPath*2 )

UsedEoA = channeli.subpathZoA;
UsedAoA = channeli.subpathAoA;

UEshiftAngleInd = find((UsedAoA-ueHorizBoresight) < -90);
UsedAoA(UEshiftAngleInd) = UsedAoA(UEshiftAngleInd) + 180;

UEshiftAngleInd = find((UsedAoA-ueHorizBoresight) > 90);
UsedAoA(UEshiftAngleInd) = UsedAoA(UEshiftAngleInd) - 180;

A_EH_UE = antennaGain(UsedAoA-ueHorizBoresight,UEHPBW,ueMaxAttenu); % (NumPath*NumSubPath*2, 1)
A_EV_UE = antennaGain(UsedEoA-90,UEHPBW,ueMaxAttenu);
tmpueAntGainPattern3D = -min(-( A_EH_UE+A_EV_UE ), ueMaxAttenu);
ueAntElementFieldPattern = (( 10.^( tmpueAntGainPattern3D/10 ) ).^0.5).';






end

