/* 
    Цель: Добавление столбцов дублирующие столбцы из списка со словом "срез в конце", 
        необходимы для фильтрации в иерархии в PBI
 */
(
    source as table, _parameter as record
) as table =>
    let
        columns = Record.Field(_parameter, "columns"),

        columns_buffer = List.Buffer(columns),
        source_columns = 
            List.Buffer(
                Table.ColumnNames(source)
            ),
        fnAddSlicerCol =
            (seed, current)=>
                let
                    slicer_column_name = current & " срез",
                    add_slicer_column = Table.AddColumn(seed, slicer_column_name, each Record.Field(_, current))
                in
                    add_slicer_column,
        add_slicer_columns = List.Accumulate(columns_buffer, source, fnAddSlicerCol)
    in
        add_slicer_columns