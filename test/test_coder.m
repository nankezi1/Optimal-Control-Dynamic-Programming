function test_coder()
obj.Q = [0.25, 0; 0, 0.05];
obj.A = [0.9974, 0.0539; -0.1078, 1.1591];
obj.B = [0.0013; 0.0539];
obj.R = 0.05;
obj.N = 130;
obj.S = 2;
obj.C = 1;
%obj.X = zeros(obj.S,obj.N);
%obj.U = zeros(obj.C,obj.N);
obj.dx = 100;
obj.du = 1000;
obj.x_max = 3;
obj.x_min = -2.5;
obj.u_max = 10;
obj.u_min = -40;
% K = 0
% Calculate and store J*NN = h(xi(N)) for all x(N)
s_r = linspace(obj.x_min,obj.x_max,obj.dx);
[obj.X1_mesh, obj.X2_mesh] = ndgrid(s_r, s_r);
U_mesh = linspace(obj.u_min, obj.u_max, obj.du);
%3d grid for voctorization in calculation of C_star_M
[obj.X1_mesh_3D,obj.X2_mesh_3D,obj.U_mesh_3D] = ndgrid(s_r,s_r,U_mesh);
%
obj.J_star = zeros([size(obj.X1_mesh),obj.N]);
obj.u_star = obj.J_star;
% Increase K by 1
for k=1:obj.N-1
    
    k_s = obj.N-k;
    J_M = J_state_M(obj, k);
    [obj.J_star(:,:,k_s),u_star_idx] = min(J_M,[],3);
    % store UMIN in UOPT(N-k,I)
    obj.u_star(:,:,k_s) = U_mesh(u_star_idx);
    fprintf('step %d - %f seconds\n', k)
end %end of for loop when k = N
get_optimal_path(obj)
end
function get_optimal_path(obj, X0)
if nargin < 2
    X0 = [2; 1]
end
%Store Optimal controls, UOPT(N-k,I) and min costs, COST(N-k,I)
%for all quantized state points (I = 1,2,..,S) and all stages
% K = 1:N
plot_k_max = obj.N;
v = 1:plot_k_max;
X = zeros(obj.S,obj.N);
U = zeros(obj.C,obj.N);
J = U;
X(:,1) = X0;
for k=1:obj.N-1
    
    Fu = griddedInterpolant(obj.X1_mesh, obj.X2_mesh,...
        obj.u_star(:,:,k),'linear');
    
    U(k) = Fu(X(1,k),X(2,k));
    
    Fj = griddedInterpolant(obj.X1_mesh, obj.X2_mesh,...
        obj.J_star(:,:,k),'linear');
    J(k) = Fj(X(1,k),X(2,k));
    
    X(:,k+1) = a_D(obj,X(1,k),X(2,k),U(k));
    % X(:,k+1) = obj.A*X(:,k) + obj.B*U(k);
end
k = k+1;
%-- Optimal Control Input u*
Fu = griddedInterpolant(obj.X1_mesh, obj.X2_mesh,...
    obj.u_star(:,:,k),'linear');
U(k) = Fu(X(1,k),X(2,k));

%-- Commented -- Cost of path
%Fj = griddedInterpolant(obj.X1_mesh, obj.X2_mesh,...
%   obj.J_star(:,:,k),'linear');
%J(k) = Fj(X(1,k),X(2,k));

%Print Optimal Controls
plot(v,X(1,v))
hold on
plot(v,X(2,v),'r')
plot(v,U(v),'--')
title('Optimal control for initial state X0')
xlabel('stage - k')
ylabel('state and inputs')
grid on
xlim([v(1) v(end)])

end


function [Xnext_M1,Xnext_M2] = a_D_M(obj)
%keyboard;
Xnext_M1 = obj.A(1)*obj.X1_mesh_3D + obj.A(3)*obj.X2_mesh_3D + obj.B(1)*obj.U_mesh_3D;
Xnext_M2 = obj.A(2)*obj.X1_mesh_3D + obj.A(4)*obj.X2_mesh_3D + obj.B(2)*obj.U_mesh_3D;
end


function X1_new = a_D(obj,X1,X2,Ui)
% old function used for get_optimal_path
X1_new = obj.A*[X1;X2] + obj.B*Ui;
end

function J = g_D(obj)
%J = [X1;X2]' * obj.Q * [X1;X2] + Ui' * obj.R * Ui;
J = obj.Q(1)*obj.X1_mesh_3D.^2 + ...
    obj.Q(4)*obj.X2_mesh_3D.^2 + obj.R * obj.U_mesh_3D.^2;
end

function J = J_state_M(obj,k)
F = griddedInterpolant(obj.X1_mesh, obj.X2_mesh,...
    obj.J_star(:,:,obj.N-k+1),'linear');
%get next state X
[X_next_M1,X_next_M2] = a_D_M(obj);
%find J final for each state and control (X,U) and add it to next state
%optimum J*
J = F(X_next_M1,X_next_M2) + g_D(obj);
end


function b = compare_data(obj1,obj2)
% use this function to compare saved datas
% check J* matrix
if( isempty(obj1.J_star) || isempty(obj2.J_star) )
    error('stop throwing empty data at me')
end
%compare
if( isequal(obj1.J_star, obj2.J_star) )
    disp('J_star matrices comparison -- Match!')
    b = true;
else
    %warning('J_star matrices -- Do NOT match')
    b = false;
end
end