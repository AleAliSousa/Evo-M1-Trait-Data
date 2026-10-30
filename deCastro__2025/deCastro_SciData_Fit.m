% Analysis of FieldBT data set. Field metabolic rates as functions of body
% mass and temperature.
% For journal "Scientific Data". 
% March 2024.


%% Data imput and transforms

% Read data table
data= readtable('FieldMR_SciDataPub.xls');


% Transform variables to NATURAL Log
logR= log(data.FMR_kJ_d);
logM= log(data.Mass_g);


% Definition of constants
K= 8.62E-5;  % Boltzmann constant eV/K
T0= 273+20;	 % Base temperature (20 C);
Tkelvin= data.Temp_C + 273; % Temperature in Kelvin



%% Temp. factor, choose one of the following. Coment out the others
% Gillooly
% data.Tf= -1./(K*Tkelvin); % Temp factor in Giloolly et al.

% Arrhenius
data.Tf= (Tkelvin-T0)./(K*Tkelvin*T0);

% Belehradek temp factor: a*T^b (but the 'a' here would be combined with intercept in log-log)
% data.Tf= log(Tkelvin); 

% Berthelot (1862): n*E^T
% data.Tf= Tkelvin;



%% Fit of linear model to the log-log data. 

% Add logR and logM as columns of 'data' to use formula sintax in fitlm.
data.logR= logR;
data.logM= logM;


% Identify ectotherms and endotherms. Fit done separately.
ecto= find(data.Endotherm==0 & ~isnan(data.Temp_C));
endo= find(data.Endotherm==1 & ~isnan(data.Temp_C));


% ECTOtherms
dataEc= data(ecto,:);
mEc= fitlm(dataEc,'logR ~ 1 + logM + Tf','RobustOpts','on');
% plotDiagnostics(mEc,'cookd')
t_cookd= 3*mean(mEc.Diagnostics.CooksDistance,'omitnan');
outEcto= find(mEc.Diagnostics.CooksDistance > t_cookd); % remove points with high Cook distance
mEc= fitlm(dataEc,'logR ~ 1 + logM + Tf','Exclude',outEcto); % and fit again.
ciEc= coefCI(mEc);
data.outlier(ecto(outEcto))= 1;


% ENDOtherms
dataEn= data(endo,:);
mEn= fitlm(dataEn,'logR ~ 1 + logM + Tf');
% plotDiagnostics(mEn,'cookd')
t_cookd= 3*mean(mEn.Diagnostics.CooksDistance,'omitnan');
outEndo= find(mEn.Diagnostics.CooksDistance > t_cookd); % remove points with high Cook distance
mEn= fitlm(dataEn,'logR ~ 1 + logM + Tf','Exclude',outEndo); % and fit again.
ciEn= coefCI(mEn);
data.outlier(endo(outEndo))= 1;


% Write copy of dataset with outliers marked
writetable(data,'FieldMR_Copy.csv');



%% Coefficents for ecto and endo
fprintf('\n\na: %6.3f [%6.3f %6.3f]\n',mEc.Coefficients.Estimate(1),ciEc(1,:))
fprintf('E: %6.3f [%6.3f %6.3f] \n',mEc.Coefficients.Estimate(2),ciEc(2,:))
fprintf('b: %6.3f [%6.3f %6.3f]\n',mEc.Coefficients.Estimate(3),ciEc(3,:))
fprintf('LogL: %6.3f\n',mEc.LogLikelihood)
fprintf('N: %6.3f\n',mEc.NumObservations)
fprintf('adj.r2: %6.3f\n',mEc.Rsquared.Adjusted)

fprintf('\n\na: %6.3f [%6.3f %6.3f]\n',mEn.Coefficients.Estimate(1),ciEn(1,:))
fprintf('E: %6.3f [%6.3f %6.3f]\n',mEn.Coefficients.Estimate(2),ciEn(2,:))
fprintf('b: %6.3f [%6.3f %6.3f]\n',mEn.Coefficients.Estimate(3),ciEn(3,:))
fprintf('LogL: %6.3f\n',mEn.LogLikelihood)
fprintf('N: %6.3f\n',mEn.NumObservations)
fprintf('adj.r2: %6.3f\n',mEn.Rsquared.Adjusted)



%% Nice Plot. Easier if fitted first with 'fit'. Creates fit object easy to plot.
sEc= fit([data.logM(ecto),data.Tf(ecto)],data.logR(ecto),'poly11');
sEn= fit([data.logM(endo),data.Tf(endo)],data.logR(endo),'poly11');

figure(200);
 	h1= plot(sEc,[data.logM(ecto),data.Tf(ecto)],data.logR(ecto));
	hold on
	h2= plot(sEn,[data.logM(endo),data.Tf(endo)],data.logR(endo));
	drawnow

	h1(1).FaceColor= [0 0 1];
	h1(1).FaceAlpha= 0.3;
	h1(1).LineStyle= 'none';
	h1(2).MarkerFaceColor= [.6 .8 1];
	h1(2).MarkerEdgeColor= [.4 .6 .8];

	h2(1).FaceColor= [1 0 0];
	h2(1).FaceAlpha= 0.2;
	h2(1).LineStyle= 'none';
	h2(2).MarkerFaceColor= [1 .8 .6];
	h2(2).MarkerEdgeColor= [.8 .6 .4];

	xlabel(mEc.PredictorNames(2));
	ylabel(mEc.PredictorNames(1));
	zlabel(mEc.ResponseName);
	

