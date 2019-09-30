/*�����W��:readingSchema                                                                                */
/*�@        ��: Andy                                                                                                      */
/*�B�z���n: �N���wLib�����ɮ�����T�����wTABLE                     */
/*��    �J:  LIB , TBL( table name to output)                                                  */
/*��    �X:  TBL                                                                                              */
/*��    �L:                                                                                                         */
/*��    ��:                                                                                                                    */
%MACRO DOC_LIBContentor( lib_name , TBL=out ) ;
	%LOCAL libonly;
	%LET libonly = ;
	%IF %kindex(%superq(lib_name) , %str(.) )  = 0 %THEN %DO ;
		%LET libonly = YES ;
	%END ;

        proc contents data=%if %superq(libonly) = YES %then &lib_name.._ALL_  ; %else &lib_name. ; 
                       	out=tmp noprint ; run ;
        proc sql ;
                create table &TBL. as 
                        select	            LIBNAME        , 
                                                MEMNAME        ,
                                                NAME    ,
                                                VARNUM        ,
                                                CASE WHEN TYPE = 1 THEN "NUM" 
                                                            WHEN TYPE = 2 THEN "CHAR"
                                                ELSE "?" END AS TYPE ,
                                                LENGTH ,
                                                LABEL,
                                                 CASE WHEN  MISSING( FORMAT )  =0  THEN TRIM( LEFT( FORMAT ) ) || LEFT( PUT(FORMATL,20.) )
                                                          ELSE "" END AS FORMAT_COM,
                                                CASE WHEN  MISSING( INFORMAT )  =0 THEN  TRIM( LEFT( INFORMAT ) ) || LEFT( PUT(INFORML,20.) )
                                                          ELSE "" END AS INFORMAT_COM,
                                               CRDATE ,
                                               MODATE 
                        from tmp
                        order by MEMNAME, VARNUM ;
        quit;
        proc sql ;
                drop table tmp;
        quit;
%MEND;
/* �d�һ��� */
         /* �d�Ҥ@: �NSTAGE ���� Table ��T�C�X��� STAGE_schema  
		libname DDS "/SASDATA2/DDS_USR" ;
                 %DOC_LIBContentor( DDS , TBL=STAGE_schema ) 
                 %DOC_LIBContentor( STAGE , TBL=STAGE_schema2 ) 
        */
        /*�d�ҤG: �N��@����T�C�X
		libname stage "/SASDATA2/stage" ; 
                %DOC_LIBContentor( stage.life_insurance_claim ) 
        */
