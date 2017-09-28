function [ UE ] = GenerateMultipleSite( x , y, ConfigSYS, ConfigMo, ConfigCH, UE )
    
ConfigSYS.siteLocation = ...
  [            x                y              ConfigSYS.cellAntennaHeight];
    % Beamforming
    BSAntWeights = GenerateBSAntWeights(ConfigSYS);
    UEAntWeights = GenerateUEAntWeights(ConfigSYS);
    %disp(BSAntWeights);
    CELL = ConstructCELL(ConfigSYS);
    %disp(CELL);

    CHANNEL = ChannelInitial(ConfigSYS,ConfigCH, ConfigMo, CELL, UE);
    
    
   
   
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
%          if timeSlot == 1 %beam Association
%                    [BSREC] = inibeamAssoc(UE,BSREC,ConfigSYS);
            

          %refBeam = timeSlot;
%          for refBeam = 0:(ConfigSYS.sectorPerSite*ConfigSYS.cellBeamNum-1)
%               [BSREC] = fullRef(ConfigSYS,UE,refBeam,SINR2CQI,BSREC);
%          end
%          end
%            for iUser = 1:ConfigSYS.totalUENum
%                 SNR = UE(iUser).signalStatus(BSREC.UEBeam(1,iUser), BSREC.UEBeam(2,iUser), BSREC.UEBeam(3,iUser))... 
%                 - noisedBm - ConfigSYS.noiseFigure;
%                 BSREC.CQI(1, iUser) = uint8(size(find(SINR2CQI < SNR),2));
%             end
        
            
           
         

        
%    end
   
    
   
%    refUEN = BSREC.referUEN;
%    outputCQI = BSREC.CQI;
    end
