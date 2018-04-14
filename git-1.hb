/*
 * git-1.hb
 *
 * IGH - Interfase Grafica Harbour
 * IGH Source Code
 *
 * Copyright 2011-Today by Carlos Britos < bcd12a (a_t) yahoo.com.ar > (Uruguay)
 * License: Read License.md
 */

/*-----------------------------------------------------------------*/
// coments
/*-----------------------------------------------------------------*/


/*-----------------------------------------------------------------*/

MEMVAR hValores

/*-----------------------------------------------------------------*/

FUNCTION Main()

   LOCAL cStdOut, cStdErr
   LOCAL sOut := "", sLog

   PUBLIC hValores := hb_hash()

   Qout( "do git pull " )
   hb_processRun( "git pull", ,@cStdOut, @cStdErr )
   Qout( cStdOut )
   // Qout( "+>"+ cStdErr )

   // IF hb_IsString( cStdErr ) .AND. .NOT. Empty( cStdErr )
   //    RETURN .F.
   // ENDIF

   // IF hb_IsString( cStdOut ) .AND. .NOT. Empty( cStdOut )
   IF "Already up-to-date." $ cStdOut
      sLog := CheckChangeLog()

      IF hb_IsNIL( sLog )
         RETURN .F.
      ENDIF

      sLog := '"' + sLog + '"'

      Qout( "------------------------------Inicio Log------------------------------" )
      Qout( sLog + hb_Eol() )
      Qout( "--------------------------------Fin Log-------------------------------" )

      Qout( "Es correcto el changelog para este commit ? - ESC cancela, otra key continua" )
      inkey( 0 )

      IF Lastkey() == 27
         RETURN .F.
      ENDIF

      hValores[ "paramLogCommit" ] := sLog

      DoCommit()

   ELSEIF .Not. Empty( cStdErr )
      Qout( cStdErr )
      RETURN .F.

   ELSE // IF "Updating" $ cStdOut
      // IF "Fast-forward" $ cStdOut
      //    DoCommit()
      // ENDIF

      // GetChangesFromGithub()
      Qout( "Reiniciar git-1.hb " )
      RETURN .F.

   ENDIF

   RETURN .T.

/*-----------------------------------------------------------------*/

FUNCTION DoCommit()

   LOCAL i, s := "", cStdOut, cStdErr

   Qout( "do add " )
   hb_processRun( "git add ." , ,@cStdOut, @cStdErr )
   // Qout( "->"+ cStdOut )
   // Qout( "+>"+ cStdErr )

   Qout( "do ignored list " )
   hb_processRun( "git ls-files -i --exclude-standard", ,@cStdOut, @cStdErr )
   // Qout( "->"+ cStdOut )
   // Qout( "+>"+ cStdErr )

   Qout( "do commit " )
   hb_processRun( "git commit -m " + hValores[ "paramLogCommit" ], ,@cStdOut, @cStdErr )
   Qout( cStdOut )
   Qout( cStdErr )

   IF "Your branch is up-to-date" $ cStdOut
      CleanLogLog()
      // DoNothing()
      RETURN .F.

   ELSEIF "Your branch is ahead of" $ cStdOut
      Qout( "Se debe hacer un git push manual" )
      //hb_processRun( "git push", ,@cStdOut )
      // Qout( "->"+ cStdOut + hb_Eol() )
      // RETURN .F.
   ENDIF

   //IF hb_IsString( cStdErr ) .AND. .NOT. Empty( cStdErr )

   IF "Changes not staged for commit" $ cStdErr
      // DoStash()
      RETURN .F.

   ELSEIF "Aborting commit due to empty commit message" $ cStdErr
      CheckChangeLog()
      RETURN .F.
   ENDIF

   Qout( "do push" + hb_Eol() )
   hb_processRun( "git push ", ,@cStdOut  ) // DONT USE cStdErr
   Qout( cStdOut + hb_Eol() )
   // Qout( "+>"+ cStdErr )
   /*
   IF "Writing objects: 100%" $ cStdOut
      Qout( "Commit exitoso" )

   ELSEIF "Everything up-to-date" $ cStdOut
      Qout( "Commit nada. is up to date" )

   ELSEIF "remote: Invalid username or password." $ cStdOut
      Qout( "Commit nada. Nombre usuario o password mal" )

   ELSE
      Qout( "Commit fallo" )

   ENDIF
   */

   // para no sobreescribir salida de git push
   FOR i := 1 TO 10
      Qout( "" )
   NEXT

   CleanLogLog()

   RETURN .T.

/*-----------------------------------------------------------------*/

FUNCTION CheckChangeLog()

   LOCAL sLog

   IF .Not. hb_FileExists( "log.log" )
      Qout( "Error: No se encuentra el archivo log.log" )
      RETURN NIL
   ENDIF

   sLog := hb_MemoRead( "log.log" )

   IF Empty( AllTrim( sLog ) )
      Qout( "Error: El archivo log.log esta vacio" )
      RETURN NIL
   ENDIF

   RETURN sLog

/*-----------------------------------------------------------------*/

FUNCTION CleanLogLog()

   Qout( "Si todo fue ok, borrar el contenido del archivo log.log ? - ESC cancela, otra key continua" )
   inkey( 0 )

   IF Lastkey() == 27
      RETURN .F.
   ELSE
      // crear un backup de log.log con nombre fechahora.log
      // antes de limpiarlo
      hb_vfCopyFile( "log.log", hb_TtoS( hb_DateTime() ) + ".log" )
      hb_MemoWrit( "log.log", "" )
      // hb_FileDelete( "..\log.log" )

   ENDIF

   RETURN .T.

/*-----------------------------------------------------------------*/
