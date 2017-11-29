function [ channelEffect ] = GenerateDynamicLOSChannelEffect( sys,ch, channeli,celli,uei,cellAntElementGain,ueAntElementGain)
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

%NormVectorArrival = zeros(NumPath*NumSubPath, 1);

r_rx_1 = bsxfun(@times,sin(channeli.subpathZoA),cos(channeli.subpathAoA));
r_rx_2 = bsxfun(@times,sin(channeli.subpathZoA),sin(channeli.subpathAoA));
r_rx_3 = cos(channeli.subpathZoA);

r_tx_1 = bsxfun(@times,sin(channeli.subpathZoD),cos(channeli.subpathAoD));
r_tx_2 = bsxfun(@times,sin(channeli.subpathZoD),sin(channeli.subpathAoD));
r_tx_3 = cos(channeli.subpathZoD);

Size = size(channeli.subpathZoA);
r_rx = zeros(Size(1),Size(2),3);
r_tx = zeros(Size(1),Size(2),3);
for i=1:Size(1)
    for j=1:Size(2)
	r_rx(i,j,:) =[ r_rx_1(i,j) r_rx_2(i,j) r_rx_3(i,j) ]; 
	r_tx(i,j,:) =[ r_tx_1(i,j) r_tx_2(i,j) r_tx_3(i,j) ];
	 
    end
end
%disp(r_rx);
%pause;
%disp(Size(1));
%pause;
d_uantenna = uei.antennaPos(1,1,:)-uei.antennaPos(1,2,:);
d_bantenna = Cell.antennaPos(1,1,:)-Cell.antennaPos(1,2,:);
v = uei.speed*norm(rand(1,3));
NumUEAnt = sys.ueAntRowNum*sys.ueAntColumnNum;
NumCellAnt = sys.cellAntRowNum * sys.cellAntColumnNum;

%{
	We should have the same order with ueantennagain , cellantennagain,
	so I put the cluster at the second , and ray at the first.
%}
for i = 1:Size(1)
    for j=1:Size(2)
        for r=1:sys.ueAntRowNum
	for c=1:sys.ueAntColumnNum
	    UE_AntGap(j,i,r*c) = exp(1i*sum(r_rx(i,j,:).*uei.antennaPos(r,c,:))*phi);
	end
	end
	
	for r=1:sys.cellAntRowNum
	for c=1:sys.cellAntColumnNum
	    Cell_AntGap(j,i,r*c) = exp(1i*sum(r_tx(i,j,:).*Cell.antennaPos(r,c,:))*phi);
	end
	end
    	SpeedEffect(j,i) = exp(1i*phi * sum(r_rx(i,j,:).*v));

    end
end
channelEffect = cell(1,3);
channelEffect(1,1) = {UE_AntGap} ;
channelEffect(1,2) = {Cell_AntGap};
channelEffect(1,3) = {SpeedEffect} ;
%PartH = zeros(NumUEAnt,NumCellAnt,NumPath);
%{

for ueant = 1:NumUEAnt
    for cellant = 1:NumCellAnt
	for n = 1:NumPath
	    PartH(ueant,cellant,n) = ueAntElementGain(n,:).*cellAntElementGain(n,:).*Cell_AntGap(n,:,cellant).*

%}
%tmp_effect = bsxfun(@times,Cell_AntGap,UE_AntGap);
%channelEffect = bsxfun(@times,tmp_effect,speedEffect);
%disp(channelEffect);
%pause;
