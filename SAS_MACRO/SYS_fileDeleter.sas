/*�����W��:SYS_fileDeleter                                                                                */
/*�@        ��: Andy                                                                                                      */
/*�B�z���n: �R�����w�ɮ�                    						*/
/*��    �J:  filename                                                					  */
/*��    �X:                                                                                                */
%MACRO SYS_fileDeleter( filename ) ; 
	%LET filename = %sysfunc( dequote( &filename. ) ) ; 
	%local rc ; 
	%LET rc = %sysfunc(filename (fref , "&filename." ) ) ;
	%LET rc = %sysfunc( fdelete( &fref. ) ) ;
%MEND ; 
/*�d�һ���:*/
	/*�d��1: 
		%SYS_fileDeleter( "/tmp/test/a.txt" ) 
	*/
