let p = jsnew Goog.Ui.hsvaPalette(Js.null, Js.null, Js.null, Js.null)
let pSmall = jsnew Goog.Ui.hsvaPalette(Js.null, Js.null, Js.null,
				       Js.some (Js.string "goog-hsva-palette-sm"))
let _ =
  p##render(Js.null);
  pSmall##render(Js.null);
  
  Goog.Events.listen
    (Goog.Tools.Union.i1 p)
    Goog.Ui.Component.EventType._ACTION
    (fun () -> pSmall##setColorRgbaHex(p##getColorRgbaHex()))
    Js.null;
  Goog.Events.listen
    (Goog.Tools.Union.i1 pSmall)
    Goog.Ui.Component.EventType._ACTION
    (fun () -> p##setColorRgbaHex(pSmall##getColorRgbaHex()))
    Js.null;