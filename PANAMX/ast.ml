(* Abstract Syntax Tree and functions for printing it *)

type op = Add | Sub | Mult | Div | Mod | Equal | Neq | Less | Leq | Greater | Geq |
          And | Or  | Mmul | Mdiv

type uop = Neg | Not | Inc | Dec

type typ = Int | Bool | String | Float | Void | Matrix | Struct of string

type bind = typ * string

type expr =
    Literal of int
  | Fliteral of string
  | BoolLit of bool
  | StrLit of string
  | Id of string
  | Binop of expr * op * expr
  | Unop of uop * expr
  | Assign of string * expr
  | Call of string * expr list
  | Noexpr
  | MatLit of expr list list
  | MatLitEmpty of expr * expr
  | MatIndex of string * expr * expr
  | MatAssign of string * expr * expr * expr
  | MatSlice of string * expr * expr * expr * expr
  | StructLit of string
  | Member of string * string
  | MemAssign of string * string * expr

type stmt =
    Block of stmt list
  | Expr of expr
  | Return of expr
  | If of expr * stmt * stmt
  | For of expr * expr * expr * stmt
  | While of expr * stmt

type func_decl = {
    typ : typ;
    fname : string;
    formals : bind list;
    locals : bind list;
    body : stmt list;
  }

type struct_decl = {
  sname : string;
  svar  : bind list;
}

type program = bind list * func_decl list * struct_decl list

(* Pretty-printing functions *)

let string_of_op = function
    Add -> "+"
  | Sub -> "-"
  | Mult -> "*"
  | Div -> "/"
  | Mod -> "%"
  | Equal -> "=="
  | Neq -> "!="
  | Less -> "<"
  | Leq -> "<="
  | Greater -> ">"
  | Geq -> ">="
  | And -> "&&"
  | Or -> "||"
  | Mmul -> ".*"
  | Mdiv -> "./"

let string_of_uop = function
    Neg -> "-"
  | Not -> "!"
  | Inc -> "++"
  | Dec -> "--"

let rec string_of_expr = function
    Literal(l) -> string_of_int l
  | Fliteral(l) -> l
  | BoolLit(true) -> "true"
  | BoolLit(false) -> "false"
  | StrLit(s) -> s
  | Id(s) -> s
  | Binop(e1, o, e2) ->
      string_of_expr e1 ^ " " ^ string_of_op o ^ " " ^ string_of_expr e2
  | Unop(o, e) -> string_of_uop o ^ string_of_expr e
  | Assign(v, e) -> v ^ " = " ^ string_of_expr e
  | Call(f, el) ->
      f ^ "(" ^ String.concat ", " (List.map string_of_expr el) ^ ")"
  | Noexpr -> ""
  | MatLit _ -> "matrix"
  | MatLitEmpty _ -> "matrix"
  | MatIndex (s, i, j) -> s ^ "[" ^ (string_of_expr i) ^ "][" ^ (string_of_expr j) ^ "]"
  | MatAssign (s, i, j, e) -> s ^ "[" ^ (string_of_expr i) ^ "][" ^ (string_of_expr j) ^ "]= " ^ (string_of_expr e)
  | MatSlice (s, i, j, k, l) -> s ^ "[" ^ (string_of_expr i) ^ ":" ^ (string_of_expr j) ^ "][" ^ 
    (string_of_expr k) ^ ":" ^ (string_of_expr l) ^ "]"
  | StructLit e -> "new struct " ^ e ^ " ()"
  | Member (s, e) -> s ^ "." ^ e
  | MemAssign (s, m, e) -> s ^ "." ^ m ^ " = " ^ (string_of_expr e)

let rec string_of_stmt = function
    Block(stmts) ->
      "{\n" ^ String.concat "" (List.map string_of_stmt stmts) ^ "}\n"
  | Expr(expr) -> string_of_expr expr ^ ";\n";
  | Return(expr) -> "return " ^ string_of_expr expr ^ ";\n";
  | If(e, s, Block([])) -> "if (" ^ string_of_expr e ^ ")\n" ^ string_of_stmt s
  | If(e, s1, s2) ->  "if (" ^ string_of_expr e ^ ")\n" ^
      string_of_stmt s1 ^ "else\n" ^ string_of_stmt s2
  | For(e1, e2, e3, s) ->
      "for (" ^ string_of_expr e1  ^ " ; " ^ string_of_expr e2 ^ " ; " ^
      string_of_expr e3  ^ ") " ^ string_of_stmt s
  | While(e, s) -> "while (" ^ string_of_expr e ^ ") " ^ string_of_stmt s

let string_of_typ = function
    Int -> "int"
  | Bool -> "bool"
  | String -> "string"
  | Float -> "float"
  | Void -> "void"
  | Matrix -> "matrix"
  | Struct e -> "struct " ^ e

let string_of_vdecl (t, id) = string_of_typ t ^ " " ^ id ^ ";\n"

let string_of_fdecl fdecl =
  string_of_typ fdecl.typ ^ " " ^
  fdecl.fname ^ "(" ^ String.concat ", " (List.map snd fdecl.formals) ^
  ")\n{\n" ^
  String.concat "" (List.map string_of_vdecl fdecl.locals) ^
  String.concat "" (List.map string_of_stmt fdecl.body) ^
  "}\n"

let string_of_program (vars, funcs, _) =
  String.concat "" (List.map string_of_vdecl vars) ^ "\n" ^
  String.concat "\n" (List.map string_of_fdecl funcs)
