let
    source = fnGetTableFromFile(schema_path, [kind = "Table", name = "календарь"]),
    #"Changed Type" = Table.TransformColumnTypes(source,{{"дата", type date}})
in
    #"Changed Type"