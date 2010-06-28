(**
 * OClosure Project - 2010
 * Class goog.ui.CharPicker
 *
 * Character Picker Class. This widget can be used to pick any Unicode
 * character by traversing a category-subcategory structure or by inputing its
   hex value.
 *
 * @author : Oran Charles
 * @version 0.1
 * @see 'goog.ui.Component'
 *)
open Component
open CharPickerData

open Js
class type charPicker = object
  inherit component

  (** Gets the last selected character. **)
  method getSelectedChar : js_string t meth

 (** Gets the list of characters user selected recently. **) 
  method getRecentChars : js_string t js_array t meth

 (** @inheritDoc **)
  method createDom : unit meth

 (** @inheritDoc **)
  method disposeInternal : unit meth

 (** @inheritDoc **)
  method decorateInternal : Dom_html.element t -> unit meth

 (** @inheritDoc **)
  method enterDocument : unit meth

end

let charPicker : (charPickerData -> js_string t array -> float -> float -> charPicker t) constr =
  Js.Unsafe.variable "goog.ui.CharPickerData"
