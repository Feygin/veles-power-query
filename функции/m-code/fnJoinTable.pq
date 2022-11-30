/* 
    Цель: Join с автоматическим ExpandTableColumn
 */
(
    _parameter as record
)=>
let
    // [
    left_table = Record.Field(_parameter, "left_table"),
    left_table_key = Record.Field(_parameter, "left_table_key"),
    right_table = Record.Field(_parameter, "right_table"),
    right_table_key = Record.FieldOrDefault(_parameter, "right_table_key", left_table_key), //если не указан берем такой же как left_table_key
    join_columns = Record.Field(_parameter, "join_columns"),
    join_columns_new_names = Record.FieldOrDefault(_parameter, "join_columns_new_names", join_columns), //если не указан имя присоединяемых столбцов = имени исходных столбцов
    join_kind = Record.FieldOrDefault(_parameter, "join_kind", JoinKind.LeftOuter),

    JOIN_COLUMN_NAME = "__joined",

    join = 
        Table.NestedJoin(
            left_table, left_table_key,
            right_table, right_table_key,
            JOIN_COLUMN_NAME, 
            join_kind
        ),
    expand = 
        Table.ExpandTableColumn(
            join, JOIN_COLUMN_NAME,
            join_columns, join_columns_new_names
        )
    // ]
in
    expand