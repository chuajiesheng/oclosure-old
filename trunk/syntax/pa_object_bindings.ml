open Camlp4

module Id : Sig.Id = struct
  let name = "O'Browser object bindings"
  let version = "0"
end

module Make (Syntax : Sig.Camlp4Syntax) = struct
  open Sig
  include Syntax
  let uid = let v = ref 0 in fun () -> incr v ; Printf.sprintf "u%x" !v

  let js_file = ref None
  let print_js s =
    match !js_file with
	None -> failwith "no JavaScript output specified"
      | Some f ->
	  output_string f (s ^ "\n")

  (* inject a value from ML to JS in ML *)
  let rec injector _loc = function
    | <:ctyp< int >> -> <:expr< JSOO.int >>
    | <:ctyp< string >> -> <:expr< JSOO.string >>
    | <:ctyp< unit >> -> <:expr< Obj.magic >>
    | <:ctyp< bool >> -> <:expr< JSOO.bool >>
    | <:ctyp< float >> -> <:expr< JSOO.float >>
    | <:ctyp< $_$ -> unit >> as t -> <:expr< fun (o : $t$) ->
	JSOO.call_function [| Obj.magic o |] (JSOO.eval ($str:js_extractor _loc
							   t$)) >>
      | <:ctyp< $_$ array >> as t -> <:expr< fun (o : $t$) ->
	  JSOO.call_function [| Obj.magic o |] (JSOO.eval ($str:js_extractor _loc
							   t$)) >>
    | _ -> <:expr<
	(fun o ->
	   let o = Obj.magic o in
	     if o == JSOO.null then
	       o
	     else
	       let jso = JSOO.get "__jso" o in
		 if jso == JSOO.undefined  then
		   o
		 else
		   jso) >>

  (* extract a value from JS to ML in ML *)
  and  extractor _loc = function
    | <:ctyp< string >> -> <:expr< JSOO.as_string >>
    | <:ctyp< int >> -> <:expr< JSOO.as_int >>
    | <:ctyp< unit >> -> <:expr< ignore >>
    | <:ctyp< bool >> -> <:expr< JSOO.as_bool >>
    | <:ctyp< float >> -> <:expr< JSOO.as_float >>
    | <:ctyp< $_$ array >> as t -> <:expr< fun o ->
	(Obj.magic
	   (JSOO.call_function [| Obj.magic o |] (JSOO.eval ($str:js_injector _loc t$))) : $t$) >>
    | _ -> <:expr<
	(fun o ->
	   let o = Obj.magic o in
	     if o == JSOO.undefined then o else
	       match JSOO.extract (JSOO.get "__caml" o) with
		 | JSOO.Nil ->
		     let wrapper = JSOO.get "__caml_wrapper" o in
		       if wrapper == JSOO.undefined then
			 Obj.magic o
		       else
			 let wrapper : '$lid:uid()$ -> '$lid:uid()$ = Obj.magic wrapper in
			 let wrapped = wrapper o in
			   JSOO.set "__caml" (Obj.magic wrapped) o ;
			   wrapped
		 | JSOO.Obj o -> Obj.magic o
		 | _ -> failwith "typeconv")
	>>

  (* inject a value from JS to ML in JS *)
  and js_injector _loc = function
    | <:ctyp< int >> -> "val_int"
    | <:ctyp< string >> -> "val_string"
    | <:ctyp< unit >> -> "(function(){return UNIT;})"
    | <:ctyp< bool >> -> "(function(o) { if(o) { return TRUE;} else { return FALSE;}}) "
    | <:ctyp< float >> -> "val_float"
    | <:ctyp< $t$ array >> ->
      "(function(o){var b = mk_block (o.length, 0);for(var
i=0;i<o.length;i++)b.set(i," ^ js_injector _loc t ^ "(o[i]));
console.debug (b); return b;})"
    | _ -> "(function (o) { if ((!o) || (!o.__caml_wrapper)) {return o; } ; if (!o.__caml) { o.__caml = running_vm.callback(o.__caml_wrapper, [o]); } ; return o.__caml; })"

  (* extract a value from ML to JS in JS *)
  and  js_extractor _loc = function
    | <:ctyp< string >> -> "string_val"
    | <:ctyp< int >> -> "int_val"
    | <:ctyp< unit >> -> "(function(){return UNIT;})"
    | <:ctyp< bool >> -> "mk_bool"
    | <:ctyp< float >> -> "float_val"
    | <:ctyp< $t$ array >> ->
      "(function(b){var o = new Array();for(var i=0;i<b.size;i++)o[i]="
      ^ js_extractor _loc t ^ "(b.get(i)); console.debug (o); return o;})"
    | _ -> "(function (o) { if (o && o.__jso) return o.__jso; return o; })"


  let make_method n t _loc =
    let argc = ref 0 in
    let rec mk_args t =
      match t with
	  <:ctyp< $t1$ -> $t2$ >> ->
		print_js ("  a[" ^ string_of_int !argc ^ "] = " ^ js_injector _loc t1 ^ "(arguments[" ^ string_of_int !argc ^ "]);");
		let a = incr argc ; Printf.sprintf "a%d" !argc in
		let v = injector _loc t1 in
		let e = mk_args t2 in
		  <:expr< fun $lid:a$ ->
			    let $lid:a$ = $v$ $lid:a$ in
			      $e$ >>
	| _ ->
	    print_js ("  var res = this.vm.callback_method(this.mlo, \"" ^ n ^ "\", a);");
	    print_js ("  return " ^ js_extractor _loc t ^ " (res);");
	    let c = extractor _loc t in
	    let rec l n =
	      if n = 0 then
		<:expr<>>
	      else
		let r = l (n - 1) in
		let n = Printf.sprintf "a%d" n in
		  Ast.ExSem (_loc, r, <:expr< $lid:n$ >>)
	    in
	    let l = l !argc in
    let nn = n ^ "_" in
	      <:expr< $c$ (JSOO.call_method $str:nn$ [| $l$ |] (JSOO.get "__jso" (Obj.magic self))) >>
    in
    let e = mk_args t in
      <:class_str_item< method $lid:n$ : $t$ = $e$ >>
	
    let make_methods _loc jsi jsmli m =
      print_js ("for (p in " ^ jsi ^ ".prototype) { " ^ jsmli ^ ".prototype[p] = " ^ jsi ^ ".prototype[p] ; }");
      let rec make = function
	| (n, t, _loc) :: l ->
	    print_js (jsmli ^ ".prototype." ^ n ^ "_ = " ^ jsi ^ ".prototype." ^ n);
	    print_js (jsmli ^ ".prototype." ^ n ^ " = function () {");
	    print_js ("  var a = [];");
	    let m = make_method n t _loc in
	      print_js ("}");
	      let l = make l in
		<:class_str_item< $m$ $l$ >>
	| [] ->
	    <:class_str_item< >>
      in make m

  let class_decl mli jsi pm inh _loc =
    let jsmlif = "__caml_make_" ^ mli in
    let jsmli = "__caml_" ^ mli in
    let tmli = "__" ^ mli in
    let mlif = "__" ^ mli ^ "_builder" in
      print_js ("function " ^ jsmli ^ "(mlo, vm, args) {");
      print_js ("  this.mlo = mlo;");
      print_js ("  this.vm = vm;");
      print_js ("  mlo.__jso = this;");
      print_js ("  " ^ jsi ^ ".apply (this, args);") ;
      print_js ("}") ;
      print_js ("function " ^ jsmlif ^ "(mlo, vm) {");
      print_js ("var args = []; for (var i = 2;i < arguments.length;i++) args[i - 2] = arguments[i];");
      print_js ("  return new " ^ jsmli ^ " (mlo, vm, args);");
      print_js ("}") ;
      print_js ("if (window.__caml_reg == undefined) __caml_reg = [];");
      print_js ("__caml_reg[\"" ^ mli ^ "\"] = " ^ jsmli ^ ";");
      print_js ("for (p in " ^ jsi ^ ".prototype) { " ^ jsmli ^ ".prototype[p] = " ^ jsi ^ ".prototype[p] ; }");
      (match inh with
	 | Some c ->
	     print_js ("for (p in __caml_reg[\"" ^ c ^ "\"].prototype) { " ^ jsmli ^ ".prototype[p] = __caml_reg[\"" ^ c ^ "\"].prototype[p] ; }");
	 | None -> ());
      let rec params = function
	  <:ctyp< $t1$ -> $t2$ >> -> (t1, _loc) :: params t2
	| _ -> []
      in
      let rec methods = function
	  <:ctyp< $t1$ -> $t2$ >> -> methods t2
	| <:ctyp< < $ms$ > >> ->
	  (let rec aux = function
	     | <:ctyp< $lid:i$ : $t$ ; $e$ >> -> (i, t, _loc) :: aux e
	     | <:ctyp< $lid:i$ : $t$ >> -> [(i, t, _loc)]
	     | <:ctyp< >> -> []
	     | _ -> failwith "bad class type"
	   in aux ms)
	| _ -> failwith "not a class type"
      in
      let p = params pm in
      let m = List.rev (methods pm) in
      let rec eargs ee n = function
	  _ :: l ->
	    let nn = Printf.sprintf "a%d" n in
	      eargs <:expr< $ee$ $lid:nn$ >> (n + 1) l
	| [] -> <:expr< $ee$ >>
      in
      let targs n p =
	let rec targs n = function
	    v :: l ->
	      let e = targs (n + 1) l in
		Ast.ExSem (_loc, <:expr< $v$ >>, e)
	  | [] -> <:expr< >>
	in let ta = targs n p in <:expr< [| $ta$ |] >>
      in
      let rec fargs ee n = function
	  _ :: l ->
	    let nn = Printf.sprintf "a%d" n in
	    let e = fargs ee (n + 1) l in
	      <:expr< fun $lid:nn$ -> $e$ >>
	      | [] -> <:expr< $ee$ >>
      in
      let rec pargs ee n = function
	  (typ, _) :: l ->
	    let nn = Printf.sprintf "a%d" n in
	    let e = pargs ee (n + 1) l in
	      <:class_expr< fun ($lid:nn$ : $typ$) -> $e$ >>
	      | [] -> <:class_expr< $ee$ >>
      in
      let transt l =
	let rec tt n = function
	  | [] -> []
	  | (e, _loc) :: l -> 
	      let nn = Printf.sprintf "a%d" n in
		<:expr< $injector _loc e$ $lid:nn$ >> :: tt (n + 1) l
	in tt 0 l
      in
      let m = make_methods _loc jsi jsmli m in
      let stub =
	match inh with
	  | None ->
	      <:class_expr< object (self)
		  $cst:m$
	      end >>
	  | Some c ->
	      <:class_expr< object (self)
		inherit $lid:"__" ^ c$
		  $cst:m$
	      end >>
      in
	<:str_item< 
	  let $lid:mlif$ o = $fargs <:expr<JSOO.call_function  $targs 0 (<:expr<Obj.magic o>> :: <:expr<JSOO.current_vm ()>> :: transt p)$ (JSOO.eval $str:jsmlif$)>> 0 (List.rev p)$
  ;;
  class $lid:tmli$ = $stub$ and $lid:mli$ = $pargs <:class_expr< object (self)
	    inherit $lid:tmli$
	    initializer 
	      ignore ($eargs <:expr<$lid:mlif$ (Obj.repr self)>> 0 p$)
	  end >> 0 p$  ;;
	  let _ =
	      JSOO.set "__caml_wrapper" (Obj.magic (fun o -> let co = Obj.magic (new $lid:tmli$) in JSOO.set "__jso" o co ; co)) (JSOO.get "prototype" (JSOO.eval $str:jsi$)) ;
	      JSOO.set "__caml_wrapper" (Obj.magic (fun o -> let co = Obj.magic (new $lid:tmli$) in JSOO.set "__jso" o co ; co)) (JSOO.get "prototype" (JSOO.eval $str:jsmli$))
	  ;; >>


  EXTEND Gram
	GLOBAL: str_item;
      str_item: [
	[ "class" ; "external" ; mli = a_LIDENT ; inh = inherit_opt ; ":" ; pm = ctyp ; jsi = jsi_opt ->
	  class_decl mli (match jsi with None -> mli | Some jsi -> jsi) pm inh _loc
	]
      ];
      jsi_opt: [
	[ "=" ; jsi = a_STRING -> Some jsi ]
      | [ [] -> None ]
      ];
      inherit_opt: [
	[ "inherit" ; i = a_LIDENT -> Some i ]
      | [ [] -> None ]
      ];
  END
    
  let _ = Camlp4.Options.add "-js" (Arg.String (fun s -> js_file := Some (open_out s))) "set JavaScript code output file name" ;;
end

let module M = Register.OCamlSyntaxExtension (Id) (Make) in ()
