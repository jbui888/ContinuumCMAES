%==========================================================================
% Function that calculates the error between the experimental and simulated
% current for CO 
%
%
% Date: April 24, 2023
% Kaitlin Corpus 
% 
%
%==========================================================================

function CO_error = compute_CO_error(x) % Output is the error and input is an array of the kinetic parameters that will be fitted

% Load the model and data set number 
global model
global num

% Import COMSOL API
import com.comsol.model.*
import com.comsol.model.util.*

% Name each of the kinetic parameters 
alpha_CO = x(1);
i0_CO = 10^(x(2));
BL = x(3);

% Load data from the data analyzer for the specified data set 
if num < 10
        curr_file = ['full_currdata_00' num2str(num) '.mat'];
        load(curr_file)
    else 
        curr_file = ['full_currdata_0' num2str(num) '.mat'];
        load(curr_file)
end

% Turns off all reactions except CO in the model 
model.param.set('H2_on',num2str(0));
model.param.set('CO_on',num2str(1));

if alpha_CO > 0 && alpha_CO < 2 && i0_CO > 0 % Bounds the kinetic parameters to physically reasonable values 

    try % Try getting a solution under different parameters 

        model.param.set('c0K',[num2str(conc),'[M]']); % Sets the electrolyte concentration in the model 
         
        % Sets the parameters that are being fitted by the optimizer
        model.param.set('alpha_c_CO',num2str(alpha_CO)); % Sets the alpha parameter in the model 
        model.param.set('i0_CO298',[num2str(i0_CO),'[A/m^2]']); % Sets the i0 parameter in the model 
        model.param.set('L_bl',[num2str(BL),'[um]']); % Sets the boundary layer parameter in the model

        gamma_CO2 = mphevaluate(model,'gamma_CO2'); % Evaluates the value for gamma CO but is not fitted 

        % Runs the study in the model 
        model.study('std1').run; 
                      
        % Extract all of the simulated current data from the model 
        CO_curr = mphevalpoint(model,'-tcd.iloc_er2');

        % Extract the simulated current data only at the experimental potentials 
        COcurr = (CO_curr(1,comparison_indeces_f))./10; % Converts to correct units of mA cm^-2
        data_CO = (COcurr.');

        % Extract the simulated current data at all simulated experimental potentials 
        COcurr2 = (CO_curr(1,:))./10; % Converts to correct units of mA cm^-2
        data_CO_2 = COcurr2.';
        
        % Calculates the mean squared error between the experimental current and simulated current
        sqerr_co = (co(:,2) - data_CO(:,1)).^2;
        CO_error = mean(sqerr_co);

        % Save the simulated current and seeded parameters data in a csv file 
        if num < 10
        simcurr_data = ['COcurr_data_00' num2str(num) 'test.csv'];
        dlmwrite(simcurr_data,data_CO_2 ,'-append');
        cma_params = ['CO_params_data_00' num2str(num) 'test.csv'];
        dlmwrite(cma_params,[alpha_CO i0_CO gamma_CO2 BL CO_error] ,'-append');
        
        % Save optimal kinetic parameters
        load("variablescmaes.mat","bestever")
        filename = ['newparam_CO_00' num2str(num) '.mat'];
        save(filename, "bestever"); 

        else 
        % Save the simulated current and seeded parameters data in a csv file 
        simcurr_data = ['COcurr_data_0' num2str(num) 'test.csv'];
        dlmwrite(simcurr_data,data_CO_2 ,'-append');

        % Save optimal kinetic parameters
        cma_params = ['CO_params_data_0' num2str(num) 'test.csv'];
        dlmwrite(cma_params,[alpha_CO i0_CO gamma_CO2 BL CO_error] ,'-append');

        load("variablescmaes.mat","bestever")
        filename = ['newparam_CO_0' num2str(num) '.mat'];
        save(filename, "bestever"); 
        end

        % Print the parameters that cma is seeding through 
        fprintf('\t\t Computed at alpha_co = %.20f and i0_co = %.20f and bl = %.20f and gamma_co2 = %.20f and error_co = %.5f\n',alpha_CO,i0_CO,BL,gamma_CO2,CO_error)
      
    catch % If the model does not converge 
%             fprintf('\t\t Model breaks at alpha_co = %.20f and i0_co = %.20f\n',alpha_CO,i0_CO)
            CO_error = Inf;
    end
else % If the cma optimizer tries values outside of physically reasonable values 
%     fprintf('\t\t Not within bounds\n')
    CO_error = Inf; 
end