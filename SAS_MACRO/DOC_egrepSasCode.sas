/*�����W��: DOC_egrepSasCode                                                                                      */
/*�@        ��: Andy                                                                                                      */
/*�B�z���n: �M�亡�����e������r���{��                                                   */
/*��    �J: pattern(����r:Regular Expressions) ,code_dir(�{���Ҧb�ؿ�)                                         */
/*��    �X:                                                                                                                */
/*��    �L:  pattern���i�]�t�ҽk�r���H*���N                                                   */
%MACRO DOC_egrepSasCode( pattern ,code_dir , OUT=egrepRes) /minoperator mindelimiter=',' ;

	%IF %upcase(&SYSSCPL.) IN ( LINUX , %str(HP-UX) ,AIX , SUNOS )  %THEN  %DO ;
		%PUT NOTE: environment is ok ; 
	%END; 
	%ELSE %DO ;
		%PUT ERROR: execute egrepSasCode only in unix like system ;
		%ABORT CANCEL ;
	%END ;
	%LOCAL cmd ;
        %LET code_dir = %sysfunc(dequote( &code_dir. ) ) ;
        %LET pattern = %qsysfunc( dequote( &pattern. ) ) ;
        %LET pattern = %sysfunc( tranwrd( &pattern. ,*  ,.* ) ) ;
	%LET cmd =  "cd &code_dir. ; egrep -sin '&pattern.' *.sas" ; 
	
	FILENAME test pipe &cmd.;
        DATA &OUT.;
                infile test truncover;
                input line $char1000. ;
        RUN;

%MEND;

/*�d�һ���:*/
	/*�d�Ҥ@: ��/SASDATA/USER/TGLEDW/COD/MCR ���]�t macro egrep ���{���P�Ҧb��� 
		options mprint; 
		%DOC_egrepSasCode( "macro.*egrep"  , "/SASDATA/USER/TGLEDW/COD/MCR" ) 
		res: 
			egrepSasCode.sas:7:%MACRO egrepSasCode( pattern ,code_dir , OUT=egrepRes) ;
			egrepSasCode.sas:25:		%egrepSasCode( ""macro.*egrep""  , ""/SASDATA/UER/TGLEDW/COD/MCR"" )
	*/
