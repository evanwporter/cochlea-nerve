% This example calculates ionic curents in the organ of Corti in response to
% a single tone presented at 2 kHz. For simplicity, the Middle and Outer
% Ear are not included.

oneMNAjob( ...
    ...recalculate=true, ...
    oe_identifier='none', ...
    me_identifier='none', ...
    debug=true,...
    Numstacks=300, ...
    amplitude=0, frequency=2000, ...
    tf_extra=Time(10,'ms'), ...
    fadeDuration=Time(3, 'ms'), ...
    zeroDuration=Time(1,'ms'), ...   
    onset=Time(1, 'ms'), ...
    offset=Time(1, 'ms'), ...
    gain_factor=1.0)