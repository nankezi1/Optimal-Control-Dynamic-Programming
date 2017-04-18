classdef Dynamic_Solver < handle
    %DYNAMIC_SOLVER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        A
        B
        H
        R
        Q
        N %Number of stages
        S %Number of state values
        C %Number of control values
        %X
        %U
        x_min
        x_max
        u_min
        u_max
        dx
        du
        u_star
        u_star_idx
        J_star
        J_current_state
        J_opt_nextstate
        X1_mesh
        X2_mesh
        X1_mesh_3D
        X2_mesh_3D
        X_next_M1
        X_next_M2
        U_mesh_3D
        J_check
        J_current_state_check 
        J_opt_nextstate_check 
        X_next_M1_check 
        X_next_M2_check
        checkstagesXJF
    end
    
    methods
        
        function obj = Dynamic_Solver()
<<<<<<< HEAD:test/Dynamic_Solver.m
            obj.Q = [0.25, 0; 0, 0.05]*5;
=======
            obj.checkstagesXJF = 1;
            obj.Q = [0.25, 0; 0, 0.05];
>>>>>>> test-linear:Dynamic_Solver.m
            obj.A = [0.9974, 0.0539; -0.1078, 1.1591];
            obj.B = [0.0013; 0.0539];
            obj.R = 0.05*5;
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
        end
        
        function obj = run(obj)
            % K = 0
            % Calculate and store J*NN = h(xi(N)) for all x(N)
            s_r = single(linspace(obj.x_min,obj.x_max,obj.dx));
            [obj.X1_mesh, obj.X2_mesh] = ndgrid(s_r, s_r);
            
            U_mesh = linspace(obj.u_min, obj.u_max, obj.du);
            
            %3d grid for voctorization in calculation of C_star_M
            [obj.X1_mesh_3D,obj.X2_mesh_3D,obj.U_mesh_3D] = ndgrid(s_r,s_r,U_mesh);
            %
<<<<<<< HEAD:test/Dynamic_Solver.m
            obj.J_star = zeros([size(obj.X1_mesh),obj.N],'single');
=======
%             obj.J_star = zeros([size(obj.X1_mesh),obj.N]);
>>>>>>> test-linear:Dynamic_Solver.m
            obj.u_star = obj.J_star;
            [obj.X_next_M1, obj.X_next_M2] = a_D_M(obj);
            obj.J_current_state = g_D(obj);
            obj.J_opt_nextstate = zeros(size(obj.X1_mesh));
            
            % Increase K by 1
            for k=1:obj.N-1
                tic
                k_s = obj.N-k;
<<<<<<< HEAD:test/Dynamic_Solver.m
                J_M = J_state_M(obj, k);
%                 switch k
%                     case {3,20,60,100,129}
%                         hold on
%                         for ii=1:100:obj.du
%                             plot3(obj.X1_mesh,obj.X2_mesh,J_M(:,:,ii))
%                         end
%                         keyboard
%                         close gcf
%                 end                
                [obj.J_star(:,:,k_s),u_star_idx] = min(J_M,[],3);
=======
                J_state_M(obj, k);
>>>>>>> test-linear:Dynamic_Solver.m
                % store UMIN in UOPT(N-k,I)
                obj.u_star(:,:,k_s) = U_mesh(obj.u_star_idx);
                fprintf('step %d - %f seconds\n', k, toc)
            end %end of for loop when k = N
            
            
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
                
%                 Fj = griddedInterpolant(obj.X1_mesh, obj.X2_mesh,...
%                     obj.J_star(:,:,k),'linear');
%                 J(k) = Fj(X(1,k),X(2,k));
                
                X(:,k+1) = a_D(obj,X(1,k),X(2,k),U(k));
                % X(:,k+1) = obj.A*X(:,k) + obj.B*U(k);
            end
            k = k+1;
            %-- Optimal Control Input u*
%             Fu = griddedInterpolant(obj.X1_mesh, obj.X2_mesh,...
%                 obj.u_star(:,:,k),'linear');
%             U(k) = Fu(X(1,k),X(2,k));
            
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
            legend('X1', 'X2', 'u*');
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
        
        function J_state_M(obj,k)
            F = griddedInterpolant(obj.X1_mesh, obj.X2_mesh,...
                obj.J_opt_nextstate,'linear');
            %get next state X
%             [X_next_M1,X_next_M2] = a_D_M(obj);
            %find J final for each state and control (X,U) and add it to next state
            %optimum J*
            
            % % Add up J's % % 
            [obj.J_opt_nextstate, obj.u_star_idx] = ...
                min(F(obj.X_next_M1, obj.X_next_M2) + obj.J_current_state,[],3);
            % % % % % % % % % %
            if(obj.checkstagesXJF)
                obj.J_current_state_check(:,:,k) = obj.J_current_state(50:55,52:57,105);
%                 obj.J_opt_nextstate_check(:,:,k) = obj.J_opt_nextstate(50:55,52:57,105);
                obj.X_next_M1_check(:,:,k) = obj.X_next_M1(50:55,52:57,105);
                obj.X_next_M2_check(:,:,k)  = obj.X_next_M2(50:55,52:57,105);
%                 obj.J_check(:,:,k) = obj.J_opt_nextstate(50:55,52:57,105);
            end
        end
        
        function compare_stages(obj, k)
            fprintf('%% -------------------------------------------\n')
            fprintf('J for stages\n')
            obj.J_check(:,:,k)
            fprintf('%% -----------------------------------------------\n')
            fprintf('J Current stage for stages\n')
            obj.J_current_state_check(:,:,k)
            fprintf('%% -------------------------------------------\n')
            fprintf('J optimum next stage for stages\n')
            obj.J_opt_nextstate_check(:,:,k)
            fprintf('%% -------------------------------------------\n')            
            fprintf('X1 next stage\n')
            obj.X_next_M1_check(:,:,k)
            fprintf('%% -------------------------------------------\n')
            fprintf('X2 next stage\n')
            obj.X_next_M2_check(:,:,k)
        end
        
    end
    
    methods (Static)
        
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
                warning('J_star matrices -- Do NOT match')
                b = false;
            end
        end
        % end
    end
    
    
end

