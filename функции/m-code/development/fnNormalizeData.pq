/* 
    Цель: массовой замены текста по полям заданным в схеме
    Параметры:
        Positional:
            source - таблица в которой производим замену
        Keyword:
            Required:
                normalization - таблица с заданной заменой
            Optional:
                columns - имя столбца или list (для режима "replace_column") в котором производим замену
                find_column_name 
                replace_column_name
                comparer - Comparer.OrdinalIgnoreCase / Comparer.Ordinal
                mode - "add_column" / "replace_column" / "replace_value"
                keep_missing - "keep" / "null"
                trim_source - "trim" / null
                new_column_name - имя нового столбца для режима add_column
 */
(source as any, _parameter as record) =>
	let
        // source = 
        //     #table(
        //         {"col1"},
        //         {
        //             {"A"}, 
        //             {"a"}, 
        //             {"a "},
        //             {null},
        //             {""},
        //             {"b"},
        //             {"c"}
        //         }
        //     ),
        // normalization = 
        //     #table(
        //         {"найти", "заменить"},
        //         {
        //             {"A", "neW value"}, 
        //             {"A", "neWx value"}, 
        //             {"c", "second new value"}
        //         }
        //     ),
        // columns = "col1",
        // find_column_name = "найти",
        // replace_column_name = "заменить",
        // comparer = Comparer.OrdinalIgnoreCase,
        // mode = "replace_column",
        // // mode = "add_column",
        // keep_missing = "keep",
        // // keep_missing = "null",
        // trim_source = "trim",
        // new_column_name = "normalized_column",

        normalization = Record.Field(_parameter, "normalization"),
        columns = Record.FieldOrDefault(_parameter, "columns", null),
        find_column_name = Record.FieldOrDefault(_parameter, "find_column_name", "найти"),
        replace_column_name = Record.FieldOrDefault(_parameter, "replace_column_name", "заменить"),
        comparer = Record.FieldOrDefault(_parameter, "comparer", Comparer.OrdinalIgnoreCase),
        mode = Record.FieldOrDefault(_parameter, "mode", "replace"),
        keep_missing = Record.FieldOrDefault(_parameter, "keep_missing", "keep"),
        trim_source = Record.FieldOrDefault(_parameter, "trim_source", "trim"),
        new_column_name = Record.FieldOrDefault(_parameter, "new_column_name", null),

        normalisation_buffer = 
            Table.Buffer(
                Table.Distinct(normalization, {find_column_name})
            ),
        fnTrimValue = (value)=> try Text.Trim(value) otherwise value,
        fnReplaceMatchingValues = 
            (value, normalization, comparer)=>
                let
                    value_to_list = {value},
                    list_with_replaces = Table.ToRows(normalization),
                    replace_val = List.ReplaceMatchingItems(value_to_list, list_with_replaces, comparer){0}
                in
                    replace_val,
        fnFindValueInNormalization =
            (value, normalization, find_column_name, comparer)=>
                let
                    find_column_values = Table.Column(normalization, find_column_name),
                    does_contain_value= List.Contains(find_column_values, value, comparer)
                in
                    does_contain_value,
        fnReplaceValue = 
            (value, normalization, find_column_name, trim, comparer, keep_missing)=>
                    let
                        trim_value = if trim = "trim" then fnTrimValue(value) else value,
                        does_contain_value = fnFindValueInNormalization(value, normalization, find_column_name, comparer),
                        replace_value = fnReplaceMatchingValues(value, normalization, comparer),
                        result = 
                            if keep_missing = "keep" or (keep_missing = "null" and does_contain_value) then 
                                replace_value
                            else if keep_missing = "null" then
                                null
                            else ...
                    in
                        result,
        fnAddReplacedValue =
            (normalization, columns, find_column_name, trim, comparer, keep_missing)=>
                    (row)=>
                        let
                            value = Record.Field(row, columns),
                            replace_val = fnReplaceValue(value, normalization, find_column_name, trim, comparer, keep_missing)
                        in
                            replace_val,
        table_add_column = 
            Table.AddColumn( 
                source, 
                new_column_name, 
                fnAddReplacedValue(normalisation_buffer, columns, find_column_name, trim_source, comparer, keep_missing)
            ),
        fnReplaceColumnValue =
            (normalization, find_column_name, trim, comparer, keep_missing)=>
                (v,o,n)=>
                    fnReplaceValue(v, normalisation_buffer, find_column_name, trim_source, comparer, keep_missing),
        table_replace_value = 
            let
                find_columns = if Value.Is(columns, type text) then {columns} else columns,
                replace_value = 
                    Table.ReplaceValue(
                        source, 
                        null,  
                        null, fnReplaceColumnValue(normalisation_buffer, find_column_name, trim_source, comparer, keep_missing), 
                        find_columns
                    )
            in
                replace_value,
        replace_value = 
            if Value.Is(source, type text) then
                fnReplaceValue(source, normalisation_buffer, find_column_name, trim_source, comparer, keep_missing)
            else error Error.Record("fnNormalizeData: не удается произвести замену для данного типа source"),
        replace_values = 
            if mode = "add_column" then table_add_column
            else if mode = "replace_column" then table_replace_value
            else if mode = "replace_value" then replace_value
            else ...,
        result = 
            if not ((Table.RowCount(normalization) = 1) and (Table.FirstValue(normalization) = null)) then 
                replace_values
            else source
    in
        result