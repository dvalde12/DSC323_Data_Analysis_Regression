proc import file = 'C:\Users\DVALDE12\Desktop\final_project\SeoulBikeSharing.csv'
out = bikeShare
dbms = csv
replace;
run;


proc print data = bikeShare;
run;

data new_bikeShare;
	set bikeShare (rename=(Rented_Bike_Count=Bike_Count VAR4= temperature VAR8= dewpoint Humidity___=Humidity Wind_speed__m_s_=WindSpeed Visibility__10m_=Visibility Solar_Radiation__MJ_m2_=Radiation Rainfall_mm_=Rain Snowfall__cm_=Snow ));
	d_Holiday = (Holiday = 'Holiday');
	d_func = (Functioning_Day = 'Yes');
	*multiple dummies for season;
	d_season1_w = (Seasons = 'Winter');
	d_season2_sp = (Seasons = 'Spring');
	d_season3_a = (Seasons = 'Autumn');
	*Transforming variables:
	log if y>0 sqrt if Y>=0 inv if Y!= 0
	date = log visibility = log bike =sqrt hour =sqrt hum =sqrt ws =sqrt radiation = sqrt rain =srqt snow =sqrt;
	Bike_Count2 = (Bike_Count)**(1/3);

	WindSpeed2 = sqrt(WindSpeed);
	Visibility2 = log(Visibility);

	Rain2 = (Rain)**(1/3);
	Snow2 = sqrt(Snow);
	*interaction;
	*all variables were statistically insignificant;
	Snow_date = Snow*Date;
	humid_date= Date*Humidity;
	wind_date = Date*WindSpeed;
	visibility_date = Date*visibility;
	radiation_date = Date*Radiation;
	rain_date = Date*Rain;

run;

proc print data = new_bikeShare;
run;
/*
*explore;
title 'explore';
proc sgplot data = new_bikeShare;
scatter y =Bike_Count x = Humidity;
reg y = Bike_Count x =Humidity;
run;
proc sgplot data = new_bikeShare;
scatter y =Bike_Count x = WindSpeed;
reg y = Bike_Count x =WindSpeed;
run;
proc sgplot data = new_bikeShare;
scatter y =Bike_Count x = Visibility;
reg y = Bike_Count x =Visibility;
run;
proc sgplot data = new_bikeShare;
scatter y =Bike_Count x = Radiation;
reg y = Bike_Count x =Radiation;
yaxis grid values=(0 to 4000 by 500) valueshint;
run;
proc sgplot data = new_bikeShare;
scatter y =Bike_Count x = Rain;
reg y = Bike_Count x =Rain;
yaxis grid values=(0 to 4000 by 500) valueshint;
run;
proc sgplot data = new_bikeShare;
scatter y =Bike_Count x = Snow;
reg y = Bike_Count x = Snow;
yaxis grid values=(0 to 4000 by 500) valueshint;
run;
proc sgplot data = new_bikeShare;
scatter y =Bike_Count x = Date;
reg y = Bike_Count x = Date;
run;
*/
data new_3;
set new_BikeShare(keep =Bike_Count temperature dewpoint Date Hour Humidity WindSpeed Visibility radiation Rain Snow d_func d_season1_w d_season2_sp d_season3_a);
run;
proc print data= new_3(obs=3);
run;

title 'Descriptive Statistics: Full Model';
proc means mean mode std stderr min p25 p50 p75 max;
var Bike_Count Date Hour temperature dewpoint Humidity WindSpeed Visibility radiation Rain Snow d_func d_season1_w d_season2_sp d_season3_a;
run;
*matrix;
proc sgscatter data=new_3;
title 'Scatterplot Matrix';
matrix Bike_Count Date Hour temperature dewpoint Humidity WindSpeed Visibility radiation Rain Snow;
run;

/*
title 'explore without outliers';
proc sgplot data = new_bikeShare;
scatter y =Bike_Count x = Humidity;
reg y = Bike_Count x =Humidity;
run;
proc sgplot data = new_bikeShare;
scatter y =Bike_Count x = WindSpeed;
reg y = Bike_Count x =WindSpeed;
run;
proc sgplot data = new_bikeShare;
scatter y =Bike_Count x = Visibility;
reg y = Bike_Count x =Visibility;
run;
proc sgplot data = new_bikeShare;
scatter y =Bike_Count x = Radiation;
yaxis grid values=(0 to 4000 by 500) valueshint;
reg y = Bike_Count x =Radiation;
run;
proc sgplot data = new_bikeShare;
scatter y =Bike_Count x = Rain;
reg y = Bike_Count x =Rain;
yaxis grid values=(0 to 4000 by 500) valueshint;
run;
proc sgplot data = new_bikeShare;
scatter y =Bike_Count x = Snow;
yaxis grid values=(0 to 4000 by 500) valueshint;
reg y = Bike_Count x = Snow;
run;
proc sgplot data = new_bikeShare;
scatter y =Bike_Count x = Date;
reg y = Bike_Count x = Date;
run;
*/

proc univariate data =new_3;
title 'Histogram: No Transformation';
var Bike_Count Date Hour Humidity WindSpeed Visibility radiation Rain Snow temperature dewpoint;
histogram;
run;
proc univariate data =new_bikeShare;
title 'Histogram: Transformed';
var Bike_Count2 Humidity dewpoint temperature WindSpeed2 Visibility2 radiation Rain2 Snow2;
histogram;
run;
proc reg data =new_bikeShare;
title 'Transformed';
model Bike_Count2 = Date Hour temperature dewpoint Humidity WindSpeed2 Visibility2 radiation Rain2 Snow2 d_holiday d_func d_season1_w d_season2_sp d_season3_a;
run;
*scatterplot matrix for transformed bike_Share;
proc sgscatter data=new_bikeShare;
title 'Scatterplot Matrix: Transformed';
matrix Bike_Count2 Humidity WindSpeed2 Visibility2 radiation Rain2 Snow2 dewpoint temperature;
run;
* transformed matrix;
proc sgscatter data=new_bikeShare;
title 'Scatterplot Matrix';
matrix Bike_Count2 Humidity WindSpeed2 Visibility2 radiation Rain2 Snow2 dewpoint temperature;
run;
*Not transformed Q-Q plots;
proc univariate data =new_3;
title 'Q-Q Plots: No Transformation';
var Bike_Count Date Hour Humidity WindSpeed Visibility radiation Rain Snow temperature dewpoint;
qqplot;
run;
*transformed Q-Q plots;
proc univariate data =new_bikeShare;
title 'Q-Q Plots: Transformation';
var Bike_Count2 Humidity WindSpeed2 Visibility2 radiation Rain2 Snow2 dewpoint temperature;
qqplot;
run;
*Transformed;
ods graphics on;
proc reg data=new_bikeShare plots(MAXPOINTS=NONE);
title 'Checking Residual: Transformed Full Model';
model Bike_Count2 = Humidity WindSpeed2 Visibility2 radiation Rain2 Snow2 dewpoint temperature;
run;
*outliers and influential pts;
proc reg data = new_bikeShare;
title 'Outliers & Influential Obs With Transformed Model';
model Bike_Count2 = Date Hour temperature dewpoint Humidity WindSpeed2 Visibility2 radiation Rain2 Snow2 
d_holiday d_func d_season1_w d_season2_sp d_season3_a/ influence r;
plot student.*(Date Hour temperature dewpoint Humidity WindSpeed2 Visibility2 radiation Rain2 Snow2 
d_holiday d_func d_season1_w d_season2_sp d_season3_a predicted.);
plot npp.*student.;
run;
*looking for influential points;
proc reg data = new_bikeShare plots(only label)=(CooksD RStudentByLeverage);
title 'influence';
model Bike_Count2 = Date Hour temperature dewpoint Humidity WindSpeed2 Visibility2 radiation Rain2 Snow2 
d_holiday d_func d_season1_w d_season2_sp d_season3_a;
run;
*influece table;
proc reg data=new_bikeShare  plots=none;
model Bike_Count2 = Date Hour temperature dewpoint Humidity WindSpeed2 Visibility2 radiation Rain2 Snow2 
d_holiday d_func d_season1_w d_season2_sp d_season3_a;
output out=RegOut predicted=Pred student=RStudent cookd=CookD H=Leverage;
quit;
 
%let p = 4;  /* number of parameter in model, including intercept */
%let n = 3456; /* Number of Observations Used */
title "Influential (Cook's D)";
proc print data=RegOut;
   where CookD > 4/&n;
   var Bike_Count2 Date Hour temperature dewpoint Humidity WindSpeed2 Visibility2 radiation Rain2 Snow2 
d_holiday d_func d_season1_w d_season2_sp d_season3_a CookD;
run;
*removing outliers;
data new_bikeShare;
set new_bikeShare;
if _n_ in (9, 25, 26, 27, 58, 73, 81, 118, 129, 145, 152, 153, 154, 222,
225, 227, 228, 764, 936, 945, 961, 969, 1493, 1497, 2167, 2166, 2180, 
2181, 2182, 2183, 2184, 2208, 2214, 2224, 2238, 2240, 2253, 2254,
2255, 2256, 2257, 2259, 2261, 2289, 2328, 2983, 2985, 3009, 3021,
3023, 3033, 3104, 3105, 3106, 3115, 3141, 3142, 3145, 3151, 3187,
3188, 3642, 3643, 3662, 3664, 3873, 3894, 3910, 4403, 4489,
4509, 4520, 4521, 4561, 4633, 4641, 5103, 5106, 5107, 5110, 5111,
5112, 5124, 5132, 5133, 5145, 5193, 5296, 5304, 5306, 5307,
5312, 5313, 5333, 5371, 5846, 5847, 5848, 5849, 5861, 5962, 6043,
6117, 6629, 6634, 6640, 6641, 6657, 6720, 6721, 7345, 7586, 7388, 7408,
7413, 7414, 7415, 7416, 7417, 7418, 7419, 7420, 7421, 7422, 7423,
7506, 7507, 7508, 7509, 7510, 7511, 7512, 7521, 7545, 7569, 8049,
8073, 8145, 8159, 8190, 8219, 8220, 8222, 8223, 8225, 8226,
8228, 8229, 8231, 8232, 8233, 8236, 8242, 8313) then delete;
*full model without outliers and influential points;
proc reg data=new_bikeShare;
title 'Full model: No Outliers or Influential Points';
model Bike_Count2 =Date Hour temperature dewpoint Humidity WindSpeed2 Visibility2 radiation Rain2 Snow2 
d_holiday d_func d_season1_w d_season2_sp d_season3_a/ vif tol;
run;
*variable selection method, temperature is removed due to collinearity;
proc reg data=new_bikeShare;
title 'Full model Selection: No Outliers or Influential Points';
model Bike_Count2 =Date Hour dewpoint Humidity WindSpeed2 Visibility2 radiation Rain2 Snow2 
d_holiday d_func d_season1_w d_season2_sp d_season3_a/ selection= adjrsq;
run;
proc reg data=new_bikeShare;
title 'Full model Selection: No Outliers or Influential Points';
model Bike_Count2 =Date Hour dewpoint Humidity WindSpeed2 Visibility2 radiation Rain2 Snow2 
d_holiday d_func d_season1_w d_season2_sp d_season3_a/ selection= stepwise;
run;
*stepwise model: Dew point, d_func, Humidity, Hour, Rain, Winter, Autumn, Radiation, Date, Wind, speed, Snow,
*adjrq model: Date Hour dewpoint Humidity WindSpeed2 Radiation Rain2 Snow2 d_Holiday d_func d_season1_w d_season3_a;
proc reg data=new_bikeShare;
title 'Full model ADJRSQ: No Outliers or Influential Points';
model Bike_Count2 =Date Hour dewpoint Humidity WindSpeed2 Radiation Rain2 Snow2 d_Holiday d_func d_season1_w d_season3_a;
run;
proc reg data=new_bikeShare;
title 'Full model Stepwise: No Outliers or Influential Points';
model Bike_Count2 =Date Hour dewpoint Humidity WindSpeed2 Radiation Rain2 Snow2 d_func d_season1_w d_season3_a;
run;
*cross validation full model with train/test set at 80/20;
title '5-fold CV with Full Model Stepwise at 80/20';
proc glmselect data= new_bikeShare
plots= (asePlot Criteria);
partition fraction (test=0.20);
model Bike_Count2 =Date Hour dewpoint Humidity WindSpeed2 Visibility2 radiation Rain2 Snow2 
d_holiday d_func d_season1_w d_season2_sp d_season3_a/
selection=stepwise (stop=cv) cvMethod=split(5) cvDetails=all;
run;

*creates a next dataset bike_train_test_set, split data into train and test sets;
*selected =1 -> Train
 selected =0 -> Test;
title 'Test and Train Sets for bike count';
proc surveyselect data = new_bikeShare
out = bike_train_test_set seed=495857
samprate = 0.80 outall;
run;
*creates new variable new_bike_count for training set, and =NA;
data bike_train_test_set;
set bike_train_test_set;
if selected then new_bike_count = Bike_Count2;
run;
proc print data = bike_train_test_set;
run;

title 'validation - test set: Model 1';
proc reg data = bike_train_test_set;
*Model 1: Stepwise;
model Bike_Count2 =Date Hour dewpoint Humidity WindSpeed2 Radiation Rain2 Snow2 d_func d_season1_w d_season3_a;
output out=outm1 (where=(new_bike_count=.)) p=yhat;
run;

*test;
*summarizes the results of cross-validatin for model 1;
title 'difference between obs and pred in test set M1';
data outm1_sum;
set outm1;
d=Bike_Count2-yhat;
absd = abs(d);
run;

*compute predictive stats: rmse and mae;
proc summary data =outm1_sum;
var d absd;
output out = outm1_stats std (d)=rmse mean(absd)=mae;
run;
proc print data =outm1_stats;
title 'Validation stats for model 1';
run;
*computes correlation of obs and pred in test set;
proc corr data = outm1;
var Bike_Count2 yhat;
run;

*creating predictions for stepwise method;
/*
data pred;
input Bike_Count2 Date Hour dewpoint Humidity WindSpeed2 radiation Rain2 Snow2 d_func d_season1_w d_season3_a;
datalines;
. 21170 9 -17.6 40 0.8 0.05 0 0 1 1 0
;
run;

data new;
set pred bike_train_test_set;
run;

proc reg data = new;
title 'CI: Prediction 1';
model Bike_Count2 =Date Hour dewpoint Humidity WindSpeed2 Radiation Rain2 Snow2 d_func d_season1_w d_season3_a
/ p cli;
run;
*/
data pred;
input Bike_Count2 Date Hour dewpoint Humidity WindSpeed2 radiation Rain2 Snow2 d_func d_season1_w d_season3_a;
datalines;
. 21080 13 -10.6 45 1.1 0.07 0.9 0 1 0 1
;
run;

data new;
set pred bike_train_test_set;
run;

proc reg data = new;
title 'CI: Prediction 1';
model Bike_Count2 =Date Hour dewpoint Humidity WindSpeed2 Radiation Rain2 Snow2 d_func d_season1_w d_season3_a
/ p cli;
run;
