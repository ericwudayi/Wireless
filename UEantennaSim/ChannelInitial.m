function [ CHANNEL ] = ChannelInitial( sys,ch, Mo, cell,ue )

    struct_channel.pathloss = 0 ;
    CHANNEL = repmat(struct_channel,sys.cellNum,sys.totalUENum);
    %for each pair of cell,ue
    for iue = 1:sys.totalUENum
        for icell = 1:sys.cellNum     
            
            %   pathloss & shadowing factor & smallscale
            if( mod(icell,3) == 1)
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
                CHANNEL(icell,iue) = CHANNEL(icell-1,iue);
            end
            
            %  H for static
                                %antennaFieldPattern = 0; % element*path*subpath
            
            
            
        end        
    end
    

end

