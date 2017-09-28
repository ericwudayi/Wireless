function [throughput] = Throughput ( UE_SINR , Beamschedule)

SizeUE = size( UE_SINR );
SizeBe = size( Beamschedule);
throughput=[0 0 0];
disp(SizeUE(2));
for uei = 1: SizeUE(2)
	throughput(1)=throughput(1)+UE_SINR(1,uei).Throughput;
	throughput(2)=throughput(2)+UE_SINR(1,uei).Throughput2;
	throughput(3)=throughput(3)+UE_SINR(1,uei).Throughput4;
end
	throughput(1) = throughput(1);
	throughput(2) = throughput(2);
	throughput(3) = throughput(3)/500;
	throughput(4) = length(find(Beamschedule~=-1)) / SizeBe(2);
