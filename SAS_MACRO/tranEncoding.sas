/*�@        ��: Andy                                                                                                                         */
/*�B�z���n: DataSet �j��s�X�ഫ�A�קKSAS DATASET �]�s�X���D�y���L�k�}��                     */
/*��    �J: in:�n�ഫ�����                                                                                   
                , out: �ഫ�᪺���
                , from: ��s�X,�w�]big5
                , to: �ഫ��s�X,�w�]big5                                                        
                , sub:  
                , file_opt:                                                                                                                     */
/*��    �X:  N/A                                                                                                                                    */
/*�̮֤ۨ�: N/A                                                                                                                    */
%MACRO tranEncoding( in /*�n�ഫ�����*/  ,
                                    out /*�ഫ�᪺���*/  ,
                                    from=big5 /*��s�X,�w�]big5*/ ,
                                    to=big5 /*�ഫ��s�X,�w�]big5*/ ,sub='?',file_opt=);
        data &out(encoding=asciiany);
                set &in;
                array cc (*) _character_;

                do _n_=1 to dim(cc);
                        cc(_n_)=kpropdata(cc(_n_),&sub,"&from","&to");
                end;
        run;
        %LET lib=%SCAN(&out,1,%STR(.));
        %LET mem=%SCAN(&out,2,%STR(.));
        %IF %LENGTH(&mem) =0 %THEN
                %DO;
                        %LET mem=&lib;
                        %LET lib=work;
                %END;
        proc datasets lib=&lib nolist;
                modify &mem /correctencoding="&to";
        run;
        quit;
%MEND;
