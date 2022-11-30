
/* 
    Цель: Замена всех ошибок во всех столбцах в таблице 
 */
    (source as table)  =>
let
    source_columns = Table.ColumnNames(source),
    transformation = List.Transform(source_columns, each {_, null}),
    replace_errors = Table.ReplaceErrorValues(source, transformation)
in
    replace_errors