%==========================================================================
% Connects MATLAB Livelink to COMSOL server
% 
%
%
% Date: April 24, 2023
% Kaitlin Corpus 
% 
%
%==========================================================================

% Initiate COMSOL Server settings object
comsol_settings = ComsolSettings();
 
% Setup and start COMSOL server
addpath(comsol_settings.comsol_path);
system(ComsolCommand(comsol_settings));
pause(5)
mphstart('localhost', comsol_settings.comsol_port, ...
          comsol_settings.comsol_user, comsol_settings.comsol_pass);