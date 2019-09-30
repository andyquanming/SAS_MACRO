/*�����W��:FuzzyMatcher                                                                                */
/*�@        ��: Andy                                                                                            */
/*�B�z���n: ���w����r������n�j�M����쵹�X�ۦ��פ���                  */
/*��    �J:  keywords : (keyWord1 ,keyWord2 ,keyWord3 , ..., keyWordn)
                 DS: ��Ʀr��
		 VAR:�������
                 disVarName: �ϥήɫ��w�ۦ��פ��ƪ����W��                        
                 DisMethod:  �ϥήɫ��w�p���k  COMPGED SPEDIS COMPLEV COMPARE
                 OUT: ���X��ƶ�
                  CNT: ���ƭ��� */
/*��    �X:  OUT: ���X��ƶ�                                                                                              */
%MACRO DOC_FuzzyMatcher( keywords /*�h������r�A�r�����j*/, 
                                       DS /*��Ʀr��*/ , 
                                       VAR /*����r�������*/  ,
                                       disVarName=probability /*�ۦ������W��*/  ,
                                       DisMethod = COMPGED /*�p���k  COMPGED SPEDIS COMPLEV COMPARE */ , 
                                       OUT=   /*���X��ƶ�*/ ,
                                       CNT=  ) ;
	%LOCAL UUID keywordsCnt i ;
	%LET UUID = &SYSJOBID._&SYSINDEX. ; /*execute_id*/
	/*�p��}�C����*/ 
	%LET keywordsCnt = 0 ;
	/*�h�Y�h��*/
	%LET keywords = %KSUBSTR( %SUPERQ(keywords) , 2 , %KLENGTH( %SUPERQ( keywords) ) - 2  ) ;
	%DO %WHILE ( %QKSCAN( %SUPERQ( keywords ) , &keywordsCnt. + 1 , %STR(,) ) ^= );
		%LET keywordsCnt = %EVAL( &keywordsCnt. + 1 ) ;
		%LOCAL m_&UUID._&keywordsCnt. ;
		%LET m_&UUID._&keywordsCnt. = %KSCAN( %SUPERQ( keywords ) , &keywordsCnt. , %STR(,) ) ;
	%END ;
	%PUT _LOCAL_ ; 
	%IF %SYSEVALF(%SUPERQ(OUT) = ) %THEN %DO ; 
		%LET OUT = O_&UUID. ;
	%END;
	data T_&UUID.  (drop= c_&UUID.:  i);
		set &DS. ; 
		c_&UUID. = kcompress(  &VAR. , " _,|" ) ;
		&disVarName. = 0 ; 
		c_&UUID._lenSum = 0 ;
		%DO i = 1 %TO &keywordsCnt. ; 
			c_&UUID._len = %KLENGTH( &&m_&UUID._&i. ) ; /*����r����*/
			c_&UUID._lenSum = c_&UUID._lenSum + c_&UUID._len ; /* ����r�����`�M*/
			c_&UUID._dis = &DisMethod.( "%sysfunc(kcompress( &&m_&UUID._&i.  , %str(_,|) ) )" , c_&UUID.)  ;
			&disVarName. = &disVarName. + 1/( c_&UUID._dis + 1)  ;
		%END;
		&disVarName. = &disVarName. / &keywordsCnt.   ;
	run ; 
	proc sql  %IF %SYSEVALF(%SUPERQ(CNT) ^= ) %THEN outobs = &CNT.; ;
		create table &OUT. as 
			select * 
			from T_&UUID.
			order by &disVarName. desc 
			;
		drop table T_&UUID. ;
	quit; 
	
%MEND; 
/*�d�һ���*/
	/*�d�Ҥ@:
	data abc ; 
		format desc xx yy ;  
		length desc $100 ;
		desc = "policy_no" ; xx = "no1" ; yy = 1 ;  output ;
		desc = "po_no" ; xx = "no2" ; yy = 2 ;  output ;
		desc = "no_no" ; xx = "no3" ; yy = 3 ;  output ;
		desc = "acct_no" ; xx = "no4" ; yy = 4 ;  output ;
		desc = "policy_chg_no" ; xx = "no5" ; yy = 5 ;  output ;
	run ; 
	%DOC_FuzzyMatcher( (  policy , no ,po  ) , abc , desc ) ;
*/
/*�d�ҤG:
	libname edwstg "/SASDATA/USER/TGLEDW/LIB/STG" ;
	%DOC_FuzzyMatcher( (  policy , id  ) , edwstg.ebao_data_dictionary_field , COLUMN_NAME) ;
*/
