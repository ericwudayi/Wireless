function [UE,CHANNEL] = UpdateUEState(sys,ch,mo,UE,CHANNEL)

% when UE.state = 1, it means UE is going to move from its startPoint.






rowNum = sys.ueAntRowNum;
columnNum = sys.ueAntColumnNum;
timeSlotDuration = mo.timeSlotDuration;



isite = 1;
%for isite = 1:sys.siteNum
    for iue = 1:sys.siteUENum    
        index = (isite-1)*sys.siteUENum + iue;
        
       
       
           
            
                % just do it when starting at startPoint
                if (UE(index).state == 1)
                    %PS. UE is at startPoint now.
                    x = UE(index).startPoint(1);
                    y = UE(index).startPoint(2);
                    x_dest = UE(index).endPoint(1);
                    y_dest = UE(index).endPoint(2);

                    % Ant. Array position move to origin (for rotating)                    
                       
                    ArrayPosMove2Origin = UE(index).antennaPos - repmat(reshape(UE(index).pos,1,1,3),rowNum,columnNum); 
                    
                    % set velocity_x,_y,_z and move
                    UE(index).velocity = [UE(index).speed * (x_dest-x) / norm([(x_dest-x), (y_dest-y)]),...
                        UE(index).speed * (y_dest-y) / norm([(x_dest-x), (y_dest-y)]),0];                   
                                     
                    x = x + UE(index).velocity(1)*timeSlotDuration/(3.6); % 1 timeslot = 1ms,  km/hr -> m/s
                    y = y + UE(index).velocity(2)*timeSlotDuration/(3.6); % 1 timeslot = 1ms,  km/hr -> m/s
               
                    UE(index).pos = [ x  y  sys.ueHeight];
                    UE(index).state = 0;
                    
                    UE(index).antennaPos = ArrayPosMove2Origin + repmat(reshape(UE(index).pos,1,1,3),rowNum,columnNum); 
                    
                    %for one site only
                    CHANNEL(1,index).MoveDistApproachScatter = MoveDopplerDist( ch, mo, CHANNEL(1,index), UE(index) );
                    CHANNEL(2,index).MoveDistApproachScatter = CHANNEL(1,index).MoveDistApproachScatter;
                    CHANNEL(3,index).MoveDistApproachScatter = CHANNEL(1,index).MoveDistApproachScatter;
                                                  
                   
                else
                    
                    ArrayPosMove2Origin = UE(index).antennaPos - repmat(reshape(UE(index).pos,1,1,3),rowNum,columnNum); 
                    % move toward destination
                    x = UE(index).pos(1);
                    y = UE(index).pos(2);
                    x = x + UE(index).velocity(1)*timeSlotDuration/(3.6); % 1 timeslot = 1ms,  km/hr -> m/s
                    y = y + UE(index).velocity(2)*timeSlotDuration/(3.6); % 1 timeslot = 1ms,  km/hr -> m/s
                    
                    UE(index).pos = [ x  y  sys.ueHeight];
                    UE(index).state = 0;

                    
                    UE(index).antennaPos = ArrayPosMove2Origin + repmat(reshape(UE(index).pos,1,1,3),rowNum,columnNum); 
                    
                    CHANNEL(1,index).MoveDistApproachScatter = MoveDopplerDist( ch, mo, CHANNEL(1,index), UE(index) );
                    CHANNEL(2,index).MoveDistApproachScatter = CHANNEL(1,index).MoveDistApproachScatter;
                    CHANNEL(3,index).MoveDistApproachScatter = CHANNEL(1,index).MoveDistApproachScatter;
                     
                    
                end
            
        
    end
    
%end




end


