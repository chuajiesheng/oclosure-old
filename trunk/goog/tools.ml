(**
   OClosure Project - 2010
   Tools module
   
   Provide some tools for the OClosure library
   
   @author : Cardoso Gabriel
   @version 0.2
*)
type element = Dom_html.element

(* used in goog/dom/dom.ml, goog/ui/zippy.ml, goog/ui/animatedZippy.ml *)
module Element_or_id = 
  struct 
    type t
    let element : element Js.t -> t = Obj.magic
    let id : Js.js_string Js.t -> t = Obj.magic
  end

(* used in goog/date/date.ml *)
module Int_or_string = 
  struct
    type t
    let int : int -> t = Obj.magic
    let string : Js.js_string Js.t -> t = Obj.magic 
  end

(* used in goog/ui/abstractSpellChecker.ml *)
module Regexp_or_string =
  struct
    type t
    let regexp : Js.regExp -> t = Obj.magic
    let string : Js.js_string Js.t -> t = Obj.magic
  end

(* used in goog/ui/abstractSpellChecker.ml *)
module Event_or_coord =
  struct
    type t
    let event : Events.BrowserEvent.browserEvent Js.t -> t = Obj.magic
    let coord : Math.Coordinate.coordinate Js.t -> t = Obj.magic
  end
    
type element_or_id
type int_or_string
type regexp_or_string
type event_or_coord

let elt : element Js.t -> element_or_id = Obj.magic

let id : Js.js_string Js.t -> element_or_id = Obj.magic

let int : int -> int_or_string = Obj.magic

let str : Js.js_string Js.t -> int_or_string = Obj.magic

let regexp : Js.regExp -> regexp_or_string = Obj.magic

let event : Events.BrowserEvent.browserEvent Js.t -> event_or_coord = Obj.magic