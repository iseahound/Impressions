#include <TextRender>
#include <JSON>
FileDelete log.txt
Sleep 500 ; Prevents any half keypresses.

; Declare an instance of TextRender with saved styles.
tr := TextRender(, "y:83%", "s:72")

; Objects to keep track of keypresses.
best := []
best.stack := ""
best.modifiers := {LWin:0, RWin:0, LControl:0, RControl:0, LAlt:0, RAlt:0, LShift: 0, RShift:0}
best.pending := {Enter: False}

; From what I can tell, the settings specified below:
ih := InputHook("V L0")                            ; Eliminate the input buffer
ih.OnChar := Func("OnChar").bind(best, tr)         ; OnChar for all visibles
ih.OnKeyDown := Func("OnKeyDown").Bind(best, tr)   ; OnKeyDown / OnKeyUp are for non-visibles.
ih.OnKeyUp := Func("OnKeyUp").Bind(best, tr)       ; But there is some overlap.
ih.NotifyNonText := True
ih.KeyOpt("{Enter}", "+N")
ih.KeyOpt("{All}", "N")                            ; Allow all keys to be notified.
ih.Start()


; Called whenever a printable character is pressed.
OnChar(best, tr, ih, chr){
   Critical

   ; Pressing Enter when the stack is non-existant returns to OnKey.
   if (best.stack == "" && chr ~= "\n")
      return

   ; The following pushes consecutive lines of text onto the stack.
   if (best.stack != "" && chr ~= "\n") {
      tr.Clear()
      best.push(best.stack)
      best.stack := ""
      return
   }
   best.stack .= chr
   tr.Render(best.stack)
}

OnKeyDown(best, tr, ih, vk, sc) {
   Critical
   return OnKey("down", best, tr, ih, vk, sc)
}

OnKeyUp(best, tr, ih, vk, sc) {
   Critical
   return OnKey("up", best, tr, ih, vk, sc)
}

OnKey(state, best, tr, ih, vk, sc) {
   key := GetKeyName(Format("vk{:x}sc{:x}", VK, SC))
   up := "{" key " up}"
   down := "{" key " down}"
   current_key := "{" key " " state "}"


   edit_stack := True


   ; Check for any orphaned key up events and avoid appending them to the array.
   ; Fixes: orphaned {Enter up}.
   for key2, value in best.pending
      if (key == key2 and state == value) {
         best.pending[key2] := False
         return
      }

   ; Enter gives control to OnChar if the stack is non-empty.
   if (key == "Enter" and best.stack != "") {
      ; This removes an orphaned "{Enter up}".
      best.pending.enter := "up"
      return
   }

   ; Shift gives control to OnChar if the stack is non-empty.
   ; Fixes: orphaned {LShift down}.
   if (key ~= "Shift" and best.stack != "") {
      return
   }

/*
   for modifier, timestamp in best.modifiers
      if (key == modifier)
         if (state == "down" and timestamp == 0) {
            best.modifiers[modifier] := True
            return
         } else if (state == "up" and timestamp > 0) {

         }
*/

   ; Check for special exceptions.
   ; If Backspace, and a stack is available, delete the last character in the stack.
   if (key == "Backspace" and best.stack != "") {
      edit_stack := False
      if (state == "down") {
         best.stack := SubStr(best.stack, 1, -1)
      }
      tr.Render(best.stack)
      return
   }

   ; Modifier keys cannot be repeated.
   if (key ~= "Control|Alt|Shift")
      if (down == best[best.MaxIndex()])
         return


   ; Only when a non-text key is pressed is the stack appended and reset.
   if (best.stack != "") && (edit_stack == True)
      best.push(best.stack), best.stack := ""



   ; Check last key state and pop if possible.
   if (state == "up") && (best[best.MaxIndex()] == down)
   {
      ; Remove last down state.
      best.pop()
      best.push(key)
      tr.Render(key)
   }

   ; Save the current key state.
   else
      best.push(%state%)

   ;tr.Render(current_key)
}

Completion(s) {
   static key := "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"
   static ai := ""

   data := {prompt: s ? s : ai, max_tokens: 12, temperature: 0.2+0}
   body := JSON.Dump(data)
   req := ComObjCreate("WinHttp.WinHttpRequest.5.1")
   req.Open("POST", "https://api.openai.com/v1/engines/text-davinci-001/completions", true)
   req.SetRequestHeader("Content-Type", "application/json")
   req.SetRequestHeader("Authorization", "Bearer " key)
   req.Send(body)
   req.WaitForResponse()

   ai := JSON.Load(req.ResponseText).choices[1].text
   return s . ai
}

array_to_string(best) {
   s := ""
   for i, x in best {
      s .= x "`r`n"
   }
   return s
}

+`::   MsgBox % Completion(array_to_string(best))
+1::    MsgBox % array_to_string(best)
+2::    FileAppend % array_to_string(best), log.txt
+Esc:: Reload
Esc::  ExitApp

KeyWaitAny(Options:="")
{
    ih := InputHook("V")
    ;ih.KeyOpt("{All}", "E")  ; End
    ih.Start()
    ;ErrorLevel := ih.Wait()  ; Store EndReason in ErrorLevel
    ;return ih.EndKey  ; Return the key name
    return ih.input
}

ExitApp
