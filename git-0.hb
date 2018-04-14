/*
 * git-0.hb
 *
 * IGH - Interfase Grafica Harbour
 * IGH Source Code
 *
 * Copyright 2011-2018 by Carlos Britos < asistex (a_t) yahoo.com.ar > (Uruguay)
 * License: Read License.md
 */

/*-----------------------------------*/
// coments
/*-----------------------------------*/

// Preparar archivos para el commit.
// This file must be located in the main folder.
// Busca en la lista de archivos  @ commit los archivos que
//   fueron modificados despues de la fecha del ultimo commit.
// Escanea en esos archivos si existe un changelog en el source code
// Si existe copia ese log en el archivo _CHANGELOG_FILE_ 'log.log' y lo
//   borra del source code
// Los archivos a leer son los que estan en la lista del archivo _LIST_OF_FILES_
// La estructura de _LIST_OF_FILES_ es:
//    # al inicio de cada linea es un cometario
//    @ marca una tabla. nombre tabla siempre en minusculas.
//    la lista debe estar continuada, sin lineas en blanco
//    una linea en blanco o el inicio de otra tabla indica fin de la tabla.
// Ej:
//    # archivos a controlar
//    @ commit
//    ..\samples\*.prg
//
//    # archivos a ignorar
//    @ ignore
//    ..\samples\demo1.prg
//
//    @ commit y @ ignore son nombres fijos en minusculas


/*-----------------------------------*/

#define _GIT_2_PATH_  Lower( hb_PathNormalize( hb_DirSepToOS( hb_DirBase()  ) ) ) /* must end with \ */
#define _CHANGELOG_FILE_ "log.log"
#define _LIST_OF_FILES_  "git-0.lst"
#define _MY_NAME_        "Carlos Britos < asistex (a_t) yahoo.com.ar >"

MEMVAR hDatos

/*-----------------------------------*/

PROCEDURE Main()

   LOCAL i, a, aGit, aFiles, cLine, aToCommit := {}, aToIgnore := {}
   LOCAL lAddToArrayCommit := .F.
   LOCAL lAddToArrayIgnore := .F.
   LOCAL oFile, aEachFile, cMask, cPath
   LOCAL aFilesToCommit := {}
   LOCAL nFiles := 0
   LOCAL nFilesNewer := 0
   LOCAL nFilesWithChangeLog := 0
   LOCAL nFilesIgnored := 0
   LOCAL nFilesOlder := 0
   LOCAL nFilesNoAutorized := 0
   LOCAL tFechaGit
   LOCAL nOffset := hb_UTCoffset()  // -> -10800
   LOCAL cPathIgnored, aFilesIgnored, cMaskIgnore
   LOCAL lIgnorar
   // LOCAL aChanges
   // LOCAL aFilesChanges := {}

   PUBLIC hDatos := hb_Hash()

   SET EXACT ON

   // entrada nueva
   hDatos[ "newentrylog" ] := hb_StrFormat( "%1$s UTC %2$02d%3$02d  %4$s",;
                                    hb_TToC( hb_DateTime(), "YYYY-MM-DD", "HH:MM:00" ),;
                                    Int( nOffset / 3600 ),;
                                    Int( ( ( nOffset / 3600 ) - Int( nOffset / 3600 ) ) * 60 ),;
                                    _MY_NAME_ ) + hb_Eol()


   Qout( "- working path", _GIT_2_PATH_ )

   // VerValor( GitUser() ) // -> asistex  (asistex yahoo.com.ar)

   // aChanges := DoctorChanges( Changes(), aFilesChanges )
   // VerValor( aChanges )
   // VerValor( aFilesChanges )


   aGit := hb_directory( _GIT_2_PATH_ + ".git\objects", "D" )
   // (A) (1)
   //     1) (A) (5)
   //          1) (C) (7) objects
   //          2) (N) (1) 0
   //          3) (T) t"2018-04-09 19:31:11.109"
   //          4) (C) (8) 19:31:11
   //          5) (C) (1) D

   IF .Not. Empty( aGit )
      tFechaGit := aGit[1][3]

   ELSE
      tFechaGit := hb_DateTime() - 180
      Qout( "* local Git repo not found" )

   ENDIF

   Qout( "- date of last commit", tFechaGit )

   // crear array aToCommit de archivos a commit desde el archivo _LIST_OF_FILES_
   // crear array aToIgnore de archivos a NO commit desde el archivo _LIST_OF_FILES_
   // son arrays unidimensionales con mascaras de [paths] + archivos (mascaras). ej: {"..\samples\*.prg","*.c"}
   IF hb_FileExists( _LIST_OF_FILES_ )

      Qout( "loading mask of files to commit, from", "'" + _LIST_OF_FILES_ + "'" )
      Qout( " " )

      oFile := TFileRead():new( _LIST_OF_FILES_ )
      oFile:open()

      IF oFile:error()
         ? oFile:errorMsg( "FileRead:" )
      ELSE
         DO WHILE oFile:moreToRead()
            cLine := oFile:readLine()
            cLine := AllTrim( cLine )

            // lineas de comentarios
            IF SubStr( cLine, 1, 1 ) == "#"
               lAddToArrayCommit := .F.
               LOOP
            ENDIF
            // lineas vacias
            IF Empty( cLine )
               lAddToArrayCommit := .F.
               LOOP
            ENDIF

            // inicio e una tabla
            IF cLine == "@ commit"
               aToCommit := {}
               lAddToArrayCommit := .T.
               LOOP
            ENDIF

            IF lAddToArrayCommit
               Aadd( aToCommit, Lower( cLine ) )
            ENDIF

            // inicio e una tabla
            IF cLine == "@ ignore"
               aToIgnore := {}
               lAddToArrayIgnore := .T.
               LOOP
            ENDIF

            IF lAddToArrayIgnore
               Aadd( aToIgnore, Lower( cLine )  )
            ENDIF

         ENDDO
         oFile:close()


      ENDIF

   ELSE
      Qout( "* not found the file", _LIST_OF_FILES_, "with mask of files to commit" )
      hb_MemoWrit( _LIST_OF_FILES_, e"# @ commit | @ ignore are tags to start arrays. name must be in lower case.\n# the list must not have blank lines or comments\n# that means the end of array\n\n@ commit\n# .\\samples\\*.prg\n\n@ ignore\n# .\\samples\\demo.prg\n# .\\res\\*\n" )
      Qout( "* the file", _LIST_OF_FILES_, "was created" )

   ENDIF

   IF Empty( aToCommit )
      Qout( "* there are no mask defined in '@ commit' of the file", "'" + _LIST_OF_FILES_ + "'" )
      RETURN
   ENDIF



   // parse each file
   FOR EACH cMask IN aToCommit

      cPath := Vias( cMask, 12 )

      aFiles := hb_directory( cMask )

      nFiles += Len( aFiles )

      // Qout( ShowValue( aFiles ) )
      // aFiles
      // -> (A) (120)
      //        1) (A) (5)
      //              1) (C) (14) COMMIT_EDITMSG
      //              2) (N) (2) 17
      //              3) (T) 2018-04-09 13:12:47.453
      //              4) (C) (8) 13:12:47
      //              5) (C) (1) A
      //        2) (A) (5)
      //              ...

      FOR EACH aEachFile IN aFiles


         // ignorados en la definicion del archivo .lst
         /// esto solo funciona cuando la mascara no incluye comodines
       //   IF hb_Ascan( aToIgnore, Lower( cPath + aEachFile[1] ) ) > 0
       //      Qout( "- ignored /", Lower( cPath + aEachFile[1] ) )
       //      nFilesIgnored ++
       //      LOOP
       //   ENDIF


         // ignorados en la definicion del archivo .lst
         // acepta los comodines en las mascaras
         lIgnorar := .F.
         FOR EACH cMaskIgnore IN aToIgnore
            // VerValor( cMaskIgnore )
            cPathIgnored := Vias( cMaskIgnore, 12 )
            // VerValor( cPathIgnored )
            IF cPath == cPathIgnored
               aFilesIgnored := hb_directory( cMaskIgnore )
               // VerValor( aFilesIgnored )

               IF Len( aFilesIgnored ) > 0
                  FOR i := 1 TO Len( aFilesIgnored )
                     IF Lower( cPath + aEachFile[1] ) == Lower( cPath + aFilesIgnored[i][1] )
                        Qout( "- ignored        -", Lower( cPath + aEachFile[1] ) )
                        nFilesIgnored ++
                        lIgnorar := .T.
                     ENDIF
                  NEXT
               ENDIF
            ENDIF
         NEXT

         IF lIgnorar
            LOOP
         ENDIF


         // a ninguno de estos archivos se le puede hacer la tarea
         IF hb_Ascan( { ".exe",".dll",".res",".db",".7z",".zip",".cab",".rar",".png",".bmp",".lib",".a",".res",".jpg",".pdf",".ico",".ani",".dat",".tif",".wav",".cur",".dbf",".ntx",".rtf",".dbt",".pps",".gif",".swf"}, Lower( Vias( aEachFile[1], 4 )  )  ) > 0
            Qout( "- protected      -", Lower( cPath + aEachFile[1] ) )
            nFilesIgnored ++
            LOOP
         ENDIF

         // solo si estan permitidos aca se realiza la tarea aunque esten definidos en @ analizar
         IF hb_Ascan( { ".prg",".c",".rc",".ch",".h",".idu",".txt",".bat",".md"}, Lower( Vias( aEachFile[1], 4 )  )  ) == 0
            Qout( "- not authorized -", Lower( cPath + aEachFile[1] ) )
            nFilesNoAutorized ++
            LOOP
         ENDIF

         // hacer la tarea
         IF aEachFile[3] > tFechaGit
            nFilesNewer ++
            nFilesWithChangeLog += SearchChangelogInFile( cPath + aEachFile[1] )

         ELSE
            nFilesOlder ++
            Qout( "- older than last commit", Lower( cPath + aEachFile[1] ) )

         ENDIF

      NEXT

   NEXT

   Qout( " " )
   Qout( hb_ValToStr( nFiles ), "parsed files" )
   Qout( hb_ValToStr( nFilesIgnored ), "ignored" )
   Qout( hb_ValToStr( nFilesNoAutorized ), "no authorized" )
   Qout( hb_ValToStr( nFilesOlder ), "older than last commit", tFechaGit )
   Qout( hb_ValToStr( nFilesNewer ), "newer than last commit", tFechaGit )
   Qout( hb_ValToStr( nFilesWithChangeLog ), "with changelog in source, of", hb_NtoS( nFilesNewer ), "newer" )
   IF nFilesNewer == 0
      Qout( "- no files to commit" )
   ELSE
      IF nFilesNewer != nFilesWithChangeLog
         Qout( "* there are files without changelog in source" )
      ENDIF
   ENDIF
   Qout( " " )


   RETURN

/*-----------------------------------*/

FUNCTION SearchChangelogInFile( cFile )

   LOCAL oFile, cLine
   LOCAL lAddToCommit := .F.
   LOCAL cInfoLog := ""
   LOCAL cPreviousLog := hb_MemoRead( _CHANGELOG_FILE_ )
   LOCAL cFileText := ""
   LOCAL nFilesWithChangeLog := 0

   Qout( "- parsing ", cFile )

   IF hb_FileExists( cFile )

      oFile := TFileRead():new( cFile )
      oFile:open()

      IF oFile:error()
         ? oFile:errorMsg( "FileRead:" )
      ELSE
         DO WHILE oFile:moreToRead()
            cLine := oFile:readLine()

            // lines of change log in source file
            IF "changelog" $ Lower( cLine ) .AND. ;
                    "#if" + "defined(" + "changelog)" $ StrTran( Lower( cLine ), " ", "" ) // " + " = pa evitar auto eliminacion

               cInfoLog += hDatos[ "newentrylog" ] + hb_Eol() + "* " + cFile + hb_Eol()
               lAddToCommit := .T.
               nFilesWithChangeLog ++
               LOOP
            ENDIF

              // se encontro el changelog en source code
            IF lAddToCommit
               // lineas propias del changelog
               IF Empty( cLine ) // bug. remueve lineas en blanco en log
                  LOOP

               ELSEIF "changelog" $ Lower( cLine ) .AND. ;
                  "#endif" + "//ifdefined(" + "changelog)" $ StrTran( Lower( cLine ), " ", "" )
                   lAddToCommit := .F.

               ELSEIF SubStr( cLine, 1, 1 ) == "#"
                  LOOP

               ELSEIF SubStr( cLine, 1, 1 ) == "."
                  cline := hb_Eol()

               ELSE
                  cInfoLog += "  " + cLine + hb_Eol()

               ENDIF

            ELSE
               cFileText += Rtrim( cLine ) + hb_Eol()

            ENDIF

         ENDDO
         oFile:close()

         IF .NOT. Empty( cInfoLog )
            cInfoLog := cPreviousLog + cInfoLog
            Qqout( "  - Log found, copying to '" )
            Qqout( _CHANGELOG_FILE_ )
            Qqout( "', removing Log from source code" )
            hb_MemoWrit( _CHANGELOG_FILE_, cInfoLog + hb_Eol() )
            hb_MemoWrit( cFile, cFileText )
            // hb_MemoWrit( cFile, Rtrim( cFileText ) )

         ELSE
            Qqout( "  - post dated, no Log in code" )

         ENDIF

      ENDIF

   ENDIF

   RETURN nFilesWithChangeLog

/*-----------------------------------*/
/*-----------------------------------*/
/*-----------------------------------*/
/*-----------------------------------*/
/*-----------------------------------*/












/*-----------------------------------*/
// A class that reads a file one line at a time
//   Donated to the public domain on 2001-04-03 by David G. Holm <dholm@jsd-llc.com>
/*-----------------------------------*/

#include "hbclass.ch"

#include "fileio.ch"

#define oF_ERROR_MIN          1
#define oF_CREATE_OBJECT      1
#define oF_OPEN_FILE          2
#define oF_READ_FILE          3
#define oF_CLOSE_FILE         4
#define oF_ERROR_MAX          4
#define oF_DEFAULT_READ_SIZE  4096

/*-----------------------------------*/

CREATE CLASS TFileRead

   VAR cFile                   // The filename
   VAR nHan                    // The open file handle
   VAR lEOF                    // The end of file reached flag
   VAR nError                  // The current file error code
   VAR nLastOp                 // The last operation done (for error messages)
   VAR cBuffer                 // The readahead buffer
   VAR nReadSize               // How much to add to the readahead buffer on each read from the file

   METHOD new( cFile, nSize )  // Create a new class instance
   METHOD open( nMode )        // Open the file for reading
   METHOD close()              // Close the file when done
   METHOD readLine()           // Read a line from the file
   METHOD name()               // Retunrs the file name
   METHOD isOpen()             // Returns .T. if file is open
   METHOD moreToRead()         // Returns .T. if more to be read
   METHOD error()              // Returns .T. if error occurred
   METHOD errorNo()            // Returns current error code
   METHOD errorMsg( cText )    // Returns formatted error message

   PROTECTED:

   METHOD EOL_pos()

END CLASS

/*-----------------------------------------------------------------*/

METHOD new( cFile, nSize ) CLASS TFileRead

   IF nSize == NIL .OR. nSize < 1
      // The readahead size can be set to as little as 1 byte, or as much as
      // 65535 bytes, but venturing out of bounds forces the default size.
      nSize := oF_DEFAULT_READ_SIZE
   ENDIF

   ::cFile     := cFile             // Save the file name
   ::nHan      := F_ERROR           // It's not open yet
   ::lEOF      := .T.               // So it must be at EOF
   ::nError    := 0                 // But there haven't been any errors
   ::nLastOp   := oF_CREATE_OBJECT  // Because we just created the class
   ::cBuffer   := ""                // and nothing has been read yet
   ::nReadSize := nSize             // But will be in this size chunks

   RETURN Self

/*-----------------------------------*/

METHOD open( nMode ) CLASS TFileRead

   IF ::nHan == F_ERROR
      // Only open the file if it isn't already open.
      IF nMode == NIL
         nMode := FO_READ + FO_SHARED   // Default to shared read-only mode
      ENDIF
      ::nLastOp := oF_OPEN_FILE
      ::nHan := FOpen( ::cFile, nMode )   // Try to open the file
      IF ::nHan == F_ERROR
         ::nError := FError()       // It didn't work
         ::lEOF   := .T.            // So force EOF
      ELSE
         ::nError := 0              // It worked
         ::lEOF   := .F.            // So clear EOF
      ENDIF
   ELSE
      // The file is already open, so rewind to the beginning.
      IF FSeek( ::nHan, 0 ) == 0
         ::lEOF := .F.              // Definitely not at EOF
      ELSE
         ::nError := FError()       // Save error code if not at BOF
      ENDIF
      ::cBuffer := ""               // Clear the readahead buffer
   ENDIF

   RETURN Self

/*-----------------------------------*/

METHOD readLine() CLASS TFileRead

   LOCAL cLine := ""
   LOCAL nPos

   ::nLastOp := oF_READ_FILE

   IF ::nHan == F_ERROR
      ::nError := F_ERROR           // Set unknown error if file not open
   ELSE
      // Is there a whole line in the readahead buffer?
      nPos := ::EOL_pos()
      WHILE ( nPos <= 0 .OR. nPos > Len( ::cBuffer ) - 3 ) .AND. ! ::lEOF
         // Either no or maybe, but there is possibly more to be read.
         // Maybe means that we found either a CR or an LF, but we don't
         // have enough characters to discriminate between the three types
         // of end of line conditions that the class recognizes (see below).
         cLine := FReadStr( ::nHan, ::nReadSize )
         IF Empty( cLine )
            // There was nothing more to be read. Why? (Error or EOF.)
            ::nError := FError()
            IF ::nError == 0
               // Because the file is at EOF.
               ::lEOF := .T.
            ENDIF
         ELSE
            // Add what was read to the readahead buffer.
            ::cBuffer += cLine
         ENDIF
         // Is there a whole line in the readahead buffer yet?
         nPos := ::EOL_pos()
      ENDDO
      // Is there a whole line in the readahead buffer?
      IF nPos <= 0
         // No, which means that there is nothing left in the file either, so
         // return the entire buffer contents as the last line in the file.
         cLine := ::cBuffer
         ::cBuffer := ""
      ELSE
         // Yes. Is there anything in the line?
         IF nPos > 1
            // Yes, so return the contents.
            cLine := Left( ::cBuffer, nPos - 1 )
         ELSE
            // No, so return an empty string.
            cLine := ""
         ENDIF
         // Deal with multiple possible end of line conditions.
         DO CASE
         CASE SubStr( ::cBuffer, nPos, 3 ) == Chr( 13 ) + Chr( 13 ) + Chr( 10 )
            // It's a messed up DOS newline (such as that created by a program
            // that uses "\r\n" as newline when writing to a text mode file,
            // which causes the '\n' to expand to "\r\n", giving "\r\r\n").
            nPos += 3
         CASE SubStr( ::cBuffer, nPos, 2 ) == Chr( 13 ) + Chr( 10 )
            // It's a standard DOS newline
            nPos += 2
         OTHERWISE
            // It's probably a Mac or Unix newline
            nPos++
         ENDCASE
         ::cBuffer := SubStr( ::cBuffer, nPos )
      ENDIF
   ENDIF

   RETURN cLine

/*-----------------------------------*/

METHOD eol_pos() CLASS TFileRead

   LOCAL nCRpos, nLFpos, nPos

   // Look for both CR and LF in the file read buffer.
   nCRpos := At( Chr( 13 ), ::cBuffer )
   nLFpos := At( Chr( 10 ), ::cBuffer )
   DO CASE
   CASE nCRpos == 0
      // If there's no CR, use the LF position.
      nPos := nLFpos
   CASE nLFpos == 0
      // If there's no LF, use the CR position.
      nPos := nCRpos
   OTHERWISE
      // If there's both a CR and an LF, use the position of the first one.
      nPos := Min( nCRpos, nLFpos )
   ENDCASE

   RETURN nPos

/*-----------------------------------*/

METHOD close() CLASS TFileRead

   ::nLastOp := oF_CLOSE_FILE
   ::lEOF := .T.
   // Is the file already closed.
   IF ::nHan == F_ERROR
      // Yes, so indicate an unknown error.
      ::nError := F_ERROR
   ELSE
      // No, so close it already!
      FClose( ::nHan )
      ::nError := FError()
      ::nHan   := F_ERROR           // The file is no longer open
      ::lEOF   := .T.               // So force an EOF condition
   ENDIF

   RETURN Self

/*-----------------------------------*/

METHOD name() CLASS TFileRead

   // Returns the filename associated with this class instance.

   RETURN ::cFile

/*-----------------------------------*/

METHOD isOpen() CLASS TFileRead

   // Returns .T. if the file is open.

   RETURN ::nHan != F_ERROR

/*-----------------------------------*/

METHOD moreToRead() CLASS TFileRead

   // Returns .T. if there is more to be read from either the file or the
   // readahead buffer. Only when both are exhausted is there no more to read.

   RETURN ! ::lEOF .OR. ! Empty( ::cBuffer )

/*-----------------------------------*/

METHOD error() CLASS TFileRead

   // Returns .T. if an error was recorded.

   RETURN ::nError != 0

/*-----------------------------------*/

METHOD errorNo() CLASS TFileRead

   // Returns the last error code that was recorded.

   RETURN ::nError

/*-----------------------------------*/

METHOD errorMsg( cText ) CLASS TFileRead

   STATIC sc_cAction := { "on", "creating object for", "opening", "reading from", "closing" }

   LOCAL cMessage, nTemp

   // Has an error been recorded?
   IF ::nError == 0
      // No, so report that.
      cMessage := "No errors have been recorded for " + ::cFile
   ELSE
      // Yes, so format a nice error message, while avoiding a bounds error.
      IF ::nLastOp < oF_ERROR_MIN .OR. ::nLastOp > oF_ERROR_MAX
         nTemp := 1
      ELSE
         nTemp := ::nLastOp + 1
      ENDIF
      cMessage := iif( Empty( cText ), "", cText ) + "Error " + hb_ntos( ::nError ) + " " + sc_cAction[ nTemp ] + " " + ::cFile
   ENDIF

   RETURN cMessage

/*-----------------------------------*/

FUNCTION Vias( cFile, nControl )

   LOCAL i, cD, cP, cN, cE
   LOCAL nPosDS, cControl, cRet := ""

   hb_Default( @cFile, "" )

   hb_FNameSplit( cFile, @cP, @cN, @cE, @cD )
   nPosDS := AT( hb_osDriveSeparator(), cP )

   // convierte a cadena para analizar cada digito del param
   cControl := hb_ValToStr( nControl )
   FOR i := 1 TO Len( cControl )
      nControl := Val( SubStr( cControl, i, 1 ) )

      SWITCH nControl
         CASE 1 // disco + :\
            cRet += cD + iif( .not. Empty( cD ), hb_osDriveSeparator() + hb_ps(), "" )
            Exit
         CASE 2 // path. inicia sin hb_ps() y termina con hb_ps()
            cRet += SubStr( cP, iif( Empty( cD ), 1, nPosDS + Len( hb_osDriveSeparator() ) + 1 ) )
            Exit
         CASE 3 // archivo
            cRet += hb_FNameName( cFile )
            Exit
         CASE 4 // extension con punto
            cRet += hb_FNameExt( cFile )
            Exit
         CASE 5 // extension sin punto
            cRet += SubStr( cE, 2 )
            Exit
         CASE 6 // disco sin :\
            cRet += cD
            Exit
      END SWITCH
   NEXT

   RETURN cRet

/*-----------------------------------*/

FUNCTION ShowValue( xVar, nIndX )

   LOCAL cRet := "", cTipoParam
   LOCAL aData, nLen, n
   LOCAL i, nInd := 2
   LOCAL aKeys, aValues
   LOCAL cTipo

   // hb_Default( nIndX, 0 )
   IF hb_IsNIL( nIndX )
      nIndX := 0
   ENDIF

   nInd += nIndX
   cTipoParam := ValType( xVar )
   cTipo := "(" + cTipoParam + ") "

   SWITCH cTipoParam

      CASE "A"
         cRet += cTipo + "(" + hb_NtoS( Len( xVar ) ) + ")"
         FOR i := 1 TO Len( xVar )
            IF hb_IsArray( xVar[i ] )
               cRet += hb_Eol() + Space( nInd ) + Str( i, 6 ) + ") "
               nInd += 3
               cRet += ShowValue( xVar[i ], nInd )
               nInd -= 3
            ELSE
               cRet += hb_Eol() + Space( nInd ) + Str( i, 6 ) + ") "
               cRet += ShowValue( xVar[i ], nInd  )
            ENDIF
         NEXT
         EXIT

      CASE "C"
         cRet := cTipo + "(" + hb_NtoS( Len( xVar ) ) + ") " + xVar
         EXIT

      CASE "M"
         cRet := cTipo + "(" + hb_NtoS( Len( xVar ) ) + ") " + xVar
         EXIT

      CASE "N"
         cRet := cTipo + "(" + hb_NtoS( LenNum( xVar ) ) + ") " + LTrim( hb_ValToStr( xVar ) )
         EXIT

      CASE "D"
         cRet := cTipo + hb_ValToStr( xVar ) + "    DToS() " + DToS( xVar ) + "    Format " + Set( 4 )
         EXIT

      CASE "L"
         cRet := cTipo + hb_ValToStr( xVar )
         EXIT

      CASE "O"
         cRet := cTipo
         // aData := __bcdObjGetValueList( xVar )
         // nLen  := Len( aData )
         // cRet += cTipo + "(" + hb_NtoS( nLen ) + ")" + hb_Eol() + Space( nInd ) + "ClassName= " + xVar:ClassName() + " :ClassH()=" + hb_NtoS( xVar:ClassH() ) + hb_Eol()
         // FOR n := 1 TO nLen
         //    cRet += Space( nInd + 3 ) + "Symbol " + hb_NtoS( n ) + " " + aData[ n ][ HB_OO_DATA_SYMBOL ] + hb_Eol()
         // NEXT
         EXIT

      CASE "B"
         cRet := "(B){||...} ->" + Space( nInd ) + ShowValue( Eval( xVar ) )
         EXIT

      CASE "P"
         cRet := cTipo + LTrim( hb_ValToStr( xVar ) ) + " hb_HexToNum()= " + LTrim( Str( hb_HexToNum( SubStr( hb_ValToStr( xVar ), 3 ) ) ) )
         EXIT

      CASE "H"
         cRet := cTipo + "(" + hb_NtoS( Len( xVar ) ) + ")"
         aKeys := hb_HKeys( xVar )
         aValues := hb_HValues( xVar )
         FOR i := 1 TO Len( aKeys )
            IF hb_IsHash( xVar[ aKeys[i] ] )
               cRet += hb_Eol() + Space( nInd ) + Str( i, 6 ) + ") "
               nInd += 2
               cRet += ShowValue( xVar[ aKeys[i] ], nInd )
               nInd -= 2

            ELSE
               cRet += hb_Eol() + Space( nInd ) + Str( i, 6 ) + ") " + hb_ValToExp( aKeys[ i ] ) + " " + ;
               iif( hb_IsHash( aValues[ i ] ), + "(H) " + hb_ValToExp( aValues[ i ] ), ShowValue( aValues[ i ], nInd ) )

            ENDIF
         NEXT
         EXIT

      CASE "T"
         cRet := cTipo + "(23) " + hb_TSToStr( xVar, .T. )
         EXIT

      CASE "U"
         cRet := "(U) Nil"
         EXIT

      CASE "S"
         cRet := cTipo
         IF hb_IsString( xVar:name )
            cRet += "@" + xVar:name + "()"
         ELSE
            cRet += "@???()"
         ENDIF
         cRet += ")"
         EXIT

      CASE "UE"
         cRet := "(UE)"
         EXIT

      OTHERWISE
         cRet := "Value Type: " + cTipo + "No soportado por showValue()"

   END SWITCH

   RETURN cRet

/*-----------------------------------*/

FUNCTION CrearLog( cFile, cLinea )

   LOCAL nHnd

   IF hb_FileExists( cFile )
      nHnd := FOpen( cFile, FO_READWRITE + FO_SHARED )
      FSeek( nHnd, 0, FS_END)
   ELSE
      nHnd := FCreate( cFile, FC_NORMAL )
   ENDIF

   IF hb_IsString( cLinea )
      FWrite( nHnd, cLinea + hb_Eol() )
   ENDIF

   FClose( nHnd )

   RETURN nHnd

/*-----------------------------------*/

FUNCTION VerValor( param )

   RETURN Qout( ShowValue( param ) )

/*-----------------------------------*/




#if 0





/*-----------------------------------*/

// VerValor( GitUser() ) // -> asistex  (asistex yahoo.com.ar)

STATIC FUNCTION GitUser()

   LOCAL cName := ""
   LOCAL cEMail := ""

   hb_processRun( Shell() + " " + "git config user.name",, @cName )
   hb_processRun( Shell() + " " + "git config user.email",, @cEMail )

   RETURN hb_StrFormat( "%s (%s)", ;
          AllTrim( hb_StrReplace( cName, Chr( 10 ) + Chr( 13 ), "" ) ), ;
          StrTran( AllTrim( hb_StrReplace( cEMail, Chr( 10 ) + Chr( 13 ), "" ) ), "@", " " ) )

/*-----------------------------------*/

STATIC FUNCTION Changes()

   LOCAL cStdOut := ""

   hb_processRun( Shell() + " git status -s",, @cStdOut )

   RETURN hb_ATokens( StrTran( cStdOut, Chr( 13 ) ), Chr( 10 ) )

/*-----------------------------------*/

STATIC FUNCTION DoctorChanges( aChanges, aFiles )

   LOCAL cLine
   LOCAL cStart
   LOCAL aNew := {}

   LOCAL cFile
   LOCAL tmp

   ASort( aChanges,,, {| x, y | x < y } )

      FOR EACH cLine IN aChanges
         IF ! Empty( cLine ) .AND. SubStr( cLine, 3, 1 ) == " "
            cStart := Left( cLine, 1 )
            IF Empty( Left( cLine, 1 ) )
               cStart := SubStr( cLine, 2, 1 )
            ENDIF

            SWITCH cStart
               CASE " "
               CASE "?"
                  cStart := ""
                  EXIT
               CASE "M"
               CASE "R"
               CASE "T"
               CASE "U"
                  cStart := "*"
                  EXIT
               CASE "A"
               CASE "C"
                  cStart := "+"
                  EXIT
               CASE "D"
                  cStart := "-"
                  EXIT
               OTHERWISE
                  cStart := "?"
            END SWITCH

            IF ! Empty( cStart )
               AAdd( aNew, "  " + cStart + " " + StrTran( SubStr( cLine, 3 + 1 ), "\", "/" ) )
               IF !( cStart == "-" )
                  cFile := SubStr( cLine, 3 + 1 )
                  IF ( tmp := At( " -> ", cFile ) ) > 0
                     cFile := SubStr( cFile, tmp + Len( " -> " ) )
                  ENDIF
                  AAdd( aFiles, cFile )
               ENDIF
            ENDIF
         ENDIF
      NEXT

   RETURN aNew

/*-----------------------------------*/

STATIC FUNCTION Shell()

   LOCAL cShell := GetEnv( "COMSPEC" )

   IF ! Empty( cShell )
      cShell += " /c"
   ENDIF

   RETURN cShell

/*-----------------------------------*/




#endif // if defined 0



#if defined( changelog )
#  indent + 2
#  format =  * Changed, ! Fix, % Optimized, + Added up, - Removal of, ; Comment

* agregado de funciones de Harbour commit.hb
  + DoctorChanges()
  + Shell()
  + Changes()
  + GitUser()


#endif // if defined( changelog )


