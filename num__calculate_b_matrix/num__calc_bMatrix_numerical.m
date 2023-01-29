%*************************************************************************
%	Script name: num__calc_bMatrix_numerical.m
%
%   Brief description: 
%       calculate b matrix of discrete data (based on numerical integration)
%
%   input:
%       eff_grad_series - the discrete data of effective gradients
%       deta_t - sampling step
%   output:
%       b_matrix - includes six b elements [bxx byy bzz bxy bxz byz]
%
%   Copyright 2023, Lisha Yuan (lishayuan@zju.edu.cn)
%*************************************************************************

function b_matrix = num__calc_bMatrix_numerical(eff_grad_series, deta_t)

gama = 42.5756*10^6;    % 1/(T*s), excluding 2*pi

%% Part I: the gradient time series
func_x = eff_grad_series(:,1);
func_y = eff_grad_series(:,2);
func_z = eff_grad_series(:,3);

%% Part II: numerical integration of the gradient time series
int_func_x = f_int_func_discrete(func_x, deta_t); % the definite integral
int_func_y = f_int_func_discrete(func_y, deta_t);
int_func_z = f_int_func_discrete(func_z, deta_t);

%% Part III: Product
int_func_xx = int_func_x.*int_func_x;
int_func_yy = int_func_y.*int_func_y;
int_func_zz = int_func_z.*int_func_z;
int_func_xy = int_func_x.*int_func_y;
int_func_xz = int_func_x.*int_func_z;
int_func_yz = int_func_y.*int_func_z;

%% Part IV: b-matrix
b_xx = f_int_func_discrete(int_func_xx, deta_t);
b_yy = f_int_func_discrete(int_func_yy, deta_t);
b_zz = f_int_func_discrete(int_func_zz, deta_t);
b_xy = f_int_func_discrete(int_func_xy, deta_t);
b_xz = f_int_func_discrete(int_func_xz, deta_t);
b_yz = f_int_func_discrete(int_func_yz, deta_t);

b_matrix= [b_xx(end) b_yy(end) b_zz(end) b_xy(end) b_xz(end) b_yz(end)]*(2*pi*gama).^2.*10^(-30);


function int_func = f_int_func_discrete(func, deta_t)
%% calculate numerical integration
num_points = length(func);
func_1 = func(1:num_points-1);
func_2 = func(2:num_points);

int_func = zeros(num_points, 1);
int_func(2:num_points) = (cumsum(func_1) + cumsum(func_2))*deta_t*0.5;
