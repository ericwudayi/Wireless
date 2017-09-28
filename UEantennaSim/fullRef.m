function [BSREC] = fullRef(sys,UE,refVBeam,SINR2CQI,BSREC)

noisedBm = 10*log10(sys.bandwidth) + sys.GaussianNoiseIndBm+sys.noiseFigure;

timeSlot = refVBeam + 1;
refCell = floor(refVBeam/sys.cellBeamNum)+1;
refBeam = refVBeam + 1 - ((refCell-1)*sys.cellBeamNum);

%refBeam = [4 2 4;5 1 3;3 5 1;1 3 5;6 8 7;8 7 6;7 6 8;2 4 2];
refUEN = 0;

%for refCell = 1:3
  for iUser = 1:BSREC.beamAssoc(refCell,refBeam).UEN
    IntraUser = BSREC.beamAssoc(refCell,refBeam).connect(iUser);
    SNR = UE(IntraUser).signalStatus(refCell, refBeam, BSREC.UEBeam(3,IntraUser)) - noisedBm;
    BSREC.CQI(IntraUser) = uint8(size(find(SINR2CQI < (SNR)),2));
    
    if (BSREC.CQI(IntraUser) > 0) 
           refUEN = refUEN + 1;
          
    end
   
  end
%end
BSREC.referUEN(timeSlot) = refUEN;





end