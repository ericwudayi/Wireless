function [ DynamicPartH ] = GenerateDynamicLOSPartH(sys,ch, channelEffect,CHANNEL, cellAntennaElementGainPattern, ueAntennaElementGainPattern )
% Finally, generate almost complete channel coefficient


NumCellAnt = sys.cellAntRowNum*sys.cellAntColumnNum;
NumUEAnt = sys.ueAntRowNum*sys.ueAntColumnNum;
NumPath = ch.NLOSClusterNum;
NumSubPath = ch.NLOSsubpathNum;

UE_AntGap = cell2mat(channelEffect(1,1));
Cell_AntGap = cell2mat(channelEffect(1,2));
SpeedEffect = cell2mat(channelEffect(1,3));

%tmp_DynamicPartH    = zeros(NumUEAnt, NumCellAnt,NumSubPath,2*NumPath);
%disp(NumSubPath);
%pause;
DynamicPartH    = zeros(NumUEAnt, NumCellAnt,2*NumPath);

for iNumUEAnt = 1: NumUEAnt
    for iNumCellAnt = 1: NumCellAnt
    tmp = zeros(NumSubPath , 2*NumPath);
    tmp2 = zeros(NumSubPath , 2*NumPath);
    
    tmp = bsxfun(@times, UE_AntGap(:,:,iNumUEAnt), ueAntennaElementGainPattern); 
    tmp2 = bsxfun(@times, Cell_AntGap(:,:,iNumCellAnt), cellAntennaElementGainPattern); 
    tmp2 = bsxfun(@times,tmp,tmp2);
    %disp(tmp2.*SpeedEffect);
    %pause; 
    tmp2  = bsxfun(@times,SpeedEffect,tmp2);
    DynamicPartH(iNumUEAnt,iNumCellAnt,:) = sqrt(CHANNEL.PathPw/NumSubPath).*sum(tmp2,1);
    end
    
end                              
%{
	LOS normalize factor
%}

for iNumUEAnt = 1 : NumUEAnt
    for iNumCellAnt = 1 : NumCellAnt
        DynamicPartH(iNumUEAnt,iNumCellAnt,:) = DynamicPartH(iNumUEAnt,iNumCellAnt,:)/ sqrt(ch.K+1);
        DynamicPartH(iNumUEAnt,iNumCellAnt,1) = DynamicPartH(iNumUEAnt,iNumCellAnt,1)*sqrt(ch.K);
    end
end
        

                       % (64, 4*20, 1)                    (4*20, 1)

%disp(DynamicPartH);
%pause;

