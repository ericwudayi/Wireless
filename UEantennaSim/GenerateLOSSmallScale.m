function [ smallScale ] = GenerateLOSSmallScale(sys, ch,celli,uei )
% Generate small scale parameters for generating scatters' positions.
% small scale parameters: PathDelay, subpathAoA,AoD,EoA,EoD.

BS = celli; UE = uei;
distance2D = norm(sys.siteLocation(1:2)-uei.pos(1:2));
h_ut = sys.ueHeight;
h_bs = sys.siteLocation(3);
clusterN = ch.LOSClusterNum;
smallScale.clusterNum = ch.LOSClusterNum;


%Generate central angle of AoA AoD AsA AsD
%smallScale.centralAoD = unifrnd(-180,180,1, clusterN); %in respect to the global coordination
%smallScale.centralAoA = unifrnd(-180,180,1, clusterN); %in respect to the global coordination

%*calculate ""LOS"" as EoD and EoA*
% EoD and EoA (definition: the included angle to +Z)
% -90 < atand <90
smallScale.centralEoD =90+ atand((BS.pos(3)-UE.pos(3)) / norm([BS.pos(1)-UE.pos(1), BS.pos(2)-UE.pos(2)]));% in respect to the antenna array facing angle
smallScale.centralEoA = 180 - smallScale.centralEoD; % EoA = 180-EoD

% Generate subpath angles

    ray_offset_angle_range = [0.0447 -0.0447 0.1413 -0.1413 0.2492 -0.2492 0.3715 -0.3715 0.5129 -0.5129 0.6797 -0.6797 0.8844 -0.8844 1.1481 -1.1481 1.5195 -1.5195 2.1551 -2.1551];
    ZoDrmsSpread = 3/8 * 10^(-3.1*norm(BS.pos(1:2)-UE.pos(1:2))/1000+0.2);

%{
    %ray_offset_angle_range = zeros(1,20);%debug
for i = 1:clusterN 
        smallScale.subpathAoA(i,:) = smallScale.centralAoA(i) + ch.UErmsAngularSpread.Horiz * ray_offset_angle_range;
        smallScale.subpathAoD(i,:) = smallScale.centralAoD(i) + ch.BSrmsAngularSpread.Horiz * ray_offset_angle_range;
        
end
%}
for i = 1:clusterN
    %smallScale.subpathEoA(i,:) = smallScale.centralEoA + ch.UErmsAngularSpread.Vert * ray_offset_angle_range;
    smallScale.subpathEoD(i,:) = smallScale.centralEoD + ZoDrmsSpread * ray_offset_angle_range;

end
%generate power and delay
r_dly = ch.r_dly;
K_factor = ch.K;
SigmaDS = ch.SigmaDS;
R1 = unifrnd(0,1,1,clusterN); 
delay_unsort = -r_dly * SigmaDS * log(R1);
PathDelay = sort(delay_unsort - min (delay_unsort));

P_correct = 10.^(-randn(1,clusterN).*ch.PerPathShadow/10);

smallScale.perPathShadowTerm = P_correct;

P_pw = exp((1-r_dly).*PathDelay./(r_dly*SigmaDS)).*P_correct; % PathDelay¡ô, P_pw¡õ (but still effect of P_correct)

%K_factor for normalize , and addition term for PathPw(1)
PathPw = P_pw./sum(P_pw)/(K_factor+1);
PathPw(1) = PathPw(1)+ K_factor/(K_factor+1);

smallScale.PathDelay = PathDelay;
smallScale.PathPw = PathPw;

				 %S T E P 7

%Generate central angle of AoA AoD AsA AsD
%AOA, AOD

avergeAsA  = 10.^(-0.08*log10(1+sys.freq/10^9)+1.73);
sigmalAsA  = 10.^(0.014*log10(1+sys.freq/10^9)+0.28);
avergeAsD  = 10.^(-0.05*log10(1+sys.freq/10^9)+1.21);
sigmalAsD  = 0.41;
distance2D = norm(sys.siteLocation(1:2)-uei.pos(1:2));
% PHI for ue to site 
phi_los    = angle((sys.siteLocation(1)-uei.pos(1)) + 1i*(sys.siteLocation(2)-uei.pos(2)));
%{
disp(phi_los);
disp(sys.siteLocation(1));
disp(uei.pos(1));
disp(sys.siteLocation(2));
disp(uei.pos(2));
disp((sys.siteLocation(1)-uei.pos(1)) + 1i*(sys.siteLocation(2)-uei.pos(2)));
pause;
%}
AoA_rms = ch.UErmsAngularSpread.Horiz;
AoD_rms = ch.BSrmsAngularSpread.Horiz;
smallScale.subpathAoA=GenerateSubpathPara(ch,avergeAsA,sigmalAsA ,P_pw,AoA_rms,phi_los);
smallScale.subpathAoD=GenerateSubpathPara(ch,avergeAsD,sigmalAsD ,P_pw,AoD_rms,phi_los);

%Cauculate ZsA ZsD ZoA ZoD
avergeZsA  = 10.^(-0.1*log10(1+sys.freq/10^9)+0.73);
sigmalZsA  = 10.^(-0.04*log10(1+sys.freq/10^9)+0.34);
avergeZsD  = max(10.^-0.21,10.^(-14.8*distance2D/1000+0.01*(h_bs-h_ut)+0.83));
sigmalZsD  = 10.^0.35;
%theta from uei to site
THETA_LOS = pi/2 - angle( distance2D + (sys.siteLocation(3)-uei.pos(3) )*1i) ;
ZoA_rms = ch.UErmsAngularSpread.Vert;
centralPara=GenerateSubpathPara2(ch,avergeZsA,sigmalZsA ,P_pw ,THETA_LOS);
ray_offset_angle_range = [0.0447 -0.0447 0.1413 -0.1413 0.2492 -0.2492 0.3715 -0.3715 0.5129 -0.5129 0.6797 -0.6797 0.8844 -0.8844 1.1481 -1.1481 1.5195 -1.5195 2.1551 -2.1551];
for i = 1:clusterN
        smallScale.subpathZoA(i,:) = centralPara(i) + ZoA_rms * ray_offset_angle_range;
end


centralPara = GenerateSubpathPara2(ch,avergeZsD,sigmalZsD ,P_pw,THETA_LOS);
u_offset = 0; % in UMi 
centralPara = centralPara + u_offset;

for i = 1:clusterN
        smallScale.subpathZoD(i,:) = centralPara(i) + 3/8 *(avergeZsD)*ray_offset_angle_range;

end

function [subpathPara]=GenerateSubpathPara(ch,averge , sigmal , P_pw, rms,phi_los)
K_factor = ch.K;
clusterN = ch.LOSClusterNum;
LOS_C = 1.035-0.028*K_factor-0.002*K_factor^2+0.0001*K_factor^3;
C_phi = 0.860*LOS_C;  %0.860 for 5 clusters
Para = normrnd(averge,sigmal,[1 clusterN]);

centralPara = 2/1.4*Para.*sqrt(-log(P_pw/max(P_pw)))/C_phi;

% Some special parameter for LOS
X_n = rand([1 clusterN]);
X_n(X_n>0.5)=1;
X_n(X_n<=0.5)=-1;
Y_n = normrnd(0,(Para/7).^2);
%AoA for general case
centralPara = centralPara.*X_n + Y_n + phi_los;

centralPara = centralPara - centralPara(1) + phi_los;
ray_offset_angle_range = [0.0447 -0.0447 0.1413 -0.1413 0.2492 -0.2492 0.3715 -0.3715 0.5129 -0.5129 0.6797 -0.6797 0.8844 -0.8844 1.1481 -1.1481 1.5195 -1.5195 2.1551 -2.1551];

for i = 1:clusterN 
        subpathPara(i,:) = centralPara(i) + rms * ray_offset_angle_range;
        
end

function [centralPara]=GenerateSubpathPara2(ch,averge , sigmal , P_pw ,t_los)
K_factor = ch.K;
clusterN = ch.LOSClusterNum;
LOS_C = 1.3086+0.0339*K_factor-0.0077*K_factor^2+0.0002*K_factor^3;
C_phi = 0.860*LOS_C;  %0.860 for 5 clusters
Para = laprnd(1,clusterN,averge,sigmal);

centralPara = -Para.*(log(P_pw/max(P_pw)))/C_phi;

% Some special parameter for LOS
X_n = rand([1 clusterN]);
X_n(X_n>0.5)=1;
X_n(X_n<=0.5)=-1;
Y_n = normrnd(0,(Para/7).^2);
%AoA for general case
centralPara = centralPara.*X_n + Y_n + t_los;

centralPara = centralPara - centralPara(1) + t_los;

function y  = laprnd(m, n, mu, sigma)
%LAPRND generate i.i.d. laplacian random number drawn from laplacian distribution
%   with mean mu and standard deviation sigma. 
%   mu      : mean
%   sigma   : standard deviation
%   [m, n]  : the dimension of y.
%   Default mu = 0, sigma = 1. 
%   For more information, refer to
%   http://en.wikipedia.org./wiki/Laplace_distribution

%   Author  : Elvis Chen (bee33@sjtu.edu.cn)
%   Date    : 01/19/07

%Check inputs
if nargin < 2
    error('At least two inputs are required');
end

if nargin == 2
    mu = 0; sigma = 1;
end

if nargin == 3
    sigma = 1;
end

% Generate Laplacian noise
u = rand(m, n)-0.5;
b = sigma / sqrt(2);
y = mu - b * sign(u).* log(1- 2* abs(u));

