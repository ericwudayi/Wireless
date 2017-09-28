function [ CHANNEL ] = NewChannel( sys,ch,cell,uei,CHANNEL )
% Generate New scatters for the New EndPoint, when UE is going to leave 
% the old EndPoint(new startPoint), toward the New EndPoint. 

        % the same smallScale & scatters for every cell in each site
        for icell = 1:sys.cellNum
            if( mod(icell,3) == 1)
                
                  % scatter1 for startPoint, scatter2 for endPoint.
                  CHANNEL(icell,uei.index).scatter1 = CHANNEL(icell,uei.index).scatter2;
                  
                  uei.pos = uei.endPoint; % in order to let scatter2 generate scatter of "endPoint" %2015.1.8                 
                  [ smallScale ] = GenerateSmallScale(ch,cell(icell),uei);                  
                  CHANNEL(icell,uei.index).scatter2 = GenerateScatterPos(sys,smallScale,cell(icell),uei); % (path*subpath,element)
                  
                  uei.pos = uei.startPoint; % reset ue.pos to startPoint %2015.1.8
            else
                CHANNEL(icell,uei.index) = CHANNEL(icell-1,uei.index);
            end
                       
        end
   






end

