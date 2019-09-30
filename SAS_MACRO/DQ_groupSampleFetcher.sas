/*�@        ��: Andy                                                                                                                  */
/*�B�z���n: �̷� SORT_KEYS �Ƨǫ� ���Ƨǫ�Ĥ@�� reduce to GROUP_KEYS                 */
/*��    �J: DSN:�B�z�e�ɮ�                                                                                   
               , GROUP_KEYS: reduce�᪺key��
               , SORT_KEYS: �w�q��ƱƧ�
               ,  OUT: reduce�᪺�ɮ�                                                                                   */
/*��    �X:  OUT.                                                                                                        */
/*��    �L:                                                                                 */
/*��    ��:                                                                                              */
%MACRO DQ_groupSampleFetcher( DSN , GROUP_KEYS , SORT_KEYS  ,OUT ) ;
        %LET GROUP_KEYS = %SYSFUNC( KCOMPRESS( &GROUP_KEYS.  , () ) ) ;
        %LET SORT_KEYS = %SYSFUNC( KCOMPRESS( &SORT_KEYS.  , () ) ) ;
 
        %LOCAL /* GROUP_KEY_noParentheses*/ SORT_KEYS_BY_SPACE  GROUP_KEYS_BY_SPACE ;
        %LET SORT_KEYS_BY_SPACE= %sysfunc(tranwrd(&GROUP_KEYS. , %str(,) , %str( ) ));
        %LET GROUP_KEYS_BY_SPACE = %sysfunc(tranwrd(&GROUP_KEYS. , %str(,) , %str( ) )) ;

    /*    %LET GROUP_KEY_noParentheses =  %SUBSTR( &GROUP_KEYS. ,2 ,%EVAL( %LENGTH( &GROUP_KEYS. ) -2 ) )  ; */
        %LOCAL UUID ; 
        %LET UUID = &SYSINDEX. ;

        proc sort  threads data=&DSN. out=reduceKey&UUID.  ; 
                by &SORT_KEYS_BY_SPACE. ; 
        run ;
        
        data &OUT. ;
                set reduceKey&UUID.(idxwhere=YES) ;
                by &GROUP_KEYS_BY_SPACE. ;
                if FIRST.%scan( &GROUP_KEYS_BY_SPACE. , 1 , %str( ) ) then output ;
        run;
        
        proc datasets lib=WORK memtype=dat nowarn nolist ;
                delete reduceKey&UUID. ;
        quit;

%MEND ;
/*�d�һ���*/
      /*�d�Ҥ@: �P�@��ID ���P�����������A�̷Ӥ�������Ƨǫ���Ĥ@��
        DATA ABC ;
		format tdate nldate10. ;
		ID = "A"  ; tdate = "01JAN2017"d ; SCORE = 1 ; SEQ = 1 ; OUTPUT ;
                ID = "A"  ; tdate = "03JAN2017"d ; SCORE = 1 ;SEQ = 2 ; OUTPUT ;
        RUN ;
	options mprint ; 
        %DQ_groupSampleFetcher( ABC , ID , (ID , DESCENDING tdate ) , ABC)
        */
