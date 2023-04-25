% =========================================================================
% Define COMSOL setting parameters
%
%    Date: Feb 12, 2020
% 
% (c) Lalit Pant, LBNL. 
%
% This code is licensed under a
% Creative Commons Attribution 4.0 International License.
% You should have received a copy of the license along with this
% work. If not, see <http://creativecommons.org/licenses/by/4.0/>.
% =========================================================================
classdef comsol_settings
    
    properties (SetAccess = 'private')
        
        % COMSOL server configuration parameters
        start_server       = true;  % Start the server (true), or already running (false)
        comsol_port        = 2036;  % COMSOL port number
        comsol_path        = 'C:\Program Files\COMSOL\COMSOL60\Multiphysics\mli';
        comsol_server_path = '"C:\Program Files\COMSOL\COMSOL60\Multiphysics\bin\win64\comsolmphserver"';
        comsol_user        = 'ECG';     % COMSOL server Username. Change for your case
        comsol_pass        = 'Fuelcell1'; % COMSOL server password. Change for your case
    end
    % =====================================================================        
    methods
        function command_string = ComsolCommand (obj)
            command_string = ['START "" ',obj.comsol_server_path,' -port ', num2str(obj.comsol_port)];
        end
    end
end