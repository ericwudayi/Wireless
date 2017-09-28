function [ConfigCH] = ConfigCH( UEspeed )
    
%cluster
ConfigCH.NLOSClusterNum           = 6;
ConfigCH.NLOSsubpathNum           = 20;
%ConfigCH.rms1spread               = [0.0447 0.1413 0.2492 0.3715 0.5129 0.6797 0.8844 1.1481 1.5195 2.1551];
ConfigCH.BSrmsAngularSpread.Horiz = 10.0; 
%ConfigCH.BSrmsAngularSpread.Vert  = 0.1186;
ConfigCH.UErmsAngularSpread.Horiz = 22.0;
ConfigCH.UErmsAngularSpread.Vert  = 7.0;
ConfigCH.r_dly = 2.1;
ConfigCH.SigmaDS = 1.3277e-07;
ConfigCH.PerPathShadow = 3.0;
ConfigCH.SFstd = 8.2;

%
%ConfigMo.maxStayPeriod = 1;
    
    
    
   
