function [UE_SINR,SiteUETable,engine,CSengine,meandelays,meanCSdelays,Throughput,CSThroughput,SINR_normal,SINR_csma] = latency (pos)

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
for row = 2 : 5
    radius = 100 * rand ;
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
	UE_SINR(1,uei).SINR=[];
	UE_SINR(1,uei).timer=[];
	UE_SINR(1,uei).startTime = 10^5; % This is a value test for no transmit
	%UE_SINR(1,uei).inter=0;
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
	arrival_time  = exprnd(0.5);
	UE_arrival = [UE_arrival arrival_time];
	UE_depart = [UE_depart 1.0e+30];
end
simTime=0;
max_simTime = 4;
while simTime<max_simTime
	[next_event_type,uei,simTime]=timing(UE_arrival,UE_depart);
	for isite = 1:m(1)
		for isector = 1 : sys.sectorPerSite
			disp(simTime);
			engine{isite,isector}.sim_time = simTime;
		end
	end
	if simTime>max_simTime
		break;
	end
	if  next_event_type==1
		disp("im arriving");
        [engine UE_arrival UE_depart UE_SINR]= arrive(engine,UE_SINR,uei,UE_arrival,UE_depart,sys);
	else
		disp("im departing");
	[engine UE_depart UE_SINR]= depart(engine,UE_SINR,uei,UE_arrival,UE_depart,sys);
	end
	disp("simTime");
	disp(simTime);
end


delays=[];
Throughput = 0;
for isite = 1: m(1)
    for isector = 1:3
        delay = engine{isite,isector}.total_of_delays;
        Throughput = Throughput + engine{isite,isector}.Throughput;
        delays=[delays delay];
    end
end
SINR_normal=[];
for uei=1:n(2)
    SINR_normal=[SINR_normal mean(UE_SINR(1,uei).SINR)];
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
sys.backofftime = 0.0001;
for uei = 1:n(2)
    UE_SINR(1,uei).SINR2=[];
    arrival_time  = exprnd(0.5);
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
max_simTime = 4;
disp("now starting CSMA");
t=0;
while simTime<max_simTime
    [next_event_type,uei,simTime]=CStiming(Base_backoff,UE_CSarrival,UE_CSdepart);
    for isite = 1:m(1)
        for isector = 1 : sys.sectorPerSite
            CSengine{isite,isector}.sim_time = simTime;
        end
    end
    if simTime>max_simTime
	break;
    end
    if  next_event_type==1
        disp("im arriving");
        [CSengine UE_CSarrival UE_CSdepart]= CSarrive(CSengine,UE_SINR,uei,UE_CSarrival,UE_CSdepart,sys);
    elseif next_event_type==2
        disp("im departing");
        [CSengine UE_CSdepart UE_SINR]=CSdepart(CSengine,UE_SINR,uei,UE_CSarrival,UE_CSdepart,sys);
    else
	disp("im backoff complete");
	[CSengine UE_CSdepart UE_SINR] = CSbackoff(CSengine,UE_SINR,UE_CSarrival,UE_CSdepart,uei,sys);% uei in here means sitei
    end
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
        delay =  CSengine{isite,isector}.total_of_delays;
	CSThroughput = CSThroughput + CSengine{isite,isector}.Throughput;
        CSdelays=[CSdelays delay];
    end
end
SINR_csma=[];
for uei=1:n(2)
    SINR_csma=[SINR_csma mean(UE_SINR(1,uei).SINR2)];
end

disp(length(UEnumplot));
disp(length(CSdelays));
plot(UEnumplot,CSdelays,'*');
meanCSdelays=mean(CSdelays);
legend('normal','CSMA');
xlabel('Serving UE Per system');
ylabel('total time delays');
figure;
hold on
cdfplot(SINR_normal);
cdfplot(SINR_csma);
legend('normal','CSMA');
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

[min_time_next_event next_event_type] =min ([min_arrival_time min_depart_time min_backoff_time]);

if next_event_type == 1
	disp("im arriving");
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


function [SimEngine,UE_arrival,UE_depart] = CSarrive(SimEngine,UE_SINR,uei,UE_arrival,UE_depart,sys)
sim_site= UE_SINR(1,uei).site(1);
sim_sector = UE_SINR(1,uei).site(2);
engine = SimEngine{sim_site,sim_sector};
engine.time_last_event=engine.sim_time;
disp(engine.sim_time);
UE_arrival(uei) = engine.sim_time+exprnd(0.5);
if engine.BackOff == 1.0e+30&&engine.server_status==engine.IDLE
	engine.BackOff =engine.sim_time+ (unidrnd(engine.MaxBack)-1)*sys.backofftime;
	engine.server_status = engine.BACKOFF;
	engine.num_in_q = 1;
	engine.time_arrival(1) = engine.sim_time;
	engine.uei_arrival(1)=uei;
else
	engine.num_in_q = engine.num_in_q+1;
	engine.time_arrival(engine.num_in_q) = engine.sim_time;
	engine.uei_arrival(engine.num_in_q) = uei;

end
SimEngine{sim_site,sim_sector} = engine;

function [SimEngine,UE_depart,UE_SINR] = CSbackoff(SimEngine,UE_SINR,UE_arrival,UE_depart,siteSector,sys)
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
[bit_rate , Csensing,SINR,inter]= speed(SimEngine,UE_SINR,uei,noisedBm);
%if Csensing >-100
if bit_rate==0
	q_pointer=2;
	temp_uei=uei;
	while bit_rate==0&& q_pointer <  engine.num_in_q
		temp_uei = engine.uei_arrival(q_pointer);
		[bit_rate,Csensing,SINR,inter]=speed(SimEngine,UE_SINR,temp_uei,noisedBm);
		
                q_pointer= q_pointer +1;
		if q_pointer==10
			break;
		end
	end		
	if q_pointer ==10|| q_pointer>= engine.num_in_q
		if engine.MaxBack<8
			engine.MaxBack = engine.MaxBack * 2;
			engine.BackOff = engine.sim_time+(unidrnd(engine.MaxBack)-1)*sys.backofftime;
			engine.server_status = engine.BACKOFF;

		else
			engine.FaultNum = engine.FaultNum+1;
			engine.num_in_q=engine.num_in_q-1;
			engine.time_arrival = engine.time_arrival(2:end);
			engine.uei_arrival = engine.uei_arrival(2:end);
			SimEngine{isite,isector} = engine;
			[SimEngine,UE_depart,UE_SINR] = CSdepart(SimEngine,UE_SINR,uei,UE_arrival,UE_depart,sys);
			return;


		end
	else	
		engine.time_arrival=[engine.time_arrival(q_pointer),engine.time_arrival];
		engine.time_arrival(q_pointer+1)=[];
		engine.uei_arrival=[engine.uei_arrival(q_pointer),engine.uei_arrival];
		engine.uei_arrival(q_pointer+1)=[];
		uei = temp_uei;
		engine.server_status = engine.BUSY;
		engine.servingUei = uei;
		engine.BackOff = 1.0e+30;
		engine.MaxBack = 2;
		engine.beaming = UE_SINR(1,uei).servingBeam;
		disp(engine.num_in_q);
		engine.num_in_q = engine.num_in_q-1;
		disp("backingoff numinq");
		disp(engine.num_in_q);
		engine.time_arrival = engine.time_arrival(2:end);
		engine.uei_arrival = engine.uei_arrival(2:end);
		UE_SINR(1,uei).SINR2=[UE_SINR(1,uei).SINR2 10*log10(SINR)];
		UE_depart(uei)=engine.sim_time+0.1/bit_rate;
		engine.Throughput = engine.Throughput+0.1;
		engine.cross=engine.cross+1;
	end
else
	engine.server_status = engine.BUSY;
	engine.servingUei = uei;
	engine.BackOff = 1.0e+30;
	engine.MaxBack = 2;	
    	engine.beaming = UE_SINR(1,uei).servingBeam;
	disp(engine.num_in_q);
	engine.num_in_q = engine.num_in_q-1;
	disp("backingoff numinq");
	disp(engine.num_in_q);
	engine.time_arrival = engine.time_arrival(2:end);
	engine.uei_arrival = engine.uei_arrival(2:end);
	UE_SINR(1,uei).SINR2=[UE_SINR(1,uei).SINR2 10*log10(SINR)];
	UE_depart(uei)=engine.sim_time+0.1/bit_rate;
	engine.Throughput = engine.Throughput+0.1;	
end	
SimEngine{isite,isector} = engine;

function [SimEngine,UE_depart,UE_SINR] =CSdepart(SimEngine,UE_SINR,uei,UE_arrival,UE_depart,sys)

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
	disp(isite);
	disp(isector);	
else
	noisedBm = 10*log10(sys.bandwidth) + sys.GaussianNoiseIndBm + sys.noiseFigure;
	uei = engine.uei_arrival(1);
        engine.beaming = UE_SINR(1,uei).servingBeam;
	[bit_rate, Csensing, SINR]= speed(SimEngine,UE_SINR,uei,noisedBm);
	%if Csensing>-100
	if bit_rate==0
		engine.MaxBack = engine.MaxBack * 2;
	
		engine.BackOff =engine.sim_time + (unidrnd(engine.MaxBack)-1)*sys.backofftime;
		engine.server_status = engine.BACKOFF;
	else
		engine.server_status = engine.BUSY;
		engine.num_in_q=engine.num_in_q-1;
		engine.delay = engine.sim_time - engine.time_arrival(1);
		engine.total_of_delays = engine.total_of_delays + engine.delay;
		engine.servingUei = uei;
		UE_SINR(1,uei).SINR2=[UE_SINR(1,uei).SINR2 log10(SINR)*10];
		UE_depart(uei)=engine.sim_time+0.1/bit_rate;
		engine.Throughput = engine.Throughput+0.1;	

		engine.time_arrival = engine.time_arrival(2:end);
		engine.uei_arrival = engine.uei_arrival(2:end);
	end	
end
SimEngine{isite,isector}=engine;

function [SimEngine,UE_arrival,UE_depart,UE_SINR] = arrive(SimEngine,UE_SINR,uei,UE_arrival,UE_depart,sys)
sim_site= UE_SINR(1,uei).site(1);
sim_sector = UE_SINR(1,uei).site(2);
engine = SimEngine{sim_site,sim_sector};
engine.time_last_event=engine.sim_time;
disp(engine.sim_time);
UE_arrival(uei) = engine.sim_time+exprnd(0.5);
UE_SINR(1,uei).package = 0.1;
if engine.server_status == engine.BUSY
    engine.num_in_q = engine.num_in_q+1;
    engine.time_arrival(engine.num_in_q) = engine.sim_time;
    engine.uei_arrival(engine.num_in_q) = uei;
else
    engine.delay = 0.0;
    engine.num_custs_delayed=engine.num_custs_delayed+1;
    engine.beaming = UE_SINR(1,uei).servingBeam;
    engine.servingUei = uei;
    engine.server_status = engine.BUSY;
    noisedBm = 10*log10(sys.bandwidth) + sys.GaussianNoiseIndBm + sys.noiseFigure;
    [bit_rate ,Csensing,SINR,inter] = speed(SimEngine,UE_SINR,uei,noisedBm);
      
    UE_SINR(1,uei).SINR=[UE_SINR(1,uei).SINR log10(SINR)*10];
    if bit_rate== 0
		UE_depart(uei)=engine.sim_time+0.02;
		engine.FaultNum = engine.FaultNum + 1;
    else
		UE_SINR(1,uei).package = 0.1;
		UE_SINR(1,uei).startTime = engine.sim_time;
        	UE_depart(uei)=engine.sim_time+0.1/bit_rate;
                UE_SINR(1,uei).inter = inter; 
		[UE_SINR UE_depart]= UpdateSINR (engine.beaming,UE_SINR,UE_depart,engine.sim_time,uei,-1,noisedBm);
		engine.Throughput = engine.Throughput+0.1;	
    end

end
SimEngine{sim_site,sim_sector} = engine;


function [SimEngine,UE_depart,UE_SINR] = depart(SimEngine,UE_SINR,uei,UE_arrival,UE_depart,sys)

isite=UE_SINR(1,uei).site(1);
isector = UE_SINR(1,uei).site(2);
engine = SimEngine{isite,isector};
engine.time_last_event=engine.sim_time;
UE_depart(uei)=1.0e+30;
UE_SINR(1,uei).startTime = 10^5;
noisedBm = 10*log10(sys.bandwidth) + sys.GaussianNoiseIndBm + sys.noiseFigure;
if engine.num_in_q==0
	disp("num_in_q==0");
	engine.server_status = engine.IDLE;
	[UE_SINR UE_depart]= UpdateSINR (engine.beaming,UE_SINR,UE_depart,engine.sim_time,-1,uei,noisedBm);
else
	engine.num_in_q=engine.num_in_q-1;
	engine.delay = engine.sim_time - engine.time_arrival(1);
        if engine.delay<0
           disp(engine.delay);
           disp(uei);
           disp(engine.sim_time);
           pause;
        end
	engine.total_of_delays = engine.total_of_delays + engine.delay;
	uei_d = uei;
        uei = engine.uei_arrival(1);
        UE_SINR(1,uei).startTime = engine.sim_time;
	engine.servingUei =uei;
        engine.beaming = UE_SINR(1,uei).servingBeam;
	[bit_rate, Csensing,SINR,inter]= speed(SimEngine,UE_SINR,uei,noisedBm);
	UE_SINR(1,uei).SINR=[UE_SINR(1,uei).SINR log10(SINR)*10];
        UE_SINR(1,uei).inter = inter;
    if bit_rate== 0
        UE_depart(uei)=engine.sim_time+0.02;
	engine.FaultNum = engine.FaultNum + 1;
    else
        UE_depart(uei)=engine.sim_time+0.1/bit_rate;
	engine.Throughput = engine.Throughput+0.1;	
    end
	[UE_SINR UE_depart]= UpdateSINR (engine.beaming,UE_SINR,UE_depart,engine.sim_time,uei,uei_d,noisedBm);

    engine.time_arrival = engine.time_arrival(2:end);
    engine.uei_arrival = engine.uei_arrival(2:end);
	
end;
SimEngine{isite,isector}=engine;
function [bit_rate,Csensing,SINR,inter] = speed(SimEngine,UE_SINR,uei,noisedBm)

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
if (log10(SINR)*10) < 0
	bit_rate = 0;
else
	bit_rate = log2(1+rssi/(inter+10^(noisedBm/10)));
end
Csensing = log10(Csensing) *10;
disp("bit_rate");
disp(bit_rate);

%{
    update SINR due to depart or arrive
%}
%{
function [UE_SINR index] = UpdateTimer (UE_SINR,sim_time)

UE_time = [UE_SINR(1,:).startTime];

index = find(UE_time<sim_time);
Size = size(index);
for i =1 :Size(2)
time = sim_time - UE_time(1,index(i)).startTime;
UE_SINR(1,index(i)).timer = [UE_SINR(1,index(i)).timer time];
end
%}
function[UE_SINR UE_depart] =UpdateSINR(beam,UE_SINR,UE_depart,sim_time,uei_a,uei_d,noisedBm)

UE_time = [UE_SINR(1,:).startTime];

activeUE = find(UE_time<sim_time);
Size = size(activeUE);
for i =1 :Size(2)
    time = sim_time - UE_SINR(1,activeUE(i)).startTime;
    UE_SINR(1,activeUE(i)).timer = [UE_SINR(1,activeUE(i)).timer time];
    bit_rate = UE_SINR(1,activeUE(i)).SINR;
    bit_rate = bit_rate(end);
    bit_rate = log2(1+10.^(bit_rate/10));
    %disp(bit_rate);
    %%pause;
    UE_SINR(1,activeUE(i)).package = UE_SINR(1,activeUE(i)).package -bit_rate*time;
    UE_SINR(1,activeUE(i)).startTime = sim_time;
end
NumUei = size(UE_SINR(1,:));
NumUei = NumUei(2);
if uei_a ~= -1
    site = UE_SINR(1,uei_a).site(1);
    sector = UE_SINR(1,uei_a).site(2);

    for i = 1:Size(2)
        rssi = 10^((UE_SINR(1,activeUE(i)).rssi)/10);
        ant = UE_SINR(1,activeUE(i)).ueant;
        signal = UE_SINR(site,activeUE(i)).signalStatus;
	add_inter = 10.^(signal(sector,beam,ant)/10);
        UE_SINR(1,activeUE(i)).inter = UE_SINR(1,activeUE(i)).inter + add_inter;
   end
end
if uei_d ~= -1
     site = UE_SINR(1,uei_d).site(1);
     sector = UE_SINR(1,uei_d).site(2);

     for i = 1:Size(2)
        rssi = 10^((UE_SINR(1,activeUE(i)).rssi)/10);
        ant = UE_SINR(1,activeUE(i)).ueant;
        signal = UE_SINR(site,activeUE(i)).signalStatus;
        add_inter = 10.^(signal(sector,beam,ant)/10);
        UE_SINR(1,activeUE(i)).inter = UE_SINR(1,activeUE(i)).inter - add_inter;
   end
end

for i=1:Size(2)
    inter = UE_SINR(1,activeUE(i)).inter;
    SINR = rssi/(inter+(10^(noisedBm/10)));
    bit_rate = log2(1+SINR);
    UE_SINR(1,activeUE(i)).SINR = [UE_SINR(1,activeUE(i)).SINR log10(SINR)*10];
    UE_depart(activeUE(i)) = sim_time+UE_SINR(1,activeUE(i)).package/bit_rate;

end    



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


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
SimEngine.time_arrival=[];
SimEngine.uei_arrival=[];
SimEngine.num_custs_delayed =0;
SimEngine.delay = 0.0;
SimEngine.beaming = 0; %the beam SiteSector is forming (only when busy)
SimEngine.servingUei = 0;
SimEngine.cross=0;

