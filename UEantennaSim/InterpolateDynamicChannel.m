    function [ CHANNEL, uei ] = InterpolateDynamicChannel( sys,ch,mo,cell,uei,CHANNEL )
    % 2 parts: Large scale & Small scale
        for icell = 1:sys.cellNum
            %--- Large scale ---
            %regenerate pathloss
            if( mod(icell,3) == 1)
		if CHANNEL(icell,uei.index).P_LOS==0
                    CHANNEL(icell,uei.index).pathLoss = GeneratePathLoss(sys,icell,uei);
                
		    CHANNEL(icell,uei.index).dynamicSmallScale = InterpolateScatter(ch, CHANNEL(icell,uei.index),uei);
	        else 
                    CHANNEL(icell,uei.index).pathLoss = GenerateLOSPathLoss(sys,icell,uei);
		end
                
            else
                CHANNEL(icell,uei.index) = CHANNEL(icell-1,uei.index);
		if CHANNEL(icell,uei.index).P_LOS==0
                    CHANNEL(icell,uei.index).dynamicSmallScale = CHANNEL(icell-1,uei.index).dynamicSmallScale;
                end
	    end
            
            %--- Small scale ---
            % it seems that, "dynamicSmallScale"s for the three cells in
            % each site are all the same, because scatters are the same there.
            
            
            % for the following 3 functions, they are different for each cell, because the parameters used of each "cell(icell)" is different.
	    if CHANNEL(icell,uei.index).P_LOS==0 
                channelEffect = GenerateDynamicChannelEffect(sys,ch, CHANNEL(icell,uei.index),cell(icell),uei);  %  (cellAntNum, (cluster*2) * subpath),  ueAntNum)
	    [cellAntElementGainPattern, ueAntElementGainPattern] = GenerateDynamicAntElementGainPattern(sys, ch, CHANNEL(icell,uei.index), cell(icell),uei);  %  ((cluster*2)*subpath, 1)
            CHANNEL(icell,uei.index).partH = GenerateDynamicPartH(sys,ch, channelEffect, cellAntElementGainPattern, ueAntElementGainPattern);
	    else
	    [cellAntElementGainPattern, ueAntElementGainPattern] = GenerateDynamicLOSAntElementGainPattern(sys, ch, CHANNEL(icell,uei.index), cell(icell),uei);  %  ((cluster*2)*subpath, 1)
		
	    channelEffect = GenerateDynamicLOSChannelEffect(sys,ch,CHANNEL(icell,uei.index),cell(icell),uei,cellAntElementGainPattern,ueAntElementGainPattern);
            
	    CHANNEL(icell,uei.index).partH = GenerateDynamicLOSPartH(sys,ch, channelEffect,CHANNEL(icell,uei.index), cellAntElementGainPattern, ueAntElementGainPattern);
            
            end

        end


    

end

