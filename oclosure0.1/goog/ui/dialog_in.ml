(** 
    * OClosure Project - 2010
    * Class goog.ui.Dialog
    *
    * Class for showing simple dialog boxes. The Html structure of the dialog 
    * box is:
    * Element         Function                Class-name, modal-dialog = default
    * ----------------------------------------------------------------------------
    * - iframe         Iframe mask              modal-dialog-bg
    * - div            Background mask          modal-dialog-bg
    * - div            Dialog area              modal-dialog
    * - div        Title bar                modal-dialog-title
    * - span                             modal-dialog-title-text
    * - text  Title text               N/A
    * - span                             modal-dialog-title-close
    * - ??    Close box                N/A
    * - div        Content area             modal-dialog-content
    * - ??      User specified content   N/A
    * - div        Button area              modal-dialog-buttons
    * - button                           N/A
    * - button
    * - ...
    * 
    * @author Cardoso Gabriel
    * @author Bozman Cagdas
    * @version 0.1
    * @see 'goog.ui.Component'
*)
open Component
  
class external dialog inherit component: 
  < 
  (** Allows arbitrary HTML to be set in the content element. *)
  setContent : string -> unit; 
 
  (** Sets the title. *)
  setTitle : string -> unit;

  (** Sets the visibility of the dialog box and moves focus to the default button. 
   *  Lazily renders the component if needed. 
   *)
  setVisible : bool -> unit;
 > = "goog.ui.Dialog"
