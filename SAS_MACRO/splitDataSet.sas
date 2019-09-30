/*�����W��: splitDataSet                                                                                           */
/*�@        ��: Andy                                                                                                      */
/*�B�z���n:  �N�@�� sasdataset ���Φ����w�Ӽ� sasdataset 	                              */
/*��    �J:   DS: dataset name 
		   DScnt: ���Φ���
                    pbuff(&syspbuff.) ,VAR=V ,CNT=Vcnt                                                   */
/*��    �X:   &VAR.  ,&CNT.                                                                                   */
/*��    �L:   del_gbl_arr /coount_var                                                                       */
/*��    ��:                                                                                                                    */
%MACRO splitDataSet(DS ,DScnt=2 ,OUT=splitDataSet );

        data %DO i = 1 %TO &DScnt.;
                &OUT.&i.
                %END;
                ;
                retain x;
                set &DS. nobs=nobs;

                if _n_ eq 1 then
                        do;
                                if mod(nobs,&DScnt.) eq 0 then
                                        x=int(nobs/&DScnt.);
                                else x=int(nobs/&DScnt.)+1;
                        end;

                if _n_ le x then
                        output &OUT.1;

                %DO i = 2 %TO &DScnt.;
                else if _n_ le (&i.*x) then
                        output &OUT.&i.;
                %END;
		drop x ;
        run;

%MEND ;


/* �d�һ���*/
        /*�d�Ҥ@: �N aaa �10���� 
        data aaa;
                 do i = 1 to 82; output; end;
        run; 
        %splitDataSet( aaa ,DScnt = 3 ,OUT = test ) 
         */

