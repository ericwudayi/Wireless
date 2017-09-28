function [ DopplerDistance ] = MoveDopplerDist(ch, mo, channeli, uei )
 
% mobility side
% the included angle -> total moving displacement -> phase difference
% Fisrt, calculate the included angle between signal directin and velocity,
% and then calculate the total moving displacement for phase difference
if (uei.speed ~=0)
timeSlotDuration = mo.timeSlotDuration;
%NumPath = ch.NLOSClusterNum;
%NumSubPath = ch.NLOSsubpathNum;



VectorArrival = [bsxfun(@minus,channeli.scatter1.UEScatterPos, uei.pos); bsxfun(@minus,channeli.scatter2.UEScatterPos, uei.pos)];
% ((NumPathStart+NumPathEnd)*NumSubPath, 3) % (4 * 20, 3)


DotProduct = sum(bsxfun(@times,uei.velocity,VectorArrival),2);
% ((NumPathStart+NumPathEnd)*NumSubPath, 3) (4*20,3)
          
%for k=1: NumPath*NumSubPath*2  % 2*20*2                 
    NormVectorArrival = rssq(VectorArrival,2);        % ((NumPathStart+NumPathEnd)*NumSubPath, 1)  
%end

          
% Not Sure: Theta = Theta(n,m,AoA) - Theta(v).
% Temporarily, we assume theta=0, when UE's velocity leaves apart from scatters.

%note:(uei.velocity*NormVectorArrival) cannot be zeros

CosTheta = DotProduct ./ (uei.speed*NormVectorArrival); % sum of every row/(|velocity|*|norm|)
            % ((NumPathStart+NumPathEnd)*NumSubPath, 1)     % ((NumPathStart+NumPathEnd)*NumSubPath, 1) 
            % CosTheta: (4 * 20, 1) 
            DopplerDistance = (uei.speed/3.6)*CosTheta*timeSlotDuration + channeli.MoveDistApproachScatter; % UE.MoveTotalDist is for each VectorArrival(from scatters).
else
    DopplerDistance = channeli.MoveDistApproachScatter;
end
% the effect of velocity * time, i think it is accumulation, which means the displacement.


end

