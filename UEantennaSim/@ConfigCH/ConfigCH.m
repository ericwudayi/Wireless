function [ConfigCH] = ConfigCH( UEspeed )
    
%cluster
ConfigCH.NLOSClusterNum           = 6;
ConfigCH.LOSClusterNum		  = 12;
ConfigCH.NLOSsubpathNum           = 20;
ConfigCH.BSrmsAngularSpread.Horiz = 10.0; 
%ConfigCH.BSrmsAngularSpread.Vert  = 0.1186;
ConfigCH.UErmsAngularSpread.Horiz = 22.0;
ConfigCH.UErmsAngularSpread.Vert  = 7.0;
ConfigCH.r_dly = 2.1;
ConfigCH.SigmaDS = 1.3277e-07;
ConfigCH.PerPathShadow = 3.0;
ConfigCH.SFstd = 8.2;
ConfigCH.LOSSF = 4;
%K factor
ConfigCH.K = 15;
%ConfigMo.maxStayPeriod = 1;
    
    
    
   
