%==========================================================================
% Main file that runs the CMA optimizer 
%
%    Date: Apr 25, 2023
% 
% (c) Kaitlin Corpus, LBNL. 
%
% This code is licensed under a
% MIT License.
% You should have received a copy of the license along with this
% work. If not, see <https://opensource.org/license/mit/>.
% =========================================================================


% Import COMSOL API
import com.comsol.model.*
import com.comsol.model.util.*

% Add path of cmaes function
addpath('C:\Users\ecg\Documents\Kaitlin Kinetic Studies\Kaitlin_Kinetic_Studies\Inputs\cmaes')

% Main study directory containing Inputs folder
base_dir = 'C:\Users\ecg\Documents\Kaitlin Kinetic Studies\Kaitlin_Kinetic_Studies\';
% COMSOL base model file name
file_name = 'AgSnCO2RR_Repository_Version';
 % Directory where all inputs are stored within base_dir
input_dir = 'Inputs';

% Make model and data set number a global variable 
global model

global num 
num = 031; % Input data set number here 

% Open COMSOL Model file
file = fullfile(base_dir, input_dir,file_name);
model = mphload(file); 
model.hist.disable;

% Set initial values for all kinetic parameters 
a_CO_0 = 0.3; 
i0_CO_0 = 10^(-5);
BL_0 = 100; 

a_H2_0 = 0.5;
i0_H2_0 = 10^(-10);

% Run the cmaes function for CO 
xmin_CO = cmaes('compute_CO_error', [a_CO_0; log10(i0_CO_0);BL_0], 0.5);

% Run the cmaes function for H2 
xmin_H2 = cmaes('compute_H2_error', [a_H2_0; log10(i0_H2_0)], 0.5);
