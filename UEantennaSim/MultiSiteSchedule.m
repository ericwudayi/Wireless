function [siteBeamDir] = MultiSiteSchedule(UE_SINR ,sys ) 
n = (size(UE_SINR));
siteBeamDir =zeros ( [ n(1) sys.cellBeamNum ] );
siteBeams = [1:sys.cellBeamNum];
siteBeam = cell(n(1),1 );
for i = 1:n(1)
	siteBeam{i} = siteBeams;
end 
%siteBeam = num2cell(siteBeam);
for row = 1 : n(1)
    for col = 1 : n(2)
        UE_site(row,col)=UE_SINR(row,col).rssi;
    end
end
m = size (UE_site) ;
UEsiteBeam = cell ( n(1) , sys.cellBeamNum );
UEAntBeam = zeros (sys.siteUENum);
for uei=1:n(2)
	uei_signal = 0;
	site = 0;
	if uei>n(2)/2
        [uei_signal , site ]= max( UE_site(m(1)/2+1:m(1),uei) );
    else
        [uei_signal , site ]= max( UE_site(1:m(1),uei) );

    end
	
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
for col = 1 : sys.cellBeamNum
	siteBeamDir( 1 , col ) = col;
	all_iue = UEsiteBeam{1,col};
	%disp(size(all_iue));
	%disp("/////");
	size_iue = size(all_iue);
	sitei = 2;
	while(size_iue(2)==0)
		%disp([sitei,col]);
		siteBeamDir(sitei,col) = siteBeam{sitei}(1);
		siteBeam{sitei}(1) = [];
		all_iue = UEsiteBeam{sitei,col};
		size_iue = size(all_iue);
		sitei=sitei+1;
		if sitei==n(1)+1
			break;
		end
	end
	if sitei==n(1)+1	
		continue;
	end
	for isite = sitei : n(1)
		
		UE = UE_SINR(isite,all_iue);
		%disp(size(UE));
		IBeam = [UEAntBeam(all_iue)];
		%disp(IBeam);
		UE = UE(1,:);
		[  UE_size ]= size(UE);
	
		%Status = UE.signalStatus;
		disp("/////");
		signal_UE = zeros(length(all_iue),length(siteBeam{isite}) );
		for ue_i =1 : length(all_iue)
			Status = UE(1,ue_i).signalStatus(:,siteBeam{isite},:);
			%disp(Status);	
			
			signal =sum(10.^(Status/10));
			%disp(signal);
			%disp(signal(1,:,IBeam(ue_i) ));
			%disp(length(siteBeam{isite}));
			%disp(IBeam(ue_i));
			signal = signal(1,:,IBeam(ue_i) );
			%disp(signal);
			signal_UE(uei,:) = signal;
		end
		signal_UE=sum(signal_UE);
		disp(signal_UE);
		[si,index]=min(signal_UE)
			%disp([isite , index]);
		siteBeamDir(isite,col)=siteBeam{isite}(index);
		siteBeam{isite}(index)=[];
			%disp(siteBeam);
			%disp([UEsiteBeam{isite,index,:}]);
			%all_iue = [all_iue  UEsiteBeam{isite,index}];
			%disp(signal);
	end
end
			
		
		



		
