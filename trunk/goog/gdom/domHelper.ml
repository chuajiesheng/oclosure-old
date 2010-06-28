(**
   OClosure Project - 2010
   Class goog.dom.DomHelper
   
   Create an instance of a DOM helper with a new document object. 
   
   @author Bozman Cagdas 
   @version 0.1
*)
open Js
open Tools

(** Node *) 
type node = Dom.node t

(** Document object*)
type document = Dom_html.document t

(** goog.math.Size *)
type size 

(** The window associated with the given document *)
type window = Dom_html.window t

class type domHelper = object
  (** Appends a child to a node *)
  method appendChild: node -> node -> unit meth
 
 (** Whether a node contains another node *)
  method contains: node -> node -> bool t meth
 
 (** Returns a dom node with a set of attributes. 
     This function accepts varargs for subsequent nodes to be added. 
     Subsequent nodes will be added to the first node as childNodes. *)
  method createDom: js_string Js.t -> js_string Js.t Js.opt -> js_string Js.t -> Dom_html.element t meth
 
 (**  Creates a new element *)
  method createElement : js_string Js.t -> Dom_html.element t meth
 
 (** Creates a new text node *)
  method createTextNode: js_string Js.t -> node meth

 (** Finds the first descendant node that matches the filter function.
     This does a depth first search. *)
  method findNode: node -> (node -> bool t) -> node meth
 
 (** Flattens an element. 
     That is, removes it and replace it with its children *)
  method flattenElement: Dom_html.element t -> Dom_html.element t meth
 
 (** Walks up the DOM hierarchy returning the first ancestor
     that passes the matcher function. *)
  method getAncestor: node -> (node -> bool t) -> bool t -> int opt -> node meth

 (** Walks up the DOM hierarchy returning the first ancestor 
     that has the passed tag name and/or class name. 
     If the passed element matches the specified criteria,
     the element itself is returned. *)
  method getAncestorByTagNameAndClass: node -> js_string Js.t -> js_string Js.t -> node meth
 
 (**  Returns the compatMode of the document *)
  method getCompatMode: js_string Js.t meth

 (** Returns the compatMode of the document *)
  method getDocument: document meth

 (** Calculates the height of the document *)
  method getDocumentHeight: int meth

 (** Gets the document scroll distance as a coordinate object **)
  method getDocumentScroll: Math.Coordinate.coordinate t meth

 (** Gets the document scroll element **)
  method getDocumentScrollElement: Dom_html.element t meth

 (** Gets the DomHelper object for the document where the element resides *)
  method getDomHelper: node -> domHelper meth
 
 (** Return the element with the given ID **)
  method getElement : (Dom_html.element t, js_string t) Union.t -> Dom_html.element t meth
 
 (** Looks up elements by both tag and class name, using browser native
     functions (querySelectorAll, getElementsByTagName or 
     getElementsByClassName) where possible. 
     The returned array is a live NodeList or a static list depending on
     the code path taken. *)
  method getElementByTagNameAndClass: js_string Js.t -> js_string Js.t -> Dom_html.element t -> number meth

 (** Returns the first child node that is an element *)
  method getFirstElementChild: node -> node meth

 (** Cross browser function for getting the document element of an iframe *)
  method getFrameContentDocument: Dom_html.element t -> Dom_html.element t meth

 (** Returns the last child node that is an element *)
  method getLastElementChild: node -> Dom_html.element t meth

 (** Returns the first next sibling that is an element *)
  method getNextElementSibling: node -> Dom_html.element t meth

 (** Returns the next node in source order from the given node **)
  method getNextNode: node -> node meth
 
 (** Returns the text length of the text contained in a node, without markup. 
     This is equivalent to the selection length if the node was selected,
     or the number of cursor movements to traverse the node.
     Images & BRs take one space.  New lines are ignored. *)
  method getNodeTextLength: node -> number meth

 (** Returns the text offset of a node relative to one of its ancestors.
     The text length is the same as the length calculated 
     by goog.dom.getNodeTextLength. *)
  method getNodeTextOffset: node -> node -> number meth

 (** Returns the owner document for a node. *)
  method getOwnerDocument: node -> Dom_html.element t meth
   
 (** Returns the first previous sibling that is an element **)
  method getPreviousElementSibling: node -> Dom_html.element t meth

 (** Returns the previous node in source order from the given node. *)
  method getPreviousNode: node -> Dom_html.element t meth

 (** Returns the text content of the current node, without markup 
     and invisible symbols.
     New lines are stripped and whitespace is collapsed,
     such that each character would be visible.
     In browsers that support it, innerText is used.
     Other browsers attempt to simulate it via node traversal.
     Line breaks are canonicalized in IE. *)
  method getTextContent: node -> js_string Js.t meth

 (** Gets the dimensions of the viewport. *)
  method getViewportSize: window -> size meth

 (** Gets the window object associated with the document. *)
  method getWindow: window meth
 
 (** Converts an HTML js_string Js.t into a document fragment. *)
  method htmlToDocumentFragment: js_string Js.t -> node meth

 (** Inserts a new node after an existing reference node
     (i.e., as the next sibling).
     If the reference node has no parent, then does nothing. *)
  method insertSiblingAfter: node -> node meth
 
 (** Inserts a new node before an existing reference node
     (i.e., as the next sibling).
     If the reference node has no parent, then does nothing. *)
  method insertSiblingBefore: node -> node meth

 (** Returns true if the browser is in "CSS1-compatible"
     (standards-compliant) mode, false otherwise. *)
  method isCss1CompatMode: bool t meth

 (** Whether the object looks like a DOM node. *)
  method isNodeLike: node -> bool t meth

 (** Removes all the child nodes on a DOM node. *)
  method removeChildren: node -> unit meth
 
 (** Removes a node from its parent. *)
  method removeNode: node -> node meth

 (** Replaces a node in the DOM tree. 
     Will do nothing if [oldNode] has no parent. *)
  method replaceNode: node -> node -> unit meth
 
 (** Sets the document object. *)
  method setDocument: document -> unit meth

 (** Sets a number of properties on a node. *)
  method setProperties: Dom_html.element t -> Dom_html.element t -> unit meth
 
 (** Cross browser function for setting the text content of an element. *)
  method setTextContent: Dom_html.element t -> js_string Js.t -> unit meth
end

let domHelper : domHelper Js.t constr = 
  Js.Unsafe.variable "goog.dom.DomHelper"
