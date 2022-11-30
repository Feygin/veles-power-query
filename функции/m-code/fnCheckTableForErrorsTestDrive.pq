let
    source = Excel.CurrentWorkbook(){[Name="fnCheckTableForErrorsSource"]}[Content],
    change_type = Table.TransformColumnTypes(source,{{"col2", type number}}),
    invalid_pivot = //случай когда ошибка в поле Detail содержит Record а не текст
        let
            source = #table({"id", "attr", "val"},{{"a", "id", 10}}),
            pivot = Table.Pivot(source, {"id"}, "attr", "val")
        in
            pivot,
    add_invalid_pivot = Table.Combine( //добавляем ошибку содержащую Detail с Record к таблице которую будем проверять
        {
            change_type,
            #table({"folder_name", "file_name", "val1", "val2"}, {{"invalid_pivot", "invalid_pivot", invalid_pivot, null}})
        }
    ),
    test_only_index = fnCheckTableForErrors(add_invalid_pivot, []),
    test_with_context = fnCheckTableForErrors(add_invalid_pivot, [columns = {"folder_name", "file_name"}])
in
    test_with_context