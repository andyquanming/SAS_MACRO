/*�@        ��: Andy                                                                                                                         */
/*�B�z���n: �M�פ��s�@�A�̷�����r�^��Source Code���                                                     */
/*��    �J: fileRef: Source Code���|                                                                                    
                , keyword: ���� sas prxparese �W������r
                , VARNAME: �s�񵲪G���ܼ�                                                                        
                , OUTDS : �s�񵲪G��SASDATASET �w�]: _NULL_                                                              */
/*��    �X:  VARNAME , 
                 , OUTDS : �s�񵲪G��SASDATASET �w�]: _NULL_                                                       */
/*�̮֤ۨ�: N/A         */

%MACRO DOC_srcCodeReader( fileRef /*source code path */ , 
                                     	keyword /*����r*/, 
                                        VARNAME /*�^�Ǧs���ܼơA���ήɥ�SUPERQ*/ ,
                                        OUTDS = _NULL_ /*�^�Ǧs����*/  ) ; 

        %LET fileRef = %QSYSFUNC( DEQUOTE( &fileRef. ) ) ; 
        %LET keyword = %QSYSFUNC( DEQUOTE( &keyword. ) ) ; 
        %LET VARNAME = %SYSFUNC( DEQUOTE( &VARNAME. ) ) ;
        %LET OUTDS = %SYSFUNC( DEQUOTE( &OUTDS. ) ) ;
   
        DATA &OUTDS. ( KEEP=Comments);
              /* Use PRXPARSE to compile the Perl regular expression.    */
             INFILE "&fileRef." DLM='01'x DSD TRUNCOVER LRECL=1000   ;
             LENGTH line $1000. ;
             INPUT line $ ; 
             LENGTH Comments $1000 ;
             RETAIN strPattern endPattern Comments strFlg ;
             IF _N_  = 1 THEN DO ; 
                        strPattern = prxparse("/\/\*.*&keyword./");
                        endPattern = prxparse("/.*\*\//");
                        strFlg = "0" ;
                        Comments = "" ;
             END ;
             positionStr=prxmatch(strPattern, line);
             IF positionStr > 0 THEN DO ; 
                        strFlg = "1" ;
             END;
             IF strFlg = "1" THEN DO ; 
                        Comments = KSTRIP(Comments) || KSTRIP( line ) ;
             END;
             positionEnd=prxmatch(endPattern, line);

             IF strFlg = "1" AND positionEnd > 0 THEN DO ; 
                        CALL SYMPUTX( RESOLVE( "&VARNAME.") , Comments ,"G" ) ;
                        OUTPUT ;
                        STOP;
             END;
             
        RUN;
        %LET &VARNAME. = %SUPERQ( &VARNAME. ) ;
%MEND ;
