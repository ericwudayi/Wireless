function [ UEAntennaWeights ] = GenerateUEAntWeights( sys )
% Generate UE beamforming

ueBeamNum = sys.ueBeamNum;
UEAntColumnNum = sys.ueAntColumnNum;
HorizBeamNum = UEAntColumnNum;
UEAntRowNum = sys.ueAntRowNum;

UEAntNum = UEAntColumnNum*UEAntRowNum;
UEAntennaWeights = zeros(ueBeamNum,UEAntNum);





steeringAngle = [-48, -14, 14, 48];
downtiltAngle = -12;


elementColumnIndex = 1:UEAntColumnNum; % left to right ->  % up to down
iniAntennaWeight = ones(UEAntRowNum,UEAntColumnNum);
iniAntennaWeight = iniAntennaWeight./sqrt(UEAntNum);




tmp_UEAntennaWeights = zeros(1,UEAntNum);

  for iA = 1:HorizBeamNum
     for irow = 1:UEAntRowNum
        tmp_antennaWeights = iniAntennaWeight(irow,:).*exp(1i*2*pi*sys.UEantennaSpacing...
        *( (UEAntRowNum-irow)*sind(downtiltAngle)-cosd(downtiltAngle)*(elementColumnIndex-1)*sind(steeringAngle(iA)) )/sys.lambda);
       
        tmp_UEAntennaWeights(((irow-1)*UEAntColumnNum+1):(irow*UEAntColumnNum))= tmp_antennaWeights;
        
     end      
    UEAntennaWeights(iA,:) = tmp_UEAntennaWeights;
    
    % reset
    tmp_UEAntennaWeights = zeros(1,UEAntNum);
  end





end

