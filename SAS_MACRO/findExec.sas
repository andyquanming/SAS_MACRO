/*�@        ��: Andy                                                                                                                         */
/*�B�z���n: ���j�M���ɮרð�����᪺���|�@���Ѽư��� command                                                      */
/*��    �J: dir: �ݳB�z�ɮ׸��|                                                                                    
                , ext: ���w���ɦW
                , cmd_prefix: ���O�e��
                , cmd_suffix : ���O���                                                              
		, dirDlm: ���|���j�r��     */
/*��    �X:  �L  */
/*�̮֤ۨ�: N/A         */
/* �Ƶ�: �Ѧ� http://support.sas.com/kb/45/805.html �[�H�קאּ���u�ʪ�����*/ 
%MACRO findExec( dir, ext=sas , cmd_prefix='%include "' , cmd_suffix = '"; '  , dirDlm = "/");                                                                                                                
	%LOCAL filrf rc did memcnt name i; 
	%LET dir = %QSYSFUNC(dequote( &dir. ) ) ; 
	%LET ext = %QSYSFUNC(dequote( &ext. ) ) ;
	%LET cmd_prefix = %QSYSFUNC(dequote( &cmd_prefix. ) ) ;
	%LET cmd_suffix = %QSYSFUNC(dequote( &cmd_suffix. ) ) ;
	%LET dirDlm = %QSYSFUNC(DEQUOTE( &dirDlm. ) ) ;
                                                                                                              
	/* Assigns a fileref to the directory and opens the directory */                                                           
	%LET rc=%SYSFUNC(filename(filrf,&dir.));                                                                                               
	%LET did=%SYSFUNC(dopen(&filrf.));                                                                                                     
	                                                                                                                        
	/* Make sure directory can be open */                                                                                                 
	%IF &did eq 0 %THEN %DO;                                                                                                              
		%PUT ERROR: Directory &dir cannot be open or does not exist ;
		%RETURN;                                                                                                                             
	%END;                                                                                                                                 
	                                                                                                                                
	/* Loops through entire directory */                                                                                                 
	%DO i = 1 %TO %SYSFUNC(dnum(&did.));                                                                                                                                                                                                                                
		/* Retrieve name of each file */                                                                                                   
		%LET name=%QSYSFUNC(dread(&did.,&i.)) ; 
		%put &=name. ;
		%if "&name." = "findExec.sas" %then %goto continue ;
		/* Checks to see if the extension matches the parameter value */                                                                   
		/* If condition is true print the full name to the log        */                                                                   
		%IF %QUPCASE(%QSCAN(&name.,-1,.)) = %UPCASE(&ext.) %THEN 
			%DO;   
				%put &cmd_prefix.&dir.&dirDlm.&name.&cmd_suffix.  ;                                                                    
				%UNQUOTE( &cmd_prefix. )&dir.&dirDlm.&name.%UNQUOTE( &cmd_suffix. )                                                                                                    
			%END;                                                                                                                         
		/* If directory name call macro again */                                                                                           
		%ELSE %IF %QSCAN(&name.,2,.) = %THEN 
			%DO;                                                                                          
				%findExec(&dir.&dirDlm.%UNQUOTE(&name.),&ext.) ;                                                                                              
			%END;      
        %continue:                                                                                        
	%END;                                                                                                                                
	                                                                                                                                
	/* Closes the directory and clear the fileref */                                                                                      
	%LET rc=%SYSFUNC(dclose(&did));                                                                                                       
	%LET rc=%SYSFUNC(filename(filrf));                                                                                                                            
%mend; 
/*�d�һ���:*/
	/*�d��1: �sĶ���w�ؿ��U�{��
		%findExec( "&RootPath./COD/MCR" , ext=sas , cmd_prefix=' %include "' ,cmd_suffix = '";'  )
	*/

	/*�d��2: �R���ɮ�
		%MACRO deleteFile( filename ) ; 
			%LET filename = %sysfunc( dequote( &filename. ) ) ; 
			%local rc ; 
			%LET rc = %sysfunc(filename (fref , "&filename." ) ) ;
			%LET rc = %sysfunc( fdelete( &fref. ) ) ;
		%MEND ; 
		%findExec( "/tmp/test" , ext=txt , cmd_prefix=' %deleteFile( ' ,cmd_suffix = ' ) ; '  )
	*/
