
/* 
    Цель: Замена ошибок в заданных столбцах в таблице 
 */
    (source as table, _parameter)  =>
let
    columns = Record.Field(_parameter, "columns"),

    transformation = List.Transform(columns, each {_, null}),
    replace_errors = Table.ReplaceErrorValues(source, transformation)
in
    replace_errors