function [UE_SINR,SiteUETable,engine,CSengine,meandelays,meanCSdelays,Throughput,CSThroughput] = latency (pos)

global sys;
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
    radius = 10 * rand ;
    theta = 2 * pi * rand;
    pos(row , : )= [radius * cos(theta) , radius * sin(theta) ];
	%pos(row,:) = [ 0 , 0 ];
end
disp(pos);
m=(size(pos));

UE_SINR(1,:) = GenerateMultipleSite(0,0,sys,Mo,ch,UE);
for row = 1:m(1)
    [UE_SINR(row,:)] = GenerateMultipleSite (pos(row,1), pos(row,2),sys,Mo,ch, UE );
	
end


SiteUETable = cell(m(1),sys.sectorPerSite,sys.cellBeamNum);

n=(size(UE_SINR));
for row = 1 : n(1)
    for col = 1 : n(2)
        UE_site(row,col)=UE_SINR(row,col).rssi;
    end
end


[signal , Totals ]=max(UE_site);
Total = tabulate( Totals );
disp(Total);

noisedBm = 10*log10(sys.bandwidth) + sys.GaussianNoiseIndBm + sys.noiseFigure;
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
    UE_SINR(1,uei).ueant =  index_3;
	UE_SINR(1,uei).site  =[site index_1];
	UE_SINR(1,uei).rssi  = uei_signal;
	UE_SINR(1,uei).servingBeam = index_2;
    SiteUETable{site,index_1,index_2} = [ SiteUETable{site,index_1,index_2} uei];
    
end
disp((SiteUETable));
SiteSectorLatency=zeros(m(1),sys.sectorPerSite);
sim_time = 0;

UEnumplot=[]
engine = cell(m(1),sys.sectorPerSite);
CSengine = cell(m(1),sys.sectorPerSite);
for isite = 1 : m(1)
	for isector = 1 : sys.sectorPerSite
		UEnum = 0;
		for ibeam = 1 : sys.cellBeamNum 
			UEnum = UEnum + length(SiteUETable{isite,isector,ibeam});
		end
		engine{isite,isector} = initialize(UEnum);
		UEnumplot = [UEnumplot UEnum];
	end
end
time=0;

UE_arrival = [];
UE_depart = [];
for uei = 1:n(2)
	arrival_time  = exprnd(1);
	UE_arrival = [UE_arrival arrival_time];
	UE_depart = [UE_depart 1.0e+30];
end
simTime=0;
max_simTime = 80;
while simTime<max_simTime
	[next_event_type,uei,simTime]=timing(UE_arrival,UE_depart);
	for isite = 1:m(1)
		for isector = 1 : sys.sectorPerSite
			disp(simTime);
			engine{isite,isector}.sim_time = simTime;
		end
	end
	if  next_event_type==1
		disp("im arriving");
        [engine UE_arrival UE_depart]= arrive(engine,UE_SINR,uei,UE_arrival,UE_depart,sys);
	else
		disp("im departing");
		[engine UE_depart]= depart(engine,UE_SINR,uei,UE_arrival,UE_depart,sys);
	end
	disp("simTime");
	disp(simTime);
end


delays=[];
Throughput = 0;
for isite = 1: m(1)
    for isector = 1:3
        delay = 0;
        if engine{isite,isector}.num_in_q~=0
            delay = engine{isite,isector}.total_of_delays;
            time_arrival = engine{isite,isector}.time_arrival;
			Throughput = Throughput + engine{isite,isector}.Throughput;
            for i=1:length(time_arrival)
                delay = delay + (max_simTime-time_arrival(i));
            end
        end
        delays=[delays delay];
    end
end
figure;
hold on;
disp(delays);
plot(UEnumplot,delays,'+');
meandelays = mean(delays);

%{
	CSMA function is below
%}


for isite = 1 : m(1)
	for isector = 1 : sys.sectorPerSite
		UEnum = 0;
		for ibeam = 1 : sys.cellBeamNum
			UEnum = UEnum + length(SiteUETable{isite,isector,ibeam});
		end
		CSengine{isite,isector} = initialize(UEnum);
	end
end
trace = [];
UE_CSarrival = [];
UE_CSdepart = [];
Base_backoff = [];
sys.backofftime = 0.001;
for uei = 1:n(2)
    arrival_time  = exprnd(1);
    UE_CSarrival = [UE_CSarrival arrival_time];
    UE_CSdepart = [UE_CSdepart 1.0e+30];
end
Numsectors = sys.sectorPerSite;
for siteSector = 1: m(1)*sys.sectorPerSite
	isector = mod(siteSector,Numsectors);
	if isector == 0
		isector = 3;
	end
	isite = (siteSector-isector)/Numsectors + 1;
	backoff = CSengine{isite,isector}.BackOff;
	Base_backoff = [Base_backoff backoff];

end
time =0;
simTime=0;
max_simTime = 80;
disp("now starting CSMA");
while simTime<max_simTime
    [next_event_type,uei,simTime]=CStiming(Base_backoff,UE_CSarrival,UE_CSdepart);
    trace = [trace next_event_type];
	for isite = 1:m(1)
        for isector = 1 : sys.sectorPerSite
            CSengine{isite,isector}.sim_time = simTime;
        end
    end
    if  next_event_type==1
        disp("im arriving");
        [CSengine UE_CSarrival UE_CSdepart]= CSarrive(CSengine,UE_SINR,uei,UE_CSarrival,UE_CSdepart,sys);
    elseif next_event_type==2
        disp("im departing");
        [CSengine UE_CSdepart]=CSdepart(CSengine,UE_SINR,uei,UE_CSarrival,UE_CSdepart,sys);
    else
		disp("im backoff complete");
		[CSengine UE_CSdepart] = CSbackoff(CSengine,UE_SINR,UE_CSdepart,uei,sys);% uei in here means sitei
	end
    disp("simTime");
    disp(simTime);
	%{
		renewing the backoff list
		
	%}
	for siteSector = 1: m(1)*sys.sectorPerSite
		isector = mod(siteSector,Numsectors);
		if isector == 0
			isector = 3;
		end
		isite = (siteSector-isector)/Numsectors + 1;
		backoff = CSengine{isite,isector}.BackOff;
		Base_backoff(siteSector) = backoff;
	end

end

CSdelays=[];
CSThroughput = 0;
for isite = 1: m(1)
    for isector = 1:3
        delay = 0;
        if CSengine{isite,isector}.num_in_q~=0
            delay = CSengine{isite,isector}.total_of_delays;
            time_arrival = CSengine{isite,isector}.time_arrival;
			CSThroughput = CSThroughput + CSengine{isite,isector}.Throughput;
            for i=1:length(time_arrival)
                delay = delay + (max_simTime-time_arrival(i));
            end
        end
        CSdelays=[CSdelays delay];
    end
end

disp(length(UEnumplot));
disp(length(CSdelays));
plot(UEnumplot,CSdelays,'*');
meanCSdelays=mean(CSdelays);


function [next_event_type,uei,sim_time]=timing(UE_arrival,UE_depart)

min_time_next_event = 1.0e+29;

[min_arrival_time,min_arrival_uei]=min(UE_arrival);

[min_depart_time,min_depart_uei]=min(UE_depart);

if(min_arrival_time < min_depart_time)
	min_time_next_event = min_arrival_time
	uei = min_arrival_uei;
	next_event_type = 1;
else
	min_time_next_event = min_depart_time
	uei = min_depart_uei;
	next_event_type = 2;
end

sim_time = min_time_next_event;

function [next_event_type,uei,sim_time]=CStiming(Base_backoff,UE_arrival,UE_depart)

min_time_next_event = 1.0e+29;
[min_backoff_time,min_backoff_sitei]=min(Base_backoff);

[min_arrival_time,min_arrival_uei]=min(UE_arrival);

[min_depart_time,min_depart_uei]=min(UE_depart);

[min_time_next_event next_event_type] =min( [min_arrival_time min_depart_time min_backoff_time]);

if next_event_type == 1
	uei = min_arrival_uei;
elseif next_event_type ==2
	uei  = min_depart_uei;
	disp("disp min_time_next_event");
	disp(uei);
	disp(min_time_next_event);
	disp(UE_depart(uei));
else
	uei = min_backoff_sitei;
	disp("backoff_sitei");
	disp(min_backoff_sitei);
	
	
end
sim_time = min_time_next_event;
%{
if(min_arrival_time < min_depart_time)
	min_time_next_event = min_arrival_time
	uei = min_arrival_uei;
	next_event_type = 1;
else
	min_time_next_event = min_depart_time
	uei = min_depart_uei;
	next_event_type = 2;
end
%}


function [SimEngine,UE_arrival,UE_depart] = CSarrive(SimEngine,UE_SINR,uei,UE_arrival,UE_depart,sys)
sim_site= UE_SINR(1,uei).site(1);
sim_sector = UE_SINR(1,uei).site(2);
engine = SimEngine{sim_site,sim_sector};
engine.time_last_event=engine.sim_time;
disp(engine.sim_time);
UE_arrival(uei) = engine.sim_time+exprnd(1);

if engine.BackOff == 1.0e+30&&engine.server_status==engine.IDLE
	engine.BackOff =engine.sim_time+ (unidrnd(engine.MaxBack)-1)*sys.backofftime;
	engine.server_status = engine.BACKOFF;
end

if engine.server_status == engine.BUSY||engine.server_status == engine.BACKOFF
    engine.num_in_q = engine.num_in_q+1;
    engine.time_arrival(engine.num_in_q) = engine.sim_time;
	engine.uei_arrival(engine.num_in_q) = uei;

else
	disp("?????");
%{
else
	noisedBm = 10*log10(sys.bandwidth) + sys.GaussianNoiseIndBm + sys.noiseFigure;
	[bit_rate Csensing]= speed(SimEngine,UE_SINR,uei,noisedBm)
	if Csensing > -80
		if engine.MaxBack<8
			engine.MaxBack = engine.MaxBack * 2;
		end
		engine.BackOff =engine.sim_time+ (unidrnd(engine.MaxBack)-1)*sys.backofftime;
		engine.num_in_q = engine.num_in_q+1;
		engine.time_arrival(engine.num_in_q) = engine.sim_time;
		engine.uei_arrival(engine.num_in_q) = uei;
		engine.server_status = engine.BACKOFF;
	else
		engine.delay = 0.0;
		engine.servingUei = uei;
		engine.num_custs_delayed=engine.num_custs_delayed+1;
		engine.beaming = UE_SINR(1,uei).servingBeam;
		engine.server_status = engine.BUSY;
		engine.BackOff = 1.0e+30;
		UE_depart(uei) = engine.sim_time + 0.1/bit_rate;
	end
%}
end
SimEngine{sim_site,sim_sector} = engine;

function [SimEngine,UE_depart] = CSbackoff(SimEngine,UE_SINR,UE_depart,siteSector,sys)
Numsectors = sys.sectorPerSite;
isector = mod(siteSector,Numsectors);
if isector == 0
	isector = Numsectors;
end
isite = (siteSector-isector)/Numsectors + 1;
engine = SimEngine{isite,isector};
engine.time_last_event=engine.sim_time;

uei = engine.uei_arrival(1);
noisedBm = 10*log10(sys.bandwidth) + sys.GaussianNoiseIndBm + sys.noiseFigure;
[bit_rate , Csensing]= speed(SimEngine,UE_SINR,uei,noisedBm);
%if Csensing >-100
if bit_rate<2
	if engine.MaxBack<8
		engine.MaxBack = engine.MaxBack * 2;
	end
	engine.BackOff = engine.sim_time+(unidrnd(engine.MaxBack)-1)*sys.backofftime;
	engine.server_status = engine.BACKOFF;
else
	engine.server_status = engine.BUSY;
	engine.servingUei = uei;
	engine.BackOff = 1.0e+30;
	engine.MaxBack = 2;	
    engine.beaming = UE_SINR(1,uei).servingBeam;

	if bit_rate== 0
		UE_depart(uei)=engine.sim_time+30;
		engine.FaultNum = engine.FaultNum + 1;
	else
		UE_depart(uei)=engine.sim_time+0.1/bit_rate;
		engine.Throughput = engine.Throughput+0.1;	
	end
end	
SimEngine{isite,isector} = engine;
function [SimEngine,UE_depart] =CSdepart(SimEngine,UE_SINR,uei,UE_arrival,UE_depart,sys)

isite=UE_SINR(1,uei).site(1);
isector = UE_SINR(1,uei).site(2);
engine = SimEngine{isite,isector};
engine.time_last_event=engine.sim_time;
UE_depart(uei)=1.0e+30;
engine.MaxBack = 2;
engine.BackOff = 1.0e+30;
if engine.num_in_q==0
	disp("num_in_q==0");
	engine.server_status = engine.IDLE;
else
	noisedBm = 10*log10(sys.bandwidth) + sys.GaussianNoiseIndBm + sys.noiseFigure;
	uei = engine.uei_arrival(1);
    engine.beaming = UE_SINR(1,uei).servingBeam;
	[bit_rate, Csensing]= speed(SimEngine,UE_SINR,uei,noisedBm);
	%if Csensing>-100
	if bit_rate<2
		if engine.MaxBack<8
			engine.MaxBack = engine.MaxBack * 2;
		end
	
		engine.BackOff =engine.sim_time + (unidrnd(engine.MaxBack)-1)*sys.backofftime;
		engine.server_status = engine.BACKOFF;
	else
		engine.server_status = engine.BUSY;
		engine.num_in_q=engine.num_in_q-1;
		engine.delay = engine.sim_time - engine.time_arrival(1);
		engine.total_of_delays = engine.total_of_delays + engine.delay;
		engine.servingUei = uei;

		if bit_rate== 0
			UE_depart(uei)=engine.sim_time+30;
			engine.FaultNum = engine.FaultNum + 1;
		else
			UE_depart(uei)=engine.sim_time+0.1/bit_rate;
			engine.Throughput = engine.Throughput+0.1;	
		end

		engine.time_arrival = engine.time_arrival(2:end);
		engine.uei_arrival = engine.uei_arrival(2:end);
	end	
end
SimEngine{isite,isector}=engine;

function [SimEngine,UE_arrival,UE_depart] = arrive(SimEngine,UE_SINR,uei,UE_arrival,UE_depart,sys)
sim_site= UE_SINR(1,uei).site(1);
sim_sector = UE_SINR(1,uei).site(2);
engine = SimEngine{sim_site,sim_sector};
engine.time_last_event=engine.sim_time;
disp(engine.sim_time);
UE_arrival(uei) = engine.sim_time+exprnd(1);
if engine.server_status == engine.BUSY
    engine.num_in_q = engine.num_in_q+1;
    engine.time_arrival(engine.num_in_q) = engine.sim_time;
	engine.uei_arrival(engine.num_in_q) = uei;
else
    engine.delay = 0.0;
    engine.num_custs_delayed=engine.num_custs_delayed+1;
	disp(sys.cellBeamNum);
    engine.beaming = UE_SINR(1,uei).servingBeam;
	engine.servingUei = uei;
    engine.server_status = engine.BUSY;
	noisedBm = 10*log10(sys.bandwidth) + sys.GaussianNoiseIndBm + sys.noiseFigure;
	[bit_rate ,Csensing] = speed(SimEngine,UE_SINR,uei,noisedBm)
	if bit_rate== 0
		UE_depart(uei)=engine.sim_time+30;
		engine.FaultNum = engine.FaultNum + 1;
    else
        UE_depart(uei)=engine.sim_time+0.1/bit_rate;
		engine.Throughput = engine.Throughput+0.1;	
    end

end
SimEngine{sim_site,sim_sector} = engine;


function [SimEngine,UE_depart] = depart(SimEngine,UE_SINR,uei,UE_arrival,UE_depart,sys)

isite=UE_SINR(1,uei).site(1);
isector = UE_SINR(1,uei).site(2);
engine = SimEngine{isite,isector};
engine.time_last_event=engine.sim_time;
UE_depart(uei)=1.0e+30;
if engine.num_in_q==0
	disp("num_in_q==0");
	engine.server_status = engine.IDLE;
else
	engine.num_in_q=engine.num_in_q-1;
	engine.delay = engine.sim_time - engine.time_arrival(1);
	engine.total_of_delays = engine.total_of_delays + engine.delay;
	noisedBm = 10*log10(sys.bandwidth) + sys.GaussianNoiseIndBm + sys.noiseFigure;
	uei = engine.uei_arrival(1);
	engine.servingUei =uei;
    engine.beaming = UE_SINR(1,uei).servingBeam;
	[bit_rate, Csensing]= speed(SimEngine,UE_SINR,uei,noisedBm);

	if bit_rate== 0
        UE_depart(uei)=engine.sim_time+30;
		engine.FaultNum = engine.FaultNum + 1;
    else
        UE_depart(uei)=engine.sim_time+0.1/bit_rate;
		engine.Throughput = engine.Throughput+0.1;	
    end

	engine.time_arrival = engine.time_arrival(2:end);
	engine.uei_arrival = engine.uei_arrival(2:end);
	
end;
SimEngine{isite,isector}=engine;
function [bit_rate,Csensing] = speed(SimEngine,UE_SINR,uei,noisedBm)

SizeSim = size(SimEngine);

site = UE_SINR(1,uei).site(1);
sector = UE_SINR(1,uei).site(2);
Csensing = 0;
SensingBeam = UE_SINR(1,uei).servingBeam;
inter = 0;
rssi = 10^((UE_SINR(1,uei).rssi)/10);
ant = UE_SINR(1,uei).ueant;
engine = SimEngine{site,sector};
for isite =1:SizeSim(1)
	for isector = 1:SizeSim(2)
		if isector == sector && isite == site
			continue;
		end
		if SimEngine{isite,isector}.server_status==SimEngine{isite,isector}.BUSY
			%%CSMA used
			SensingUei = SimEngine{isite,isector}.servingUei;
			disp("SensingUei");
			disp(SensingUei);
			Cssignal = UE_SINR(site,SensingUei).signalStatus;
			SensingAnt = UE_SINR(1,SensingUei).ueant;
			Csensing = Csensing + 10.^((Cssignal(sector,SensingBeam,SensingAnt)-10)/10);
			
			%% CSMA used end 
			beam = SimEngine{isite,isector}.beaming;
			signal = UE_SINR(isite,uei).signalStatus;
			disp(beam);
			disp(ant);
			inter = inter+ 10.^(signal(isector,beam,ant)/10);
		end
	end
end
SINR = rssi/(inter+(10^(noisedBm/10)));
if (log10(SINR)*10) < -20
	bit_rate = 0;
else
	bit_rate = log2(1+rssi/(inter+10^(noisedBm/10)));
end
Csensing = log10(Csensing) *10;
disp("bit_rate");
disp(bit_rate);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%{
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
%}
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%{


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
%}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function [SimEngine] = initialize(UEnum)
SimEngine.Throughput=0;
SimEngine.FaultNum = 0;
SimEngine.IDLE = 0;
SimEngine.BackOff = 1.00e+30;
SimEngine.MaxBack = 2;
SimEngine.BUSY = 1;
SimEngine.BACKOFF=2;
SimEngine.sim_time = 0.0;
SimEngine.server_status = SimEngine.IDLE;
SimEngine.num_in_q = 0;
SimEngine.time_last_event = 0.0;
SimEngine.num_custs_delay = 0;
SimEngine.total_of_delays = 0.0;
SimEngine.area_num_in_q = 0.0;
SimEngine.area_server_status = 0.0;
SimEngine.time_next_event=[];
SimEngine.time_next_event(1) = SimEngine.sim_time + poissrnd(100/UEnum);
SimEngine.time_next_event(2) = 1.0e+30;
SimEngine.time_arrival=[];
SimEngine.uei_arrival=[];
SimEngine.num_custs_delayed =0;
SimEngine.delay = 0.0;
SimEngine.beaming = 0; %the beam SiteSector is forming (only when busy)
SimEngine.servingUei = 0;


