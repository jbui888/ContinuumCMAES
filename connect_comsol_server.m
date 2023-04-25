%==========================================================================
% Connects MATLAB Livelink to COMSOL server
% 
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


% Initiate COMSOL Server settings object
comsol_settings = ComsolSettings();
 
% Setup and start COMSOL server
addpath(comsol_settings.comsol_path);
system(ComsolCommand(comsol_settings));
pause(5)
mphstart('localhost', comsol_settings.comsol_port, ...
          comsol_settings.comsol_user, comsol_settings.comsol_pass);
