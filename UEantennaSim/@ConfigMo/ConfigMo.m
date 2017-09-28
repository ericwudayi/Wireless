function [ConfigMo] = ConfigMo( UEspeed )
    

ConfigMo.totalTimeSlots = 1;
ConfigMo.timeSlotDuration = 0.0005;   % sec.
ConfigMo.speed = UEspeed;

