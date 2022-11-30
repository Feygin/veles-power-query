let
    source = Excel.CurrentWorkbook(){[Name="столбцы_факт"]}[Content],
    change_dtype = Table.TransformColumnTypes(source,{{"расположение столбцов факт", type text}}),
    filter_nulls = Table.SelectRows(change_dtype, each ([расположение столбцов факт] <> null) and ([расположение столбцов факт] <> "")),
    clean_text = Table.TransformColumns(filter_nulls,{{"расположение столбцов факт", each Text.Trim(Text.Clean(Text.Lower(_))), type text}}),
    to_list = clean_text[расположение столбцов факт]
in
    to_list