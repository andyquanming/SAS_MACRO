/*�����W��: DQ_missingCounter                                                                            */
/*�@        ��: Andy                                                                                                 */
/*�B�z���n: ���Ҫ��missing������                                 					*/
/*��    �J: DSN: �����Ҫ��
                , OUT: ���ҵ��G
                , prefix: ���Ҳέp�q���W�٫e��   */
/*��    �X:  �L  */
/*�̮֤ۨ�: N/A         */
/*��    �L:                                                                                                                    */
%MACRO DQ_missingCounter( DSN  ,OUT=&DSN._OUT , prefix=mcnt_ ) ; 
        %LET memname = %scan( &DSN. , -1 , %STR(.) ) ;
        %LET  libname = %scan( &DSN. , -2 , %STR(.) ) ;
        %IF %SYSEVALF(%SUPERQ(libname)=,boolean) %THEN %LET libname = WORK ;
        %let libname =  %upcase(&libname.) ; 
        %let memname =  %upcase(&memname.) ; 
        %PUT &memname..&libname. is processing ... ;

        proc sql noprint;
                select " SUM(IFN( cmiss( " || kstrip(name) ||  " ) , 1, 0 ))  as &prefix." || kstrip(name)  || " " 
                into :check_tmp  separated by ','
                from sashelp.vcolumn
                where memtype = "DATA" 
                and memname = "&memname." 
                and libname = "&libname" 
                ;
        quit ; 
        %put &check_tmp. ;

        proc sql ; 
                create table &OUT. as 
                        select &check_tmp. 
                        from &libname..&memname. 
                        ;
        quit; 

%MEND ;

/*�d�һ���*/

	/*�d��1: unit test example 
		data test ; 
		        x1 = 1 ; x2 = "A" ; x3 = 1  ; output ; 
		        x1 = . ; x2 = "A" ; x3 = 2  ; output ; 
		        x1 = 1 ; x2 = "" ; x3 = 3  ; output ; 
		        x1 = 1 ; x2 = "" ; x3 = 4  ; output ; 
		        x1 = . ; x2 = "A" ; x3 = 5  ; output ; 
		run ; 
		%DQ_missingCounter(test , OUT=ooo) ;
	*/
