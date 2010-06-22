(**
   OClosure Project - 2010
   Class goog.async.ConditionalDelay
   
   @author : Cardoso Gabriel
   @version 0.2
*)

open Js

class type conditionalDelay = object
  inherit Disposable.disposable

  method isActive : unit -> bool t meth

  method isDone : unit -> bool t meth

(**
   Called when this delayed call is cancelled because the timeout has been
   exceeded, and the listener has never returned true.
   Designed for inheritance, should be overridden by subclasses or on the
   instances if they care.

   Do nothing by default
*)
  method onFailure : unit -> unit meth
   
(**
   Called when the listener has been successfully executed and returned
   true. The isDone method should return true by now.
   Designed for inheritance, should be overridden by subclasses or on the
   instances if they care.
*)
  method onSuccess : unit -> unit meth

(**
   Starts the delay timer. The provided listener function will be called
   repeatedly after the specified interval until the function returns
   {@code true} or the timeout is exceeded. Calling start on an active timer
   will stop the timer first.
   @param {number=} opt_interval The time interval between the function
   invocations (in milliseconds). Default is 0.
   @param {number=} opt_timeout The timeout interval (in milliseconds). Takes
   precedence over the {@code opt_interval}, i.e. if the timeout is less
   than the invocation interval, the function will be called when the
   timeout is exceeded. A negative value means no timeout. Default is 0.
*)
  method start : number t -> number t -> unit meth

(**
   Stops the delay timer if it is active. No action is taken if the timer is not
   in use.
*)

  method stop : unit -> unit meth  
end

let conditionalDelay : ((unit -> bool t) callback -> 'a t opt -> conditionalDelay t) constr = 
  Js.Unsafe.variable "goog.async.ConditionalDelay"
