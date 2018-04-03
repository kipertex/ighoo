/*
 * $Id: ighver.hb 182 2013-05-19 18:08:20Z Xp $
 *
 *
 * IGH - Interfase Grafica Harbour
 * IGH Source Code
 *
 * Copyright 2011-2013 by Carlos Britos < bcd12a (a_t) yahoo.com.ar > (Uruguay)
 *
 */

/*-----------------------------------------------------------------*/
// coments
/*-----------------------------------------------------------------*/


/*-----------------------------------------------------------------*/
// related files
/*-----------------------------------------------------------------*/





/*-----------------------------------------------------------------*/

FUNCTION Main( ... )

   LOCAL cStdOut
   LOCAL sOut := ""
      
   // LOCAL s := hb_MemoRead( "c:\prog\ighoo\ighoo\q.txt" )

   hb_processRun( "git pull ", ,@cStdOut )

   IF hb_IsString( cStdOut ) .AND. .NOT. Empty( cStdOut )
      IF cStdOut == "Already up-to-date."
         DoCommit()

      ELSE
         GetChangesFromGithub()          

      ENDIF 

   ENDIF

   Qout( cStdOut )   

   RETURN nil


/*-----------------------------------------------------------------*/

FUNCTION GetChangesFromGithub()

   // LOCAL 

   Qout( "getchangesfromgithub" )

   RETURN .T.

/*-----------------------------------------------------------------*/

FUNCTION DoCommit()

   // LOCAL vars

   Qout( "do commit" )

   RETURN .T.

/*-----------------------------------------------------------------*/




/*-----------------------------------------------------------------*/
