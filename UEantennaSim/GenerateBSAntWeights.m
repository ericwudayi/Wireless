function [ BSAntennaWeights ] = GenerateBSAntWeights( sys )
% Generate BS beamforming

cellBeamNum = sys.cellBeamNum;
cellAntColumnNum = sys.cellAntColumnNum;
cellAntRowNum = sys.cellAntRowNum;
cellAntNum = cellAntColumnNum*cellAntRowNum; % 4*16 = 64
BSAntennaWeights = zeros(cellBeamNum,cellAntNum); 




steeringAngle = (30+(120/cellBeamNum)/2) +(120/cellBeamNum)*(0:cellBeamNum-1); % azimuth to array boresight

%steeringAngle = [37.5, 37.5+15, 37.5+30, 37.5+45, 37.5+60, 37.5+75, 37.5+90, 37.5+105];
elementColumnIndex = 1:cellAntColumnNum; % left to right ->  % up to down
iniAntennaWeight = ones(cellAntRowNum,cellAntColumnNum);
iniAntennaWeight = iniAntennaWeight./sqrt(cellAntNum);
tmp_BSAntennaWeights = zeros(1,cellAntNum);


for iA = 1:cellBeamNum
    for irow = 1:cellAntRowNum 
                      
        tmp_RowAntennaWeights = iniAntennaWeight(irow,:).*exp(1i*2*pi*sys.BSantennaSpacing...
        *( (elementColumnIndex-1)*cosd(steeringAngle(iA)) )/sys.lambda); 
        tmp_BSAntennaWeights(((irow-1)*cellAntColumnNum+1):(irow*cellAntColumnNum)) = tmp_RowAntennaWeights;
            
                                                                             
    end       
    BSAntennaWeights(iA,:) = tmp_BSAntennaWeights;
    
    % reset
    tmp_BSAntennaWeights = zeros(1,cellAntNum);
end


end

