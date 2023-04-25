Coupling covariance matrix adaptation with COMSOL model simulations to fit kinetic parameters for CO2 reduction 


—----------------------------------------------------------------------------------------------------------------
The files contained in this zip file download are: 


Information of the fitting procedure:       
	README.txt - this document


Data file:
         Folder 031 - contains raw current-voltage data and metadata on a single data set 


Comsol Model file: 
         AgSnCO2RR_Repository_Version.mph


M-Files:
        cma_data_analyzer.m - Analyzes raw data from txt file 
	runcma.m - Runs the cma optimizer 
	compute_CO_error - Function that calculates error of CO fits 
	compute_H2_error - Function that calculates error of H2 fits 
	cmaes.m - CMA optimizer - From MATLAB (https://www.mathworks.com/matlabcentral/fileexchange/52898-cma-es-in-matlab)
	Connect_comsol_server.m - Connects MATLAB Livelink to COMSOL server 
        comsol_settings.m - Defines all COMSOL settings


—---------------------------------------------------------------------------------------------------------------
Fitting procedure for kinetic parameters:


1) Under comsol_settings.m, define all of the necessary COMSOL settings and run connect_comsol_server.m to connect the COMSOL server to MATLAB. 
2) Obtain raw current-voltage data as well as the necessary metadata as shown in the example folder 031 contained in this download. 
3) Input the number of folders you will be analyzing and run the cma_data_analyzer.m to analyze the raw data that will be used in the fitting method
4) The COMSOL model must next be set up for the CMA optimizer. From the data analyzer, the variables “h2” and “co” contain the corrected current-voltage data and must be inputted into the model. 
	* Open “Component 1” in the model and then “Definitions” 
	* Under “Definitions”, open “ExpH2”, then input the data from the “h2” variable 
	* Next, open “ExpCO”, then input the data from the “co” variable
5) Then, open “Study 1” and click on “Step 1: Stationary” 
	* Under “Study Extensions”, input the range of values from the “COMSOL_V_list_CO” variable into the “Parameter value 	list” 
	* Note: If the range of voltages for CO and H2 products are different, you must input “COMSOL_V_list_H2” after running the error function of CO 
6) The model is now ready to be coupled with CMA.
7) Now, open the runcma.m file and specify the model name. In this case, it is “AgSnCO2RR_Repository_Version.mph”
8) You will also specify the data folder you will be using. In this case, it is 031. 
9) Next, you can specify the initial values of your kinetic parameters.
10) You can now run this script and it will output the optimal kinetic parameters as well as the parameters CMA had seeded through and the simulated current at each set of seeded parameters.
