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



MEMVAR hValores

/*-----------------------------------------------------------------*/

// param es log del commit

FUNCTION Main( ... )

   LOCAL cStdOut, cStdErr
   LOCAL sOut := "", sLog
   // LOCAL i, a := hb_aParams()

   PUBLIC hValores := hb_hash()

   sLog := hb_MemoRead( "..\log.log" )
   sLog := '"' + sLog + '"'

   IF .Not. Empty( sLog )

      IF hb_IsString( sLog )
         hValores[ "paramLogCommit" ] := sLog 
      ENDIF
   ELSE
      DoFaltaParam()
      RETURN .F. 
   ENDIF

   // LOCAL s := hb_MemoRead( "c:\prog\ighoo\ighoo\q.txt" )

   Qout( "do git pull " )
   hb_processRun( "git pull", ,@cStdOut, @cStdErr )
   Qout( "->"+ cStdOut )
   Qout( "+>"+ cStdErr )

   IF hb_IsString( cStdErr ) .AND. .NOT. Empty( cStdErr )
      RETURN .F.
   ENDIF

   IF hb_IsString( cStdOut ) .AND. .NOT. Empty( cStdOut )
      IF "Already up-to-date." $ cStdOut
         DoCommit()

      ELSE
         GetChangesFromGithub()          
         RETURN .F. 

      ENDIF 

   ENDIF

   RETURN .T.

/*-----------------------------------------------------------------*/

FUNCTION DoCommit()

   LOCAL s := "", cStdOut, cStdErr

   IF .NOT. Empty( hValores ) .AND. hb_IsString( hValores[ "paramLogCommit" ] )

      Qout( "do add " )
      hb_processRun( "git add ." , ,@cStdOut, @cStdErr )
      Qout( "->"+ cStdOut )
      Qout( "+>"+ cStdErr )

      Qout( "do ignored list " )
      hb_processRun( "git ls-files -i --exclude-standard", ,@cStdOut, @cStdErr )
      Qout( "->"+ cStdOut )
      Qout( "+>"+ cStdErr )

      Qout( "do commit " )
      hb_processRun( "git commit -m " + hValores[ "paramLogCommit" ], ,@cStdOut, @cStdErr )
      Qout( "->"+ cStdOut )
      Qout( "+>"+ cStdErr )

      IF "Your branch is up-to-date" $ cStdOut
         DoNothing()
         RETURN .F.

      ELSEIF "Your branch is ahead of" $ cStdOut
         Qout( "Se debe hacer un git push manual" )
         RETURN .F.
      ENDIF
      
      //IF hb_IsString( cStdErr ) .AND. .NOT. Empty( cStdErr )

         IF "Changes not staged for commit" $ cStdErr
            DoStash()
            RETURN .F.

         ELSEIF "Aborting commit due to empty commit message" $ cStdErr
            DoFaltaParam()
            RETURN .F.
         ENDIF

            Qout( "do push " )
            hb_processRun( "git push ", ,@cStdOut  )
            // Qout( "->"+ cStdOut )
            // Qout( "+>"+ cStdErr )

/*
            IF "Writing objects: 100%" $ cStdErr
               Qout( "Commit exitoso" )

            ELSEIF "Everything up-to-date" $ cStdErr
               Qout( "Commit nada. is up to date" )

            ELSEIF "remote: Invalid username or password." $ cStdErr
               Qout( "Commit nada. Nombre usuario o password mal" )

            ELSE
               Qout( "Commit fallo" )

            ENDIF
*/            

         // ENDIF
   ENDIF   

   RETURN .T.

/*-----------------------------------------------------------------*/

FUNCTION DoNothing()
			
   Qout( "do nothing" )

   RETURN .T.

/*-----------------------------------------------------------------*/

FUNCTION DoStash()

   // LOCAL vars
   Qout( "do stash" )

   RETURN .T.

/*-----------------------------------------------------------------*/

FUNCTION DoFaltaParam()
   
   Qout( "Faltan param log changes. File= ..\log.log" )

   IF .Not. hb_FileExists( "..\log.log" )
      Qout( "no se encuentra el file ..\log.log" )
   ENDIF

   RETURN .T.

/*-----------------------------------------------------------------*/

FUNCTION GetChangesFromGithub()

   Qout( "getchangesfromgithub" )

   RETURN .T.

/*-----------------------------------------------------------------*/

