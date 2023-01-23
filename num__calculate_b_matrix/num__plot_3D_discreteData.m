%*************************************************************************
%	Script name: num__plot_3D_discreteData.m
%
%   Brief description: 
%       plot the 3D piecewise function
%
%   input:
%       grad_series - 3D discrete gradient data
%       time points - sampling points of the discrete data
%                     (uniformly discretizing the whole time)
%       maxAmplitude - the max amplitude of the 3D discrete data
%
%   Copyright 2023, Lisha Yuan (lishayuan@zju.edu.cn)
%*************************************************************************

function num__plot_3D_discreteData(grad_series, time_points, maxAmplitude)
set(0,'defaultfigurecolor','w')

scale_factor = 1.1;
figure;
subplot(3,1,1);
plot(time_points, grad_series(:,3), 'c', 'Linewidth', 2)
xlabel('Time (us)','FontName','Times New Roman','FontSize',12,'FontWeight','bold');
ylabel('z-axis','FontName','Times New Roman','FontSize',12,'FontWeight','bold');
set(gca,'FontName','Times New Roman','FontSize',12,'FontWeight','bold','LineWidth',2) 
box off
title('Gradient amplitude (mT/m)','FontName','Times New Roman','FontSize',20,'FontWeight','bold');    
axis([time_points(1), time_points(end), -maxAmplitude*scale_factor, maxAmplitude*scale_factor])

subplot(3,1,2);
plot(time_points, grad_series(:,2), 'b', 'Linewidth', 2)
xlabel('Time (us)','FontName','Times New Roman','FontSize',12,'FontWeight','bold');
ylabel('y-axis','FontName','Times New Roman','FontSize',12,'FontWeight','bold');
set(gca,'FontName','Times New Roman','FontSize',12,'FontWeight','bold','LineWidth',2) 
box off
axis([time_points(1), time_points(end), -maxAmplitude*scale_factor, maxAmplitude*scale_factor])

subplot(3,1,3);
plot(time_points, grad_series(:,1), 'r', 'Linewidth', 2)
xlabel('Time (us)','FontName','Times New Roman','FontSize',12,'FontWeight','bold');
ylabel('x-axis','FontName','Times New Roman','FontSize',12,'FontWeight','bold');
set(gca,'FontName','Times New Roman','FontSize',12,'FontWeight','bold','LineWidth',2) 
box off
axis([time_points(1), time_points(end), -maxAmplitude*scale_factor, maxAmplitude*scale_factor])