(**
   OClosure Project - 2010
   Class goog.ui.MenuSeparatorRenderer
   
   @author : 
   @version 0.2
*)

open Js

class type menuSeparatorRenderer = object
  inherit ControlRenderer.controlRenderer

  method createDom : #Separator.separator t -> Dom_html.element t meth

  method decorate : #Separator.separator t -> Dom_html.element t -> Dom_html.element t meth

  method getCssClass : js_string t meth

  method setContent : Separator.separator t -> ControlContent.controlContent -> unit meth
end

let menuSeparatorRenderer : (menuSeparatorRenderer t) constr = 
  Js.Unsafe.variable "goog.ui.MenuSeparatorRenderer"
