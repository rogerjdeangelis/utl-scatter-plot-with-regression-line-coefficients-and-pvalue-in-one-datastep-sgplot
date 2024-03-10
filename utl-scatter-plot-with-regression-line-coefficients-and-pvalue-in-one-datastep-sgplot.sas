%let pgm=utl-scatter-plot-with-regression-line-coefficients-and-pvalue-in-one-datastep-sgplot;

Scatter plot with regression line coefficients and pvalue in one datastep sgplot

github
https://tinyurl.com/3u9p8zxv
https://github.com/rogerjdeangelis/utl-scatter-plot-with-regression-line-coefficients-and-pvalue-in-one-datastep-sgplot

SOAPBOX ON

NOTES

  Documentation is lacking for DOSUBL so I am taking measures to make sure dosubl
  environement is no affected by the parent enviroment.

  1. I delete undocuemented sasmacr# catalogs in work
  2. I delete macro variables that might exist in the parent environment
  3. At the top of dosubl I delete macro variables that are created by dodubl
  4. I set dosubl return codes to failure status at the top of dosubl.
     That way syserr will have to reset the failed status for sucessful completion.

  We really neeed better documentation and performance improvements for dosubl.
  Also we need a way to share common storage with dosubl (sas r and python)

SOAPBOX OFF

see
https://goo.gl/bd96Pf
https://communities.sas.com/t5/SAS-GRAPH-and-ODS-Graphics/scatter-plot-with-regression-line-and-coefficient-and-pvalue/m-p/354721

rework of
http://blogs.sas.com/content/iml/2013/02/27/slope-of-a-regression-line.html

/**************************************************************************************************************************/
/*                 |                                                     |                                                */
/*     INPUT       |                                                     |                                                */
/*                 |                                                     |                                                */
/*  SASHELP.CLASS  | proc datasets nolist nodetails mt=cat;              |        WORK.LOG                                */
/*                 |   delete sasmac1 sasmac2;                           |                                                */
/*   HEIGHT WEIGHT | run;quit;                                           |           REGSTATUS                            */
/*                 |                                                     |    Proc reg completed                          */
/*    69.0   112.5 | %symdel int slope pval cc rx/ nowarn;               |                                                */
/*    56.5    84.0 | ods exclude all;                                    |            PLOTSTATUS                          */
/*    65.3    98.0 | data log;                                           |    Sgplot completed                            */
/*    62.8   102.5 |                                                     |                                                */
/*    63.5   102.5 |  if _n_=0 then do;                                  |                                                */
/*                 |    %dosubl('                                        |                   HEIGHT                       */
/*                 |     %symdel int slope pval cc / nowarn;             |          50         60         70              */
/*                 |     %let cc=99;                                     |          -+----------+----------+----          */
/*                 |     ods output ParameterEstimates=PE;               |          |                          |          */
/*                 |     proc reg data=sashelp.class(keep-height weight);|          |  Parameters              |          */
/*                 |        model weight = height;                       |          |                      / * |          */
/*                 |     run;                                            |          |  Intercept -143     /    |          */
/*                 |     data _null_;                                    |      140 +  Slope      3.9    /     + 140      */
/*                 |        set PE;                                      |          |  P-Value < 0.0001 / *    |          */
/*                 |        if _n_ = 1 then call symput("Int"            |    W     |                * /       |     W    */
/*                 |         ,put(estimate, BEST6.));                    |    E     |             *   /        |     E    */
/*                 |        else do;                                     |    I 120 +                /         + 120 I    */
/*                 |           call symput("Slope"                       |    G     |            * */     *    |     G    */
/*                 |             ,put(estimate, BEST6.));                |    H     |              /   *       |     H    */
/*                 |           if probt < .0001  then                    |    T     |             /**          |     T    */
/*                 |               call symput("PVal", '< 0.0001');      |      100 +          * /    *        + 100      */
/*                 |           else call symput("Pval"                   |          |           /              |          */
/*                 |              ,put(probt, BEST12.));                 |          |          /     *         |          */
/*                 |       end;                                          |          |       **/ *  *           |          */
/*                 |     run;quit;                                       |       80 +        /                 +  80      */
/*                 |     %let cc=&syserr;                                |          |       /                  |          */
/*                 |    ');                                              |           -+----------+----------+---          */
/*                 |                                                     |           50         60         70             */
/*                 |   end;                                              |                    HEIGHT                      */
/*                 |                                                     |                                                */
/*                 |   if symgetn('cc') ne 0 then do;                    |                                                */
/*                 |       regStatus= "stopping proc reg did not run";   |                                                */
/*                 |   end;                                              |                                                */
/*                 |   else regStatus = "proc reg datastep completed";   |                                                */
/*                 |                                                     |                                                */
/*                 |   putlog "&int";                                    |                                                */
/*                 |   putlog "&slope";                                  |                                                */
/*                 |   putlog "&pval";                                   |                                                */
/*                 |                                                     |                                                */
/*                 |   rc=dosubl('                                       |                                                */
/*                 |     %symdel rx / nowarn;                            |                                                */
/*                 |     %let rx=99;                                     |                                                */
/*                 |     ods select all;                                 |                                                */
/*                 |     ods graphics on;                                |                                                */
/*                 |     ods pdf file="d:/pdf/regbeta.pdf";              |                                                */
/*                 |     proc sgplot data=sashelp.class noautolegend;    |                                                */
/*                 |       title "Regression Slope Intercept P-Value";   |                                                */
/*                 |       reg y=weight x=height;                        |                                                */
/*                 |       inset "Intercept = &Int"                      |                                                */
/*                 |             "Slope     = &Slope"                    |                                                */
/*                 |             "P-Value   = &pval" /                   |                                                */
/*                 |        border                                       |                                                */
/*                 |        title="Parameter Estimates"                  |                                                */
/*                 |        position=topleft;                            |                                                */
/*                 |     run;quit;                                       |                                                */
/*                 |     %let rx=&syserr;                                |                                                */
/*                 |     ods pdf close;                                  |                                                */
/*                 |     ods graphics off;                               |                                                */
/*                 |   ');                                               |                                                */
/*                 |                                                     |                                                */
/*                 |   if symgetn('rx') ne 0 then do;                    |                                                */
/*                 |      plotStatus = "Stopping proc sgplot failed";    |                                                */
/*                 |   end;                                              |                                                */
/*                 |   else plotStatus = "sgplot completed";             |                                                */
/*                 |                                                     |                                                */
/*                 |  drop rc;                                           |                                                */
/*                 |  output;                                            |                                                */
/*                 |  stop;                                              |                                                */
/*                 |                                                     |                                                */
/*                 | run;quit;                                           |                                                */
/*                 |                                                     |                                                */
/**************************************************************************************************************************/

/*                   _
(_)_ __  _ __  _   _| |_
| | `_ \| `_ \| | | | __|
| | | | | |_) | |_| | |_
|_|_| |_| .__/ \__,_|\__|
        |_|
*/

/**************************************************************************************************************************/
/*                                                                                                                        */
/*     INPUT                                                                                                              */
/*                                                                                                                        */
/*  SASHELP.CLASS(KEEP-HEIGHT WEIGHT)                                                                                     */
/*                                                                                                                        */
/*   HEIGHT WEIGHT                                                                                                        */
/*                                                                                                                        */
/*    69.0   112.5                                                                                                        */
/*    56.5    84.0                                                                                                        */
/*    65.3    98.0                                                                                                        */
/*    62.8   102.5                                                                                                        */
/*    63.5   102.5                                                                                                        */
/*                                                                                                                        */
/**************************************************************************************************************************/

/*
 _ __  _ __ ___   ___ ___  ___ ___
| `_ \| `__/ _ \ / __/ _ \/ __/ __|
| |_) | | | (_) | (_|  __/\__ \__ \
| .__/|_|  \___/ \___\___||___/___/
|_|
*/
 proc datasets nolist nodetails mt=cat;
   delete sasmac1 sasmac2;
 run;quit;

 %symdel int slope pval cc rx/ nowarn;
 ods exclude all;
 data log;

  if _n_=0 then do;
    %dosubl('
     %symdel int slope pval cc / nowarn;
     %let cc=99;
     ods output ParameterEstimates=PE;
     proc reg data=sashelp.class(keep-height weight);
        model weight = height;
     run;
     data _null_;
        set PE;
        if _n_ = 1 then call symput("Int"
         ,put(estimate, BEST6.));
        else do;
           call symput("Slope"
             ,put(estimate, BEST6.));
           if probt < .0001  then
               call symput("PVal", '< 0.0001');
           else call symput("Pval"
              ,put(probt, BEST12.));
       end;
     run;quit;
     %let cc=&syserr;
    ');

   end;

   if symgetn('cc') ne 0 then do;
       regStatus= "stopping proc reg did not run";
   end;
   else regStatus = "proc reg datastep completed";

   putlog "&int";
   putlog "&slope";
   putlog "&pval";

   rc=dosubl('
     %symdel rx / nowarn;
     %let rx=99;
     ods select all;
     ods graphics on;
     ods pdf file="d:/pdf/regbeta.pdf";
     proc sgplot data=sashelp.class noautolegend;
       title "Regression Slope Intercept P-Value";
       reg y=weight x=height;
       inset "Intercept = &Int"
             "Slope     = &Slope"
             "P-Value   = &pval" /
        border
        title="Parameter Estimates"
        position=topleft;
     run;quit;
     %let rx=&syserr;
     ods pdf close;
     ods graphics off;
   ');

   if symgetn('rx') ne 0 then do;
      plotStatus = "Stopping proc sgplot failed";
   end;
   else plotStatus = "sgplot completed";

  drop rc;
  output;
  stop;

 run;quit;

/*           _               _
  ___  _   _| |_ _ __  _   _| |_
 / _ \| | | | __| `_ \| | | | __|
| (_) | |_| | |_| |_) | |_| | |_
 \___/ \__,_|\__| .__/ \__,_|\__|
                |_|
*/

/**************************************************************************************************************************/
/*                                                                                                                        */
/*                                                                                                                        */
/*                                                                                                                        */
/*       WORK.LOG                                                                                                         */
/*                                                                                                                        */
/*          REGSTATUS                                                                                                     */
/*   Proc reg completed                                                                                                   */
/*                                                                                                                        */
/*           PLOTSTATUS                                                                                                   */
/*   Sgplot completed                                                                                                     */
/*                                                                                                                        */
/*                                                                                                                        */
/*                  HEIGHT                                                                                                */
/*         50         60         70                                                                                       */
/*         -+----------+----------+----                                                                                   */
/*         |                          |                                                                                   */
/*         |  Parameters              |                                                                                   */
/*         |                      / * |                                                                                   */
/*         |  Intercept -143     /    |                                                                                   */
/*     140 +  Slope      3.9    /     + 140                                                                               */
/*         |  P-Value < 0.0001 / *    |                                                                                   */
/*   W     |                * /       |     W                                                                             */
/*   E     |             *   /        |     E                                                                             */
/*   I 120 +                /         + 120 I                                                                             */
/*   G     |            * */     *    |     G                                                                             */
/*   H     |              /   *       |     H                                                                             */
/*   T     |             /**          |     T                                                                             */
/*     100 +          * /    *        + 100                                                                               */
/*         |           /              |                                                                                   */
/*         |          /     *         |                                                                                   */
/*         |       **/ *  *           |                                                                                   */
/*      80 +        /                 +  80                                                                               */
/*         |       /                  |                                                                                   */
/*          -+----------+----------+---                                                                                   */
/*          50         60         70                                                                                      */
/*                   HEIGHT                                                                                               */
/*                                                                                                                        */
/**************************************************************************************************************************/

/*              _
  ___ _ __   __| |
 / _ \ `_ \ / _` |
|  __/ | | | (_| |
 \___|_| |_|\__,_|

*/












































































































|
|
|
|
|
|
|
|




HAVE
===

sashelp.class total obs=19

 NAME    SEX AGE  HEIGHT WEIGHT

 Alfred   M   14   69.0   112.5
 Alice    F   13   56.5    84.0
 Barbara  F   13   65.3    98.0
 Carol    F   14   62.8   102.5
 Henry    M   14   63.5   102.5



                       HEIGHT
              50         60         70
              -+----------+----------+----
              |                          |
              |  Parameters              |
              |                      / * |
              |  Intercept -143     /    |
          140 +  Slope      3.9    /     + 140
              |  P-Value < 0.0001 / *    |
        W     |                * /       |     W
        E     |             *   /        |     E
        I 120 +                /         + 120 I
        G     |            * */     *    |     G
        H     |              /   *       |     H
        T     |             /**          |     T
          100 +          * /    *        + 100
              |           /              |
              |          /     *         |
              |       **/ *  *           |
           80 +        /                 +  80
              |       /                  |
              -+----------+----------+---
              50         60         70
                       HEIGHT

WORKING CODE
============
  DOSUBL

       proc reg data=sashelp.class;
       if _n_ = 1 then call symput("Int", put(estimate, BEST6.));
       else            call symput("Slope", put(estimate, BEST6.));

  DOSUBL

    proc sgplot data=sashelp.class noautolegend;
    reg y=weight x=height;
    inset "Intercept = &Int" "Slope = &Slope" /

*          _       _   _
 ___  ___ | |_   _| |_(_) ___  _ __
/ __|/ _ \| | | | | __| |/ _ \| '_ \
\__ \ (_) | | |_| | |_| | (_) | | | |
|___/\___/|_|\__,_|\__|_|\___/|_| |_|

;
/*----                                                                   ----*/
/*---- I have tried to clear every possible previous catalogs            ----*/
/*---- or macro variables. Even though I don't think it is needed.       ----*/
/*----                                                                   ----*/

proc datasets nolist nodetails mt=cat;
 delete sasmac1 sasmac2;
run;quit;

%symdel int slope pval cc rx/ nowarn;

data log;

  if _n_=0 then do;
     %dosubl('
       %symdel int slope pval cc / nowarn;
       %let cc=99;
       ods output ParameterEstimates=PE;
       proc reg data=sashelp.class;
          model weight = height;
       run;
       data _null_;
          set PE;
          if _n_ = 1 then call symput("Int"
           ,put(estimate, BEST6.));
          else do;
             call symput("Slope"
               ,put(estimate, BEST6.));
             if probt < .0001  then
                 call symput("PVal", '< 0.0001');
             else call symput("Pval"
                ,put(probt, BEST12.));
         end;
       run;quit;
       %let cc=&syserr;
     ');

   end;

   if symgetn('cc') ne 0 then do;
       regStatus  = "stopping 'proc reg' did not run";
   end;
   else regStatus = "proc reg datastep completed";

   putlog "&int";
   putlog "&slope";
   putlog "&pval";

   rc=dosubl('
     %symdel rx / nowarn;
     %let rx=99;
     ods select all;
     ods graphics on;
     ods pdf file="d:/pdf/regbeta.pdf";
     proc sgplot data=sashelp.class noautolegend;
       title "Regression Slope Intercept P-Value";
       reg y=weight x=height;
       inset "Intercept = &Int"
             "Slope    = &Slope"
             "P-Value" "&pval" /
        border
        title="Parameter Estimates"
        position=topleft;
     run;quit;
     %let rx=&syserr;
     ods pdf close;
     ods graphics off;
   ');

   if symgetn('rx') ne 0 then do;
      plotStatus = "Stopping 'proc sgplot' did not run";
   end;
   else plotStatus = "sgplot completed";

  drop rc;
  output;
  stop;

run;quit;










data log;


  rc=dosubl('
    proc sql;
      create
         table names as
      select
         *
      from
         sashelp.class
     quit;
     %let cc=3;
  ');

  if symgetn('cc') = 0 then status="Completed";
  else status="Failed";
  put status;

run;quit;
