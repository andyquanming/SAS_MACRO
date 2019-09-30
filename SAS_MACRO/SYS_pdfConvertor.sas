/*�@        ��: Andy                                                                                                                         */
/*�B�z���n: �N SASDataSet �নPDF                                                                                          */
/*��    �J: SasDataSet:�n�C�L���ɮ�                                                                                   
                , OutPDF: �n���X�����|�ɦW
                ,Title: ������D
                , FootNote: ������}                                                        
                , Style: �n�M�Ϊ��榡�i�ۦ�g proc template �w�q��ǤJ�W�١A�Τ��ǥѮ֤ߨM�w 
                , NOOBS:�Y�n��� OBS �h�ǤJ�ť�                                                                               */
/*��    �X:  PDF                                                                                                                                  */
/*�̮֤ۨ�: N/A                                                                                                                           */
%MACRO SYS_pdfConvertor( SasDataSet , OutPDF , Title="" , FootNote="" , Style="" , NOOBS="" ) ;
        /* �N SASDataSet �নPDF �C�L */
        %LET SasDataSet = %SYSFUNC( DEQUOTE( &SasDataSet. ) ) ;
        %LET OutPDF = %SYSFUNC( DEQUOTE( &OutPDF. ) ) ;
        %LET Title = %SYSFUNC( DEQUOTE( &Title. ) ) ;
        %LET FootNote = %SYSFUNC( DEQUOTE( &FootNote. ) ) ;
        %LET Style = %SYSFUNC( DEQUOTE( &Style. ) ) ;
        %LET NOOBS = %SYSFUNC( DEQUOTE( &NOOBS. ) ) ;

        /* �M�w�w�]���X�榡*/ 
        %IF %sysevalf(%superq( Style )=,boolean) EQ 1  %then %DO ;
                proc template;
                        define style Styles.Custom;
                                parent = Styles.Printer;
                                replace fonts /
                                        'TitleFont' = ("Times Roman",8pt,Bold Italic) /* Titles from TITLE statements */

                                        'TitleFont2' = ("Times Roman",8pt,Bold Italic) /* Proc titles ("The XX Procedure")*/

                                        'StrongFont' = ("Times Roman",8pt,Bold)
                                        'EmphasisFont' = ("Times Roman",8pt,Italic)
                                        'headingEmphasisFont' = ("Times Roman",8pt,Bold Italic)
                                        'headingFont' = ("Times Roman",8pt,Bold) /* Table column and row headings */

                                        'docFont' = ("Times Roman",8pt) /* Data in table cells */
                                        'footFont' = ("Times Roman",6pt) /* Footnotes from FOOTNOTE statements */

                                        'FixedEmphasisFont' = ("Courier",8pt,Italic)
                                        'FixedStrongFont' = ("Courier",8pt,Bold)
                                        'FixedHeadingFont' = ("Courier",8pt,Bold)
                                        'BatchFixedFont' = ("Courier",6pt)
                                        'FixedFont' = ("Courier",8pt);
                                replace color_list /
                                        'link' = blue /* links */
                                        'bgH' = grayBB /* row and column header background */
                                        'bgT' = white /* table background */
                                        'bgD' = white /* data cell background */
                                        'fg' = black /* text color */
                                        'bg' = white; /* page background color */

                                replace Table from Output /
                                        frame = box /* outside borders: void, box, above/below, vsides/hsides, lhs/rhs */
                                        rules = all /* internal borders: none, all, cols, rows, groups */
                                        cellpadding = 4pt /* the space between table cell contents and the cell border */
                                        cellspacing = 0.25pt /* the space between table cells, allows background to show */
                                        borderwidth = 0.75pt /* the width of the borders and rules */
                                        background = color_list('bgT') /* table background color */;
                        end;
                run;
                %LET Style = Custom ;
        %END ;
        
        goptions device=ACTXIMG;
        options orientation=landscape ;

        ods pdf close;
        ods pdf file="&OutPDF." style=&Style. ;

        title ;
        footnote;
        %IF %sysevalf(%superq( Title )=,boolean) eq 0  %THEN %DO ;  
                title "&Title." ;
        %END ;
        %IF %sysevalf(%superq( FootNote )=,boolean) eq 0  %THEN %DO ;
                footnote "&FootNote." ;
        %END;
        proc print data=&SasDataSet. &NOOBS. label; run ;

        ods pdf close;
        
%MEND ;

