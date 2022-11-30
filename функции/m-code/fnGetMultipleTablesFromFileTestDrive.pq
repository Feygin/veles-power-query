let
    test_extract_tables = 
        fnGetMultipleTablesFromFile(
            #"current_folder" & "fnGetTableFromFileTestDrive\fnGetTableFromFileSource.xlsx",
            [
                kind = "Table",
                names = {"sourceTable", "sourceTable2"},
                file = "TEST_FILENAME"
            ]
        ),
    test_missing_table = 
        fnGetMultipleTablesFromFile(
            #"current_folder" & "fnGetTableFromFileTestDrive\fnGetTableFromFileSource.xlsx",
            [
                kind = "Table",
                names = {"sourceTable", "sourceTable2", "thisTableDoesntExist"},
                file = "TEST_FILENAME"
            ]
        )
in
    test_missing_table