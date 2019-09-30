/*�@        ��: Andy                                                                                                                         */
/*�B�z���n: �t�αH�o�q���H                                                          					     */
/*��    �J: FROM: �H���                                                                                   
                , TO: �����( email1 , email2 , ... , emailn )
                , CC: �����( email1 , email2 , ... , emailn )
                , BCC: �����( email1 , email2 , ... , emailn )                                                      
                , SUBJECT: �H��D��
		, ATTACH: ���[�ɮ�( "file1" , "fil2" , ... , "filen" ) 
		, BODY: ����( "line1" , "line2" , ... , "linen" ) */
/*��    �X:  N/A                                                                                                                                  */
/*�̮֤ۨ�: N/A                                                                                                                           */
%MACRO SYS_mailSender( FROM , 
				  TO=( ) , 
				  CC=( ) , 
				  BCC=( ) , 
			          SUBJECT="System Mail message" , 
				  ATTACH=( ) ,
				  BODY=("sas system mail" , "thanks") ) ;
	%LET FROM = %QSYSFUNC(DEQUOTE( &FROM.) ) ; 
	%LET SUBJECT = %QSYSFUNC(DEQUOTE( &SUBJECT. ) ) ;
	%LET TO = %QKSUBSTR( %SUPERQ(TO) , 2 , %KLENGTH( &TO. ) - 2 ) ;
	%LET CC = %QKSUBSTR( %SUPERQ(CC) , 2 , %KLENGTH( &CC. ) - 2 ) ;
	%LET BCC = %QKSUBSTR( %SUPERQ(BCC) , 2 , %KLENGTH( &BCC. ) - 2 ) ;
	%LET ATTACH = %QKSUBSTR( %SUPERQ(ATTACH) , 2 , %KLENGTH( &ATTACH. ) - 2 ) ;
	%LET BODY = %QKSUBSTR( %SUPERQ(BODY) , 2 , %KLENGTH( &BODY. ) - 2 ) ;
	
	%IF %EVAL( %SUPERQ( TO )= ) %THEN %DO ;
		%PUT ERROR: RECIEPT PARAMETER "TO" IS  INVALID ;
		%RETURN ;
		%END;

	filename Mailbox email;  
	data _null_;   
		file Mailbox  ; 
		put "!EM_FROM! &FROM. ";
		%IF %EVAL( %SUPERQ(TO)= ) %THEN;
		%ELSE %DO ;
			%LET TO = %SYSFUNC( translate( &TO. , %str(%')%str( ) , %str(%")%str(,) ) ) ;
			put "!EM_TO! ( &TO. )" ;
		%END ;
		%IF %EVAL( %SUPERQ(CC)= ) %THEN;
		%ELSE %DO ;
			%LET CC = %SYSFUNC( translate( &CC. , %str(%')%str( ) , %str(%")%str(,) ) ) ;
			put "!EM_CC! ( &CC.  )"   ;
		%END ;

		%IF %EVAL( %SUPERQ(BCC)= ) %THEN;
		%ELSE %DO ;
			%LET BCC = %SYSFUNC( translate( &BCC. , %str(%')%str( ) , %str(%")%str(,) ) ) ;
			put "!EM_BCC! ( &BCC.  )"   ;
		%END ;

		put "!EM_SUBJECT! &SUBJECT." ;
		%IF %EVAL( %SUPERQ(ATTACH)= ) %THEN;
		%ELSE %DO ;
			%LET ATTACH = %SYSFUNC( translate( &ATTACH. , %str(%')%str( ) , %str(%")%str(,) ) ) ; 
			put "!EM_ATTACH! ( &ATTACH. ) " ;
		%END;

		%IF %EVAL( %SUPERQ(BODY)= ) %THEN;
		%ELSE %DO ;
			%LET BODY = %QSYSFUNC( tranwrd( &BODY. , %STR(,) , %STR(; PUT)) );
			put %UNQUOTE(&BODY.) %str(;) ;
		%END;
	run ;

%MEND;
/*�d�һ���*/
      /*�d�Ҥ@:
	options mprint ; 
	%SYS_mailSender( "andywang@transglobe.com.tw" , 
			TO=( "andywang@transglobe.com.tw" ) ,
			BODY=( "Hello" , "world")  )
*/
