/* 
    Цель: добавление полей с сортировкой; изменяет порядок строк в исходной таблице из-за Join
 */
 (
    source,
    _parameter as record
 )=>
    let
        // [
        columns = Record.Field(_parameter, "columns"),
        sort_columns = Record.FieldOrDefault(_parameter, "sort_columns", null), //названия новых столбцов с сортировкой
        
        generate_sort_column_names = if sort_columns = null then List.Transform(columns, each _ & "_sort") else sort_columns, //названия по умолчанию
        zip_columns = List.Zip({columns, generate_sort_column_names}),
        fnSortData = 
            (source, source_column, sort_column_name)=>
                let
                    data = Table.SelectColumns(source, source_column),
                    distict_data = Table.Distinct(data),
                    add_sort = Table.AddIndexColumn(distict_data, sort_column_name, 1)
                in
                    add_sort,
        fnSortColumnsFromZip = 
            (seed, current)=>
                let
                    source_column = current{0},
                    sort_column_name = current{1},
                    sort = fnSortData(source, source_column, sort_column_name),
                    add_sort_to_seed = seed & {sort}
                in
                    add_sort_to_seed,
        sort_columns_and_add_to_list = List.Accumulate(zip_columns, {}, fnSortColumnsFromZip),
        fnJoinSortToSource = 
            (seed,current)=> 
                let
                    join_column_name = List.First(Table.ColumnNames(current)),
                    join_table = Table.Join(seed, join_column_name, current, join_column_name)
                in
                    join_table,

        add_sort_to_source = List.Accumulate(sort_columns_and_add_to_list, source, fnJoinSortToSource)
        // ]
    in
        add_sort_to_source