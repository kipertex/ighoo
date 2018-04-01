# ighoo

*IGH* is GUI lib written in harbour OOP sintax

* Interfase grafica para harbour
* Graphic user interfase for harbour
* windows OS

Sample:

    #include "igh.ch"
    MEMVAR oWin

    PROCEDURE Main()
      LOCAL oMenu, oCmb1, oBtnRel, oStat
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
      oStat:addItem( "item 1", 0, {|| MsgBox( "click 1" ) }, , "iconowin", )
      oStat:addItem( "item 2", 100, {|| MsgBox( "click 2" ) }, , "rc_ico", )

      oCmb1 := comboBox():new( oWin, "oCmb1" )
      oCmb1:row             := 20
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
      oCmb1:backColor       := 16769984 // or {r,g,b]
      oCmb1:fontColor       := 255
      oCmb1:value           := 1
      oCmb1:tooltip         := "tooltip"

      oBtnRel := button():new( oWin, "oBtnRel" )
      oBtnRel:autoSizePos    := "left2right=120;top2bottom=40"
      oBtnRel:text           := "Close"
      oBtnRel:onClick        := {|| oWin:release() }

     oWin:center()
     oWin:activate()

     RETURN
