function [ gain ] = antennaGain( degree,HPBW, maxAttenu )
%ANTENNAGAIN Summary of this function goes here
%   Detailed explanation goes here


gain = -min(12*(degree/HPBW).^2,maxAttenu);
% if(abs(degree) >65)
% gain = -1000;
% end





end

