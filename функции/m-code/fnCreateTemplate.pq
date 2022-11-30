/* 
    Цель: создание шаблона таблицы согласно списку столбцовc
 */
(
     _parameter as record
) as table =>
    let
        columns = Record.Field(_parameter, "columns"),
        // columns_type = Record.Field(_parameter, "columns_type"),

        create_table = #table(columns, {})
        // ,
        // change_dtype = fnTransformColType(create_table, [columns = columns, columns_type = columns_type])
    in
        create_table
        
