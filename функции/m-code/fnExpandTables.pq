/*
    Цель: объединение таблиц у которых могут отличаться названия столбов
 */
 (
    source as table,
    _parameter as record
 )=>
let
    // [
    column = Record.Field(_parameter, "column"),

    union_columns = 
        List.Distinct(
            List.Buffer(
                List.Combine(
                    List.Transform(
                        Table.Column(source, column),
                        Table.ColumnNames
                    )
                )
            )
        ),
    expand_columns = Table.ExpandTableColumn(source, column, union_columns)
    // ]
in
    expand_columns