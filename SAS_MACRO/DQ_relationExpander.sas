/*�@        ��: Andy                                                                                               */
/*�B�z���n: ��z���V�����p                                                                          */
/*��    �J:  ���W�١A���`�I�A�l�`�I�A���X��ƦW��(optional)         		*/
/*��    �X:                                                                                                            */
/*��    �L: �YDataSet(TBL) �p�U
                  NODE       LEAF
	          ------------------------------
                  a                b 
		  a                 c
                  b                 c
                  c                 d 
                ���wa �i�H��X a ���l�]�A��z�����p(OUT)
		NODE        LEAF        LEVEL
		-----------------------------------------
		ROOT         a               0
		a                  b               1
		a                  c               1
		a                  d               2		
			            */
/*��    ��:                                                                                                             */
%MACRO DQ_relationExpander( TBL /* mapping relation including node (1) to leaf (many) */ , 
						NODE , 
						LEAF ,
						NODE_VAL ,
						OUT=TREE /*output dataset with link level */ ,
						MAX=20  /* maximum iteration */ );
        %LET TBL =  %SYSFUNC( dequote( &TBL. ) ) ;
        %LET NODE =  %SYSFUNC( dequote( &NODE. ) ) ;
        %LET LEAF =  %SYSFUNC( dequote( &LEAF. ) ) ;
        %LET NODE_VAL = %QSYSFUNC( dequote( &NODE_VAL. ) ) ; /*��w�����u��֡A�S���w�N�O����*/ 

	%IF %SYSEVALF(%SUPERQ(NODE_VAL)=,boolean) %THEN %DO ;
		%PUT ERROR:INPUT NODE_VAL INVALID ;
		%ABORT CANCEL ;
	%END;
        %LOCAL level nlevel ii UUID;
	%LET UUID = &SYSJOBID._&SYSINDEX.  ;  /* session_id + execute macro count */
        %LET   level = 1;

        PROC SQL;
		/*�d�U���ı��Х]�t���`�I�P���`�I�����*/
                CREATE TABLE  S&UUID. AS 
                        SELECT                *
                        FROM                 &TBL. 
                        WHERE                 &NODE.         NE &LEAF. 
                        AND                 MISSING(&NODE.) = 0 
                        AND                 MISSING(&LEAF.) = 0 
                        ; 
	QUIT ;%IF &SYSERR. > 6 %THEN %ABORT CANCEL ; 
	PROC SQL ;
		/* �Ĥ@�h���p*/
                CREATE table L&UUID._1 AS
                        SELECT * ,1 as level
                        FROM S&UUID.
                        WHERE 
                                %IF "&NODE_VAL." NE "" %THEN &NODE. = "&NODE_VAL."  ; 
                        ;  
	QUIT ; %IF &SYSERR. > 6 %THEN %ABORT CANCEL ; 
	/* append root node */
	DATA L&UUID._0 ;
		IF 0 THEN SET L&UUID._1 ;
		&NODE. = "ROOT"  ;
		&LEAF. = "&NODE_VAL." ;
		LEVEL = 0 ;
	RUN ;	%IF &SYSERR. > 6 %THEN %ABORT CANCEL ; 

        %DO %WHILE(&SQLOBS > 0);
		/* use node to find leaf as node and go on finding leaf */
		/* append nodes in levels */
		DATA S0&UUID. ; 
			SET %DO ii = 1 %TO &level.;
				 L&UUID._&ii.  
				%END ; ;
		RUN ;
		PROC SQL ; 
		/* �j�鰱�����O�d�L��ƩάO���ƹF�W��MAX */
	                %LET nlevel = %EVAL(&level + 1);
	                CREATE TABLE L&UUID._&nlevel. AS
	                        SELECT A.* , &nlevel. as level
	                        FROM S&UUID.  A INNER JOIN ( SELECT DISTINCT &LEAF. FROM L&UUID._&level. ) B
	                                ON ( A.&NODE. = B.&LEAF. ) 
				WHERE A.&LEAF. NOT IN (SELECT &NODE. FROM S0&UUID. );
	                %LET level = &nlevel;
	                %if  &nlevel. GT &MAX. %THEN %do ;
	                        %put ERROR: LOOP TOO MUCH ,CHK DEPENDENCY ; 
	                        %goto LEAVE_LOOP ;
	                %end ;
		QUIT ; %IF &SYSERR. > 6 %THEN %ABORT CANCEL ; 
        %END; 
%LEAVE_LOOP:

	/* ����*/
	DATA &OUT. ; 
		SET L&UUID._: ;
	RUN ; %IF &SYSERR. > 6 %THEN %ABORT CANCEL ; 
	
	/*�MTEMP��*/
	PROC DATASETS LIB=WORK NOLIST NOWARN ;
		DELETE L&UUID._: S&UUID.  S0&UUID. ;
	QUIT;%IF &SYSERR. > 6 %THEN %ABORT CANCEL ; 

%MEND;
/* �d�һ���*/
	/*�d��1: 
		data relation ; 
			father= "a1" ; son = "b1"  ; output ; 
		 	father= "b1" ; son = "c1"  ; output ;
			father= "c1" ; son = "d1"  ; output ;
			father= "b1" ; son = "e1"  ; output ;
			father= "e1" ; son = "f1"  ; output ;
			father= "f1" ; son = "g1"  ; output ;
			father= "f1" ; son = "h1"  ; output ;
			father= "g1" ; son = "c1"  ; output ;
			father= "h1" ; son = "d1"  ; output ;
		run ;
		%DQ_relationExpander( relation , 	father , son , "b1" ) 	
	*/
