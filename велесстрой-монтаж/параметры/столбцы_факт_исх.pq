let
    source = Excel.CurrentWorkbook(){[Name="столбцы_факт_исх"]}[Content],
    change_dtype = Table.TransformColumnTypes(source,{{"исходные столбцы факт", type text}}),
    filter_nulls = Table.SelectRows(change_dtype, each ([исходные столбцы факт] <> null) and ([исходные столбцы факт] <> "")),
    clean_text = Table.TransformColumns(filter_nulls,{{"исходные столбцы факт", each Text.Trim(Text.Clean(Text.Lower(_))), type text}}),
    to_list = clean_text[исходные столбцы факт]
in
    to_list