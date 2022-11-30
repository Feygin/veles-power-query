let
    Source = Excel.CurrentWorkbook(){[Name="параметр"]}[Content],
    norm_values = Table.TransformColumns(Source,{{"значение", each Text.Trim(Text.Lower(_)), type text}})
in
    norm_values