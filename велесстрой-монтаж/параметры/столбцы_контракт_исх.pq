let
    source = Excel.CurrentWorkbook(){[Name="столбцы_контракт_исх"]}[Content],
    change_dtype = Table.TransformColumnTypes(source,{{"исходные столбцы контракт", type text}}),
    filter_nulls = Table.SelectRows(change_dtype, each ([исходные столбцы контракт] <> null) and ([исходные столбцы контракт] <> "")),
    clean_text = Table.TransformColumns(filter_nulls,{{"исходные столбцы контракт", each Text.Trim(Text.Clean(Text.Lower(_))), type text}}),
    to_list = clean_text[исходные столбцы контракт]
in
    to_list