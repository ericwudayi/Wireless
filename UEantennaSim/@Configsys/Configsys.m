function [ConfigSYS] = Configsys( UEspeed )
    
ConfigSYS.freq                   = 28*10^9;
ConfigSYS.lambda                 = 3*10^8/ConfigSYS.freq;
ConfigSYS.BSantennaSpacing       = 0.5*ConfigSYS.lambda;
ConfigSYS.UEantennaSpacing       = 0.5*ConfigSYS.lambda;
ConfigSYS.eNodeBPowerIndBm       = 33;                   %dBm
ConfigSYS.cellAntennaGain        = 8;                   %dBi
ConfigSYS.ueAntennaGain          = 5;                    %dBi
ConfigSYS.cellAntRowNum          = 2;
ConfigSYS.cellAntColumnNum       = 8;
%ConfigSYS.cellAntNum             = ConfigSYS.cellAntRowNum * ConfigSYS.cellAntColumnNum;
ConfigSYS.cellBeamNum            = 8;
ConfigSYS.ueAntRowNum            = 2;
ConfigSYS.ueAntColumnNum         = 4;
%ConfigSYS.ueAntNum               = ConfigSYS.ueAntRowNum * ConfigSYS.ueAntColumnNum;
ConfigSYS.ueBeamNum              = 4;
ConfigSYS.cellAntennaInclinationAngle = 12;           %inclination Angle 15 degree
ConfigSYS.cellAntennaBoresight   = [30 150 -90];        %degree
ConfigSYS.cellAntennaElementPos_x  = ((-ConfigSYS.cellAntColumnNum/2+0.5):1:(ConfigSYS.cellAntColumnNum/2-0.5))*ConfigSYS.BSantennaSpacing;
%ConfigSYS.cellAntennaElementPos_y  = 0;
ConfigSYS.cellAntennaElementPos_z  = ((-ConfigSYS.cellAntRowNum/2+0.5):1:(ConfigSYS.cellAntRowNum/2-0.5))*ConfigSYS.BSantennaSpacing;
ConfigSYS.ueAntennaElementPos_x    = ((-ConfigSYS.ueAntColumnNum/2+0.5):1:(ConfigSYS.ueAntColumnNum/2-0.5))*ConfigSYS.UEantennaSpacing;
%ConfigSYS.ueAntennaElementPos_y    = 0;
ConfigSYS.ueAntennaElementPos_z    = ((-ConfigSYS.ueAntRowNum/2+0.5):1:(ConfigSYS.ueAntRowNum/2-0.5))*ConfigSYS.UEantennaSpacing;
ConfigSYS.cellAntennaElementHPBW = 65;                   %degree
ConfigSYS.ueAntennaElementHPBW = 90;                   %degree
ConfigSYS.cellMaxAttenuat = 30; %dB
ConfigSYS.ueMaxAttenuat = 25; %dB
ConfigSYS.cellAntennaHeight      = 10;
%ConfigSYS.ueAntennaElementHPBW   = 65;
ConfigSYS.ueHeight               = 1.5;
% each cell/site parameters
%ConfigSYS.ISD               = 200;                                           
ConfigSYS.dist_limit_min    = 0;
ConfigSYS.siteNum           = 1;
ConfigSYS.cellNum           = ConfigSYS.siteNum*3;
ConfigSYS.sectorPerSite     = 3;
ConfigSYS.siteUENum         = 100;
ConfigSYS.totalUENum        = ConfigSYS.siteUENum*ConfigSYS.siteNum;

% 3 eNodeB location
ConfigSYS.siteLocation = ...
  [            0                 0              ConfigSYS.cellAntennaHeight];
%site boundary point
%ISD =  ConfigSYS.ISD;
% ConfigSYS.siteBoundary = [
%  ISD/3^0.5  ISD/2/3^0.5  -ISD/2/3^0.5  -ISD/3^0.5  -ISD/2/3^0.5  ISD/2/3^0.5;         
%  0          ISD/2         ISD/2         0          -ISD/2        -ISD/2
% ];


ConfigSYS.bandwidth = 1000e6;
ConfigSYS.GaussianNoiseIndBm = -174;
ConfigSYS.noiseFigure = 13;





%ConfigMo.maxStayPeriod = 1;
% for generating scatters position
ConfigSYS.MinUE2SDist = 5.3571; % default: 5.3571

        
