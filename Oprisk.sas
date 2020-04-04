/*-----------------------------------------------------------
* PROJECT NAME 		: ICAAP -OpRisk Modelling.egp
* DESCRIPTION 		: Statistical Modelling based on Monte Carl simulations, 
					  in support of ICAAP 2019 Operational Risk Scenario Analysis
* CALLED BY 		: 
* CALLS TO 			: 
		   			
*------------------------------------------------------------
* INPUT FILES 		: N/A
					: N/A

* OUTPUT FILES 		: a) Excel: Simulations Stats v3.xlsx 
						\M:\Risk\IMV\OpRisk
					  b) PDF: Snapshot of Code output (plots, statistical summaries, performance)

*------------------------------------------------------------

* MODIFICATIONS 		 
* --------------------------------------------------------------------------------------------------------- 
* DATE 				: 6 Sep 2019
* CHANGE VERSION 	: V4.0
* MODEL DEVELOPER(S): Dimitris Kontogiannis
* DESCRIPTION 		: Statistical Modelling based on Monte Carlo simulations, 
					  in support of ICAAP 2019 Operational Risk Scenario Analysis
/*---------------------------------------------------------------------------------------------------------*/




/*-------------------------------------------------------- 
LIST OF SCENARIO CATEGORIES 
----------------------------------------------------------

1	Internal Fraud	(Internal Fraud)
2	External Fraud	(External Fraud)
3	Data	(Execution, Delivery & Process Management)
4	Business Resilience	(Damage to Physical Assets)
5	People	(Employment Practices & Workplace Safety)
6	Financial Crime	(Clients, Products & Business Practices)
7	Supplier / Outsourcing	(Execution, Delivery & Process Management)
8	Information Security & Cyber	(External Fraud,Business Disruption & System Failures)
9	Process Execution	(Execution, Delivery & Process Management)
10	Technical Resilience	(Business Disruption & System Failures)
11	Legal & Regulatory	(Clients, Products & Business Practices)

-----------------------------------------------------------------
*/







%MACRO OPRISK;

%DO K=1 %to 50;



proc datasets library=WORK kill; run; quit;


/*MACRO FOR CHOOSING A RANDOM NUMBER BETWEEN 1-100*/

%macro RandBetween(min, max);
   (&min + floor((1+&max-&min)*rand("uniform")))
%mend;


/*1ST MACRO FOR ADDING ROW NUMBER TO DATASETS*/

%macro rownum(id=,);
PROC SQL;
CREATE TABLE &id.
AS SELECT monotonic() AS ROW,*
FROM AGGLOSSSAMPLE_&id.
;
QUIT;
%mend;

/*MACRO FOR RANDOMISING THE ROWS IN A DATASET*/


%macro randomise(id=,);
proc sql;
create table &id.
as
 select *
     from &id.
    order by  ranuni(0);
	quit;
%mend;


/*MACRO FOR JOINING DATASETS*/
%macro JOIN(id,id1=,id2=);
proc sql;
create table &id.
as
 select aggloss
     from &id1.
  union all
select aggloss
	from &id2.
;
	quit;
%mend;






/*2ND MACRO FOR ADDING ROW NUMBER TO DATASETS*/
%macro rownum2(id=,);
PROC SQL;
CREATE TABLE ran_&id.
AS SELECT monotonic() AS ROW_NEW,*
FROM &id.
;
QUIT;
%mend;




%macro create_cdm(repetitions);
   %do i=1 %to &repetitions;



/*-------------------------------------------------------- 
1. EXTERNAL FRAUD
----------------------------------------------------------

/*1a. Simulation for Stressed-Extreme*/

/*Simulate data for an intercept only Poisson Model*/

ods graphics on;
data claimcount_ext_fraud1_&i(keep=numLosses);
	/*call streaminit(12345);*/
	label numLosses='Number of Loss Events in a Year';
	lambda=1;
	do n=1 to 500;
	numLosses=rand('POISSON',Lambda);
	output;
	end;
run;

proc freq data=claimcount_ext_fraud1_&i;
tables numLosses / plots=freqplot;
run;

/* Fit an intercept-only Poisson count model and
   write estimates to an item store */
proc countreg data=claimcount_ext_fraud1_&i;
   model numLosses= / dist=poisson;
   store countStorePoisson;
run;

/* Simulate data for Lognormal severity model */

data claimsev_ext_fraud1_&i(keep=y label='Simple Lognormal Sample');
call streaminit(45678);
label y='Response Variable';
Mu = 12.68467112;
Sigma = 2.087373901;
do n = 1 to 500;
y = exp(Mu) * rand('LOGNORMAL')**Sigma;
output;
end;
run;

proc sgplot data=claimsev_ext_fraud1_&i; histogram y; run;

/* Fit severity models and write estimates to a data set */
proc severity data=claimsev_ext_fraud1_&i criterion=aicc outest=sevest covout plots=none;
   loss y;
   dist _predefined_;
run;

/* Simulate and estimate Poisson-Lognormal compound distribution model */
proc hpcdm countstore=countStorePoisson severityest=sevest
           seed=13579 nreplicates=10000 plots=(edf(alpha=0.05) density )
           print=(summarystatistics percentiles) ;
   severitymodel logn;
   output out=aggLossSample_ext_fraud1_&i samplevar=aggloss ;
   outsum out=aggLossSummary_ext_fraud1_&i mean stddev skewness kurtosis
         p01 p05 p95 p995 pctlpts=10 30 50 70 80 90 97.5 99.9;
run;

/* Conduct parameter perturbation analysis of
   the Poisson-Lognormal compound distribution model */
proc hpcdm countstore=countStorePoisson severityest=sevest
           seed=13579 nreplicates=10000 nperturbedsamples=50
           print(only)=(perturbsummary) plots=all;
   severitymodel logn;
   output out=aggLossSample_ext_fraud1_&i  samplevar=aggloss;
   outsum out=aggLossSummary_ext_fraud1_&i mean stddev skewness kurtosis
          p01 p05 p95 p995 pctlpts=10 30 50 70 80 90 97.5 99.9;
run;






/*1b. Simulation for Moderate-Stressed*/

/*Simulate data for an intercept only Poisson Model*/

ods graphics on;
data claimcount_ext_fraud2_&i(keep=numLosses);
	/*call streaminit(12345);*/
	label numLosses='Number of Loss Events in a Year';
	lambda=1;
	do n=1 to 500;
	numLosses=rand('POISSON',Lambda);
	output;
	end;
run;

proc freq data=claimcount_ext_fraud2_&i;
tables numLosses / plots=freqplot;
run;

/* Fit an intercept-only Poisson count model and
   write estimates to an item store */
proc countreg data=claimcount_ext_fraud2_&i;
   model numLosses= / dist=poisson;
   store countStorePoisson;
run;

/* Simulate data for Lognormal severity model */

data claimsev_ext_fraud2_&i(keep=y label='Simple Lognormal Sample');
call streaminit(45678);
label y='Response Variable';
Mu = 8.043916571;
Sigma = 4.908752334;
do n = 1 to 500;
y = exp(Mu) * rand('LOGNORMAL')**Sigma;
output;
end;
run;

proc sgplot data=claimsev_ext_fraud2_&i; histogram y; run;

/* Fit severity models and write estimates to a data set */
proc severity data=claimsev_ext_fraud2_&i criterion=aicc outest=sevest covout plots=none;
   loss y;
   dist _predefined_;
run;

/* Simulate and estimate Poisson-Lognormal compound distribution model */
proc hpcdm countstore=countStorePoisson severityest=sevest
           seed=13579 nreplicates=10000 plots=(edf(alpha=0.05) density )
           print=(summarystatistics percentiles) ;
   severitymodel logn;
   output out=aggLossSample_ext_fraud2_&i samplevar=aggloss ;
   outsum out=aggLossSummary_ext_fraud2_&i mean stddev skewness kurtosis
         p01 p05 p95 p995 pctlpts=10 30 50 70 80 90 97.5 99.9;
run;

/* Conduct parameter perturbation analysis of
   the Poisson-Lognormal compound distribution model */
proc hpcdm countstore=countStorePoisson severityest=sevest
           seed=13579 nreplicates=10000 nperturbedsamples=50
           print(only)=(perturbsummary) plots=all;
   severitymodel logn;
   output out=aggLossSample_ext_fraud2_&i samplevar=aggloss;
   outsum out=aggLossSummary_ext_fraud2_&i mean stddev skewness kurtosis
          p01 p05 p95 p995 pctlpts=10 30 50 70 80 90 97.5 99.9;
run;






/*-------------------------------------------------------- 
2. INTERNAL FRAUD
----------------------------------------------------------


/*2a. Simulation for Stressed-Extreme*/

/*Simulate data for an intercept only Poisson Model*/

ods graphics on;
data claimcount_int_fraud1_&i(keep=numLosses);
	/*call streaminit(12345);*/
	label numLosses='Number of Loss Events in a Year';
	lambda=1;
	do n=1 to 500;
	numLosses=rand('POISSON',Lambda);
	output;
	end;
run;

proc freq data=claimcount_int_fraud1_&i;
tables numLosses / plots=freqplot;
run;

/* Fit an intercept-only Poisson count model and
   write estimates to an item store */
proc countreg data=claimcount_int_fraud1_&i;
   model numLosses= / dist=poisson;
   store countStorePoisson;
run;

/* Simulate data for Lognormal severity model */

data claimsev_int_fraud1_&i(keep=y label='Simple Lognormal Sample');
/*call streaminit(45678);*/
label y='Response Variable';
Mu = 12.60771937;
Sigma =1.804594541;
do n = 1 to 500;
y = exp(Mu) * rand('LOGNORMAL')**Sigma;
output;
end;
run;


proc sgplot data=claimsev_int_fraud1_&i; histogram y; run;


/* Fit severity models and write estimates to a data set */
proc severity data=claimsev_int_fraud1_&i criterion=aicc outest=sevest covout plots=none;
   loss y;
   dist _predefined_;
run;

/* Simulate and estimate Poisson-gamma compound distribution model */
proc hpcdm countstore=countStorePoisson severityest=sevest
           seed=13579 nreplicates=10000 plots=(edf(alpha=0.05) density )
           print=(summarystatistics percentiles);
   severitymodel logn;
   output out=aggLossSample_int_fraud1_&i samplevar=aggloss;
   outsum out=aggLossSummary_int_fraud1_&i mean stddev skewness kurtosis
          p01 p05 p95 p995 pctlpts=10 30 50 70 80 90 97.5 99.9;
run;


/* Conduct parameter perturbation analysis of
   the Poisson-gamma compound distribution model */
proc hpcdm countstore=countStorePoisson severityest=sevest
           seed=13579 nreplicates=10000 nperturbedsamples=50
           print(only)=(perturbsummary) plots=none;
   severitymodel logn;
   output out=aggLossSample_int_fraud1_&i samplevar=aggloss;
   outsum out=aggLossSummary_int_fraud1_&i mean stddev skewness kurtosis
       p01 p05 p95 p995 pctlpts=10 30 50 70 80 90 97.5 99.9;
run;




/*2b. Simulation for Moderate-Stressed*/

/*Simulate data for an intercept only Poisson Model*/

ods graphics on;
data claimcount_int_fraud2_&i(keep=numLosses);
	/*call streaminit(12345);*/
	label numLosses='Number of Loss Events in a Year';
	lambda=1;
	do n=1 to 500;
	numLosses=rand('POISSON',Lambda);
	output;
	end;
run;

proc freq data=claimcount_int_fraud2_&i;
tables numLosses / plots=freqplot;
run;

/* Fit an intercept-only Poisson count model and
   write estimates to an item store */
proc countreg data=claimcount_int_fraud2_&i;
   model numLosses= / dist=poisson;
   store countStorePoisson;
run;

/* Simulate data for Lognormal severity model */

data claimsev_int_fraud2_&i(keep=y label='Simple Lognormal Sample');
call streaminit(45678);
label y='Response Variable';
Mu = 10.61753592;
Sigma = 3.014540167;
do n = 1 to 500;
y = exp(Mu) * rand('LOGNORMAL')**Sigma;
output;
end;
run;


proc sgplot data=claimsev_int_fraud2_&i; histogram y; run;


/* Fit severity models and write estimates to a data set */
proc severity data=claimsev_int_fraud2_&i criterion=aicc outest=sevest covout plots=none;
   loss y;
   dist _predefined_;
run;

/* Simulate and estimate Poisson-gamma compound distribution model */
proc hpcdm countstore=countStorePoisson severityest=sevest
           seed=13579 nreplicates=10000 plots=(edf(alpha=0.05) density )
           print=(summarystatistics percentiles);
   severitymodel logn;
   output out=aggLossSample_int_fraud2_&i samplevar=aggloss;
   outsum out=aggLossSummary_int_fraud2_&i mean stddev skewness kurtosis
          p01 p05 p95 p995 pctlpts=10 30 50 70 80 90 97.5 99.9;
run;


/* Conduct parameter perturbation analysis of
   the Poisson-gamma compound distribution model */
proc hpcdm countstore=countStorePoisson severityest=sevest
           seed=13579 nreplicates=10000 nperturbedsamples=50
           print(only)=(perturbsummary) plots=none;
   severitymodel logn;
   output out=aggLossSample_int_fraud2_&i samplevar=aggloss;
   outsum out=aggLossSummary_int_fraud2_&i mean stddev skewness kurtosis
       p01 p05 p95 p995 pctlpts=10 30 50 70 80 90 97.5 99.9;
run;





/*-------------------------------------------------------- 
3. DATA 
----------------------------------------------------------

/*3a. Simulation for Stressed-Extreme*/

/*Simulate data for an intercept only Poisson Model*/

ods graphics on;
data claimcount_data1_&i(keep=numLosses);
	/*call streaminit(12345);*/
	label numLosses='Number of Loss Events in a Year';
	lambda=1;
	do n=1 to 500;
	numLosses=rand('POISSON',Lambda);
	output;
	end;
run;

proc freq data=claimcount_data1_&i;
tables numLosses / plots=freqplot;
run;

/* Fit an intercept-only Poisson count model and
   write estimates to an item store */
proc countreg data=claimcount_data1_&i;
   model numLosses= / dist=poisson;
   store countStorePoisson;
run;



/* Simulate data for Lognormal severity model */
data claimsev_data1_&i(keep=y label='Simple Lognormal Sample');
call streaminit(45678);
label y='Response Variable';
Mu = 12.48821632;
Sigma = 2.121632873;
do n = 1 to 500;
y = exp(Mu) * rand('LOGNORMAL')**Sigma;
output;
end;
run;
proc sgplot data=claimsev_data1_&i; histogram y; run;


/* Fit severity models and write estimates to a data set */
proc severity data=claimsev_data1_&i criterion=aicc outest=sevest covout plots=none;
   loss Y;
   dist _predefined_;
run;

/* Simulate and estimate Poisson-gamma compound distribution model */
proc hpcdm countstore=countStorePoisson severityest=sevest
           seed=13579 nreplicates=10000 plots=(edf(alpha=0.05) density )
           print=(summarystatistics percentiles);
   severitymodel logn;
   output out=aggLossSample_data1_&i samplevar=aggloss;
   outsum out=aggLossSummary_data1_&i mean stddev skewness kurtosis
         p01 p05 p95 p995 pctlpts=10 30 50 70 80 90 97.5 99.9;
run;


/* Conduct parameter perturbation analysis of
   the Poisson-gamma compound distribution model */
proc hpcdm countstore=countStorePoisson severityest=sevest
           seed=13579 nreplicates=10000 nperturbedsamples=50
           print(only)=(perturbsummary) plots=none;
   severitymodel logn;
   output out=aggLossSample_data1_&i samplevar=aggloss;
   outsum out=aggLossSummary_data1_&i mean stddev skewness kurtosis
          p01 p05 p95 p995 pctlpts=10 30 50 70 80 90 97.5 99.9;
run;




/*3b. Simulation for Moderate-Stressed*/

/*Simulate data for an intercept only Poisson Model*/

ods graphics on;
data claimcount_data2_&i(keep=numLosses);
	/*call streaminit(12345);*/
	label numLosses='Number of Loss Events in a Year';
	lambda=1;
	do n=1 to 500;
	numLosses=rand('POISSON',Lambda);
	output;
	end;
run;

proc freq data=claimcount_data2_&i;
tables numLosses / plots=freqplot;
run;

/* Fit an intercept-only Poisson count model and
   write estimates to an item store */
proc countreg data=claimcount_data2_&i;
   model numLosses= / dist=poisson;
   store countStorePoisson;
run;



/* Simulate data for Lognormal severity model */
data claimsev_data2_&i(keep=y label='Simple Lognormal Sample');
/*call streaminit(45678);*/
label y='Response Variable';
Mu = 10.48647637;
Sigma = 3.338604354;
do n = 1 to 500;
y = exp(Mu) * rand('LOGNORMAL')**Sigma;
output;
end;
run;
proc sgplot data=claimsev_data2_&i; histogram y; run;


/* Fit severity models and write estimates to a data set */
proc severity data=claimsev_data2_&i criterion=aicc outest=sevest covout plots=none;
   loss Y;
   dist _predefined_;
run;

/* Simulate and estimate Poisson-gamma compound distribution model */
proc hpcdm countstore=countStorePoisson severityest=sevest
           seed=13579 nreplicates=10000 plots=(edf(alpha=0.05) density )
           print=(summarystatistics percentiles);
   severitymodel logn;
   output out=aggLossSample_data2_&i samplevar=aggloss;
   outsum out=aggLossSummary_data2_&i mean stddev skewness kurtosis
         p01 p05 p95 p995 pctlpts=10 30 50 70 80 90 97.5 99.9;
run;


/* Conduct parameter perturbation analysis of
   the Poisson-gamma compound distribution model */
proc hpcdm countstore=countStorePoisson severityest=sevest
           seed=13579 nreplicates=10000 nperturbedsamples=50
           print(only)=(perturbsummary) plots=none;
   severitymodel logn;
   output out=aggLossSample_data2_&i samplevar=aggloss;
   outsum out=aggLossSummary_data2_&i mean stddev skewness kurtosis
          p01 p05 p95 p995 pctlpts=10 30 50 70 80 90 97.5 99.9;
run;





/*-------------------------------------------------------- 
4. BUSINESS RESILIENCE
----------------------------------------------------------


/*4a. Simulation for Stressed-Extreme*/

/*Simulate data for an intercept only Poisson Model*/

ods graphics on;
data claimcount_business_resilience_&i(keep=numLosses);
/*	call streaminit(12345);*/
	label numLosses='Number of Loss Events in a Year';
	lambda=1;
	do n=1 to 500;
	numLosses=rand('POISSON',Lambda);
	output;
	end;
run;

proc freq data=claimcount_business_resilience_&i;
tables numLosses / plots=freqplot;
run;

/* Fit an intercept-only Poisson count model and
   write estimates to an item store */
proc countreg data=claimcount_business_resilience_&i;
   model numLosses= / dist=poisson;
   store countStorePoisson;
run;



/* Simulate data for gamma severity model */
data claimsev_bus_res_&i(keep=lossValue);
   /*call streaminit(67890);*/
   label y='Severity of a Loss Event';
   Theta = 8200;
   Alpha = 10.5;
   do n = 1 to 500;
      lossValue = quantile('Gamma', rand('UNIFORM'), Alpha, Theta);
      output;
   end;
run;




/* Fit severity models and write estimates to a data set */
proc severity data=claimsev_bus_res_&i criterion=aicc outest=sevest covout plots=none;
   loss lossValue;
   dist _predefined_;
run;

/* Simulate and estimate Poisson-Gamma compound distribution model */
proc hpcdm countstore=countStorePoisson severityest=sevest
           seed=13579 nreplicates=19500plots=(edf(alpha=0.05) density )
           print=(summarystatistics percentiles);
   severitymodel logn;
   output out=aggLossSample_bus_res_&i samplevar=aggloss;
   outsum out=aggLossSummary_bus_res_&i mean stddev skewness kurtosis
         p01 p05 p95 p995 pctlpts=10 30 50 70 80 90 97.5 99.9;
run;


/* Conduct parameter perturbation analysis of
   the Poisson-gamma compound distribution model */
proc hpcdm countstore=countStorePoisson severityest=sevest
           seed=13579 nreplicates=19500 nperturbedsamples=50
           print(only)=(perturbsummary) plots=none;
   severitymodel logn;
   output out=aggLossSample_bus_res_&i  samplevar=aggloss;
   outsum out=aggLossSummary_bus_res_&i mean stddev skewness kurtosis
          p01 p05 p95 p995 pctlpts=10 30 50 70 80 90 97.5 99.9;
run;






/*-------------------------------------------------------- 
5. PEOPLE
----------------------------------------------------------*/


/*Simulate data for an intercept only Poisson Model*/

ods graphics on;
data claimcount_people_&i(keep=numLosses);
	/*call streaminit(12345);*/
	label numLosses='Number of Loss Events in a Year';
	lambda=1;
	do n=1 to 500;
	numLosses=rand('POISSON',Lambda);
	output;
	end;
run;

proc freq data=claimcount_people_&i;
tables numLosses / plots=freqplot;
run;

/* Fit an intercept-only Poisson count model and
   write estimates to an item store */
proc countreg data=claimcount_people_&i;
   model numLosses= / dist=poisson;
   store countStorePoisson;
run;



/* Simulate data for gamma severity model */
data claimsev_people_&i(keep=lossValue);
   /*call streaminit(67890);*/
   label y='Severity of a Loss Event';
   Theta = 11000;
   Alpha = 11.5;
   do n = 1 to 500;
      lossValue = quantile('Gamma', rand('UNIFORM'), Alpha, Theta);
      output;
   end;
run;
proc sgplot data=claimsev_people_&i; histogram lossValue; run;
/* Fit severity models and write estimates to a data set */
proc severity data=claimsev_people_&i criterion=aicc outest=sevest covout plots=none;
   loss lossValue;
   dist _predefined_;
run;

/* Simulate and estimate Poisson-gamma compound distribution model */
proc hpcdm countstore=countStorePoisson severityest=sevest
           seed=13579 nreplicates=19500 plots=(edf(alpha=0.05) density )
           print=(summarystatistics percentiles);
   severitymodel logn;
   output out=aggLossSample_people_&i samplevar=aggloss;
   outsum out=aggLossSummary_people_&i mean stddev skewness kurtosis
         p01 p05 p95 p995 pctlpts=10 30 50 70 80 90 97.5 99.9;
run;


/* Conduct parameter perturbation analysis of
   the Poisson-gamma compound distribution model */
proc hpcdm countstore=countStorePoisson severityest=sevest
           seed=13579 nreplicates=19500 nperturbedsamples=50
           print(only)=(perturbsummary) plots=none;
   severitymodel logn;
   output out=aggLossSample_people_&i  samplevar=aggloss;
   outsum out=aggLossSummary_people_&i mean stddev skewness kurtosis
          p01 p05 p95 p995 pctlpts=10 30 50 70 80 90 97.5 99.9;
run;




/*-------------------------------------------------------- 
6. FINANCIAL CRIME
----------------------------------------------------------

/*6a. Simulation for Stressed-Extreme*/

/*Simulate data for an intercept only Poisson Model*/

ods graphics on;
data claimcount_fin_crime_&i(keep=numLosses);
	/*call streaminit(12345);*/
	label numLosses='Number of Loss Events in a Year';
	lambda=0.228;
	do n=1 to 500;
	numLosses=rand('POISSON',Lambda);
	output;
	end;
run;

proc freq data=claimcount_fin_crime_&i;
tables numLosses / plots=freqplot;
run;

/* Fit an intercept-only Poisson count model and
   write estimates to an item store */
proc countreg data=claimcount_fin_crime_&i;
   model numLosses= / dist=poisson;
   store countStorePoisson;
run;



/* Simulate data for Lognormal severity model */
data claimsev_fin_crime_&i(keep=y label='Simple Lognormal Sample');
/*call streaminit(45678);*/
label y='Response Variable';
Mu = 16.62578533;
Sigma = 0.143251451;
do n = 1 to 500;
y = exp(Mu) * rand('LOGNORMAL')**Sigma;
output;
end;
run;
proc sgplot data=claimsev_fin_crime_&i; histogram y; run;


/* Fit severity models and write estimates to a data set */
proc severity data=claimsev_fin_crime_&i criterion=aicc outest=sevest covout plots=none;
   loss Y;
   dist _predefined_;
run;

/* Simulate and estimate Poisson-gamma compound distribution model */
proc hpcdm countstore=countStorePoisson severityest=sevest
           seed=13579 nreplicates=19500 plots=(edf(alpha=0.05) density )
           print=(summarystatistics percentiles);
   severitymodel logn;
   output out=aggLossSample_fin_crime1_&i samplevar=aggloss;
   outsum out=aggLossSummary_fin_crime_&i mean stddev skewness kurtosis
         p01 p05 p95 p995 pctlpts=10 30 50 70 80 90 97.5 99.9;
run;


/* Conduct parameter perturbation analysis of
   the Poisson-gamma compound distribution model */
proc hpcdm countstore=countStorePoisson severityest=sevest
           seed=13579 nreplicates=19500 nperturbedsamples=50
           print(only)=(perturbsummary) plots=none;
   severitymodel logn;
   output out=aggLossSample_fin_crime1_&i samplevar=aggloss;
   outsum out=aggLossSummary_fin_crime_&i mean stddev skewness kurtosis
          p01 p05 p95 p995 pctlpts=10 30 50 70 80 90 97.5 99.9;
run;









/*-------------------------------------------------------- 
7. SUPPLIER / OUTSOURCING
----------------------------------------------------------

/*7a. Simulation for Stressed-Extreme*/

/*Simulate data for an intercept only Poisson Model*/

ods graphics on;
data claimcount_supplier1_&i(keep=numLosses);
	/*call streaminit(12345);*/
	label numLosses='Number of Loss Events in a Year';
	lambda=1;
	do n=1 to 500;
	numLosses=rand('POISSON',Lambda);
	output;
	end;
run;

proc freq data=claimcount_supplier1_&i;
tables numLosses / plots=freqplot;
run;

/* Fit an intercept-only Poisson count model and
   write estimates to an item store */
proc countreg data=claimcount_supplier1_&i;
   model numLosses= / dist=poisson;
   store countStorePoisson;
run;



/* Simulate data for Lognormal severity model */
data claimsev_supplier1_&i(keep=y label='Simple Lognormal Sample');
/*call streaminit(45678);*/
label y='Response Variable';
Mu = 9.735856137;
Sigma = 3.000006609;
do n = 1 to 500;
y = exp(Mu) * rand('LOGNORMAL')**Sigma;
output;
end;
run;
proc sgplot data=claimsev_supplier1_&i; histogram y; run;


/* Fit severity models and write estimates to a data set */
proc severity data=claimsev_supplier1_&i criterion=aicc outest=sevest covout plots=none;
   loss Y;
   dist _predefined_;
run;

/* Simulate and estimate Poisson-gamma compound distribution model */
proc hpcdm countstore=countStorePoisson severityest=sevest
           seed=13579 nreplicates=10000 plots=(edf(alpha=0.05) density )
           print=(summarystatistics percentiles);
   severitymodel logn;
   output out=aggLossSample_supplier1_&i samplevar=aggloss;
   outsum out=aggLossSummary_supplier1_&i mean stddev skewness kurtosis
          p01 p05 p95 p995 pctlpts=10 30 50 70 80 90 97.5 99.9;
run;


/* Conduct parameter perturbation analysis of
   the Poisson-gamma compound distribution model */
proc hpcdm countstore=countStorePoisson severityest=sevest
           seed=13579 nreplicates=10000 nperturbedsamples=50
           print(only)=(perturbsummary) plots=none;
   severitymodel logn;
   output out=aggLossSample_supplier1_&i samplevar=aggloss;
   outsum out=aggLossSummary_supplier1_&i mean stddev skewness kurtosis
          p01 p05 p95 p995 pctlpts=10 30 50 70 80 90 97.5 99.9;
run;



/*7b. Simulation for Moderate-Stressed*/

/*Simulate data for an intercept only Poisson Model*/

ods graphics on;
data claimcount_supplier2_&i(keep=numLosses);
	/*call streaminit(12345);*/
	label numLosses='Number of Loss Events in a Year';
	lambda=1;
	do n=1 to 500;
	numLosses=rand('POISSON',Lambda);
	output;
	end;
run;

proc freq data=claimcount_supplier2_&i;
tables numLosses / plots=freqplot;
run;

/* Fit an intercept-only Poisson count model and
   write estimates to an item store */
proc countreg data=claimcount_supplier2_&i;
   model numLosses= / dist=poisson;
   store countStorePoisson;
run;


/* Simulate data for Lognormal severity model */
data claimsev_supplier2_&i(keep=y label='Simple Lognormal Sample');
/*call streaminit(45678);*/
label y='Response Variable';
Mu = 11.19145826;
Sigma = 2.115063354;
do n = 1 to 500;
y = exp(Mu) * rand('LOGNORMAL')**Sigma;
output;
end;
run;
proc sgplot data=claimsev_supplier2_&i; histogram y; run;


/* Fit severity models and write estimates to a data set */
proc severity data=claimsev_supplier2_&i criterion=aicc outest=sevest covout plots=none;
   loss Y;
   dist _predefined_;
run;

/* Simulate and estimate Poisson-gamma compound distribution model */
proc hpcdm countstore=countStorePoisson severityest=sevest
           seed=13579 nreplicates=10000 plots=(edf(alpha=0.05) density )
           print=(summarystatistics percentiles);
   severitymodel logn;
   output out=aggLossSample_supplier2_&i samplevar=aggloss;
   outsum out=aggLossSummary_supplier2_&i mean stddev skewness kurtosis
          p01 p05 p95 p995 pctlpts=10 30 50 70 80 90 97.5 99.9;
run;


/* Conduct parameter perturbation analysis of
   the Poisson-gamma compound distribution model */
proc hpcdm countstore=countStorePoisson severityest=sevest
           seed=13579 nreplicates=10000 nperturbedsamples=50
           print(only)=(perturbsummary) plots=none;
   severitymodel logn;
   output out=aggLossSample_supplier2_&i samplevar=aggloss;
   outsum out=aggLossSummary_supplier2_&i mean stddev skewness kurtosis
          p01 p05 p95 p995 pctlpts=10 30 50 70 80 90 97.5 99.9;
run;





/*-------------------------------------------------------- 
8. INFORMATION SECURITY & CYBER
----------------------------------------------------------

/*8a. Simulation for Stressed-Extreme*/

/*Simulate data for an intercept only Poisson Model*/

ods graphics on;
data claimcount_it_cyber1_&i(keep=numLosses);
	/*call streaminit(12345);*/
	label numLosses='Number of Loss Events in a Year';
	lambda=1;
	do n=1 to 500;
	numLosses=rand('POISSON',Lambda);
	output;
	end;
run;

proc freq data=claimcount_it_cyber1_&i;
tables numLosses / plots=freqplot;
run;

/* Fit an intercept-only Poisson count model and
   write estimates to an item store */
proc countreg data=claimcount_it_cyber1_&i;
   model numLosses= / dist=poisson;
   store countStorePoisson;
run;



/* Simulate data for Lognormal severity model */
data claimsev_it_cyber1_&i(keep=y label='Simple Lognormal Sample');
/*call streaminit(45678);*/
label y='Response Variable';
Mu = 12.75685702;
Sigma = 2.139005635;
do n = 1 to 500;
y = exp(Mu) * rand('LOGNORMAL')**Sigma;
output;
end;
run;
proc sgplot data=claimsev_it_cyber1_&i; histogram y; run;


/* Fit severity models and write estimates to a data set */
proc severity data=claimsev_it_cyber1_&i criterion=aicc outest=sevest covout plots=none;
   loss Y;
   dist _predefined_;
run;

/* Simulate and estimate Poisson-gamma compound distribution model */
proc hpcdm countstore=countStorePoisson severityest=sevest
           seed=13579 nreplicates=10000 plots=(edf(alpha=0.05) density )
           print=(summarystatistics percentiles);
   severitymodel logn;
   output out=aggLossSample_it_cyber1_&i  samplevar=aggloss;
   outsum out=aggLossSummary_it_cyber1_&i mean stddev skewness kurtosis
          p01 p05 p95 p995 pctlpts=10 30 50 70 80 90 97.5 99.9;
run;


/* Conduct parameter perturbation analysis of
   the Poisson-gamma compound distribution model */
proc hpcdm countstore=countStorePoisson severityest=sevest
           seed=13579 nreplicates=10000 nperturbedsamples=50
           print(only)=(perturbsummary) plots=none;
   severitymodel logn;
   output out=aggLossSample_it_cyber1_&i  samplevar=aggloss;
   outsum out=aggLossSummary_it_cyber1_&i mean stddev skewness kurtosis
          p01 p05 p95 p995 pctlpts=10 30 50 70 80 90 97.5 99.9;
run;





/*8b. Simulation for Moderate-Stressed*/

/*Simulate data for an intercept only Poisson Model*/

ods graphics on;
data claimcount_it_cyber2_&i(keep=numLosses);
	/*call streaminit(12345);*/
	label numLosses='Number of Loss Events in a Year';
	lambda=1;
	do n=1 to 500;
	numLosses=rand('POISSON',Lambda);
	output;
	end;
run;

proc freq data=claimcount_it_cyber2_&i;
tables numLosses / plots=freqplot;
run;

/* Fit an intercept-only Poisson count model and
   write estimates to an item store */
proc countreg data=claimcount_it_cyber1_&i;
   model numLosses= / dist=poisson;
   store countStorePoisson;
run;



/* Simulate data for Lognormal severity model */
data claimsev_it_cyber2_&i(keep=y label='Simple Lognormal Sample');
/*call streaminit(45678);*/
label y='Response Variable';
Mu = 6.307282704;
Sigma =6.060068404;
do n = 1 to 500;
y = exp(Mu) * rand('LOGNORMAL')**Sigma;
output;
end;
run;
proc sgplot data=claimsev_it_cyber2_&i; histogram y; run;


/* Fit severity models and write estimates to a data set */
proc severity data=claimsev_it_cyber2_&i criterion=aicc outest=sevest covout plots=none;
   loss Y;
   dist _predefined_;
run;

/* Simulate and estimate Poisson-gamma compound distribution model */
proc hpcdm countstore=countStorePoisson severityest=sevest
           seed=13579 nreplicates=10000 plots=(edf(alpha=0.05) density )
           print=(summarystatistics percentiles);
   severitymodel logn;
   output out=aggLossSample_it_cyber2_&i  samplevar=aggloss;
   outsum out=aggLossSummary_it_cyber2_&i mean stddev skewness kurtosis
          p01 p05 p95 p995 pctlpts=10 30 50 70 80 90 97.5 99.9;
run;


/* Conduct parameter perturbation analysis of
   the Poisson-gamma compound distribution model */
proc hpcdm countstore=countStorePoisson severityest=sevest
           seed=13579 nreplicates=10000 nperturbedsamples=50
           print(only)=(perturbsummary) plots=none;
   severitymodel logn;
   output out=aggLossSample_it_cyber2_&i samplevar=aggloss;
   outsum out=aggLossSummary_it_cyber2_&i mean stddev skewness kurtosis
          p01 p05 p95 p995 pctlpts=10 30 50 70 80 90 97.5 99.9;
run;





/*-------------------------------------------------------- 
9. PROCESS EXECUTION
----------------------------------------------------------


/*Simulate data for an intercept only Poisson Model*/

ods graphics on;
data claimcount_process_execution_&i(keep=numLosses);
	/*call streaminit(12345);*/
	label numLosses='Number of Loss Events in a Year';
	lambda=1;
	do n=1 to 500;
	numLosses=rand('POISSON',Lambda);
	output;
	end;
run;

proc freq data=claimcount_process_execution_&i;
tables numLosses / plots=freqplot;
run;

/* Fit an intercept-only Poisson count model and
   write estimates to an item store */
proc countreg data=claimcount_process_execution_&i;
   model numLosses= / dist=poisson;
   store countStorePoisson;
run;



/* Simulate data for Lognormal severity model */
data claimsev_process_exec_&i(keep=y label='Simple Lognormal Sample');
/*call streaminit(45678);*/
label y='Response Variable';
Mu = 7.243214381;
Sigma = 3.791374666;
do n = 1 to 500;
y = exp(Mu) * rand('LOGNORMAL')**Sigma;
output;
end;
run;
proc sgplot data=claimsev_process_exec_&i; histogram y; run;


/* Fit severity models and write estimates to a data set */
proc severity data=claimsev_process_exec_&i criterion=aicc outest=sevest covout plots=none;
   loss Y;
   dist _predefined_;
run;

/* Simulate and estimate Poisson-gamma compound distribution model */
proc hpcdm countstore=countStorePoisson severityest=sevest
           seed=13579 nreplicates=19500 plots=(edf(alpha=0.05) density )
           print=(summarystatistics percentiles);
   severitymodel logn;
   output out=aggLossSample_proc_exec_&i samplevar=aggloss;
   outsum out=aggLossSummary_proc_exec_&i mean stddev skewness kurtosis
          p01 p05 p95 p995 pctlpts=10 30 50 70 80 90 97.5 99.9;
run;


/* Conduct parameter perturbation analysis of
   the Poisson-gamma compound distribution model */
proc hpcdm countstore=countStorePoisson severityest=sevest
           seed=13579 nreplicates=19500 nperturbedsamples=50
           print(only)=(perturbsummary) plots=none;
   severitymodel logn;
   output out=aggLossSample_proc_exec_&i samplevar=aggloss;
   outsum out=aggLossSummary_proc_exec_&i mean stddev skewness kurtosis
          p01 p05 p95 p995 pctlpts=10 30 50 70 80 90 97.5 99.9;
run;





/*-------------------------------------------------------- 
10. TECHNICAL RESILIENCE
----------------------------------------------------------
/*10a. Simulation for Stressed-Extreme*/
/*Simulate data for an intercept only Poisson Model*/

ods graphics on;
data claimcount_tech_resilience1_&i(keep=numLosses);
	/*call streaminit(12345);*/
	label numLosses='Number of Loss Events in a Year';
	lambda=1;
	do n=1 to 500;
	numLosses=rand('POISSON',Lambda);
	output;
	end;
run;

proc freq data=claimcount_tech_resilience1_&i;
tables numLosses / plots=freqplot;
run;

/* Fit an intercept-only Poisson count model and
   write estimates to an item store */
proc countreg data=claimcount_tech_resilience1_&i;
   model numLosses= / dist=poisson;
   store countStorePoisson;
run;



/* Simulate data for Lognormal severity model */
data claimsev_tech_resilience1_&i(keep=y label='Simple Lognormal Sample');
/*call streaminit(45678);*/
label y='Response Variable';
Mu = 0.002610298;
Sigma = 8.573304834;
do n = 1 to 500;
y = exp(Mu) * rand('LOGNORMAL')**Sigma;
output;
end;
run;
proc sgplot data=claimsev_tech_resilience1_&i; histogram y; run;


/* Fit severity models and write estimates to a data set */
proc severity data=claimsev_tech_resilience1_&i criterion=aicc outest=sevest covout plots=none;
   loss Y;
   dist _predefined_;
run;

/* Simulate and estimate Poisson-gamma compound distribution model */
proc hpcdm countstore=countStorePoisson severityest=sevest
           seed=13579 nreplicates=10000 plots=(edf(alpha=0.05) density )
           print=(summarystatistics percentiles);
   severitymodel logn;
   output out=aggLossSample_tech_res1_&i samplevar=aggloss;
   outsum out=aggLossSummary_tech_res1_&i mean stddev skewness kurtosis
         p01 p05 p95 p995 pctlpts=10 30 50 70 80 90 97.5 99.9;
run;


/* Conduct parameter perturbation analysis of
   the Poisson-gamma compound distribution model */
proc hpcdm countstore=countStorePoisson severityest=sevest
           seed=13579 nreplicates=10000 nperturbedsamples=50
           print(only)=(perturbsummary) plots=none;
   severitymodel logn;
   output out=aggLossSample_tech_res1_&i samplevar=aggloss;
   outsum out=aggLossSummary_tech_res1_&i mean stddev skewness kurtosis
          p01 p05 p95 p995 pctlpts=10 30 50 70 80 90 97.5 99.9;
run;



/*10b. Simulation for Moderate-Stressed*/
/*Simulate data for an intercept only Poisson Model*/

ods graphics on;
data claimcount_tech_resilience2_&i(keep=numLosses);
	/*call streaminit(12345);*/
	label numLosses='Number of Loss Events in a Year';
	lambda=1;
	do n=1 to 500;
	numLosses=rand('POISSON',Lambda);
	output;
	end;
run;

proc freq data=claimcount_tech_resilience2_&i;
tables numLosses / plots=freqplot;
run;

/* Fit an intercept-only Poisson count model and
   write estimates to an item store */
proc countreg data=claimcount_tech_resilience2_&i;
   model numLosses= / dist=poisson;
   store countStorePoisson;
run;



/* Simulate data for Lognormal severity model */
data claimsev_tech_resilience2_&i(keep=y label='Simple Lognormal Sample');
/*call streaminit(45678);*/
label y='Response Variable';
Mu = 5.755202598;
Sigma = 5.075977044;
do n = 1 to 500;
y = exp(Mu) * rand('LOGNORMAL')**Sigma;
output;
end;
run;
proc sgplot data=claimsev_tech_resilience2_&i; histogram y; run;


/* Fit severity models and write estimates to a data set */
proc severity data=claimsev_tech_resilience2_&i criterion=aicc outest=sevest covout plots=none;
   loss Y;
   dist _predefined_;
run;

/* Simulate and estimate Poisson-gamma compound distribution model */
proc hpcdm countstore=countStorePoisson severityest=sevest
           seed=13579 nreplicates=10000 plots=(edf(alpha=0.05) density )
           print=(summarystatistics percentiles);
   severitymodel logn;
   output out=aggLossSample_tech_res2_&i samplevar=aggloss;
   outsum out=aggLossSummary_tech_res2_&i mean stddev skewness kurtosis
         p01 p05 p95 p995 pctlpts=10 30 50 70 80 90 97.5 99.9;
run;


/* Conduct parameter perturbation analysis of
   the Poisson-gamma compound distribution model */
proc hpcdm countstore=countStorePoisson severityest=sevest
           seed=13579 nreplicates=10000 nperturbedsamples=50
           print(only)=(perturbsummary) plots=none;
   severitymodel logn;
   output out=aggLossSample_tech_res2_&i samplevar=aggloss;
   outsum out=aggLossSummary_tech_res2_&i mean stddev skewness kurtosis
          p01 p05 p95 p995 pctlpts=10 30 50 70 80 90 97.5 99.9;
run;



/*-------------------------------------------------------- 
11. LEGAL & REGULATORY
----------------------------------------------------------

/*11a. Simulation for Stressed-Extreme*/

/*Simulate data for an intercept only Poisson Model*/

ods graphics on;
data claimcount_legal_reg1_&i(keep=numLosses);
	/*call streaminit(12345);*/
	label numLosses='Number of Loss Events in a Year';
	lambda=1;
	do n=1 to 500;
	numLosses=rand('POISSON',Lambda);
	output;
	end;
run;

proc freq data=claimcount_legal_reg1_&i;
tables numLosses / plots=freqplot;
run;

/* Fit an intercept-only Poisson count model and
   write estimates to an item store */
proc countreg data=claimcount_legal_reg1_&i;
   model numLosses= / dist=poisson;
   store countStorePoisson;
run;

/* Simulate data for Lognormal severity model */
data claimsev_legal_reg1_&i(keep=y label='Simple Lognormal Sample');
/*call streaminit(45678);*/
label y='Response Variable';
Mu =11.24055277;
Sigma = 2.666814732;
do n = 1 to 500;
y = exp(Mu) * rand('LOGNORMAL')**Sigma;
output;
end;
run;


proc sgplot data=claimsev_legal_reg1_&i; histogram y; run;


/* Fit severity models and write estimates to a data set */
proc severity data=claimsev_legal_reg1_&i criterion=aicc outest=sevest covout plots=none;
   loss Y;
   dist _predefined_;
run;

/* Simulate and estimate Poisson-gamma compound distribution model */
proc hpcdm countstore=countStorePoisson severityest=sevest
           seed=13579 nreplicates=10000 plots=(edf(alpha=0.05) density )
           print=(summarystatistics percentiles);
   severitymodel logn;
   output out=aggLossSample_legal_reg1_&i samplevar=aggloss;
   outsum out=aggLossSummary_legal_reg1_&i mean stddev skewness kurtosis
          p01 p05 p95 p995 pctlpts=10 30 50 70 80 90 97.5 99.9;
run;


/* Conduct parameter perturbation analysis of
   the Poisson-gamma compound distribution model */
proc hpcdm countstore=countStorePoisson severityest=sevest
           seed=13579 nreplicates=10000 nperturbedsamples=50
           print(only)=(perturbsummary) plots=none;
   severitymodel logn;
   output out=aggLossSample_legal_reg1_&i samplevar=aggloss;
   outsum out=aggLossSummary_legal_reg1_&i mean stddev skewness kurtosis
          p01 p05 p95 p995 pctlpts=10 30 50 70 80 90 97.5 99.9;
run;





/*11b. Simulation for Moderate-Stressed*/

/*Simulate data for an intercept only Poisson Model*/

ods graphics on;
data claimcount_legal_reg2_&i(keep=numLosses);
	/*call streaminit(12345);*/
	label numLosses='Number of Loss Events in a Year';
	lambda=1;
	do n=1 to 500;
	numLosses=rand('POISSON',Lambda);
	output;
	end;
run;

proc freq data=claimcount_legal_reg2_&i;
tables numLosses / plots=freqplot;
run;

/* Fit an intercept-only Poisson count model and
   write estimates to an item store */
proc countreg data=claimcount_legal_reg2_&i;
   model numLosses= / dist=poisson;
   store countStorePoisson;
run;

/* Simulate data for Lognormal severity model */
data claimsev_legal_reg2_&i(keep=y label='Simple Lognormal Sample');
/*call streaminit(45678);*/
label y='Response Variable';
Mu = 10.30481793;
Sigma = 3.235701122;
do n = 1 to 500;
y = exp(Mu) * rand('LOGNORMAL')**Sigma;
output;
end;
run;


proc sgplot data=claimsev_legal_reg2_&i; histogram y; run;


/* Fit severity models and write estimates to a data set */
proc severity data=claimsev_legal_reg2_&i criterion=aicc outest=sevest covout plots=none;
   loss Y;
   dist _predefined_;
run;

/* Simulate and estimate Poisson-gamma compound distribution model */
proc hpcdm countstore=countStorePoisson severityest=sevest
           seed=13579 nreplicates=10000 plots=(edf(alpha=0.05) density )
           print=(summarystatistics percentiles);
   severitymodel logn;
   output out=aggLossSample_legal_reg2_&i samplevar=aggloss;
   outsum out=aggLossSummary_legal_reg2_&i mean stddev skewness kurtosis
          p01 p05 p95 p995 pctlpts=10 30 50 70 80 90 97.5 99.9;
run;


/* Conduct parameter perturbation analysis of
   the Poisson-gamma compound distribution model */
proc hpcdm countstore=countStorePoisson severityest=sevest
           seed=13579 nreplicates=10000 nperturbedsamples=50
           print(only)=(perturbsummary) plots=none;
   severitymodel logn;
   output out=aggLossSample_legal_reg2_&i samplevar=aggloss;
   outsum out=aggLossSummary_legal_reg2_&i mean stddev skewness kurtosis
          p01 p05 p95 p995 pctlpts=10 30 50 70 80 90 97.5 99.9;
run;




%macro subset_95(id,pct);
proc UNIVARIATE data=&id.;                                               
   var AGGLOSS;                                                       
    output out=TEST_&id. pctlpts=&pct.  pctlpre=PostTest_
              pctlname=P95;                                  
run;                                                                 
                                                                      
/* Create macro variables for the 95th percentile values  */     
data _null_;                                                         
   set  TEST_&id.; 
    call symputx('p95',PostTest_p95);                                     
run;    
%put &p95; 
                                                                      
data  &id.;                                                             
   set  &id.   ;                                                      
/* Use a WHERE statement to subset the data  */                         
    where   AGGLOSS le &p95;                                     
	run;
%mend;




%rownum(id=EXT_FRAUD1_&i);
%rownum(id=EXT_FRAUD2_&i);
%rownum(id=INT_FRAUD1_&i);
%rownum(id=INT_FRAUD2_&i);
%rownum(id=BUS_RES_&i);
%rownum(id=DATA1_&i);
%rownum(id=DATA2_&i);
%rownum(id=FIN_CRIME1_&i);
%rownum(id=IT_CYBER1_&i);
%rownum(id=IT_CYBER2_&i);
%rownum(id=LEGAL_REG1_&i);
%rownum(id=LEGAL_REG2_&i);
%rownum(id=PEOPLE_&i);
%rownum(id=PROC_EXEC_&i);
%rownum(id=SUPPLIER1_&i);
%rownum(id=SUPPLIER2_&i);
%rownum(id=TECH_RES1_&i);
%rownum(id=TECH_RES2_&i);


%subset_95(EXT_FRAUD2_&i,pct=95);
%subset_95(INT_FRAUD2_&i,pct=95);
%subset_95(DATA2_&i,pct=95);
%subset_95(IT_CYBER2_&i,pct=95);
%subset_95(LEGAL_REG2_&i,pct=95);
%subset_95(SUPPLIER2_&i,pct=95);
%subset_95(TECH_RES2_&i,pct=95);



%JOIN (EXT_FRAUD_&i,id1=EXT_FRAUD1_&i,id2=EXT_FRAUD2_&i);
%JOIN (INT_FRAUD_&i,id1=INT_FRAUD1_&i,id2=INT_FRAUD2_&i);
%JOIN (DATA_&i,id1=DATA1_&i,id2=DATA2_&i);
%JOIN (IT_CYBER_&i,id1=IT_CYBER1_&i,id2=IT_CYBER2_&i);
%JOIN (LEGAL_REG_&i,id1=LEGAL_REG1_&i,id2=LEGAL_REG2_&i);
%JOIN (SUPPLIER_&i,id1=SUPPLIER1_&i,id2=SUPPLIER2_&i);
%JOIN (TECH_RES_&i,id1=TECH_RES1_&i,id2=TECH_RES2_&i);



%randomise(id=EXT_FRAUD_&i);
%randomise(id=INT_FRAUD_&i);
%randomise(id=BUS_RES_&i);
%randomise(id=DATA_&i);
%randomise(id=FIN_CRIME1_&i);
%randomise(id=IT_CYBER_&i);
%randomise(id=LEGAL_REG_&i);
%randomise(id=PEOPLE_&i);
%randomise(id=PROC_EXEC_&i);
%randomise(id=SUPPLIER_&i);
%randomise(id=TECH_RES_&i);



%rownum2(id=EXT_FRAUD_&i);
%rownum2(id=INT_FRAUD_&i);
%rownum2(id=BUS_RES_&i);
%rownum2(id=DATA_&i);
%rownum2(id=FIN_CRIME1_&i);
%rownum2(id=IT_CYBER_&i);
%rownum2(id=LEGAL_REG_&i);
%rownum2(id=PEOPLE_&i);
%rownum2(id=PROC_EXEC_&i);
%rownum2(id=SUPPLIER_&i);
%rownum2(id=TECH_RES_&i);




PROC SQL;
CREATE TABLE LOSSES_&i
AS
SELECT 
A.AGGLOSS AS EXT_FRAUD,
B.AGGLOSS AS INT_FRAUD,
C.AGGLOSS AS BUS_RES,
D.AGGLOSS AS DATA,
E.AGGLOSS AS FIN_CRIME,
F.AGGLOSS AS IT_CYBER,
G.AGGLOSS AS LEGAL_REG,
H.AGGLOSS AS PEOPLE,
I.AGGLOSS AS PROC_EXEC,
J.AGGLOSS AS SUPPLIER,
K.AGGLOSS AS TECH_RES

FROM RAN_EXT_FRAUD_&i A
LEFT JOIN RAN_INT_FRAUD_&i B
ON A.ROW_NEW=B.ROW_NEW
LEFT JOIN RAN_BUS_RES_&i C
ON A.ROW_NEW=C.ROW_NEW
LEFT JOIN RAN_DATA_&i D
ON A.ROW_NEW=D.ROW_NEW
LEFT JOIN RAN_FIN_CRIME1_&i E
ON A.ROW_NEW=E.ROW_NEW
LEFT JOIN RAN_IT_CYBER_&i F
ON A.ROW_NEW=F.ROW_NEW
LEFT JOIN RAN_LEGAL_REG_&i G
ON A.ROW_NEW=G.ROW_NEW
LEFT JOIN RAN_PEOPLE_&i H
ON A.ROW_NEW=H.ROW_NEW
LEFT JOIN RAN_PROC_EXEC_&i I
ON A.ROW_NEW=I.ROW_NEW
LEFT JOIN RAN_SUPPLIER_&i J
ON A.ROW_NEW=J.ROW_NEW
LEFT JOIN RAN_TECH_RES_&i K
ON A.ROW_NEW=K.ROW_NEW
;
QUIT;


PROC SQL;
CREATE TABLE BOUND_LOSSES_&i
AS
SELECT 
CASE WHEN EXT_FRAUD>= 28236820 THEN 28236820 ELSE EXT_FRAUD END AS EXT_FRAUD,
CASE WHEN INT_FRAUD >= 14544886 THEN 14544886 ELSE INT_FRAUD END AS INT_FRAUD,
CASE WHEN BUS_RES >= 400000 THEN 400000 ELSE BUS_RES END AS BUS_RES,
CASE WHEN DATA >= 24902350 THEN 24902350 ELSE DATA END AS DATA,
CASE WHEN FIN_CRIME >= 22932160 THEN 22932160 ELSE FIN_CRIME END AS FIN_CRIME,
CASE WHEN IT_CYBER >= 33766888 THEN 33766888 ELSE IT_CYBER END AS IT_CYBER,
CASE WHEN LEGAL_REG >= 21919560 THEN 21919560 ELSE LEGAL_REG END AS LEGAL_REG,
CASE WHEN PEOPLE >= 787000 THEN 787000 ELSE PEOPLE END AS PEOPLE,
CASE WHEN PROC_EXEC >= 4592960 THEN 4592960 ELSE PROC_EXEC END AS PROC_EXEC,
CASE WHEN SUPPLIER >= 9603147 THEN 9603147 ELSE SUPPLIER END AS SUPPLIER,
CASE WHEN TECH_RES >= 37712600 THEN 37712600 ELSE TECH_RES END AS TECH_RES
FROM LOSSES_&i
;
QUIT;



PROC SQL;
CREATE TABLE INS_AGG_&i
AS
SELECT  SUM(EXT_FRAUD, INT_FRAUD) AS POLICY_A,
		BUS_RES,
		PROC_EXEC AS POLICY_C,
		LEGAL_REG as POLICY_D,
DATA,
FIN_CRIME,
IT_CYBER,
PEOPLE,
SUPPLIER,
TECH_RES
FROM BOUND_LOSSES_&i
;
QUIT;



PROC SQL;
CREATE TABLE LOSSES_INS_&i
AS
SELECT 
CASE WHEN POLICY_A>1000000 THEN (POLICY_A-10000000+1500000) 
 	 WHEN POLICY_A BETWEEN 1500000 AND 1000000 THEN 1500000
	 ELSE POLICY_A END AS POLICY_A,

BUS_RES, 
DATA,
FIN_CRIME,
IT_CYBER,
CASE WHEN POLICY_D>20000000 THEN (POLICY_D-20000000+1500000) 
	 WHEN POLICY_D BETWEEN 1500000 AND 20000000 THEN 1500000
	 ELSE POLICY_D END AS POLICY_D,
PEOPLE,
CASE WHEN POLICY_C>10000000 THEN (POLICY_C-10000000+1500000) 
	 WHEN POLICY_C BETWEEN 1500000 AND 10000000 THEN 1500000
	 ELSE POLICY_C END AS POLICY_C,
SUPPLIER,
TECH_RES
FROM INS_AGG_&i
;
QUIT;



/*RISK SUMMATION*/

PROC SQL;
CREATE TABLE OPLOSS_&i
AS
SELECT 
Sum(POLICY_A,
BUS_RES,
POLICY_C,
POLICY_D,
DATA,
FIN_CRIME,
IT_CYBER,
PEOPLE,
SUPPLIER,
TECH_RES) as oploss
from 
LOSSES_INS_&i
;
QUIT;

PROC UNIVARIATE DATA=OPLOSS_&i;
  VAR oploss;
  output out=Pctls_&i pctlpts=20 40 50 70 80 82 84 86 88 90 95 97.5 99 99.5 99.9 pctlpre=PostTest_
              pctlname=P20 P40 P50 P70 P80 P82 P84 P86 P88 P90 P95 P975 p99 p995 p999;
RUN;

 %end;


%mend create_cdm;

%create_cdm(3);




data OPLOSS_STATS;
 set Pctls_:;
run;








/*******************************************************************************/

/*********************************/
/*CORRELATIONS*/
/*********************************/

/*******************************************************************************/


/*THE MACRO IMPORTS A NUMBER OF RANDOM MATRICES(M) FROM A LIST OF 100 EXTERNAL MATRICES*/

 
%macro RANDOM_MATRIX(M);
%do j=1 %to &M;
DATA RAN_INTL;
DO i=1;
x=%randbetween(1,100);
KEEP X;
OUTPUT;
END;
RUN;

PROC SQL;
	 SELECT X
	 INTO:VARLIST 
	 FROM RAN_INTL;
	 QUIT;
	%PUT &VARLIST;


%LOCAL i item itemCount;
%LET i = 1;

    %do %while (%length(%scan(&varlist,&i)));
    %let item = %scan(&varlist,&i);

    %let itemCount = &i;  
    %local item&i;       
    %let item&i = &item;  

    %let i = %eval(&i+1);
  %end;

 %do i =1 %to &itemCount;
  proc import
  out=MATRIX_&ITEM
  dbms=xlsx
  datafile="/creditrisk/risk/IMV/OpRisk/Input/Matrix/MacroTestFile&&item&i"
  replace;
  sheet="Sheet1"; 
  getnames=yes;
  datarow=4;
run;


DATA COR_MATRIX_&j;
SET MATRIX_&ITEM;
RUN;

PROC SQL;
CREATE TABLE COR_MATRIX_SUB_&J
AS
SELECT 
BU,BV,BW,BX,BY,BZ,CA,CB,CC,CD,CE
FROM COR_MATRIX_&J
;
QUIT;


PROC DELETE DATA=MATRIX_&ITEM;
RUN;

PROC DELETE DATA=COR_MATRIX_&J;
RUN;
%end;
%end;
%mend;

%RANDOM_MATRIX(3);



/*MACRO TO SORT AND JOIN THE DATASETS WITH THE MATRICES*/



%macro ranked(repetitions);
   %do i=1 %to &repetitions;

proc sort data=EXT_FRAUD_&i;
by aggloss;
run;
proc sort data=INT_FRAUD_&i;
by aggloss;
run;
proc sort data=BUS_RES_&i;
by aggloss;
run;
proc sort data=DATA_&i;
by aggloss;
run;
proc sort data=FIN_CRIME1_&i;
by aggloss;
run;
proc sort data=IT_CYBER_&i;
by aggloss;
run;
proc sort data=LEGAL_REG_&i;
by aggloss;
run;
proc sort data=PEOPLE_&i;
by aggloss;
run;
proc sort data=PROC_EXEC_&i;
by aggloss;
run;
proc sort data=SUPPLIER_&i;
by aggloss;
run;
proc sort data=TECH_RES_&i;
by aggloss;
run;

%rownum2(id=EXT_FRAUD_&i);
%rownum2(id=INT_FRAUD_&i);
%rownum2(id=BUS_RES_&i);
%rownum2(id=DATA_&i);
%rownum2(id=FIN_CRIME1_&i);
%rownum2(id=IT_CYBER_&i);
%rownum2(id=LEGAL_REG_&i);
%rownum2(id=PEOPLE_&i);
%rownum2(id=PROC_EXEC_&i);
%rownum2(id=SUPPLIER_&i);
%rownum2(id=TECH_RES_&i);




PROC SQL;
CREATE TABLE RANKED_LOSSES_&i
AS
SELECT
A.*,
B.AGGLOSS AS BUS_RES,
C.AGGLOSS AS DATA,
D.AGGLOSS AS EXT_FRAUD,
E.AGGLOSS AS FIN_CRIME,
F.AGGLOSS AS IT_CYBER,
G.AGGLOSS AS INT_FRAUD,
H.AGGLOSS AS LEGAL_REG,
I.AGGLOSS AS PEOPLE,
J.AGGLOSS AS PROC_EXEC,
K.AGGLOSS AS SUPPLIER,
L.AGGLOSS AS TECH_RES
FROM COR_MATRIX_SUB_&i A
LEFT JOIN 
RAN_BUS_RES_&i B
ON A.BU=B.ROW_NEW
LEFT JOIN 
RAN_DATA_&i C
ON A.BV=C.ROW_NEW
LEFT JOIN 
RAN_EXT_FRAUD_&i D
ON A.BW=D.ROW_NEW
LEFT JOIN 
RAN_FIN_CRIME1_&i E
ON A.BX=E.ROW_NEW
LEFT JOIN 
RAN_IT_CYBER_&i F
ON A.BY=F.ROW_NEW
LEFT JOIN 
RAN_INT_FRAUD_&i G
ON A.BZ=G.ROW_NEW
LEFT JOIN 
RAN_LEGAL_REG_&i H
ON A.CA=H.ROW_NEW
LEFT JOIN 
RAN_PEOPLE_&i I
ON A.CB=I.ROW_NEW
LEFT JOIN 
RAN_PROC_EXEC_&i J
ON A.CC=J.ROW_NEW
LEFT JOIN 
RAN_SUPPLIER_&i K
ON A.CD=K.ROW_NEW
LEFT JOIN 
RAN_TECH_RES_&i L
ON A.CE=L.ROW_NEW
;
QUIT;

DATA RANKED_LOSSES_&i;
SET RANKED_LOSSES_&i;
KEEP BUS_RES 
DATA
EXT_FRAUD
FIN_CRIME
IT_CYBER
INT_FRAUD
LEGAL_REG
PEOPLE
PROC_EXEC
SUPPLIER
TECH_RES;
RUN;

/*******************************************/



PROC SQL;
CREATE TABLE COR_BOUND_LOSSES_&i
AS
SELECT 
CASE WHEN EXT_FRAUD>= 28236820 THEN 28236820 ELSE EXT_FRAUD END AS EXT_FRAUD,
CASE WHEN INT_FRAUD >= 14544886 THEN 14544886 ELSE INT_FRAUD END AS INT_FRAUD,
CASE WHEN BUS_RES >= 400000 THEN 400000 ELSE BUS_RES END AS BUS_RES,
CASE WHEN DATA >= 24902350 THEN 24902350 ELSE DATA END AS DATA,
CASE WHEN FIN_CRIME >= 22932160 THEN 22932160 ELSE FIN_CRIME END AS FIN_CRIME,
CASE WHEN IT_CYBER >= 33766888 THEN 33766888 ELSE IT_CYBER END AS IT_CYBER,
CASE WHEN LEGAL_REG >= 21919560 THEN 21919560 ELSE LEGAL_REG END AS LEGAL_REG,
CASE WHEN PEOPLE >= 787000 THEN 787000 ELSE PEOPLE END AS PEOPLE,
CASE WHEN PROC_EXEC >= 4592960 THEN 4592960 ELSE PROC_EXEC END AS PROC_EXEC,
CASE WHEN SUPPLIER >= 9603147 THEN 9603147 ELSE SUPPLIER END AS SUPPLIER,
CASE WHEN TECH_RES >= 37712600 THEN 37712600 ELSE TECH_RES END AS TECH_RES
FROM RANKED_LOSSES_&i
;
QUIT;



PROC SQL;
CREATE TABLE COR_INS_AGG_&i
AS
SELECT  SUM(EXT_FRAUD, INT_FRAUD) AS POLICY_A,
		BUS_RES,
		PROC_EXEC AS POLICY_C,
		LEGAL_REG as POLICY_D,
DATA,
FIN_CRIME,
IT_CYBER,
PEOPLE,
SUPPLIER,
TECH_RES
FROM COR_BOUND_LOSSES_&i
;
QUIT;


PROC SQL;
CREATE TABLE COR_LOSSES_INS_&i
AS
SELECT 
CASE WHEN POLICY_A>1000000 THEN (POLICY_A-10000000+1500000) 
 	 WHEN POLICY_A BETWEEN 1500000 AND 1000000 THEN 1500000
	 ELSE POLICY_A END AS POLICY_A,

BUS_RES, 
DATA,
FIN_CRIME,
IT_CYBER,
CASE WHEN POLICY_D>20000000 THEN (POLICY_D-20000000+1500000) 
	 WHEN POLICY_D BETWEEN 1500000 AND 20000000 THEN 1500000
	 ELSE POLICY_D END AS POLICY_D,
PEOPLE,
CASE WHEN POLICY_C>10000000 THEN (POLICY_C-10000000+1500000) 
	 WHEN POLICY_C BETWEEN 1500000 AND 10000000 THEN 1500000
	 ELSE POLICY_C END AS POLICY_C,
SUPPLIER,
TECH_RES
FROM COR_INS_AGG_&i
;
QUIT;


PROC SQL;

CREATE TABLE OPLOSS_COR_&i
as
select 
Sum(POLICY_A,
BUS_RES,
POLICY_C,
POLICY_D,
DATA,
FIN_CRIME,
IT_CYBER,
PEOPLE,
SUPPLIER,
TECH_RES) as oploss
from 
COR_LOSSES_INS_&i
;
quit;

PROC UNIVARIATE DATA=OPLOSS_COR_&i;
  VAR oploss;
  output out=cor_Pctls_&i pctlpts=20 40 50 70 80 82 84 86 88 90 95 97.5 99 99.5 99.9 pctlpre=PostTest_
              pctlname=P20 P40 P50 P70 P80 P82 P84 P86 P88 P90 P95 P975 p99 p995 p999;
RUN;



%end;
%MEND ranked;


%ranked(3);



data COR_OPLOSS_STATS;
 set cor_Pctls_:;
run;






 proc import
  out=uncor_output
  dbms=xlsx
  datafile="/creditrisk/risk/. Analytics/79. ENTERPRISE RISK ANALYTICS/ICAAP 2019/Monte Carlo Simulation/IMV Material/Simulations Stats v3.xlsx"
  replace;
  sheet="Uncorrelated runs"; 
  getnames=yes;
;
run;


data uncor_output;
set uncor_output OPLOSS_STATS;
run;


proc export
 data=uncor_output
  dbms=xlsx 
  outfile="/creditrisk/risk/. Analytics/79. ENTERPRISE RISK ANALYTICS/ICAAP 2019/Monte Carlo Simulation/IMV Material/Simulations Stats v3.xlsx"
  replace;
  sheet="Uncorrelated runs";
run;



 proc import
  out=cor_output
  dbms=xlsx
  datafile="/creditrisk/risk/. Analytics/79. ENTERPRISE RISK ANALYTICS/ICAAP 2019/Monte Carlo Simulation/IMV Material/Simulations Stats v3.xlsx"
  replace;
  sheet="Correlated runs"; 
  getnames=yes;
;
run;


data cor_output;
set cor_output COR_OPLOSS_STATS;
run;


proc export
 data=cor_output
  dbms=xlsx 
  outfile="/creditrisk/risk/. Analytics/79. ENTERPRISE RISK ANALYTICS/ICAAP 2019/Monte Carlo Simulation/IMV Material/Simulations Stats v3.xlsx"
  replace;
  sheet="Correlated runs";
run;

%end;

%MEND OPRISK;

%OPRISK;













