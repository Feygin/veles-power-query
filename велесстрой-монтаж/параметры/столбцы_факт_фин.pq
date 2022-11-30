let
    source = Excel.CurrentWorkbook(){[Name="столбцы_факт_фин"]}[Content],
    change_dtype = Table.TransformColumnTypes(source,{{"окончательное расположение факт", type text}}),
    filter_nulls = Table.SelectRows(change_dtype, each ([окончательное расположение факт] <> null) and ([окончательное расположение факт] <> "")),
    clean_text = Table.TransformColumns(filter_nulls,{{"окончательное расположение факт", each Text.Trim(Text.Clean(Text.Lower(_))), type text}}),
    to_list = clean_text[окончательное расположение факт]
in
    to_list