let
    source = Table.FromColumns( {{"a".."g"}}, {"col1"}),
    test_default_column = fnAddRefreshDateTime(source),
    test_custom_column = fnAddRefreshDateTime(source, [column = "my column with datetime"])
in
    test_custom_column