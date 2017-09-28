function [UE_SINR,BeamSchedule] = LAA (pos)

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
for row = 2 : 500
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
%noisedBm = -300;
%{
	for UEs , first half are LAA , others are unlincense

	for sites , first half are LAA , others are unlincense
%}

% normal non-scheduling

	for uei=1:n(2)
		inter=0;
		uei_signal = 0;
		site = 0;
		if uei>n(2)/2
	    	[uei_signal , site ]= max( UE_site(m(1)/2+1:m(1),uei) );
		else
			[uei_signal , site ]= max( UE_site(1:m(1),uei) );

		end
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
			for isector= 1 : sys.sectorPerSite	
				if ((isite ~= site) || (index_1 ~= isector))
				other_status = UE_SINR(isite,uei).signalStatus;
				ibeam = unidrnd(sys.cellBeamNum);
				other_signal = 10.^(other_status(isector,ibeam,index_3)/10);
				inter=inter+ other_signal;
				end
			end
			%disp(inter);
		end
		%disp(inter);
		UE_SINR(1,uei).Throughput = log2(1+((10.^(Total/10))/(inter+10.^(noisedBm/10))))/ sys.cellBeamNum;
		%UE_SINR(1,uei).Throughput =1;
		UE_SINR(1,uei).SINR=10*log10(((10.^(Total/10))/(inter+10.^(noisedBm/10) )));
		if UE_SINR(1,uei).SINR<-10
			UE_SINR(1,uei).Throughput=0;
		end
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
BeamSchedule = MultiSiteSchedule(UE_SINR , sys );
size_Schedule = size(BeamSchedule);


for uei=1:n(2)
        inter=0;
		uei_signal = 0;
		site = 0;
        if uei>n(2)/2
            [uei_signal , site ]= max( UE_site(m(1)/2+1:m(1),uei) );
        else
            [uei_signal , site ]= max( UE_site(1:m(1),uei) );

        end
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
		for isector=1:3
            if ((isite ~= site)||(isector~=index_1))
            other_status = UE_SINR(isite,uei).signalStatus;
            other_signal = sum(10.^(other_status(isector,BeamSchedule(isite ,BeamSlot),index_3)/10));
            inter=inter+ other_signal;
            end
		end
            %disp(inter);
        end
        %disp(inter);
		UE_SINR(1,uei).Throughput2 = log2(1+((10.^(Total/10))/(inter+10.^(noisedBm/10))))/ sys.cellBeamNum;
		%UE_SINR(1,uei).Throughput2=1;
        UE_SINR(1,uei).SINR2=10*log10(((10.^(Total/10))/(inter+10.^(noisedBm/10) )));
    	if UE_SINR(1,uei).SINR2<-10
            UE_SINR(1,uei).Throughput2=0;
        end

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
Numsectors = sys.sectorPerSite;
rows_Schedule = size_Schedule(1);
disp(BeamSchedule);

    for uei=1:n(2)
		UE_SINR(1,uei).Throughput4 = 0;
        inter=0;
		uei_signal = 0;
		site = 0;
		if uei>n(2)/2
            [uei_signal , site ]= max( UE_site(m(1)/2+1:m(1),uei) );
        else
            [uei_signal , site ]= max( UE_site(1:m(1),uei) );

        end
        %site = 1;
		
        Total =[ UE_SINR(site,uei).signalStatus ];
        [Total,index_1] = max(Total);
        [Total,index_2] = max(Total);
        [Total,index_3] = max(Total);
        index_2=index_2(1,index_3);
        index_1=index_1(1,index_2,index_3);
        UE_SINR(1,uei).distance=norm(UE_SINR(1,uei).pos);
		SectorSite = Numsectors*(site-1)+index_1;
		BeamSlot = find(BeamSchedule(SectorSite , :)==index_2);
		SizeBeam = length (BeamSlot);
		UE_SINR(1,uei).SINR4 = 0;
		for i = 1: SizeBeam
			for sector=1:rows_Schedule
				if sector ~= SectorSite
					Beam = BeamSchedule(sector ,BeamSlot(i))
					if Beam == -1
						continue;
					end
					isector = mod(sector,Numsectors);
					if isector == 0
						isector = 3;
					end
					isite = (sector-isector)/Numsectors + 1;
					other_status = UE_SINR(isite,uei).signalStatus;
					other_signal = 10.^(other_status(isector,Beam,index_3)/10);
					inter=inter+ other_signal;
					end
				%disp(inter);
			end
			%disp(inter);
			sinr = 10*log10(((10.^(Total/10))/(inter+10.^(noisedBm/10) )));

			if sinr>-10
				UE_SINR(1,uei).Throughput4 = UE_SINR(1,uei).Throughput4 + log2(1+((10.^(Total/10))/(inter+10.^(noisedBm/10) )));
				%UE_SINR(1,uei).Throughput4=UE_SINR(1,uei).Throughput4+1;
			end
			UE_SINR(1,uei).SINR4=UE_SINR(1,uei).SINR4+sinr;
			
		end
		num = SizeBeam;
		disp("//////////num///////////");	
		disp(num);
		UE_SINR(1,uei).SINR4 = UE_SINR(1,uei).SINR4 / num ;
		%UE_SINR(1,uei).Throughput4 = UE_SINR(1,uei).Throughput4 / num ;

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

