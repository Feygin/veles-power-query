let
    source = Excel.CurrentWorkbook(){[Name="fnCreateRecordHierarchyTableSource"]}[Content],
    test_full_hierarhy = 
        fnCreateRecordHierarchyTable(
            source,
            [
                path = {"file", "table"},
                value = {"find", "replace"}
            ]
        ),
    full_hierarhy_data = 
        [
            lvl0 = test_full_hierarhy,
            lvl1 = lvl0[file_1],
            val = lvl1[table_a]
        ],
    full_hierarhy_data_missing_path = 
        [
            lvl0 = test_full_hierarhy,
            missing = lvl0[missing_file]
        ]
in
    full_hierarhy_data_missing_path