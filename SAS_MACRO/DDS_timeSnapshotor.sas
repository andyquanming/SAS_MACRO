/*�����W��:DDS_timeSnapshotor                                                                                */
/*�@        ��: Andy                                                                                                      */
/*�B�z���n: ����DDS�ַ�                    						*/
/*��    �J:  DSName:DDS���W�� 
                  timePoint: ���w�ɶ��I
                  timeInterval: ���w�϶�
                  OUT: ���X���W��
                  INFORMAT: ��J�ɶ��榡
                  validFromDttm: �ɶ��W�O���W��
                  validToFromDttm: �ɶ��W�O���W��
                   */
/*��    �X:  ���                                                                                              */
%MACRO DDS_timeSnapshotor(  DSName , 
                                                    timePoint= , 
                                                    timeInterval= , 
                                                    OUT=%SYSFUNC(SCAN( &DSName. , -1 ,%str(.) ))_OUT , 
                                                    INFORMAT=nldatm19. , 
                                                    validFromDttm = valid_from_dttm , 
						    validToDttm = valid_to_dttm 
                                                 ) ;	
        %PUT _LOCAL_ ;
	%LET INFORMAT = %SYSFUNC(DEQUOTE( &INFORMAT. ) ) ;
	%LOCAL timePointVal timeStr timeEnd /*timeInterval*/ timeStr1 timeEnd1 /*timePoint*/;
	%IF %SYSEVALF( %SUPERQ( timePoint ) ^= ) %THEN  %DO ;
        	%LET timePointVal = %SYSFUNC(INPUTN( &timePoint. , &INFORMAT. ) ) ;
		%LET timeStr1 = &timePointVal. ;
		%LET timeEnd1 = &timePointVal. ;
	%END;
	%IF %SYSEVALF( %SUPERQ( timeInterval ) ^= ) %THEN %DO; 
		%LET timeInterval = %KSUBSTR( &timeInterval. , 2  , %KLENGTH( &timeInterval. ) - 2 ) ;		
		%LET timeStr = %SYSFUNC( SCAN( %SUPERQ(timeInterval) , 1 , %STR(,) ) ) ;
		%LET timeStr = %SYSFUNC(INPUTN( &timeStr. , &INFORMAT. ) ) ;
		%LET timeEnd = %SYSFUNC( SCAN( %SUPERQ(timeInterval) , 2 , %STR(,) ) ) ;
		%LET timeEnd = %SYSFUNC(INPUTN( &timeEnd. , &INFORMAT. ) ) ;
                %IF %SYSEVALF(%SUPERQ(timePoint) =) %THEN %DO ;
                	%LET timeStr1 = &timeStr. ;
			%LET timeEnd1 = &timeEnd. ;
                 %END;
	%END;
	%ELSE %DO ;
                %IF %SYSEVALF( %SUPERQ(timePointVal) = ) %THEN %DO ;
			%PUT ERROR: Both timePoint AND timeInterval are invalid ; 
			%ABORT CANCEL ; 
		%END;
		%ELSE %DO ;
			%LET timeStr = &timeStr1. ; 
			%LET timeEnd = &timeEnd1. ;
		%END;
	%END;
	DATA &OUT. ; 
		SET &DSName. ; 
                IF &validToDttm. >= &timeStr1. AND 
                    &validFromDttm. <= &timeEnd1. AND
                    &validFromDttm. <= &timeEnd. AND 
		    &validToDttm. >= &timeStr. THEN OUTPUT  ;
	RUN;
%MEND ;

/*�d�һ���:*/
        /*�d�Ҥ@: ��X��@�ɶ��I���ַ�
	DATA testtimeSnapshotor ;
               format valid_from_dttm nldatm19. ;
	       format valid_to_dttm nldatm19. ; 
               valid_from_dttm = "01JAN2018 00:00:00"dt ; valid_to_dttm = "03JAN2018 23:59:59"dt ; 
               pkey = "NO1" ; value = 1 ; output ; 
               valid_from_dttm = "04JAN2018 00:00:00"dt ; valid_to_dttm = "07JAN2018 23:59:59"dt ; 
               pkey = "NO2" ; value = 2 ; output ; 
               valid_from_dttm = "08JAN2018 00:00:00"dt ; valid_to_dttm = "12JAN2018 23:59:59"dt ; 
               pkey = "NO3" ; value = 3 ; output ; 
               valid_from_dttm = "13JAN2018 00:00:00"dt ; valid_to_dttm = "19JAN2018 23:59:59"dt ; 
               pkey = "NO4" ; value = 4 ; output ; 
               valid_from_dttm = "20JAN2018 00:00:00"dt ; valid_to_dttm = "01JAN5999 00:00:00"dt ; 
               pkey = "NO5" ; value = 5 ; output ; 
        RUN ; 
  
         %DDS_timeSnapshotor(testtimeSnapshotor , timePoint=2018/01/02 00:00:00 ,OUT=tmp ) 
         */
         /*�d�ҤG: ��X���w�ɶ��϶����ַ�
	DATA testtimeSnapshotor ;
               format valid_from_dttm nldatm19. ;
	       format valid_to_dttm nldatm19. ; 
               valid_from_dttm = "01JAN2018 00:00:00"dt ; valid_to_dttm = "03JAN2018 23:59:59"dt ; 
               pkey = "NO1" ; value = 1 ; output ; 
               valid_from_dttm = "04JAN2018 00:00:00"dt ; valid_to_dttm = "07JAN2018 23:59:59"dt ; 
               pkey = "NO2" ; value = 2 ; output ; 
               valid_from_dttm = "08JAN2018 00:00:00"dt ; valid_to_dttm = "12JAN2018 23:59:59"dt ; 
               pkey = "NO3" ; value = 3 ; output ; 
               valid_from_dttm = "13JAN2018 00:00:00"dt ; valid_to_dttm = "19JAN2018 23:59:59"dt ; 
               pkey = "NO4" ; value = 4 ; output ; 
               valid_from_dttm = "20JAN2018 00:00:00"dt ; valid_to_dttm = "01JAN5999 00:00:00"dt ; 
               pkey = "NO5" ; value = 5 ; output ; 
        RUN ; 
	 %DDS_timeSnapshotor(testtimeSnapshotor , timeInterval=( 2018/01/02 00:00:00 , 2018/01/09 00:00:00) ,OUT=tmp2 ) 
	*/
 
