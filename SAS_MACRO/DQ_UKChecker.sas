/*�����W��: DQ_UKChecker                                                                                            */
/*�@        ��: Andy                                                                                                      */
/*�B�z���n: ����TBL p_key �O�_ unique                                                               */
/*��    �J:  TBL: ���Ҫ�� , 
           keyArr: (key1 , key2 , ... , keyn )  , 
                   WHERE_CONDITION : condition1 and condition2 and ...  ,
                   maxOut: �̤j��X����                                    */
/*��    �X:   errOut                                                                                */
/*��    �L:                                                                                                                    */
%MACRO DQ_UKChecker( TBL , 
				                    keyArr , 
				                    whereClus=  , 
				                    errOut=%kscan( &tbl. , -1 , str(.) )_uniErr , 
				                    maxOut=10 ) ;
    %IF %SUPERQ(whereClus) ^= %THEN %LET whereClus = %SYSFUNC( dequote( &whereClus. ) ) ; 
    %LET keyArr = %ksubstr( %SUPERQ(keyArr) , 2 , %klength(&keyArr.) -2 ) ;
        proc sql %IF %UPCASE(%SUPERQ(maxOut)) ^= MAX %THEN OUTOBS=&maxOut. ; ;
        create table &errOut. as
                    select &keyArr. , *
                    from &TBL. 
                    %IF %SUPERQ(whereClus) ^= %THEN where &whereClus. ;
                    group by &keyArr. 
                    having count(*) > 1 
                    ;
        quit;
%MEND ;
/* �d�һ���*/
        /* �d�Ҥ@: check ok case
        data abc ;
            xx = 1 ; yy = "ab" ; zz = 5 ; output ;
            xx = 1 ; yy = "ac" ; zz = 5 ; output ;
            xx = 1 ; yy = "ad" ; zz = 5 ; output ;
        run ; 
        options mprint ; 
        %DQ_UKChecker( work.abc ,  ( xx , yy ) ) 

        */
     /* �d�ҤG: check not ok case
        data abc ;
            xx = 1 ; yy = "ab" ; zz = 5 ; output ;
            xx = 1 ; yy = "ac" ; zz = 5 ; output ;
            xx = 1 ; yy = "ad" ; zz = 5 ; output ;
        run ; 
        options mprint ; 
        %DQ_UKChecker( work.abc ,  ( xx  ) ) 
        */
