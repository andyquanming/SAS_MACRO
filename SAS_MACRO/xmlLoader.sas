/*�@        ��: Andy                                                                                                                         */
/*�B�z���n: �NXML��ƶפJLIB�A�ñNGLOBAL�ݩʸ�ƶפJMACRO�ܼ�                     */
/*��    �J:  LIBNAME: ���w����]�W��
                  xmlSrc: XML ������|                                                                                               */
/*��    �X:  LIB , MACRO VARIALBES   */
/*�̮֤ۨ�:                                                                                                                                 */
%MACRO xmlLoader( LIBNAME , xmlSrc ) ; 
	libname &LIBNAME. xml "%sysfunc(dequote( &xmlSrc. ))" ; 
	data _null_ ;
		set &LIBNAME..GLOBAL ;
		array char{*} _character_ ;
		array num{*} _numeric_ ;
		length vnames $200. ; 
		do i = 1 to dim(num) ;
			vnames = vname(num{i}) ;
			CALL EXECUTE( '%LET %UNQUOTE(' || vnames || ') = %UNQUOTE( ' || num{i} || ' ) ;' ) ;
		end ;
		do i = 1 to dim(char) ;
			vnames = vname(char{i}) ;
			CALL EXECUTE( '%LET %UNQUOTE(' || vnames || ') = %UNQUOTE( ' || KSTRIP(char{i})  || ' ) ;' ) ;
		end ;
	run ; 
%MEND ;
/*�d�һ���*/
	/*�d�Ҥ@: �N/SASDATA/USER/TGLEDW/test.xml �פJ EDW 
		test.xml ���e�p�U:
		<?xml version="1.0" encoding="UTF-8" ?>
		<root>
		  <GLOBAL>
			<name>test</name>
			<tt>test2</tt>
			<tt2>2</tt2>
			<tt3>2017/01/02</tt3>
			<tm_proc>%sysfunc(datetime())</tm_proc>
			<tm_valid>%SYSFUNC( INTNX( dtDay , %SYSFUNC( DATETIME()) , -1 , E ) )</tm_valid>
		  </GLOBAL>
		  <data>
		    <id>1</id>
		    <name>Andy</name>
		    <score>100</score>
		  </data>
		  <data>
		    <id>2</id>
		    <name>Bandy</name>
		    <score>90</score>
		  </data>
		  <data>
		    <id>3</id>
		    <name>Amy</name>
		    <score>10</score>
		  </data>
		</root>
		%xmlLoader( EDW , "/SASDATA/USER/TGLEDW/test.xml" ) 
	*/




