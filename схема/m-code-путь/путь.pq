let
    Source = Excel.CurrentWorkbook(){[Name="путь"]}[Content],
    #"Changed Type" = Table.TransformColumnTypes(Source,{{"файл", type text}, {"путь", type text}})
in
    #"Changed Type"