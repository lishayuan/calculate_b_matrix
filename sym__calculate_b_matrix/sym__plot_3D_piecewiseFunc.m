%*************************************************************************
%	Script name: sym__plot_3D_piecewiseFunc.m
%
%   Brief description: 
%       plot the 3D piecewise function
%
%   input:
%       combined_grad_pulses - a 3D piecewise function of gradient pulses
%                 each line: [start_time, end_time, x_func, y_func, z_func]
%       time_points - time points which defines the intervals
%       maxAmplitude - the max amplitude of the 3D piecewise function
%
%   Copyright 2023, Lisha Yuan (lishayuan@zju.edu.cn)
%*************************************************************************

function sym__plot_3D_piecewiseFunc(combined_grad_pulses, time_points, maxAmplitude)
set(0,'defaultfigurecolor','w')

scale_factor = 1.1;
figure;
for idx = 1:(size(time_points,1)-1)
    start_time = combined_grad_pulses(idx).start_time;
    end_time = combined_grad_pulses(idx).end_time;
    
    %% Part I: plot the piecewise function of z-axis
	subplot(3,1,1);
    fplot(combined_grad_pulses(idx).z_func, [start_time, end_time], 'Linewidth', 2);
	hold on
	% plot([end_time,end_time],[-maxAmplitude*scale_factor,maxAmplitude*scale_factor],'--r')
	% hold on
    if (idx == size(time_points,1)-1)
        xlabel('Time (us)','FontName','Times New Roman','FontSize',12,'FontWeight','bold');
        ylabel('z-axis','FontName','Times New Roman','FontSize',12,'FontWeight','bold');
        set(gca,'FontName','Times New Roman','FontSize',12,'FontWeight','bold','LineWidth',2) 
        % title('The piecewise function of z-axis','FontName','Times New Roman','FontSize',20);
        box off
        title('Gradient amplitude (mT/m)','FontName','Times New Roman','FontSize',20,'FontWeight','bold');    
        axis([combined_grad_pulses(1).start_time, combined_grad_pulses(end).end_time, -maxAmplitude*scale_factor, maxAmplitude*scale_factor]) % [-260, 200]
    end

    %% Part II: plot the piecewise function of y-axis
	subplot(3,1,2); 
    fplot(combined_grad_pulses(idx).y_func, [start_time, end_time], 'Linewidth', 2);
	hold on
	% plot([end_time,end_time],[-maxAmplitude*scale_factor,maxAmplitude*scale_factor],'--r')
	% hold on
    if (idx == size(time_points,1)-1)
        xlabel('Time (us)','FontName','Times New Roman','FontSize',12,'FontWeight','bold');
        ylabel('y-axis','FontName','Times New Roman','FontSize',12,'FontWeight','bold');
        set(gca,'FontName','Times New Roman','FontSize',12,'FontWeight','bold','LineWidth',2) 
        % title('The piecewise function of y-axis','FontName','Times New Roman','FontSize',20);
        box off
        axis([combined_grad_pulses(1).start_time, combined_grad_pulses(end).end_time, -maxAmplitude*scale_factor, maxAmplitude*scale_factor]) % [-70, 60]
    end
    
    %% Part III: plot the piecewise function of x-axis
	subplot(3,1,3);
    fplot(combined_grad_pulses(idx).x_func, [start_time, end_time], 'Linewidth', 2);
	hold on
	% plot([end_time,end_time],[-maxAmplitude*scale_factor,maxAmplitude*scale_factor],'--r')
	% hold on
    if (idx == size(time_points,1)-1)
        xlabel('Time (us)','FontName','Times New Roman','FontSize',12,'FontWeight','bold');
        ylabel('x-axis','FontName','Times New Roman','FontSize',12,'FontWeight','bold');
        set(gca,'FontName','Times New Roman','FontSize',12,'FontWeight','bold','LineWidth',2) 
        % title('The piecewise function of ','FontName','Times New Roman','FontSize',20);
        box off
        axis([combined_grad_pulses(1).start_time, combined_grad_pulses(end).end_time, -maxAmplitude*scale_factor, maxAmplitude*scale_factor]) % [-200, 200]
    end
    
    clear start_time end_time
end
hold off