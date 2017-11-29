function [UE] = ConstructUEmobility(sys,ConfigMo)
% Generate initial state and and Ant. Array for UE
% Generate: index, startPoint, pos, EndPoint, velocity
%           stayPeriod, timer, state, MoveTotalDistApartScatter
%           antennaPos, BoresightAngle


struct_ue.index = 1;
UE = repmat(struct_ue,1,sys.siteUENum*sys.siteNum);


AntPos_x = sys.ueAntennaElementPos_x;
AntPos_z = sys.ueAntennaElementPos_z;
rowNum = sys.ueAntRowNum;
columnNum = sys.ueAntColumnNum;
originalAntPos = zeros(rowNum, columnNum, 3); % (Z axis element, X axis element, coordinates)

tmp_antennaPos2Vel = zeros(rowNum, columnNum, 3);

%add new distr
dist_limit_min = sys.dist_limit_min;
dist_limit_max = 20;
phi_limit_min = 0;
phi_limit_max = 360;
%add new distr
    % Antenna Position
    % #dim(coordinates, columNum, rowNum) = (4, 8 ,3)
    
    % the Ant. array  has lied on X-Z plane, the origin is at the array center. 
    %         Ant. array 4x4
    
    % add coordinate X
    originalAntPos(:,:,1) = repmat(AntPos_x,rowNum,1);
    
   
    
    % add coordinate Y
    originalAntPos(:,:,2) = 0; 
    %originalAntPos(:,:,3) = fliplr(AntPos_z)
    % add coordinate Z
    originalAntPos(:,:,3) = repmat((fliplr(AntPos_z)).',1,columnNum);
    
     % when finished loop, #dim(antennaPos) = (4, 8, 3)
    

isite = 1; % for one site now
%for isite = 1:sys.siteNum 
    for iue = 1:sys.siteUENum
        % Generate first startPoint
        %x = unifrnd(-sys.ISD/3^0.5,sys.ISD/3^0.5);
        %y = unifrnd(-sys.ISD/2,sys.ISD/2);
        %while(~inpolygon(x,y,boundaryX,boundaryY) || norm([x y]) < 10)
       %     x = unifrnd(-sys.ISD/3^0.5,sys.ISD/3^0.5);
          %  y = unifrnd(-sys.ISD/2,sys.ISD/2);
      %  end
        %add distr
        dist = sqrt(unifrnd(dist_limit_min^2,dist_limit_max^2,1, 1));
        phi = unifrnd(phi_limit_min, phi_limit_max, 1, 1);  
        x = dist * cosd(phi);
        y = dist * sind(phi);
        
        %add distr
        tempIndex = (isite-1)*sys.siteUENum + iue;
        UE(tempIndex).index = tempIndex;
        UE(tempIndex).pos = [ x+sys.siteLocation(isite,1), y+sys.siteLocation(isite,2), sys.ueHeight];
      
        UE(tempIndex).startPoint = UE(tempIndex).pos;
        
        
        
        
     
        dist = 8.0; %interpolation distance
        phi = unifrnd(phi_limit_min, phi_limit_max, 1, 1);  
        
        x_dest = x+(dist * cosd(phi));
        y_dest = y+(dist * sind(phi));
        destDist = norm([x_dest  y_dest]); %the distance of BS to destination
        while (destDist < dist_limit_min ) %prevent UE destination is in BS minimum distance
            phi = unifrnd(phi_limit_min, phi_limit_max, 1, 1);  
            x_dest = x+(dist * cosd(phi));
            y_dest = y+(dist * sind(phi));
            destDist = norm([x_dest  y_dest]);
        end
        
                   
        % prevent UE move into BS region = % prevent dist( BS to (UE route) ) < 10
        c = y_dest*x - x_dest*y;
        a = y-y_dest;
        b = x_dest-x;
        distBS2Route = abs(c)/norm([a  b]); %the distance of BS position to UE moving line
         
        optimP = (x*(x_dest-x) + y*(y_dest-y))/(a^2 + b^2); %solution of minimum point 
         %from BS to UE moving line
        %{ 
        while((destDist < dist_limit_min ) || (optimP < 0 && optimP > -1 && distBS2Route < dist_limit_min)) 
            %-1<optimP<0 mean solution exist
            %random destination again
            phi = unifrnd(phi_limit_min, phi_limit_max, 1, 1);  
            
            x_dest = x+(dist * cosd(phi));
            y_dest = y+(dist * sind(phi));
            destDist = norm([x_dest  y_dest]);
            c = y_dest*x - x_dest*y;
            a = y-y_dest;
            b = x_dest-x;
            distBS2Route = abs(c)/norm([a  b]);
            optimP = (x*(x_dest-x) + y*(y_dest-y))/(a^2 + b^2);
         
        end
	%}
        UE(tempIndex).endPoint = ...
          [ x_dest + sys.siteLocation(isite,1),  y_dest+sys.siteLocation(isite,2),  sys.ueHeight];
        
        
        
        
        UE(tempIndex).speed = ConfigMo.speed;
        
        
       UE(tempIndex).state = 1;
        
        
        % make Ant. boresight toward velocity
        xVector = (x_dest-x);
        yVector = (y_dest-y);
        distVector = norm([xVector, yVector]);
        if(yVector >= 0)
            Theta = acosd(xVector/distVector); % 0 =< acosd =< 180
        else
            Theta = -acosd(xVector/distVector); % 0 =< acosd =< 180
        end
                    
        spinAngle = Theta - 90;  % becuz array boresight direction : +Y axis
        % (spinAngle which is > 180) is impossible 
        if (spinAngle < -180)
            spinAngle = 360 + spinAngle;
        end
                    
                    
        arrayRotate2Velocity = [cosd(spinAngle),-sind(spinAngle),0;...
                                            sind(spinAngle), cosd(spinAngle),0;...
                                            0               ,0                ,1];
        %rotate UE Ant array                    
        for irow = 1:rowNum
            for icolumn = 1:columnNum
            
                tmp_antennaPos2Vel(irow,icolumn,:) = arrayRotate2Velocity*reshape(originalAntPos(irow,icolumn, :),3,1);
                % rotate along Z-axis.
            end     %(1,1,3)                           %(3,3,1)        %(3,1,1)
        end                
        %when loop finished, #dim(tmp_antennaPos2Vel) = (4, 4, 3)                   
    
        % move UE Ant array
        % P.S. UE is at startPoint now.

 UE(tempIndex).antennaPos = tmp_antennaPos2Vel + repmat(reshape(UE(tempIndex).pos,1,1,3),rowNum,columnNum); 
        % #dim(UE(iue).antennaPos) = (4, 4, 3) 
                    
        UE(tempIndex).BoresightAngle = Theta; % Now, Theta is the Angle of Ant. array boresight.
    end
%end







