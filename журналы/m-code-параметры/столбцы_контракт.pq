let
    source = Excel.CurrentWorkbook(){[Name="столбцы_контракт"]}[Content],
    change_dtype = Table.TransformColumnTypes(source,{{"расположение столбцов контракт", type text}}),
    filter_nulls = Table.SelectRows(change_dtype, each ([расположение столбцов контракт] <> null) and ([расположение столбцов контракт] <> "")),
    clean_text = Table.TransformColumns(filter_nulls,{{"расположение столбцов контракт", each Text.Trim(Text.Clean(Text.Lower(_))), type text}}),
    to_list = clean_text[расположение столбцов контракт]
in
    to_list