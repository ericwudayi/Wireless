function [throuput,schedulCount,BSREC] = schedulable(sys,UE,throuput,SINR2CQI,schedulCount,BSREC,timeSlot)

RSrecTime = BSREC.refTime;

[~, UEindex, schedulSetCount] = find(RSrecTime&((timeSlot-RSrecTime)<9)&BSREC.xv(mod(timeSlot-RSrecTime-1,8)+1));
%find(schedulCount); 
% UE have received RS with CQI > 0
% UE received RS not expired (within sweeping period 8 time slots)
% UE is schedulable in this time slot

noisedBm = 10*log10(sys.bandwidth) + sys.GaussianNoiseIndBm+sys.noiseFigure;

schedulUEN = size(schedulSetCount,2);
BSREC.schedUEN(timeSlot) = schedulUEN;

recThrouputUEN = 0;
for intraUser = UEindex
        
       SNR = UE(intraUser).signalStatus(BSREC.UEBeam(1,intraUser),BSREC.UEBeam(2,intraUser),BSREC.UEBeam(3,intraUser))-noisedBm;
       if BSREC.UEwTimer(intraUser) > 0
           recThrouputUEN = recThrouputUEN + 1;
          if SNR < SINR2CQI(BSREC.CQI(intraUser)) 
           throuput(schedulCount(intraUser),intraUser) = 0;
          else
           throuput(schedulCount(intraUser),intraUser) = sys.bandwidth/(10^6) / schedulUEN * log2(1+10^(SINR2CQI(BSREC.CQI(intraUser)) /10));
           %throuput(schedulCount(intraUser),intraUser) = sys.bandwidth/(10^6) * log2(1+10^(SINR2CQI(BSREC.CQI(intraUser)) /10));
          %test
          end
          BSREC.UEwTimer(intraUser) = BSREC.UEwTimer(intraUser)-1;
       end   
             schedulCount(intraUser) = schedulCount(intraUser)-1; 
end
BSREC.recUEN(timeSlot) = recThrouputUEN;



end