*How to create DUMMY Variables using INFILE and IMPORT Statements;

*Method-1: INFILE: variables are created within INFILE statement;
data movie_infile;
infile 'movies_Dummy.txt' delimiter='09'x MISSOVER firstobs=2;
input movie $ opening budget star $ release $ ;
d_star=(star="Star"); *dummy variable for star;
d_sum = (release="Summer"); *dummy variable for release;
run;

proc print data=movie_infile;
run;


*Method-2: IMPORT: variables are created outside IMPORT statement;
proc import datafile="movies_Dummy.txt" out=movie_import replace; 
delimiter='09'x; 
getnames=YES; 
datarow=2;
run; 

*proc print shows only the original fields;
proc print data=movie_import;
run;

*creating dummy variables outside using DATA and SET command;
*SET --> telles which data file to use. Since data was written into movie_import dataset, use this;
*DATA --> tells which dataset to write into after creating the variables. Since dataset names are the same for;
*         DATA and SET commands, it is overwriting the existing datafile;
data movie_import;
set movie_import;
d_star=(star="Star"); *dummy variable for star;
d_sum = (release="Summer"); *dummy variable for release;
run;

*proc print shows the original fields and the 2 dummy fields;
proc print data=movie_import;
run;
