function [ servingCellBeam,signalStatus,rssi,CELL] = DynamicAssociation( sys,ch,uei,CHANNEL,CELL,BSAntWeights,UEAntWeights)
%   for each cell
%   for each beam direction -> generate H -> H + PL + SF 
%                     -> decide best cell & beam index

% BSAntWeights x UEAntWeights x channel coefficients

subpathNum = ch.NLOSsubpathNum;
BSbeamNum = sys.cellBeamNum;
UEbeamNum = sys.ueBeamNum;

%sizeBSAntWeights = size(BSAntWeights);
sizeUEAntWeights = size(UEAntWeights);

BSAntWeights = BSAntWeights.'; % (NumCellAnt, NumCellBeam) = (NumCellAnt, NumCellBeam, 1)   %conjugate transpose BSAntWeights
UEAntWeights = conj(reshape(UEAntWeights,1,sizeUEAntWeights(1),sizeUEAntWeights(2))); % (1, NumUEBeam, NumUEAnt)
signalStatus = zeros(sys.cellNum,BSbeamNum,UEbeamNum);

rssi = -10000;

for icell = 1:sys.cellNum
    CH = CHANNEL(icell,uei.index); 
    partH = CH.partH;  % (NumCellAnt, 4*20, NumUEAnt)
    PL = CH.pathLoss; 
    SF = CH.shadow;
    for ibeamBS = 1:BSbeamNum
        temp_H = bsxfun(@times,BSAntWeights(:,ibeamBS),partH); % (NumCellAnt, 4*20, NumUEAnt)        
        for ibeamUE = 1:UEbeamNum
            H = bsxfun(@times,UEAntWeights(1,ibeamUE,:),temp_H); % (NumCellAnt, 4*20, NumUEAnt)
            temp_impulse = sum(H,3); % (NumCellAnt, 4*20)
            %temp_impulse = sum(H(:,:,1),1); % for testing UE beamforming
            temp_impulse = sum(temp_impulse,1); % (1, 4*20)
            %temp_impulse = temp_impulse.';   % (4*20, 1)
            temp_impulse = reshape(temp_impulse.',ch.NLOSsubpathNum,ch.NLOSClusterNum*2); % (20, 4)
            temp_impulse = sum(temp_impulse,1); % (1, 4) = (1, path*2)                                   
            pathPw = CH.dynamicSmallScale.pathPw;   % (2, 2) = [startPath1Pw, startPath2PW; endPath1Pw, endPath2PW]
            %pathPw = pathPw.';   % (2, 2) = [startPath1Pw, endPath1Pw; startPath2PW, endPath2PW]
            pathPw = reshape(pathPw.',1,ch.NLOSClusterNum*2);  % (1, 4) = [startPath1Pw, startPath2PW, endPath1Pw, endPath2PW]                       
            
            impulseResponse = ((pathPw/subpathNum).^0.5).*temp_impulse; % (1, 4)
           
            beamform_path_gain = 10*log10( (sum(abs(impulseResponse).^2)) ); %  impluse = complex strength            
            signalPowerIndBm = sys.eNodeBPowerIndBm + sys.cellAntennaGain + beamform_path_gain + sys.ueAntennaGain -PL -SF ;
            signalStatus(icell,ibeamBS,ibeamUE) = signalPowerIndBm; 
            %find the highest power cell,beam combination
            if(signalPowerIndBm > rssi)
                rssi = signalPowerIndBm;
                servingCellBeam = uint8([icell,ibeamBS,ibeamUE]);
            end
        end
    end

end

% store each ue's index under "serving cell", ex: [3,8,11,15,23,...]
%CELL(servingCellBeam(1)).connected_UE = [ CELL(servingCellBeam(1)).connected_UE uei.index ];   
% store each cell's beam index under "serving cell", ex: [1,2,1,3,5,5,...]
%CELL(servingCellBeam(1)).connected_BSbeam = [ CELL(servingCellBeam(1)).connected_BSbeam servingCellBeam(2) ];

%CELL(servingCellBeam(1)).connected_UEbeam = [ CELL(servingCellBeam(1)).connected_UEbeam servingCellBeam(3) ];

end

