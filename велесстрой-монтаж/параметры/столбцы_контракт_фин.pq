let
    source = Excel.CurrentWorkbook(){[Name="столбцы_контракт_фин"]}[Content],
    change_dtype = Table.TransformColumnTypes(source,{{"окончательное расположение контракт", type text}}),
    filter_nulls = Table.SelectRows(change_dtype, each ([окончательное расположение контракт] <> null) and ([окончательное расположение контракт] <> "")),
    clean_text = Table.TransformColumns(filter_nulls,{{"окончательное расположение контракт", each Text.Trim(Text.Clean(Text.Lower(_))), type text}}),
    to_list = clean_text[окончательное расположение контракт]
in
    to_list