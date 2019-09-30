/*�����W��: DQ_FKChecker                                                                            */
/*�@        ��: Andy                                                                                                     */
/*�B�z���n: ����DS �O�_����ForeignKey Constraint                                               */
/*��    �J:  DS: �n����FK�����
		   fkArr: ( fk1 , fk2 , fk3 , ... ) 
		   ConsDS: Constraint Table
		   ConsArr: Constraint Fk's
		   OUT: ���~���W��
		   MissExcludeInd: �O�_�ư���missing��record default 0 
                   maxOut: �̤j��X����                                    */
/*��    �X:   errOUT                                                                                */
/*��    �L:                                                                                                                    */
%MACRO DQ_FKChecker( DS , fkArr , ConsDS , ConsArr , errOUT= %kscan( &DS. , -1 , str(.) )_fkErr , maxOut=10 , MissExcludeInd = 0 ) ; 
	%LOCAL fkArrCnt  ConsArrCnt joinCondition i cmissCondition ; 
	%LET fkArr = %QKSUBSTR( %SUPERQ( fkArr ) , 2 , %KLENGTH( &fkArr. )  -2  ) ;
	%LET ConsArr = %QKSUBSTR( %SUPERQ( ConsArr ) , 2 , %KLENGTH( &ConsArr. )  -2  ) ;
	%LET fkArrCnt = 0 ;
	%LET ConsArrCnt = 0 ;
	%DO %WHILE ( %QKSCAN( %SUPERQ( fkArr ) , &fkArrCnt. + 1 , %STR(,) ) ^= ) ;
		%LET fkArrCnt = %EVAL( &fkArrCnt. + 1 ) ;
	%END;
	%DO %WHILE ( %QKSCAN( %SUPERQ( ConsArr ) , &ConsArrCnt. + 1 , %STR(,) ) ^= ) ;
		%LET ConsArrCnt = %EVAL( &ConsArrCnt. + 1 ) ;
	%END;
	%IF &fkArrCnt. ^= &ConsArrCnt. %THEN %DO ; 
		%PUT _local_ ; 
		%PUT ERROR: fkArr size should equal to ConsArr size ; 
	%END;
	%DO i = 1 %TO &fkArrCnt. ; 
		%IF &i. = 1 %THEN %DO ;
			%LET joinCondition = A.%KSCAN( %SUPERQ( fkArr ) , &i. , %STR(,) ) = B.%KSCAN( %SUPERQ( ConsArr ) , &i. , %STR(,) )  ;
			%LET cmissCondition = A.%KSCAN( %SUPERQ( fkArr ) , &i. , %STR(,) )  ;
		%END;
		%ELSE %DO ;
			%LET joinCondition = &joinCondition. AND A.%KSCAN( %SUPERQ( fkArr ) , &i. , %STR(,) ) = B.%KSCAN( %SUPERQ( ConsArr ) , &i. , %STR(,) ) ;
			%LET cmissCondition = &cmissCondition. , A.%KSCAN( %SUPERQ( fkArr ) , &i. , %STR(,) )  ;
		%END;
	%END ;

	PROC SQL MAGIC = 103 REMERGE %if %UPCASE(%SUPERQ(maxOut) ) ^= MAX %THEN OUTOBS= &maxOut. ; ; 
		create table &errOUT. as 
			select A.*
			from &DS. AS A left join &ConsDS. AS B
			on ( &joinCondition. ) 
			where B.%KSCAN( %SUPERQ( ConsArr ) , 1 , %STR(,) )  is null
			%IF MissExcludeInd ^= 0 %THEN AND cmiss( &cmissCondition. ) = 0 ;
			;
%MEND; 
/*�d�һ���*/
	/*�d�Ҥ@: 
		data abc  ;
			xx = 1 ; yy = "A" ; output ; 
			xx = 2 ; yy = "b" ; output ; 
			xx = 3 ; yy = "b" ; output ; 
		run ; 

		data def  ;
			xx = 2 ; yy = "b" ; output ; 
			xx = 3 ; yy = "b" ; output ; 
		run ; 

		%DQ_FKChecker( abc , ( xx ) , def , (xx ) ) 
	*/
