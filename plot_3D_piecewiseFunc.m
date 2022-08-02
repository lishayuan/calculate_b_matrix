function plot_3D_piecewiseFunc(piecewiseFuncStruct, time_points, maxAmplitude)
%   Function statement: plot the 3D piecewise function and check the timing
%   input:
%           piecewiseFuncStruct - define 3D piecewise function in struct array
%                   each struct contain [start_time, end_time, x_func, y_func, z_func]
%           time_points - the individual time point which separates the 3D piecewise function
%           maxAmplitude - the max amplitude of the 3D piecewise function
% 
% 
%   (c) Lisha Yuan 2019
set(0,'defaultfigurecolor','w')

scale_factor = 1.1;
figure;
for idx = 1:(size(time_points,1)-1)
    start_time = piecewiseFuncStruct(idx).start_time;
    end_time = piecewiseFuncStruct(idx).end_time;
    
    %% Step 1: plot the piecewise function of z-axis
	subplot(3,1,1);
    fplot(piecewiseFuncStruct(idx).z_func,[start_time,end_time],'Linewidth',2);
	hold on
	% plot([end_time,end_time],[-maxAmplitude*scale_factor,maxAmplitude*scale_factor],'--r')
	% hold on
    if (idx == size(time_points,1)-1)
        xlabel('Time (us)','FontName','Times New Roman','FontSize',14,'FontWeight','bold');
        ylabel('(z-axis) Gradient (mT/m)','FontName','Times New Roman','FontSize',14,'FontWeight','bold');
        set(gca,'FontName','Times New Roman','FontSize',14,'FontWeight','bold','LineWidth',2) 
        % title('The piecewise function of z-axis','FontName','Times New Roman','FontSize',20);
        box off
        % axis([piecewiseFuncStruct(1).start_time, piecewiseFuncStruct(end).end_time, -maxAmplitude*scale_factor, maxAmplitude*scale_factor])
        axis([piecewiseFuncStruct(1).start_time, piecewiseFuncStruct(end).end_time, -260, 200])
    end

    %% Step 2: plot the piecewise function of y-axis
	subplot(3,1,2); 
    fplot(piecewiseFuncStruct(idx).y_func,[start_time, end_time],'Linewidth',2);
	hold on
	% plot([end_time,end_time],[-maxAmplitude*scale_factor,maxAmplitude*scale_factor],'--r')
	% hold on
    if (idx == size(time_points,1)-1)
        xlabel('Time (us)','FontName','Times New Roman','FontSize',14,'FontWeight','bold');
        ylabel('(y-axis) Gradient (mT/m)','FontName','Times New Roman','FontSize',14,'FontWeight','bold');
        set(gca,'FontName','Times New Roman','FontSize',14,'FontWeight','bold','LineWidth',2) 
        % title('The piecewise function of y-axis','FontName','Times New Roman','FontSize',20);
        box off
        % axis([piecewiseFuncStruct(1).start_time, piecewiseFuncStruct(end).end_time, -maxAmplitude*scale_factor, maxAmplitude*scale_factor])
        axis([piecewiseFuncStruct(1).start_time, piecewiseFuncStruct(end).end_time, -70, 60])
    end
    
    %% Step 3: plot the piecewise function of x-axis
	subplot(3,1,3);
    fplot(piecewiseFuncStruct(idx).x_func,[start_time, end_time],'Linewidth',2);
	hold on
	% plot([end_time,end_time],[-maxAmplitude*scale_factor,maxAmplitude*scale_factor],'--r')
	% hold on
    if (idx == size(time_points,1)-1)
        xlabel('Time (us)','FontName','Times New Roman','FontSize',14,'FontWeight','bold');
        ylabel('(x-axis) Gradient (mT/m)','FontName','Times New Roman','FontSize',14,'FontWeight','bold');
        set(gca,'FontName','Times New Roman','FontSize',14,'FontWeight','bold','LineWidth',2) 
        % title('The piecewise function of ','FontName','Times New Roman','FontSize',20);
        box off
        % axis([piecewiseFuncStruct(1).start_time, piecewiseFuncStruct(end).end_time, -maxAmplitude*scale_factor, maxAmplitude*scale_factor])
        axis([piecewiseFuncStruct(1).start_time, piecewiseFuncStruct(end).end_time, -200, 200])
    end
    
    clear start_time end_time
end
hold off
grid on