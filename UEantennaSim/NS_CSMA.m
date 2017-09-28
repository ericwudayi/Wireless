function [SINR] =NS_CSMA(UE_SINR , sys )

n= (size(UE_SINR) );
siteBeam = cell(n(1)*sys.sectorPerSite ,1 );
SINR = cell(n(1)*sys.sectorPerSite,1);
Numsectors = sys.sectorPerSite;
%SINR = [];
%{
for i = 1: n(1)
	siteBeam{i} = randperm(sys.cellBeamNum);
end
%}
%%%%%%%%%%%%%%
for i = 1: n(1)*sys.sectorPerSite
    siteBackoff(i) = unidrnd(2) - 1;
	siteMaxBackoff(i) = 2 ;
end


%% a simple relation between servingbeam and UEAnt and site
UEsiteBeam = cell ( n(1)*sys.sectorPerSite , sys.cellBeamNum );
UEAntBeam = zeros (sys.siteUENum);

for row = 1 : n(1)
    for col = 1 : n(2)
        UE_site(row,col)=UE_SINR(row,col).rssi;
    end
end
m = size(UE_site);

for uei=1:n(2)
    %disp(site);
	uei_signal =0;
	site =0 ;
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
    UEAntBeam(uei) = index_3 ;
    UEsiteBeam{Numsectors*(site-1)+index_1,index_2}=[UEsiteBeam{Numsectors*(site-1)+index_1,index_2} uei];
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
m= (size(siteBeam));
%SINR = cell ( m(1) ,1 );
all_Beams=-1
time = 0;

while 1
	time = time +1;
	if(time>500)
		break;
	end
	all_Beams = 0;
	for i = 1 : m(1)
		all_signal(1,i) = 0 ;
	end
	ActiveSite = find(siteBackoff==0);
	disp("<<<<<<<<<<<");
	disp(ActiveSite);	
	SizeActive = size(ActiveSite);
	for i = 1: n(1)*sys.sectorPerSite
    siteBeam{i} = unidrnd(8);
	end
	for isite = 1: SizeActive(2)
		active = ActiveSite(isite);		
		if( length( siteBeam{active} )>0 )
			iBeam = siteBeam{active}(1);
			UE_Serve = UEsiteBeam{active , iBeam };
				for UEs_i = 1 : length(UE_Serve)
					disp(length(UE_Serve));
					iUEs = UE_Serve(UEs_i);
					UEAnt = UEAntBeam(iUEs);
					for other_site = 1 : m(1)
						if other_site == ActiveSite(isite)
							continue;
						end
						sectorNum = mod(other_site,Numsectors);
						if sectorNum == 0
							sectorNum = Numsectors;
						end
						siteNum = (other_site-sectorNum)/Numsectors + 1;
						disp(other_site);
						disp(siteNum);		
						Site_SS = UE_SINR(siteNum,iUEs).signalStatus;
						Site_SS = 10.^( (Site_SS-10) /10) ; %UE antenna power lower 10
						Site_SS = Site_SS (sectorNum,siteBeam{other_site}(1) , UEAnt );
						all_signal(1,other_site) = all_signal(1,other_site) + Site_SS;
					end
				end
				%disp(all_signal);
		end
	end
	all_signal = log10(all_signal) *10 ;
	for isite = 1:m(1)
		%active = ActiveSite(isite);
		%{
		if length(siteBeam{isite}) == 0
            SINR{isite} = [SINR{isite} -1 ];
            siteBackoff(isite) = -1 ;
            continue;
        end
		%}
		if siteBackoff(isite) == 0
			if all_signal(1,isite)< -100 || all_signal(1,isite)==-Inf %lower than -100 can transmit
				disp(all_signal(1,isite));
				SINR{isite}=[ SINR{isite} siteBeam{isite}(1) ] ;
				siteMaxBackoff(isite) = 2;
				siteBackoff(isite) = unidrnd(2)-1;
			else
				SINR{isite} = [SINR{isite} -1 ];
				if siteMaxBackoff(isite)<8
					siteMaxBackoff(isite) = siteMaxBackoff(isite) * 2;
				end
				siteBackoff(isite) = unidrnd(siteMaxBackoff(isite)) -1;
			end
		else
			if all_signal(1,isite)> -100
				
			else
				siteBackoff(isite) = siteBackoff(isite) -1 ;
			end
			SINR{isite} = [SINR{isite} -1 ];
		end
		

	end
	%{
	for isite = 1:m(1)
		all_Beams = all_Beams + length(siteBeam{isite})
	end
	%}
	disp(siteBackoff);
end

%disp(time);
%disp(all_signal);
%SINR = str2num(char(SINR)) ;
%siteBeamDir = cell2mat(SINR);
