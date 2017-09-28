function [UE_SINR] = mainSINR (pos)

 sys = Configsys(3);
 Mo = ConfigMo(3);
 ch = ConfigCH(3);
    %disp(BSAntWeights);
    %disp(CELL);
SINR = [];
TotalSites=[];
%for totalSite = 1 :100
 UE  = ConstructUEmobility(sys,Mo);
 pos(1,:) = [ 0 , 0 ];
for row = 2 : 20
    radius = 100 * rand ;
    theta = 2 * pi * rand;
    pos(row , : )= [radius * cos(theta) , radius * sin(theta) ];
	%pos(row,:) = [ 0 , 0 ];
end
disp(pos);
m=(size(pos));

UE_SINR(1,:) = GenerateMultipleSite(0,0,sys,Mo,ch,UE);
%for row = 2:m(1)
%    [UE_SINR(row,:)] = UE_SINR(1,:);
for row = 1:m(1)
    [UE_SINR(row,:)] = GenerateMultipleSite (pos(row,1), pos(row,2),sys,Mo,ch, UE );
	
end

n=(size(UE_SINR));
for row = 1 : n(1)
    for col = 1 : n(2)
        UE_site(row,col)=UE_SINR(row,col).rssi;
    end
end
%UE_site = UE_SINR .rssi;
%disp(UE_site);


[signal , Totals ]=max(UE_site);
%disp(signal);
%disp(Totals);
Total = tabulate( Totals );
disp(Total);


noisedBm = 10*log10(sys.bandwidth) + sys.GaussianNoiseIndBm + sys.noiseFigure;

% normal non-scheduling

BeamSchedule = MultiSiteSchedule(UE_SINR , sys );
size_Schedule = size(BeamSchedule);
disp(BeamSchedule);
	for uei=1:n(2)
		inter=0;
	    [uei_signal , site ]= max( UE_site(:,uei) );
	    %site = 1;
	    Total =[ UE_SINR(site,uei).signalStatus ];
	    [Total,index_1] = max(Total);
	    [Total,index_2] = max(Total);
	    [Total,index_3] = max(Total);
	    index_2=index_2(1,index_3);
	    index_1=index_1(1,index_2,index_3);
	    UE_SINR(1,uei).distance=norm(UE_SINR(1,uei).pos);
		%BeamSlot = find(BeamSchedule(site , :)==index_2);
	    for isite=1:m(1)
			if isite ~= site
			other_status = UE_SINR(isite,uei).signalStatus;
			other_signal = sum(10.^(other_status(:,index_2,index_3)/10));
			inter=inter+ other_signal;
			end
			%disp(inter);
		end
		%disp(inter);
		UE_SINR(1,uei).Throughput = log2(1+((10.^(Total/10))/(inter+10.^(noisedBm/10))))/ sys.cellBeamNum;
		UE_SINR(1,uei).SINR=10*log10(((10.^(Total/10))/(inter+10.^(noisedBm/10) )));
	end
for col=1:n(2)
	sir(1,col)=double(UE_SINR(1,col).SINR);
	dis(1,col)=double(UE_SINR(1,col).distance);
end


%plot(dis,sir,'+');
figure;
hold on;
cdfplot(sir);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% Coloring algorithm scheduling

for uei=1:n(2)
        inter=0;
        [uei_signal , site ]= max( UE_site(:,uei) );
        %site = 1;
        Total =[ UE_SINR(site,uei).signalStatus ];
        [Total,index_1] = max(Total);
        [Total,index_2] = max(Total);
        [Total,index_3] = max(Total);
        index_2=index_2(1,index_3);
        index_1=index_1(1,index_2,index_3);
        UE_SINR(1,uei).distance=norm(UE_SINR(1,uei).pos);
		disp([site,index_2]);
        BeamSlot = find(BeamSchedule(site , :)==index_2);
        disp(BeamSlot);
		disp("//////////////");
        for isite=1:m(1)
            if isite ~= site
            other_status = UE_SINR(isite,uei).signalStatus;
            other_signal = sum(10.^(other_status(:,BeamSchedule(isite ,BeamSlot),index_3)/10));
            inter=inter+ other_signal;
            end
            %disp(inter);
        end
        %disp(inter);
		UE_SINR(1,uei).Throughput2 = log2(1+((10.^(Total/10))/(inter+10.^(noisedBm/10))))/ sys.cellBeamNum;

        UE_SINR(1,uei).SINR2=10*log10(((10.^(Total/10))/(inter+10.^(noisedBm/10) )));
    end
for col=1:n(2)
    sir2(1,col)=double(UE_SINR(1,col).SINR2);
    dis(1,col)=double(UE_SINR(1,col).distance);
end


%plot(dis,sir,'+');
cdfplot(sir2);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%{
%% CSMA-CA DL

BeamSchedule = CSMA(UE_SINR , sys );
BeamSchedule = cell2mat(BeamSchedule);
size_Schedule = size(BeamSchedule);
disp(BeamSchedule);
    for uei=1:n(2)
        inter=0;
        [uei_signal , site ]= max( UE_site(:,uei) );
        %site = 1;
        Total =[ UE_SINR(site,uei).signalStatus ];
        [Total,index_1] = max(Total);
        [Total,index_2] = max(Total);
        [Total,index_3] = max(Total);
        index_2=index_2(1,index_3);
        index_1=index_1(1,index_2,index_3);
        UE_SINR(1,uei).distance=norm(UE_SINR(1,uei).pos);
        BeamSlot = find(BeamSchedule(site , :)==index_2);
        for isite=1:m(1)
            if isite ~= site
				Beam = BeamSchedule(isite ,BeamSlot)
				if Beam == -1
					continue;
				end
				other_status = UE_SINR(isite,uei).signalStatus;
				other_signal = sum(10.^(other_status(:,Beam,index_3)/10));
				inter=inter+ other_signal;
				end
            %disp(inter);
        end
        %disp(inter);
        UE_SINR(1,uei).SINR3=10*log10(((10.^(Total/10))/(inter+10.^(noisedBm/10) )));

    end

for col=1:n(2)
    sir3(1,col)=double(UE_SINR(1,col).SINR3);
    dis(1,col)=double(UE_SINR(1,col).distance);
end

cdfplot(sir3);

%}
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%NS_CSMA-CA DL

BeamSchedule = NS_CSMA(UE_SINR , sys );
BeamSchedule = cell2mat(BeamSchedule);
size_Schedule = size(BeamSchedule);
disp(BeamSchedule);

    for uei=1:n(2)
		UE_SINR(1,uei).Throughput4 = 0;
        inter=0;
        [uei_signal , site ]= max( UE_site(:,uei) );
        %site = 1;
        Total =[ UE_SINR(site,uei).signalStatus ];
        [Total,index_1] = max(Total);
        [Total,index_2] = max(Total);
        [Total,index_3] = max(Total);
        index_2=index_2(1,index_3);
        index_1=index_1(1,index_2,index_3);
        UE_SINR(1,uei).distance=norm(UE_SINR(1,uei).pos);
        BeamSlot = find(BeamSchedule(site , :)==index_2);
		SizeBeam = size(BeamSlot);
		UE_SINR(1,uei).SINR4 = 0;
		for i = 1: SizeBeam(2)
			for isite=1:m(1)
				if isite ~= site
					Beam = BeamSchedule(isite ,BeamSlot(i))
					if Beam == -1
						continue;
					end
					other_status = UE_SINR(isite,uei).signalStatus;
					other_signal = sum(10.^(other_status(:,Beam,index_3)/10));
					inter=inter+ other_signal;
					end
				%disp(inter);
			end
			%disp(inter);
			UE_SINR(1,uei).Throughput4 = UE_SINR(1,uei).Throughput4 + log2(1+((10.^(Total/10))/(inter+10.^(noisedBm/10) )));
			UE_SINR(1,uei).SINR4=UE_SINR(1,uei).SINR4+10*log10(((10.^(Total/10))/(inter+10.^(noisedBm/10) )));
		end
		num = SizeBeam(2);
		disp("//////////num///////////");	
		disp(num);
		UE_SINR(1,uei).SINR4 = UE_SINR(1,uei).SINR4 / SizeBeam(2) ;
		UE_SINR(1,uei).Throughput4 = UE_SINR(1,uei).Throughput4 / size_Schedule(2) ;
    end


for col=1:n(2)
    sir4(1,col)=double(UE_SINR(1,col).SINR4);
    dis(1,col)=double(UE_SINR(1,col).distance);
end

cdfplot(sir4);

legend('normal','coloring','NS CSMA-DL');



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%{

%Test for lowest SINR

for uei=1:n(2)
	inter=0;
	[uei_signal , site ]= max( UE_site(:,uei) );
	%site = 1;
	Total =[ UE_SINR(site,uei).signalStatus ];
	[Total,index_1] = max(Total);
	[Total,index_2] = max(Total);
	[Total,index_3] = max(Total);
	index_2=index_2(1,index_3);
	index_1=index_1(1,index_2,index_3);
	UE_SINR(1,uei).distance=norm(UE_SINR(1,uei).pos);
	%BeamSlot = find(BeamSchedule(site , :)==index_2);
	for isite=1:m(1)
		if isite ~= site
		other_status = UE_SINR(isite,uei).signalStatus;
		other_signal = sum(10.^(other_status/10),1);
		disp(other_signal);
		other_signal = max(other_signal(1,:,index_3));
		disp(other_signal);
		inter=inter+ other_signal;
		end
		%disp(inter);
	end
	disp(10.^(Total/10));
	disp(index_3);
	%disp(inter);
	%UE_SINR(1,uei).Throughput = log2(1+((10.^(Total/10))/(inter+10.^(noisedBm/10))))/ sys.cellBeamNum;
	UE_SINR(1,uei).SINR=10*log10(((10.^(Total/10))/(inter+10.^(noisedBm/10) )));
end
	SINR = [SINR UE_SINR(1,uei).SINR];
	TotalSites = [ TotalSites  totalSite ] ;
	clear UE_SINR;
end
%disp(TotalSites);
figure;
hold on;
%plot(TotalSites , SINR,'+');
cdfplot(SINR);
%}

