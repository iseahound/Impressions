; Impressions will automatically automate workflows.
; It's quite intelligent, but not perfect. 
; Say thanks if it's helpful!

#NoEnv
#NoTrayIcon
#SingleInstance force
#MaxHotkeysPerInterval 200
#InstallKeybdHook
#InstallMouseHook
Coordmode Mouse, Screen
DetectHiddenWindows On
ListLines Off
Process Priority,,High
SetWorkingDir %A_ScriptDir%
SetBatchLines -1


#include <Graphics>

TickCount := ""
str := ""
obj := {}
g := TextRenderI("Impressions-- by iseahound", "y:82% m:1vmin")


F10:: Reload
F9::   Replay(1,6)
+F9::  fold()
^+F9:: MsgBox % str
!F9::  KeyHistory


keyevent(key) {
   global str, obj
   global TickCount
   str .= key
   obj.push([key, A_TickCount - TickCount])
   TickCount := A_TickCount
   return Abduct_Induct(key)
}

mouseevent(key) {
   global str, obj
   global TickCount
   MouseGetPos, x, y, window, control
   str .= key
   obj.push([key, A_TickCount - TickCount, x, y])
   TickCount := A_TickCount
   return Abduct_Induct(key)
}

fold(){
   global str, obj
   for i, set in obj
      keys .= Format("{:-16}", set.1) A_Tab set.2 A_Tab set.3 A_Tab set.4 . "`r`n"
   MsgBox % keys
}

Abduct_Induct(key) {
   ; Don't trigger on key up events.
   if (key ~= "i)up")
      return

   if !(array := IsCriticalDisplay(key))
      return

   list := array.1
   step := array.2

   global str, obj

   i := list.pop()

   ; It starts at the first instance of a new key (:
   static void := ObjBindMethod({}, {})
   Hotkey, Space, % void, On
   h := TextRender("Press [Space] to repeat pattern!", "y:75% m:1vmin")
   KeyWait, Space, D T3
   if (ErrorLevel)
      return
   h.Blank()
   Hotkey, Space, % void, Off
   Replay(i+2, step-2)

   loop {
      Hotkey, Space, % void, On
      h.Render("Press [Space] to repeat pattern!", "y:75% m:1vmin c:pink")
      KeyWait, Space, D T3
      if (ErrorLevel)
         return
      h.Blank()
      Hotkey, Space, % void, Off
      Replay(i, step)
   }
}

IsCriticalDisplay(key) {
   global g
   (array := IsCritical(key)) ? g.Render("This sequence is critcal!") : "" ;g.Render("Waiting!")
   return array
}

IsCritical(key) {
   global str, obj

   ; Reverse the object order.
   rev := {}
   for i, set in obj
      rev.push(set)

   ; Extract a list of indexes that correspond to the key.
   list := []
   for i, set in rev
      if (key == set.1)
         list.push(i)

   ; Filter the indexes by checking for criticality.
   loop
   {
      step := A_Index

      ; Look at the second letter in the sequences beginning with 'key' from the list.
      buffer := {}
      for each, i in list {
         exist := false
         for j, tuple in buffer
            if (tuple.1 == rev[i+step].1)
               exist := true, tuple.2++
         if (exist == false)
            buffer.push([rev[i+step].1, 1])
      }

      ; Determine most frequent key. 
      max := 0
      _key := -1
      for j, tuple in buffer
         if (tuple.2 = max)
            _key := -1
         else if (tuple.2 > max)
            _key := tuple.1, max := tuple.2
      buffer := ""

      ; If there is no most frequent key the sequence is not critical.
      if (_key == -1)
         return
      
      ; Remove indexes that correspond to an uncommon key.
      for each, i in list
         if (_key != rev[i+step].1)
            list.delete(each)

      ; If the list contains one index or less the sequence is not critical. 
      if (list.count() < 2)
         return

      ; Determine the critical boundary.
      boundary := list.2 - list.1

      ; Ignore simple repeats.
      if (boundary < 6)
         return

      ; If the sequence overlaps itself it is critical.
      if (step == boundary) {
         for each, i in list
            i := obj.length() - i - steps + 2
         return [list, step]
      }
   }
}

Replay(i, step){
   global g
   global str, obj

   loop % step {
      set := obj[i + A_Index - 1]

      if (A_Index > 1)
         Sleep % set.2

      if !(set.3 == "" && set.4 == "") {
          g.Render("MouseMove to " set.3 ", " set.4)
          MouseMove set.3, set.4
      }
      g.Render(set.1)
      Send % set.1
   }
}

ReplayAll() {
   global g
   global str, obj
   for i, set in obj {
      Sleep % set.2
      if !(set.3 == "" && set.4 == "") {
          g.Render("MouseMove to " set.3 ", " set.4)
          MouseMove set.3, set.4
      }
      g.Render(set.1)
      Send % set.1
   }
}


; Tactics:
; qwerty
; abcdefg
; 12345
; same word


~LControl::    keyevent("{LControl Down}")
~LControl Up:: keyevent("{LControl Up}")
~RControl::    keyevent("{RControl Down}")
~RControl Up:: keyevent("{RControl Up}")
~LWin::        keyevent("{LWin Down}")
~LWin Up::     keyevent("{LWin Up}")
~RWin::        keyevent("{RWin Down}")
~RWin Up::     keyevent("{RWin Up}")
~LAlt::        keyevent("{LAlt Down}")
~LAlt Up::     keyevent("{LAlt Up}")
~RAlt::        keyevent("{RAlt Down}")
~RAlt Up::     keyevent("{RAlt Up}")
~LShift::      keyevent("{LShift Down}")
~LShift Up::   keyevent("{LShift Up}")
~RShift::      keyevent("{RShift Down}")
~RShift Up::   keyevent("{RShift Up}")

~LButton::     mouseevent("{LButton Down}")
~LButton Up::  mouseevent("{LButton Up}")
~MButton::     mouseevent("{MButton Down}")
~MButton Up::  mouseevent("{MButton Up}")
~RButton::     mouseevent("{RButton Down}")
~RButton Up::  mouseevent("{RButton Up}")
~WheelUp::     mouseevent("{WheelUp}")
~WheelDown::   mouseevent("{WheelDown}")
~WheelLeft::   mouseevent("{WheelLeft}")
~WheelRight::  mouseevent("{WheelRight}")

~*F1::      keyevent("{F1 Down}")
~*F1 Up::   keyevent("{F1 Up}")
~*F2::      keyevent("{F2 Down}")
~*F2 Up::   keyevent("{F2 Up}")
~*F3::      keyevent("{F3 Down}")
~*F3 Up::   keyevent("{F3 Up}")
~*F4::      keyevent("{F4 Down}")
~*F4 Up::   keyevent("{F4 Up}")
~*F5::      keyevent("{F5 Down}")
~*F5 Up::   keyevent("{F5 Up}")
~*F6::      keyevent("{F6 Down}")
~*F6 Up::   keyevent("{F6 Up}")
~*F7::      keyevent("{F7 Down}")
~*F7 Up::   keyevent("{F7 Up}")
~*F8::      keyevent("{F8 Down}")
~*F8 Up::   keyevent("{F8 Up}")

/*
~*F9::      keyevent("{F9 Down}")
~*F9 Up::   keyevent("{F9 Up}")
~*F10::     keyevent("{F10 Down}")
~*F10 Up::  keyevent("{F10 Up}")
~*F11::     keyevent("{F11 Down}")
~*F11 Up::  keyevent("{F11 Up}")
~*F12::     keyevent("{F12 Down}")
~*F12 Up::  keyevent("{F12 Up}")
~*F13::     keyevent("{F13 Down}")
~*F13 Up::  keyevent("{F13 Up}")
~*F14::     keyevent("{F14 Down}")
~*F14 Up::  keyevent("{F14 Up}")
~*F15::     keyevent("{F15 Down}")
~*F15 Up::  keyevent("{F15 Up}")
~*F16::     keyevent("{F16 Down}")
~*F16 Up::  keyevent("{F16 Up}")
~*F17::     keyevent("{F17 Down}")
~*F17 Up::  keyevent("{F17 Up}")
~*F18::     keyevent("{F18 Down}")
~*F18 Up::  keyevent("{F18 Up}")
~*F19::     keyevent("{F19 Down}")
~*F19 Up::  keyevent("{F19 Up}")
~*F20::     keyevent("{F20 Down}")
~*F20 Up::  keyevent("{F20 Up}")
~*F21::     keyevent("{F21 Down}")
~*F21 Up::  keyevent("{F21 Up}")
~*F22::     keyevent("{F22 Down}")
~*F22 Up::  keyevent("{F22 Up}")
~*F23::     keyevent("{F23 Down}")
~*F23 Up::  keyevent("{F23 Up}")
~*F24::     keyevent("{F24 Down}")
~*F24 Up::  keyevent("{F24 Up}")
*/

~*1::    keyevent("{1 Down}")
~*1 Up:: keyevent("{1 Up}")
~*2::    keyevent("{2 Down}")
~*2 Up:: keyevent("{2 Up}")
~*3::    keyevent("{3 Down}")
~*3 Up:: keyevent("{3 Up}")
~*4::    keyevent("{4 Down}")
~*4 Up:: keyevent("{4 Up}")
~*5::    keyevent("{5 Down}")
~*5 Up:: keyevent("{5 Up}")
~*6::    keyevent("{6 Down}")
~*6 Up:: keyevent("{6 Up}")
~*7::    keyevent("{7 Down}")
~*7 Up:: keyevent("{7 Up}")
~*8::    keyevent("{8 Down}")
~*8 Up:: keyevent("{8 Up}")
~*9::    keyevent("{9 Down}")
~*9 Up:: keyevent("{9 Up}")
~*0::    keyevent("{0 Down}")
~*0 Up:: keyevent("{0 Up}")

~*q::    keyevent("{q Down}")
~*q Up:: keyevent("{q Up}")
~*w::    keyevent("{w Down}")
~*w Up:: keyevent("{w Up}")
~*e::    keyevent("{e Down}")
~*e Up:: keyevent("{e Up}")
~*r::    keyevent("{r Down}")
~*r Up:: keyevent("{r Up}")
~*t::    keyevent("{t Down}")
~*t Up:: keyevent("{t Up}")
~*y::    keyevent("{y Down}")
~*y Up:: keyevent("{y Up}")
~*u::    keyevent("{u Down}")
~*u Up:: keyevent("{u Up}")
~*i::    keyevent("{i Down}")
~*i Up:: keyevent("{i Up}")
~*o::    keyevent("{o Down}")
~*o Up:: keyevent("{o Up}")
~*p::    keyevent("{p Down}")
~*p Up:: keyevent("{p Up}")

~*a::    keyevent("{a Down}")
~*a Up:: keyevent("{a Up}")
~*s::    keyevent("{s Down}")
~*s Up:: keyevent("{s Up}")
~*d::    keyevent("{d Down}")
~*d Up:: keyevent("{d Up}")
~*f::    keyevent("{f Down}")
~*f Up:: keyevent("{f Up}")
~*g::    keyevent("{g Down}")
~*g Up:: keyevent("{g Up}")
~*h::    keyevent("{h Down}")
~*h Up:: keyevent("{h Up}")
~*j::    keyevent("{j Down}")
~*j Up:: keyevent("{j Up}")
~*k::    keyevent("{k Down}")
~*k Up:: keyevent("{k Up}")
~*l::    keyevent("{l Down}")
~*l Up:: keyevent("{l Up}")

~*z::    keyevent("{z Down}")
~*z Up:: keyevent("{z Up}")
~*x::    keyevent("{x Down}")
~*x Up:: keyevent("{x Up}")
~*c::    keyevent("{c Down}")
~*c Up:: keyevent("{c Up}")
~*v::    keyevent("{v Down}")
~*v Up:: keyevent("{v Up}")
~*b::    keyevent("{b Down}")
~*b Up:: keyevent("{b Up}")
~*n::    keyevent("{n Down}")
~*n Up:: keyevent("{n Up}")
~*m::    keyevent("{m Down}")
~*m Up:: keyevent("{m Up}")
~*,::    keyevent("{, Down}")
~*, Up:: keyevent("{, Up}")
~*.::    keyevent("{. Down}")
~*. Up:: keyevent("{. Up}")
~*/::    keyevent("{/ Down}")
~*/ Up:: keyevent("{/ Up}")