function [outputCQI, refUEN ] = Example( UEspeed )
    
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
ConfigSYS.dist_limit_min    = 10;
ConfigSYS.siteNum           = 1;
ConfigSYS.cellNum           = ConfigSYS.siteNum*3;
ConfigSYS.sectorPerSite     = 3;
ConfigSYS.siteUENum         = 30;
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
ConfigSYS.bandwidth = 1000e6;
ConfigSYS.GaussianNoiseIndBm = -174;
ConfigSYS.noiseFigure = 13;




% UE mobility parameters
%ConfigSYS.schedulTimes = 4;
ConfigMo.totalTimeSlots = 1;
ConfigMo.timeSlotDuration = 0.0005;   % sec.
ConfigMo.speed = UEspeed;

%ConfigMo.maxStayPeriod = 1;
% for generating scatters position
ConfigSYS.MinUE2SDist = 5.3571; % default: 5.3571

    %load('mapSINR2CQI.mat');
    
    SINR2CQI = [-9.478,-6.658,-4.098,-1.798,0.399,2.424,4.489,6.367,...
        8.456,10.266,12.218,14.122,15.849,17.786,19.809];
    
    % Beamforming
    BSAntWeights = GenerateBSAntWeights(ConfigSYS);
    UEAntWeights = GenerateUEAntWeights(ConfigSYS);
        
    CELL = ConstructCELL(ConfigSYS);
    UE   = ConstructUEmobility(ConfigSYS,ConfigMo);

    CHANNEL = ChannelInitial(ConfigSYS,ConfigCH, ConfigMo, CELL, UE);
    
    
    
    BSREC.CQI = uint8(zeros(1,ConfigSYS.totalUENum));
    BSREC.UEBeam = uint8(zeros(3,ConfigSYS.totalUENum));
    %BSREC.timerEn = boolean(0);
    
    
    
    
    
    
    
   
   
   
   %debug
   BSREC.referUEN = zeros(1,ConfigSYS.sectorPerSite*ConfigSYS.cellBeamNum);
   
   %debug
   
    
  
    
    
   
    %noisedBm = 10*log10(ConfigSYS.bandwidth) + ConfigSYS.GaussianNoiseIndBm;
   
    
    for timeSlot = 1:ConfigMo.totalTimeSlots  % 1 timeslot = timelength (s)     
        
       
        [UE, CHANNEL] = UpdateUEState(ConfigSYS,ConfigCH,ConfigMo,UE,CHANNEL); % UE moving, update UE position and doppler phase
        for iue = 1:ConfigSYS.totalUENum            
            if (UE(iue).state == 1)  % state == 1 means that UE is going to leave the "old EndPoint"(new startPoint)            
                CHANNEL = NewChannel(ConfigSYS,ConfigCH,CELL,UE(iue),CHANNEL);                            
            else
                  [ CHANNEL, UE(iue) ] = InterpolateDynamicChannel(ConfigSYS,ConfigCH,ConfigMo,CELL,UE(iue),CHANNEL);
            end
            
            [ UE(iue).servingCellBeam, UE(iue).signalStatus, UE(iue).rssi, CELL] = DynamicAssociation(ConfigSYS,ConfigCH,UE(iue),CHANNEL,CELL,BSAntWeights,UEAntWeights);

        end
        

        
        %add ref & scheduling
        
            
             
          %testbench        
          if timeSlot == 1 %beam Association
                    [BSREC] = inibeamAssoc(UE,BSREC,ConfigSYS);
            

          %refBeam = timeSlot;
          for refBeam = 0:(ConfigSYS.sectorPerSite*ConfigSYS.cellBeamNum-1)
               [BSREC] = fullRef(ConfigSYS,UE,refBeam,SINR2CQI,BSREC);
          end
          end
%            for iUser = 1:ConfigSYS.totalUENum
%                 SNR = UE(iUser).signalStatus(BSREC.UEBeam(1,iUser), BSREC.UEBeam(2,iUser), BSREC.UEBeam(3,iUser))... 
%                 - noisedBm - ConfigSYS.noiseFigure;
%                 BSREC.CQI(1, iUser) = uint8(size(find(SINR2CQI < SNR),2));
%             end
        
            
           
         

        
    end
   
    
   
    refUEN = BSREC.referUEN;
    outputCQI = BSREC.CQI;
    end
