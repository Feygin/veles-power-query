/* 
    Цель: Добавление системной строки к dimension описывающей отсутствующие данные
 */
(
    source as any,
    _parameter as record
)=>
let
    columns = Record.Field(_parameter, "columns"),
    columns_type = Record.Field(_parameter, "columns_type"),
    data = Record.Field(_parameter, "data"),

    system_row = Table.FromRows({data}, columns),
    change_dtype = fnTransformColType(system_row, [columns = columns, columns_type = columns_type]),
    combine_with_source = Table.Combine({source, change_dtype})
in
    combine_with_source