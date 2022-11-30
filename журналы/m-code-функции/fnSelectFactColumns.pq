/* 
    Цель: выбор столбцов принадлежащих базе факт
*/
(source, normalized_header)=>
let
    // [
        filter_contract_cols = Table.SelectRows(normalized_header, each ([столбцы факт] = "v")),
        cols_to_select = filter_contract_cols[извлеченные столбцы],
        list_with_renames = Table.ToRows(
            filter_contract_cols[[извлеченные столбцы], [столбцы нормализованные]]
        ),
        
        select_cols = Table.SelectColumns(source, cols_to_select),
        rename_cols = Table.RenameColumns(select_cols, list_with_renames)
    // ]
in
    rename_cols