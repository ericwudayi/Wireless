function [ DynamicPartH ] = GenerateDynamicPartH(sys,ch, channelEffect, cellAntennaElementGainPattern, ueAntennaElementGainPattern )
% Finally, generate almost complete channel coefficient


NumCellAnt = sys.cellAntRowNum*sys.cellAntColumnNum;
NumUEAnt = sys.ueAntRowNum*sys.ueAntColumnNum;
NumPath = ch.NLOSClusterNum;
NumSubPath = ch.NLOSsubpathNum;


tmp_DynamicPartH    = zeros(NumCellAnt, NumPath*NumSubPath*2, NumUEAnt);
DynamicPartH        = zeros(NumCellAnt, NumPath*NumSubPath*2, NumUEAnt);

for iNumUEAnt = 1: NumUEAnt
    tmp_DynamicPartH(:,:,iNumUEAnt) = bsxfun(@times, channelEffect(:,:,iNumUEAnt), ueAntennaElementGainPattern); 
end                                                     % (64, 4*20, 1)                    (4*20, 1)
                                            

for iNumCellAnt = 1: NumCellAnt
    DynamicPartH(iNumCellAnt,:,:)  =  bsxfun(@times, tmp_DynamicPartH(iNumCellAnt,:,:), cellAntennaElementGainPattern); 
end                                                     % (1, 4*20, 16)                    (4*20, 1)
%(64, 4*20, 16)



end

