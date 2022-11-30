let
    columns = {"col1", "col2", "col3", "col4"},
    // columns_type = {"Text.Type", "Date.Type", "Number.Type", "Any.Type"},

    // test = fnCreateTemplate([columns = columns, columns_type = columns_type])
    test = fnCreateTemplate([columns = columns])
in
    test