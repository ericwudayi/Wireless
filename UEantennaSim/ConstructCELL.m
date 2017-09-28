function [CELL] = ConstructCELL(sys)
% Generate initial state and and Ant. Array for cells

rowNum = sys.cellAntRowNum;
columnNum = sys.cellAntColumnNum;
InclinationAngle = sys.cellAntennaInclinationAngle;
struct_cell.index = 1;
CELL = repmat(struct_cell,1,sys.cellNum);
AntPos_x = sys.cellAntennaElementPos_x;
AntPos_z = sys.cellAntennaElementPos_z;
tmp_antennaPos = zeros(rowNum, columnNum, 3); % (Z axis element, X axis element, coordinates)
tmp_antennaPos_Rx = zeros(rowNum, columnNum, 3);
tmp_antennaPos_Rz = zeros(rowNum, columnNum, 3);


for cellIndex = 1:sys.cellNum
    CELL(cellIndex).index = cellIndex;
    siteIndex = ceil( cellIndex/3 );
    sectorIndex = mod(cellIndex-1,3)+1;
    boresightAngle = sys.cellAntennaBoresight(sectorIndex);
    CELL(cellIndex).boresightAngle = boresightAngle;
    spinAngle = boresightAngle-90; %initial antenna boresight is +y direction
    CELL(cellIndex).pos = sys.siteLocation(siteIndex,:);
    
     
    
    tmp_antennaPos(:,:,1) = repmat(AntPos_x,rowNum,1); 
    
    % add coordinate Y
    tmp_antennaPos(:,:,2) = 0; 
    
    % add coordinate Z
    tmp_antennaPos(:,:,3) = repmat((fliplr(AntPos_z)).',1,columnNum); 
        %(4, 1)                    %(1, 4)
    
    
    % along X-axis ,clockwise rotate inclination angle degrees
    arrayRotateInclination = [1,                      0,                      0;...
                               0,cosd(-InclinationAngle),-sind(-InclinationAngle);...
                               0,sind(-InclinationAngle),cosd(-InclinationAngle)];
    for irow = 1:rowNum
        for icolumn = 1:columnNum
            tmp_antennaPos_Rx(irow,icolumn,:) = arrayRotateInclination*reshape(tmp_antennaPos(irow,icolumn, :),3,1);
        end         
    end
    %when loop finished, #dim(tmp_antennaPos_Rx) = (4, 16, 3)
    
    arrayRotate2Boresight = [cosd(spinAngle),-sind(spinAngle),0;...    %  becuz spinAngle is clockwise
                            sind(spinAngle), cosd(spinAngle),0;...
                            0               ,0                ,1];
                        
    for irow = 1:rowNum
        for icolumn = 1:columnNum
            tmp_antennaPos_Rz(irow,icolumn,:) = arrayRotate2Boresight*reshape(tmp_antennaPos_Rx(irow,icolumn,:),3,1);
        end
    end                
    %when loop finished, #dim(tmp_antennaPos_Rz) = (4, 16, 3)                   
    
    % move cell Anteena to  each site position
    siteLocation = sys.siteLocation(siteIndex,:);
    
    
    %when loop finished, #dim(antennaPos) = (4, 16, 3)  
    
    CELL(cellIndex).antennaPos = tmp_antennaPos_Rz+repmat(reshape(siteLocation,1,1,3),rowNum,columnNum);
    
    %CELL(cellIndex).connected_UE = [];
    %CELL(cellIndex).connected_BSbeam = [];
    %CELL(cellIndex).connected_UEbeam = [];
end



