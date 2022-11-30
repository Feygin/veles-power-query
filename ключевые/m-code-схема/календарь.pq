let
    source = fnGetTableFromFile(схема_путь, [kind = "Table", name = "календарь"]),
    #"Changed Type" = Table.TransformColumnTypes(source,{{"дата", type date}})
in
    #"Changed Type"