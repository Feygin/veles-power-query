/* 
    Цель: unpivot части журнала содержащего данные по периодам
 */
(source, index_column)=>
let
    // [
        replace_errors = fnReplaceAllErrors(source),
        filter = Table.SelectRows(
            replace_errors, 
            each (Record.Field(_, index_column) <> null) and
                    (Record.Field(_, index_column) <> "")
        )
    // ]
in
    filter