function [ channelEffect ] = GenerateDynamicChannelEffect( sys,ch, channeli,celli,uei)
% generate 3 phase difference part of channel coefficient 
%    - cell side
%    - UE side
%    - mobility side
% phase difference = 2*pi/lambda * (distance difference)

Cell = celli; 
%timeSlotDuration = mo.timeSlotDuration;

cellAntRowNum = sys.cellAntRowNum;
cellAntColumnNum = sys.cellAntColumnNum;
cellAntNum = cellAntRowNum*cellAntColumnNum;
ueAntRowNum = sys.ueAntRowNum;
ueAntColumnNum = sys.ueAntColumnNum;
ueAntNum = ueAntRowNum*ueAntColumnNum;
NumPath = ch.NLOSClusterNum; %2
NumSubPath = ch.NLOSsubpathNum; %20
lambda = sys.lambda;
phi = 2*pi/lambda; % phi = k


% NumPathStart = 2,
% NumPathEnd = 2
% NumSubPath = 20
% Start = startPoint , End = endPoint 
% phi = k ,=(2*pi/lambda)

scatterT1 = channeli.scatter1; 
scatterT2 = channeli.scatter2;
BSScatterPos = [scatterT1.BSScatterPos;scatterT2.BSScatterPos]; % (4*20, 3)
UEScatterPos = [scatterT1.UEScatterPos;scatterT2.UEScatterPos]; % (4*20, 3)

%NormVectorArrival = zeros(NumPath*NumSubPath, 1);

dist_cellAntEmt2BSS = zeros(NumPath*2*NumSubPath, cellAntNum);
dist_UES2UEAntEmt = zeros(NumPath*2*NumSubPath, ueAntNum);


% cell side                                        


tmp_BSScatterPos = zeros(1,1,3);


% calculate distance difference for each Ant element 
for ipath = 1:NumPath*2
    for isubpath = 1:NumSubPath    
        
        % for the same coordinate as "Cell.antennaPos"
       
        tmp_BSScatterPos(1,1,:) = BSScatterPos((ipath-1)*NumSubPath +isubpath,:);
            %when loop finished : #dim(tmp_BSScatterPos) = (1,1,3)
        
        vector_cellAntEmt2BSS...    % #dim(vector_cellAntEmt2BSS) = (4, 16, 3)
            = bsxfun(@minus,tmp_BSScatterPos,Cell.antennaPos); 
                    % (@minus, (1, 1, 3), 
                    %          (4, 16, 3));
        
        % for distance of vector    
        
        
                
        % for "norm" (it must be 2-D) 
        % computed the norm of x, y, z
        tmp_dist_cellAntEmt2BSS = rssq(vector_cellAntEmt2BSS,3); %distance
                
        % when loop finished : #dim(tmp_dist_cellAntEmt2BSS) = (4, 16, 1)
        
        
        % normalize
        norm_tmp_dist_cellAntEmt2BSS = tmp_dist_cellAntEmt2BSS - min(min(tmp_dist_cellAntEmt2BSS,[],1),[],2);   
                     %(4, 16, 1)            %(4, 16, 1)              %(1,1,1)

        % take Ant element: left to right ->  % up to down, 
        %for the purpose: the same "order of taking Ant elemets" as "GenerateBSAntWeight.m"
        
        
        %4x8->1x32
        dist_cellAntEmt2BSS((ipath-1)*NumSubPath +isubpath,:) = reshape(norm_tmp_dist_cellAntEmt2BSS.',1,cellAntNum); % 1x32
        
        % when loop finished : dist_cellAntEmt2BSS = (4*20, 4*16)
    end
end






% UE side
tmp_UEScatterPos = zeros(1,1,3);
% calculate distance difference for each Ant element
for ipath = 1:NumPath*2
    for isubpath = 1:NumSubPath
        
        % for the same coordinate as "UE.antennaPos"
        
        tmp_UEScatterPos(1,1,:) = UEScatterPos((ipath-1)*NumSubPath +isubpath,:);
            %when loop finished : #dim(tmp_BSScatterPos) = (1,1,3)
        
        vector_UES2UEAntEmt...    % (UErowNum,UEcolumnNum, 3)    % "Emt" means element
            = bsxfun(@minus, uei.antennaPos,... 
                            tmp_UEScatterPos); 
                        
        % for distance of vector 
       
        tmp_dist_ueAntEmt2BSS = rssq(vector_UES2UEAntEmt,3);

        % normalize
        norm_tmp_dist_ueAntEmt2BSS = tmp_dist_ueAntEmt2BSS - min(min(tmp_dist_ueAntEmt2BSS,[],1),[],2);   
                   %(4, 16, 1)            %(4, 16, 1)              %(1,1,1)

        % take Ant element: left to right ->  % up to down, 
        % for the purpose: the same "order of taking Ant elemets" as "GenerateUEAntWeight.m"
        
       

        dist_UES2UEAntEmt((ipath-1)*NumSubPath +isubpath,:) = reshape(norm_tmp_dist_ueAntEmt2BSS.',1,ueAntNum); % (1, 4*4)
        
        
    end
end
%UE_AntGap = ones(80,16)*0.25*exp(1i*pi/180*170);


Cell_AntGap = exp(1i*phi*dist_cellAntEmt2BSS);  %dim = ((NumPathStart+NumPathEnd)*NumSubPath)*CellNumAnt  % (4*20, 4*16) 
Cell_AntGap = Cell_AntGap.'; % cellNumAnt * (NumPath*2*NumSubPath)   % (cellNumAnt, 4*20)

UE_AntGap = exp(1i*phi*dist_UES2UEAntEmt);   %dim = ((NumPathStart+NumPathEnd)*NumSubPath)*UENumAnt  % (4*20, UENumAnt) 
s = size(UE_AntGap);
buffer = reshape(UE_AntGap,1,s(1),s(2)); % (1, 4*20, UENumAnt)

tmp_effect = bsxfun(@times,Cell_AntGap,buffer);% cellNumAnt * ((NumPathStart+NumPathEnd)*NumSubPath) * UENumAnt  


% 2017.3.6
% betewwn BS's scatterers and UE's scatterers
distS2S = [channeli.scatter1.BSS2UESDist;channeli.scatter2.BSS2UESDist];
PhaseDifference_BetweenScatterers = exp(1i*phi*distS2S); % (4*20, 1)
tmp_effect = bsxfun(@times, PhaseDifference_BetweenScatterers.', tmp_effect);

% mobility side
speedEffect = exp(1i*phi*channeli.MoveDistApproachScatter);    % ((NumPathStart+NumPathEnd)*NumSubPath, 1)  % (4 * 20, 1) 

 %(1, 4*20, 1)

channelEffect = bsxfun(@times, tmp_effect, speedEffect.');    % (cellNumAnt, ((NumPathStart+NumPathEnd)*NumSubPath), UENumAnt)  
                                                                  % (64, 4 * 20, 16)




                                                                  
end

