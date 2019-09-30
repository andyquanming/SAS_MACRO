/*�@        ��: Andy                                                                                                                         */
/*�B�z���n: ��Ƥ��s��p��έp�q�A�ë��w�@���ܼƮi�}���έp�q�x�}                          */
/*��    �J:  DSNAME: �n�ഫ��DataSet
		 BYVAR: ���s�ܼ�
		 IDVAR: �n��m���ܼ�(�ܼƭȷ|�ܦ����W��)
                 PREFIX: �ܼƫe��W��
                 SUFFIX: �ܼƫ��W��
		 OUT : �ഫ�ᵲ�G 
                  AGGREGATE: �έp�q */
/*��    �X:  N/A                                                                                                                                  */
/*�̮֤ۨ�: N/A                                                                                                                           */
%MACRO DQ_matricsBuilder( DSNAME , 
						 BYVAR/*variable to group by (var1, var2, ... ,varn) */ , 
						  IDVAR /* variable to expand to columns */ , 
						  PREFIX= /* idvar �e��W�� */,
                                                  SUFFIX= /* idvar ���W�� */ ,
						  OUT=%scan( &DSNAME. , -1  , %str(.) )_&SYSJOBID.&SYSINDEX. /*Result DataSet*/ ,
						  AGGREGATE=count(*) ) ; 
	%LOCAL TAB UUID BYVAR_SPACE BYVAR_COMMA ;
	%LET TAB = %scan( &DSNAME. , -1  , %str(.) ) ;
	%LET UUID = &SYSJOBID.&SYSINDEX. ;
	%LET BYVAR_COMMA = %KSUBSTR( %SUPERQ(BYVAR) , 2 , %KLENGTH( %SUPERQ(BYVAR) ) - 2 ) ;
	%LET BYVAR_SPACE = %SYSFUNC(TRANWRD( &BYVAR_COMMA. , %STR(,) ,%STR( ) ) ) ;

	proc sql ; 
	create table &TAB._&UUID. as 
		select &BYVAR_COMMA. , ifc( missing(&IDVAR.) , "MISSING" , &IDVAR. ) as &IDVAR.  , &AGGREGATE. as statistic
		from &DSNAME. 
		group by &BYVAR_COMMA. , &IDVAR.
	;
	quit ; 
	proc sort data=&TAB._&UUID. ; by &BYVAR_SPACE. ; run ;
	proc transpose data=&TAB._&UUID. out=&OUT.(drop=_name_)  
                              %IF %SYSEVALF(%SUPERQ(PREFIX) ^= ,BOOLEAN) %THEN PREFIX=&PREFIX. ; 
                              %IF %SYSEVALF(%SUPERQ(SUFFIX) ^= ,BOOLEAN) %THEN SUFFIX=&SUFFIX. ;
                ;
		by &BYVAR_SPACE. ;
		id &IDVAR. ;
		var statistic ;
	run ;
	proc sql ; 
		drop table &TAB._&UUID. ; 
	quit ;
%MEND; 
/*�d�һ���*/
	/*�d�Ҥ@:
                data test;
			index_group = "COMPLETENESS .." ; index_name="missingCnt "; index_value = 20;  phase = "STG" ; output;
			index_group = "UNIQUENESS" ; index_name="pkey"; index_value = 1;  phase = "STG" ; output;
			index_group = "UNIQUENESS" ; index_name="UK"; index_value = 3;  phase = "STG" ; output;
			index_group = "VALIDITY" ; index_name="prem "; index_value = 50;  phase = "STG" ; output;
			index_group = "COMPLETENESS .." ; index_name="missingCnt "; index_value = 120;  phase = "DDS" ; output;
			index_group = "UNIQUENESS" ; index_name="pkey"; index_value = 11;  phase = "DDS" ; output;
			index_group = "UNIQUENESS" ; index_name="UK"; index_value = 13;  phase = "DDS" ; output;
			index_group = "VALIDITY" ; index_name="prem "; index_value = 150;  phase = "DDS" ; output;
		run;
		%DQ_matricsBuilder( test , (index_group ) , phase ,out= tt ,PREFIX= phase_  , AGGREGATE=sum(index_value) ) 
	*/
	/*�d�ҤG:
                data test;
			index_group = "COMPLETENESS .." ; index_name="missingCnt "; index_value = 20;  phase = "STG" ; output;
			index_group = "UNIQUENESS" ; index_name="pkey"; index_value = 1;  phase = "STG" ; output;
			index_group = "UNIQUENESS" ; index_name="UK"; index_value = 3;  phase = "STG" ; output;
			index_group = "VALIDITY" ; index_name="prem "; index_value = 50;  phase = "STG" ; output;
			index_group = "COMPLETENESS .." ; index_name="missingCnt "; index_value = 120;  phase = "DDS" ; output;
			index_group = "UNIQUENESS" ; index_name="pkey"; index_value = 11;  phase = "DDS" ; output;
			index_group = "UNIQUENESS" ; index_name="UK"; index_value = 13;  phase = "DDS" ; output;
			index_group = "VALIDITY" ; index_name="prem "; index_value = 150;  phase = "DDS" ; output;
		run;
		%DQ_matricsBuilder( test , (index_group ) , phase ,out= tt ,PREFIX= phase_   ) 
	*/

