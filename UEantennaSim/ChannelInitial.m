function [ CHANNEL ] = ChannelInitial( sys,ch, Mo, cell,ue )

    struct_channel.pathloss = 0 ;
    CHANNEL = repmat(struct_channel,sys.cellNum,sys.totalUENum);
   
    %for each pair of cell,ue
    for iue = 1:sys.totalUENum
	%simulate for LOS , calculate distance for probability
	distance2D = norm(sys.siteLocation(1:2)-ue.posi(1:2));
	P_LOS = 0;
        for icell = 1:sys.cellNum     
            
            %   pathloss & shadowing factor & smallscale
            if( mod(icell,3) == 1)
	    %   cauculate the probability of LOS.
		  if distance<=18
		      P_LOS = 1;   
		  else
		      P_LOS=18/distance+exp(-distance/36)*(1-18/distance);
		      random = rand;
		      if random > P_LOS
		  	P_LOS = 0;
		      else
			P_LOS = 1;
		      end
		  end
		  if P_LOS ==0
                      CHANNEL(icell,iue).pathLoss = GeneratePathLoss(sys,icell,ue(iue));
                  
                      CHANNEL(icell,iue).shadow   = randn()*ch.SFstd;
                  
                      [ smallScale ] = GenerateSmallScale(ch,cell(icell),ue(iue));
                      CHANNEL(icell,iue).MoveDistApproachScatter = 0;
                      CHANNEL(icell,iue).scatter1 = GenerateScatterPos(sys,smallScale,cell(icell),ue(iue)); % (path*subpath,element)
                      ue(iue).pos = ue(iue).endPoint; % in order to let scatter2 generate scatter of "endPoint"
                      [ smallScale ] = GenerateSmallScale(ch,cell(icell),ue(iue));  
                      CHANNEL(icell,iue).scatter2 = GenerateScatterPos(sys,smallScale,cell(icell),ue(iue));
                      % reset ue.pos to startPoint 
                      ue(iue).pos = ue(iue).startPoint;
		 else 
                      CHANNEL(icell,iue).pathLoss = GenerateLOSPathLoss(sys,icell,ue(iue));
		      CHANNEL(icell,iue).shadow = randn()*ch.LOSSF;
		      
            else
                CHANNEL(icell,iue) = CHANNEL(icell-1,iue);
            end
            
            %  H for static
                                %antennaFieldPattern = 0; % element*path*subpath
            
            
            
        end        
    end
    

end

