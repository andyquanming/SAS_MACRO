/*�����W��:DDS_rollbacker                                                                                */
/*�@        ��: Andy                                                                                                      */
/*�B�z���n: ��_DDS�ܫ��w�ɶ��I                     						*/
/*��    �J:  DSName:DDS���W�� 
                  timePoint: ���w�ɶ��I
                  OUT: ���X���W��
                  INFORMAT: ��J�ɶ��榡
                  validFromDttm: �ɶ��W�O���W��
                  validToFromDttm: �ɶ��W�O���W��
		   maxDttm : �t�γ̤j�ɶ�
                   */
/*��    �X:  ���                                                                                              */
%MACRO DDS_rollbacker(  DSName , 
                                               timePoint , 
                                               OUT=%SYSFUNC(SCAN( &DSName. , -1 ,%str(.) ))_OUT , 
						INFORMAT=nldatm19. , 
                                                validFromDttm = valid_from_dttm , 
						validToDttm = valid_to_dttm ,
						maxDttm=%sysfunc(inputn(5999/01/01 00:00:00 , nldatm19. ) ) ;
                                                 ) ;	
        %PUT _LOCAL_ ;
	%LET INFORMAT = %SYSFUNC(DEQUOTE( &INFORMAT. ) ) ;
	%LOCAL timePointVal timeStr timeEnd /*timeInterval*/;
	%IF %SYSEVALF( %SUPERQ( timePoint ) ^= ) %THEN  %DO ;
        	%LET timePointVal = %SYSFUNC(INPUTN( &timePoint. , &INFORMAT. ) ) ;
		%LET timeStr = . ;
		%LET timeEnd = &timePointVal. ;
	%END;
	%ELSE %DO ;
		%PUT ERROR: timePoint is invalid ; 
		%ABORT CANCEL ;
	%END; 
	DATA &OUT. ; 
		SET &DSName. ; 
                IF &validFromDttm. <= &timeEnd. AND 
		    &validToDttm. >= &timeStr. THEN DO;
			IF &validToDttm. >= &timeEnd. THEN DO;
				&validToDttm. = &maxDttm. ;
			END;
			OUTPUT  ;
		END;
	RUN;
%MEND ;	  
/*�d�һ���: */
	/*�d�Ҥ@:  
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
	options mprint ;
	%DDS_rollbacker(testtimeSnapshotor , 2018/01/10 00:00:00 ) 
	*/

