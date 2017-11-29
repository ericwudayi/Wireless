function [ pathLoss ] = GenerateLOSPathLoss( sys,icell,UEi )
% Generate LOS distance

siteIndex = ceil(icell/3);
cellPos = sys.siteLocation(siteIndex,:);
uePos = UEi.pos;
distance3D = norm(cellPos-uePos);
distance2D = norm(cellPos(1:2)-uePos(1:2));
%effective height = acutal height - h_E, h_E =1 in Umi
h_E = 1;
velocity = 3*10^8;
h_BS = sys.siteLocation(3) - h_E;
h_UT = uePos(3) - h_E;
d_BP = 4*h_BS*h_UT*sys.freq/velocity;
% LOS formula:
if distance2D >= 10 && distance2D < d_BP

pathLoss = 32.4+ 21*log10(distance3D)+ 20*log10(sys.freq/(10^9));

else

pathLoss = 32.4+ 40*log10(distance3D)+ 20*log10(sys.freq/(10^9))...
	       - 9.5*log10(d_BP^2+(h_BS-h_UT)^2);



end

