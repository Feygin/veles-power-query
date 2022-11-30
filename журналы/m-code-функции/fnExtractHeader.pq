/* 
    Цель: извлечение шапки
 */
 (source as table) =>
    let
    // [
        HEADER_LENGTH = 4,
        NULL_COLUMN_COMBINED = "^^^",

        get_header = Table.FirstN(source, HEADER_LENGTH),
        transpose = Table.Transpose(get_header),
        rename_columns = 
            Table.RenameColumns(
                transpose,
                {
                    {"Column1", "тип заголовка"},
                    {"Column2", "имя заголовка"},
                    {"Column3", "дата"},
                    {"Column4", "идентификатор"}
                }
            ),
        dtype_to_date = Table.TransformColumnTypes( //для последующего преобразования в text
                rename_columns, //без time части из datetime
                {
                    {"дата", type date}
                }
            ),
        dtype_to_text = 
            Table.TransformColumnTypes(
                dtype_to_date,
                {
                    {"тип заголовка", type text},
                    {"имя заголовка", type text},
                    {"дата", type text},
                    {"идентификатор", type text}
                }
            ),
        fnNormalizeText = (val)=> Text.Trim(Text.Clean(Text.Lower(val))),
        normalize_text = 
            Table.TransformColumns(
                dtype_to_text,
                {
                    {"тип заголовка", fnNormalizeText, type text},
                    {"имя заголовка", fnNormalizeText, type text},
                    {"идентификатор", fnNormalizeText, type text}
                }
            ),
        combine_header = 
            Table.CombineColumns(
                normalize_text, 
                {
                    "тип заголовка",
                    "имя заголовка",
                    "дата",
                    "идентификатор"
                },
                Combiner.CombineTextByDelimiter("^"),
                "объединенный заголовок"
            ),
        transpose_back = Table.Transpose(combine_header),
        combine_source_with_header = Table.Combine({transpose_back, source}),
        promote = Table.PromoteHeaders(combine_source_with_header, [PromoteAllScalars = true]),
        remove_header_rows = Table.Skip(promote,4),
        columns_to_remove = 
            List.Select(
                List.Buffer(
                    Table.ColumnNames(remove_header_rows)
                ),
                each Text.StartsWith(_, NULL_COLUMN_COMBINED)
            ),
        remove_columns = Table.RemoveColumns(remove_header_rows, columns_to_remove)
    // ]
    in
        remove_columns