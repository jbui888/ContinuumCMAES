%==========================================================================
% Function that calculates the error between the experimental and simulated
% current for H2
%
%
% Date: April 24, 2023
% Kaitlin Corpus 
% 
%
%==========================================================================

function H2_error = compute_H2_error(x) % Output is the error and input is an array of the kinetic parameters that will be fitted

% Load the model and data set number 
global model
global num

% Import COMSOL API
import com.comsol.model.*
import com.comsol.model.util.*

% Name each of the kinetic parameters 
alpha_H2 = x(1);
i0_H2 = 10^(x(2));

% Load data from the data analyzer and the CO kinetic parameters for the specified data set 
if num < 10
        curr_file = ['full_currdata_00' num2str(num) '.mat'];
        load(curr_file)
        CO_param_file =  ['newparam_CO_00' num2str(num) '.mat'];
        load(CO_param_file)
    else 
        curr_file = ['full_currdata_0' num2str(num) '.mat'];
        load(curr_file)
        CO_param_file =  ['newparam_CO_0' num2str(num) '.mat'];
        load(CO_param_file)
end

% Extracts the fitted CO kinetic parameters
COparam = bestever.x;
alpha_CO = COparam(1);
i0_CO = 10^(COparam(2));
BL = COparam(3);

% Turns on both reactions 
model.param.set('H2_on',num2str(1));
model.param.set('CO_on',num2str(1));

model.param.set('c0K',[num2str(conc),'[M]']); % Sets the electrolyte concentration in the model 
model.param.set('L_bl',[num2str(BL),'[um]']); % Sets the boundary layer parameter in the model

if alpha_H2 > 0 && alpha_H2 < 2.5 && i0_H2 > 0 && i0_H2 < 10  % Bounds the kinetic parameters to physically reasonable values
    
    try % Try getting a solution under different parameters
        model.param.set('alpha_c_CO',num2str(alpha_CO)); % Sets the fitted alpha parameter for CO in the model 
        model.param.set('i0_CO298',[num2str(i0_CO),'[A/m^2]']);  % Sets the fitted i0 parameter for CO in the model 

        % Sets the parameters that are being fitted by the optimizer
        model.param.set('alpha_c_HER',num2str(alpha_H2)); % Sets the fitted alpha parameter for H2 in the model 
        model.param.set('i0_HER298',[num2str(i0_H2),'[A/m^2]']); % Sets the H2 parameter in the model 

        % Runs the study in the model 
        model.study('std1').run; 
                      
        % Extract all of the simulated current data from the model 
        HER_curr = mphevalpoint(model,'-tcd.iloc_er1');

        % Extract the simulated current data only at the experimental potentials 
        HERcurr = (HER_curr(1,comparison_indeces_f_2))./10; % Converts to correct units of mA cm^-2
        data_H2 = HERcurr.';
        
        % Extract the simulated current data at all simulated experimental potentials 
        HERcurr2 = (HER_curr(1,:))./10; % Converts to correct units of mA cm^-2
        data_H2_2 = HERcurr2.';

        % Calculates the mean squared error between the experimental current and simulated current
        sqerr_h2 = (h2(:,2) - data_H2(:,1)).^2;
        H2_error = mean(sqerr_h2);

        % Save the simulated current and seeded parameters data in a csv file 
        if num < 10
        simcurr_data = ['H2curr_data_00' num2str(num) 'test.csv'];
        dlmwrite(simcurr_data,data_H2_2 ,'-append');
        cma_params = ['H2_params_data_00' num2str(num) 'test.csv'];
        dlmwrite(cma_params,[alpha_H2 i0_H2 H2_error] ,'-append');
        
        % Save optimal kinetic parameters
        load("variablescmaes.mat","bestever")
        filename = ['newparam_H2_00' num2str(num) '.mat'];
        save(filename, "bestever"); 

        else 
        % Save the simulated current and seeded parameters data in a csv file 
        simcurr_data = ['H2curr_data_0' num2str(num) 'test.csv'];
        dlmwrite(simcurr_data,data_H2_2 ,'-append');

        % Save optimal kinetic parameters
        cma_params = ['H2_params_data_0' num2str(num) 'test.csv'];
        dlmwrite(cma_params,[alpha_H2 i0_H2 H2_error] ,'-append');

        load("variablescmaes.mat","bestever")
        filename = ['newparam_H2_0' num2str(num) '.mat'];
        save(filename, "bestever"); 
        end

        % Print the parameters that cma is seeding through 
        fprintf('\t\t Computed at alpha_h2 = %.20f and i0_h2 = %.25f and alpha_h2_HCO3 = %.20f and i0_h2_HCO3 = %.25f and error_h2 = %.5f\n',alpha_H2,i0_H2,alpha_H2_HCO3,i0_H2_HCO3,H2_error)
        
    catch % If the model does not converge 
%         fprintf('\t\t Model breaks at alpha_h2 = %.20f and i0_h2 = %.20f and gamma_H2 = %.20f\n',alpha_H2,i0_H2,gamma_H2)
        H2_error = Inf;
    end
else % If the cma optimizer tries values outside of physically reasonable values 
%     fprintf('\t\t Not within bounds\n')
    H2_error = Inf;
end