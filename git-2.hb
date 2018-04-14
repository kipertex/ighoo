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

/*-----------------------------------*/
// coments
/*-----------------------------------*/


/*-----------------------------------*/

#define _GIT_2_PATH_  Lower( hb_PathNormalize( hb_DirSepToOS( hb_DirBase()  ) ) ) /* must end with dirsep */
#define _CHANGELOG_FILE_ "log.log"
#define _LIST_OF_FILES_  "git-2.lst"


MEMVAR hValores

/*-----------------------------------*/
// buscar archivos modificados despues del ultimo commit
/*-----------------------------------*/

FUNCTION Main()

   LOCAL a, aGit, aFiles, cLine, aToCommit := { "*.*" }, aToIgnore := {}
   LOCAL lAddToArrayCommit := .F.
   LOCAL lAddToArrayIgnore := .F.
   LOCAL oFile, aEachFile, cMask, cPath
   LOCAL aFilesToCommit := {}

   PUBLIC hValores := hb_hash()

   Qout( "path git-2.hb ", _GIT_2_PATH_ )

   aGit := hb_directory( _GIT_2_PATH_ + ".git\objects", "D" )
   // 1) (A) (5)
   //       1) (C) (7) objects
   //       2) (N) (1) 0
   //       3) (D) 04/09/18    DToS() 20180409    Format mm/dd/yy
   //       4) (C) (8) 13:12:47
   //       5) (C) (1) D

   // Qout( aGit[1][1] )
   // Qout( aGit[1][2] )
   Qout( "fecha ultimo commit ", aGit[1][3] )
   // Qout( aGit[1][4] )
   // Qout( aGit[1][5] )  //   Qout( ValType( aGit[1][3] ) )

   // crear array aToCommit de archivos a commit desde el archivo git-2.lst
   // crear array aToIgnore de archivos a NO commit desde el archivo git-2.lst
   // son arrays unidimensionales con mascaras de [paths] + archivos (mascaras). ej: {"..\samples\*.prg","*.c"}
   IF hb_FileExists( _LIST_OF_FILES_ )

      Qout( "cargando mascaras de archivos para el commit desde ", _LIST_OF_FILES_ )

      oFile := TFileRead():new( _LIST_OF_FILES_ )
      oFile:Open()

      IF oFile:Error()
         ? oFile:ErrorMsg( "FileRead:" )
      ELSE
         DO WHILE oFile:MoreToRead()
            cLine := oFile:ReadLine()
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
            IF cLine == "@ tocommit"
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
         oFile:Close()

      ENDIF

   ELSE
      Qout( "archivo", _LIST_OF_FILES_, "con mascaras para el commit no fue encontrado" )
      hb_MemoWrit( _LIST_OF_FILES_, e"# @ marca una tabla. nombre tabla siempre en minusculas.\n# la lista debe estar continuada, sin lineas en blanco\n# una linea en blanco indica fin de la tabla @ tocommit\n\n@ tocommit\n..\samples\*.prg\n\n@ ignore\n*.cfg\n" )
      Qout( "archivo", _LIST_OF_FILES_, "fue creado" )

   ENDIF


   // parse each file
   FOR EACH cMask IN aToCommit

      cPath := Vias( cMask, 12 )

      // IF var1:__enumindex == nVal
      //    doSomething()
      // ENDIF

      aFiles := hb_directory( cMask )

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
      //              1) (C) (6) config
      //              2) (N) (3) 299
      //              3) (T) 2018-04-09 13:12:47.453
      //              4) (C) (8) 15:30:39
      //              5) (C) (1) A

      FOR EACH aEachFile IN aFiles

         // IF var1:__enumindex == nVal
         //    doSomething()
         // ENDIF

         IF aEachFile[3] > aGit[1][3]
            IF hb_Ascan( aToIgnore, Lower( cPath + aEachFile[1] )  ) > 0
               Qout( "- ignored by list ", Lower( cPath + aEachFile[1] ) )
               LOOP
            ENDIF

            SearchChangelogInFile( cPath + aEachFile[1] )

         ENDIF

      NEXT

   NEXT

   RETURN .T.

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

   LOCAL cxLineaRet := "", cTipoParam
   LOCAL aData, nLen, n
   LOCAL i, nInd := 2
   LOCAL aKeys, aValues
   LOCAL cTipo
   LOCAL cRightParent := ")"
   LOCAL cIgual := " "

   // hb_Default( nIndX, 0 )
   IF hb_IsNIL( nIndX )
      nIndX := 0
   ENDIF

   nInd += nIndX
   cTipoParam := ValType( xVar )
   cTipo := "(" + cTipoParam + ") "

   SWITCH cTipoParam

      CASE "A"
         cxLineaRet += cTipo + "(" + hb_NtoS( Len( xVar ) ) + cRightParent
         FOR i := 1 TO Len( xVar )
            IF hb_IsArray( xVar[i ] )
               cxLineaRet += hb_Eol() + Space( nInd ) + Str( i, 6 ) + cRightParent + " "
               nInd += 3
               cxLineaRet += ShowValue( xVar[i ], nInd )
               nInd -= 3
            ELSE
               cxLineaRet += hb_Eol() + Space( nInd ) + Str( i, 6 ) + cRightParent + " "
               cxLineaRet += ShowValue( xVar[i ], nInd  )
            ENDIF
         NEXT
         EXIT

      CASE "C"
         cxLineaRet := cTipo + "(" + hb_NtoS( Len( xVar ) ) + cRightParent + cIgual + xVar
         EXIT

      CASE "M"
         cxLineaRet := cTipo + "(" + hb_NtoS( Len( xVar ) ) + cRightParent + cIgual + xVar
         EXIT

      CASE "N"
         cxLineaRet := cTipo + "(" + hb_NtoS( LenNum( xVar ) ) + cRightParent + cIgual + LTrim( hb_ValToStr( xVar ) )
         EXIT

      CASE "D"
         cxLineaRet := cTipo + hb_ValToStr( xVar ) + "    DToS() " + DToS( xVar ) + "    Format " + Set( 4 ) // + cRightParent
         EXIT

      CASE "L"
         cxLineaRet := cTipo + hb_ValToStr( xVar )
         EXIT

      CASE "O"
         // aData := __BCDobjGetValueList( xVar )
         // nLen  := Len( aData )
         // cxLineaRet += cTipo + "(" + hb_NtoS( nLen ) + cRightParent + hb_Eol() + Space( nInd ) + "ClassName= " + xVar:ClassName() + " :ClassH()=" + hb_NtoS( xVar:ClassH() ) + hb_Eol()
         // FOR n := 1 TO nLen
         //    cxLineaRet += Space( nInd + 3 ) + "Symbol " + hb_NtoS( n ) + cIgual + aData[ n ][ HB_OO_DATA_SYMBOL ] + hb_Eol()
         // NEXT
         EXIT

      CASE "B"
         cxLineaRet := "(B){||...}"
         EXIT

      CASE "P"
         cxLineaRet := cTipo + LTrim( hb_ValToStr( xVar ) ) + " hb_HexToNum()= " + LTrim( Str( hb_HexToNum( SubStr( hb_ValToStr( xVar ), 3 ) ) ) ) // + cRightParent
         EXIT

      CASE "H"
         IF Empty( xVar )
            cxLineaRet := cTipo + "(0)"
         ELSE
            cxLineaRet := cTipo + "(" + hb_NtoS( Len( xVar ) ) + cRightParent + hb_Eol()
            aKeys := hb_HKeys( xVar )
            aValues := hb_HValues( xVar )
            FOR i := 1 TO Len( aKeys )
               cxLineaRet += Space( nInd ) + Str( i, 6 ) + cRightParent + " " + hb_ValToExp( aKeys[ i ] ) + cIgual + ;
               iif( hb_IsHash( aValues[ i ] ), + "(H) " + hb_ValToExp( aValues[ i ] ), ShowValue( aValues[ i ], nInd ) ) + hb_Eol()
            NEXT
            cxLineaRet += cRightParent
         ENDIF
         EXIT

      CASE "T"
         cxLineaRet := cTipo + 't"' + hb_TSToStr( xVar, .T. ) + '"' // + cRightParent
         EXIT

      CASE "U"
         /// cxLineaRet := "(U) = Nil"
         cxLineaRet := "(U)(0) Nil"
         EXIT

      CASE "S"
         cxLineaRet := cTipo
         IF hb_IsString( xVar:name )
            cxLineaRet += "@" + xVar:name + "()"
         ELSE
            cxLineaRet += "@???()"
         ENDIF
         cxLineaRet += cRightParent
         EXIT

      CASE "UE"
         cxLineaRet := "(UE)"
         EXIT

      OTHERWISE
         cxLineaRet := "Value Type: " + cTipo + "No soportado"

   END SWITCH

   RETURN cxLineaRet

/*-----------------------------------*/

FUNCTION SearchChangelogInFile( cFile )

   LOCAL oFile, cLine
   LOCAL lAddToCommit := .F.
   LOCAL cInfoLog := ""
   LOCAL cPreviousLog := hb_MemoRead( _CHANGELOG_FILE_ )
   LOCAL cFileText := ""

   Qout( "Parsing ", cFile )

   IF hb_FileExists( cFile )

      oFile := TFileRead():new( cFile )
      oFile:Open()

      IF oFile:Error()
         ? oFile:errorMsg( "FileRead:" )
      ELSE
         DO WHILE oFile:moreToRead()
            cLine := oFile:readLine()

            // lines of change log in source file
            IF "changelog" $ Lower( cLine ) .AND. ;
                    "#if" + "defined(" + "changelog)" $ StrTran( Lower( cLine ), " ", "" ) // " + " = pa evitar auto eliminacion
               cInfoLog += "* " + cFile + hb_Eol()
               lAddToCommit := .T.
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
            Qqout( "  - Log not found in source code" )

         ENDIF

      ENDIF

   ENDIF

   RETURN .T.

/*-----------------------------------*/
