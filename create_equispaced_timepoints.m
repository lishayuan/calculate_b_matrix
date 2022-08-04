function  create_time_points = create_equispaced_timepoints(yFirstTime, yLastTime, Nspen)

time_range = yLastTime-yFirstTime;
delta_time = time_range/(Nspen-1);
create_time_points = (yFirstTime:delta_time:yLastTime)';

