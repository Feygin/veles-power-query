let
    source = Excel.CurrentWorkbook(){[Name="fnAddSystemRowSource"]}[Content],
    change_dtype = Table.TransformColumnTypes(source, {{"id", Int64.Type}, {"description", Text.Type}, {"val", Int64.Type}}),
    columns = {"id", "description"},
    columns_type = {"Int64.Type", "Text.Type"},
    data = {9999, "#не определен"},

    test = fnAddSystemRow(change_dtype, [columns = columns, columns_type = columns_type, data = data])
in
    test