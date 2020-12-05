# ighoo
[![GitHub license](https://img.shields.io/github/license/asistex/ighoo)](https://github.com/asistex/ighoo/blob/develop/LICENSE)
*IGHoo* is GUI lib written with harbour OOP syntax.

* GUI- Graphic User Interfase for harbour to create Microsoft Windows applications.
* `This is a work in progress and there are a lot things to do`.

 * Interfase gráfica harbour para crear aplicaciones en Microsoft Windows

Sample:

    #include "igh.ch"
    MEMVAR oWin

    PROCEDURE Main()
      LOCAL oMenu, oCmb1, oBtnRel, oStat, o7z
      PUBLIC oWin

      SET LANGUAGE TO SPANISH

      // win declaration
      oWin := window():new( , "oWin" )
      oWin:text := "test IGH"


      // main menu
      Define Menu oMenu
         PopUp "set"
            Item "visible"  Action oCmb1:visible( ! oCmb1:visible() )
         End PopUp
      End Menu oMenu Of oWin


      // statusbar
      oStat := statusBar():new( oWin, "oStat" )
      oStat:addItem( "item 1", 0, {|| MsgBox( "click 1" ) } )
      oStat:addItem( "item 2", 100, {|| MsgBox( "click 2" ) }, , "rc_ico", )


      // syntax 1- @ row, col
      @ 10, 20 label oLbl of oWin width 400 height 25 text "sample of IGH"


      // syntax 2-
      oCmb1 := comboBox():new( oWin, "oCmb1" )
      oCmb1:row             := 50
      oCmb1:col             := 30
      oCmb1:width           := 210
      oCmb1:minWidth        := 100
      oCmb1:height          := 180
      oCmb1:items           := { "aa", "bbb", "ccc" }
      oCmb1:onChange        := {|| showInfo( "Event oCmb1:onChange       " ) }
      oCmb1:OnClick         := {|| showInfo( "Event oCmb1:OnClick        " ) }
      oCmb1:OnEnter         := {|| showInfo( "Event oCmb1:OnEnter        " ) }
      oCmb1:onListDisplay   := {|| showInfo( "Event oCmb1:onListDisplay  " ) }
      oCmb1:onListClose     := {|| showInfo( "Event oCmb1:onListClose    " ) }
      oCmb1:onLostFocus     := {|| showInfo( "Event oCmb1:onLostFocus    " ) }
      oCmb1:onGotFocus      := {|| showInfo( "Event oCmb1:onGotFocus     " ) }
      oCmb1:backColor       := 16769984 // or {R,G,B}
      oCmb1:fontColor       := 255
      oCmb1:value           := 1
      oCmb1:tooltip         := "tooltip"


      //  syntax 3-  With Object
      WITH OBJECT o7z := T7Zip():new()
         :cArcName        := "ArcName"
         :aFiles          := { "*.txt", "*.doc" }
         :cPassword       := "123"
         :lShowProcessDlg := .T.
         :lRecursive      := .F.          /* .T. = include sub-dirs */
         :aExcludeFiles   := { "*.prg" }  /* prg files will not be archived */
      END


      oBtnRel := button():new( oWin, "oBtnRel" )
      oBtnRel:autoSizePos    := "left2right=120;top2bottom=40"
      oBtnRel:text           := "Close"
      oBtnRel:onClick        := {|| oWin:release() }


      oWin:center()
      oWin:activate()

      RETURN


**https://asistex.github.io/ighoo/**

**https://github.com/asistex**

***`Carlos.  Asistex`***


