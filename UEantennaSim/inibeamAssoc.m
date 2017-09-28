function [BSREC] = inibeamAssoc(UE,BSREC,sys)

%initialize

for icell = 1:sys.cellNum
    for ibeam = 1:sys.cellBeamNum
         %BSREC.beamAssoc(icell,ibeam).connect = zeros(1,sys.totalUENum);
         BSREC.beamAssoc(icell,ibeam).UEN = 0;
    end
end

for iue = 1:sys.totalUENum
    icell = UE(iue).servingCellBeam(1);
    ibeam = UE(iue).servingCellBeam(2);
    BSREC.beamAssoc(icell,ibeam).UEN = BSREC.beamAssoc(icell,ibeam).UEN+1;
    BSREC.UEBeam(:,iue) = uint8([icell; ibeam;UE(iue).servingCellBeam(3)]);
end

for icell = 1:sys.cellNum
    for ibeam = 1:sys.cellBeamNum
         BSREC.beamAssoc(icell,ibeam).connect = zeros(1,BSREC.beamAssoc(icell,ibeam).UEN);
    end
end

NumberUE = zeros(sys.cellNum,sys.cellBeamNum);
for iue = 1:sys.totalUENum
    icell = UE(iue).servingCellBeam(1);
    ibeam = UE(iue).servingCellBeam(2);
    %BSREC.beamAssoc(icell,ibeam).UEN = BSREC.beamAssoc(icell,ibeam).UEN+1;
    NumberUE(icell,ibeam) = NumberUE(icell,ibeam)+1;
    BSREC.beamAssoc(icell,ibeam).connect(NumberUE(icell,ibeam)) = iue;
end


%delete NULL

% for icell = 1:sys.cellNum
%     for ibeam = 1:sys.cellBeamNum
%         NumberUE = BSREC.beamAssoc(icell,ibeam).UEN;
%         BSREC.beamAssoc(icell,ibeam).connect((NumberUE+1):end) = [];
%     end
% end

end