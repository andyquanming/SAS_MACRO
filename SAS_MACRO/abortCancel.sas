/*�@        ��: Andy                                                                                                                         */
/*�B�z���n: ��o�Ϳ��~ �O��LOG �ä��_�{��                                                    */
/*��    �J: log: ���wLOG���e �w�]: error occur   */
/*��    �X:  N/A  */
/*�̮֤ۨ�: %sasMail                                                                                                                                 */
%MACRO abortCancel( log=error occur  /*�n��ܪ��T��,�w�]�� error occur */ , 
                                       from = "pearlmale@gmail.com" , 
                                       email=( "pearlmale@gmail.com" ) );
        %IF &syserr. gt 6 %THEN %DO;
		%LET log = %QSYSFUNC(dequote( &log. ) ) ;
                %PUT ERROR:  Error_Flag %SYSFUNC(dequote( &log. ) ) ;
		%sasMail( &from., TO= &email. , BODY = ( "&log.") )
                %ABORT cancel ;
        %END ;
%MEND;

/*�d�һ���*/
      /*�d�Ҥ@: 
		OPTIONS MPRINT ; 
                DATA TEST ; 
                        123a = "A1"  ; NAME = "���j��" ;OUTPUT ; 
                run ; %abortCancel( log="error occur" , from = "andywang@transglobe.com.tw" , email =( "andywang@transglobe.com.tw" ) ) ; 
        */ 
