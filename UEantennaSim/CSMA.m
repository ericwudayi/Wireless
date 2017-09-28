function [SINR] = CSMA(UE_SINR , sys )

n= (size(UE_SINR) );
siteBeam = cell(n(1) ,1 );
SINR = cell(n(1),1); 
%SINR = [];
for i = 1: n(1)
	siteBeam{i} = randperm(sys.cellBeamNum);
end

%% a simple relation between servingbeam and UEAnt and site
UEsiteBeam = cell ( n(1) , sys.cellBeamNum );
UEAntBeam = zeros (sys.siteUENum);

for row = 1 : n(1)
    for col = 1 : n(2)
        UE_site(row,col)=UE_SINR(row,col).rssi;
    end
end


for uei=1:n(2)
    [uei_signal , site ] =max( UE_site(:,uei) );
    %disp(site);
    Total =[ UE_SINR(site,uei).signalStatus ];
    [Total,index_1] = max(Total);
    [Total,index_2] = max(Total);
    [Total,index_3] = max(Total);
    index_2=index_2(1,index_3);
    %index_1=index_1(1,index_2,index_3);
    UEAntBeam(uei) = index_3 ;
    UEsiteBeam{site,index_2}=[UEsiteBeam{site,index_2} uei];
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
m= (size(siteBeam));
%SINR = cell ( m(1) ,1 );
all_Beams=-1
time = 0;

while all_Beams ~= 0
	time = time +1;
	if(time>48)
		break;
	end
	all_Beams = 0;
	all_signal = zeros(1,m(1) );
	for isite = 1:m(1)
		%all_signal = zeros( 1,m(1) ) ;
		if( length( siteBeam{isite} )>0 )
			iBeam = siteBeam{isite}(1);
			UE_Serve = UEsiteBeam{isite , iBeam };
			for UEs_i = 1 : length(UE_Serve)
				iUEs = UE_Serve(UEs_i);
				UEAnt = UEAntBeam(iUEs);
				for other_site = 1 : m(1)
					if other_site == isite 
						continue;
					end
					if length(siteBeam{other_site}) == 0
						continue;
					end
					Site_SS = UE_SINR(other_site,iUEs).signalStatus;
					Site_SS = sum(10.^( (Site_SS-10) /10) ); %UE antenna power lower 20
					%disp(UEAnt);
					Site_SS = Site_SS (1,siteBeam{other_site}(1) , UEAnt );
					all_signal(1,other_site) = all_signal(1,other_site) + Site_SS;
				end
			end
			%disp(all_signal);
		end
	end
		
	all_signal = log10(all_signal) *10 ;
	%disp(all_signal);
	for isite = 1:m(1)
		if length(siteBeam{isite}) == 0
			SINR{isite} = [SINR{isite} -1 ];
			continue;
		end

		if all_signal(1,isite)< -65 %lower than -65 can transmit
			SINR{isite}=[ SINR{isite} siteBeam{isite}(1) ] ;
			siteBeam{isite}(1)=[];
		else
			SINR{isite} = [SINR{isite} -1 ];

		end
	end
	for isite = 1:m(1)
		all_Beams = all_Beams + length(siteBeam{isite})
	end
end

%disp(time);
%disp(all_signal);
%SINR = str2num(char(SINR)) ;
%siteBeamDir = cell2mat(SINR);
