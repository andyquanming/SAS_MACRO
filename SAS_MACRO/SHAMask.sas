/*�@        ��: Andy                                                                                                                        */
/*�B�z���n: �]���ӤH��ƫO�@�k�HMD5 Function�B���ӷP�Ӹ�ïd�U�٭�LOG��                      */
/*��    �J: Table2Mask: �n�B���ӤH��ƪ����
                , Column2Mask :�n�B�����Ӹ����榡��pbuff ex: (col1 ,col2 , col3 ,.... )
                , LogTablePrefix: �B���d�s��Log DataSet�W�٫e��
                 , LogDSName: �YColumn2Mask �]�t����W�ٻ��B�~���wColumn2Mask�������^��W�� */
/*��    �X: SAS ��ƶ�: LogTablePrefix_LogDSName                                                                       */
/*�̮֤ۨ�: N/A                                                                                                                          */
%MACRO SHAMask( Table2Mask     /* �n�B���ӤH��ƪ���� */ , 
                                  Column2Mask  /* �n�B�����Ӹ���� */         , 
				  SHA=MD5 ,
				  SHAFormat="$hex32." ,
                                  LogTablePrefix=SHALog        /* �B���d�s��Log DataSet �W�٬� LogTablePrefix_Column2Mask  */ ,
                                  LogDSName= ) ;

        %LOCAL i  MaskCnt MaskPbuff UUID ;
        %LET UUID = &SYSJOBID._&SYSINDEX. ;
	%LET MaskPbuff = %QKSUBSTR( %SUPERQ( Column2Mask ) , 2 , %KLENGTH( &Column2Mask. )  -2  ) ;
	%LET MaskCnt = 0  ;
	%DO %WHILE (%QKSCAN( %SUPERQ( MaskPbuff ) , &MaskCnt. + 1  , %STR(,) ) ^= );
		%LET MaskCnt = %EVAL( &MaskCnt. + 1 ) ; 
		%LET Mask&MaskCnt. = %KSCAN( %SUPERQ( MaskPbuff ) , &MaskCnt. , %STR(,) ) ;
	%END;
	%LET SHAFormat = %SYSFUNC(DEQUOTE( &SHAFormat. ) ) ; 
        
        %LOCAL LogDSNameCnt ;
        %IF %sysevalf(%superq( LogDSName )=,boolean) %THEN %DO;
                %LET LogDSNameCnt = &MaskCnt. ;
                 %DO i = 1 %TO &LogDSNameCnt.;
                        %LOCAL LogDSName&i. ; 
                        %LET LogDSName&i. = &&Mask&i. ;
                        %END;
                %END;
        %ELSE %DO ;
                %LET LogColumnPbuff = %QSYSFUNC( KSTRIP( %QSUBSTR( &LogDSName. ,2 ,%EVAL( %LENGTH( &LogDSName. ) -2 ) ) ) );
                %LET LogDSNameCnt = %EVAL( %SYSFUNC( KLENGTH( &LogColumnPbuff. ) ) - %SYSFUNC( KLENGTH( %SYSFUNC( KCOMPRESS( &LogColumnPbuff. ,%str(,) ) ) ) ) + 1 )  ;
                %DO i = 1 %TO &LogDSNameCnt.;
                        %LOCAL LogDSName&i. ; 
                        %LET LogDSName&i. = %SYSFUNC(KSTRIP( %QSYSFUNC( KSCAN( &LogColumnPbuff. , &i. , %str(,) ) ) ) );
                        %END;
                %END;

        proc datasets lib=work nolist ;
                delete &SHA._&UUID. ;
                append base=&SHA._&UUID. data=&Table2Mask. ;
        run;

        %DO i = 1 %TO &MaskCnt. ;
                proc sql ;
                        create table %KCMPRES(&LogTablePrefix.)_%KCMPRES(%UNQUOTE(%NRSTR(&)LogDSName&i.))  as 
                                select    distinct 
                                                %UNQUOTE( %NRSTR(&)Mask&i.) ,
                                                putc( &SHA.( %UNQUOTE( %NRSTR(&)Mask&i.) ) , "&SHAFormat." )  as  %KCMPRES(%UNQUOTE(%NRSTR(&)LogDSName&i.))_hash 
                                from &SHA._&UUID. ;
                quit;
        %END;

        proc sql  ;
                create table &Table2Mask.  ( DROP= %DO i = 1 %TO &maskCnt. ;
                                                                        %KCMPRES(%UNQUOTE(%NRSTR(&)Mask&i.))_drop  %str( )
                                                                %END ;  ) AS 
                        select        %DO i = 1 %TO &maskCnt. ;
                                putc( &SHA.( %KCMPRES(%UNQUOTE(%NRSTR(&)Mask&i.))_drop ) , "&SHAFormat." ) as &&Mask&i. ,
                        %END;
                        %unquote( %str(*) ) 
                        from &SHA._&UUID. ( RENAME=( %DO i = 1 %TO &maskCnt. ;
                                                                                     %UNQUOTE( %NRSTR(&)Mask&i.) = %KCMPRES(%UNQUOTE(%NRSTR(&)Mask&i.))_drop %str( )
                                                                           %END ;
                                                                        ) 
                                                        )
                        ;
        quit ;

        proc datasets lib=WORK NOLIST ;
                delete &SHA._&UUID. ;
        run;

%MEND; 

/*�d�һ���*/
      /*�d�Ҥ@: �B���ӷP���
                DATA personalInfoAA ; 
                        ID = "A1"  ; NAME = "���j��" ;OUTPUT ; 
                RUN ; 
		options mprint ;
                %SHAMask( personalInfoAA    , 
                                  ( ID ,NAME)     , 
                                  LogTablePrefix=MD5Log        ) ;
        */ 
