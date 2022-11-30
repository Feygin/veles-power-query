let
    test_extract_table = 
        fnGetTableFromFile(
            #"current_folder" & "fnGetTableFromFileTestDrive\fnGetTableFromFileSource.xlsx",
            [
                kind = "Table",
                name = "sourceTable",
                file = "TEST_FILENAME"
            ]
        ),
    test_missing_table = 
        fnGetTableFromFile(
            #"current_folder" & "fnGetTableFromFileTestDrive\fnGetTableFromFileSource.xlsx",
            [
                kind = "Table",
                name = "thisTableDoesntExist",
                file = "TEST_FILENAME"
            ]
        ),
    test_missing_table_deafault_filename_error = 
        fnGetTableFromFile(
            #"current_folder" & "fnGetTableFromFileTestDrive\fnGetTableFromFileSource.xlsx",
            [
                kind = "Table",
                name = "thisTableDoesntExist"
            ]
        ),
    test_extract_sheet = 
        fnGetTableFromFile(
            #"current_folder" & "fnGetTableFromFileTestDrive\fnGetTableFromFileSource.xlsx",
            [
                kind = "Sheet",
                name = "sheetWithData",
                file = "TEST_FILENAME"
            ]
        ),
    test_extract_binary = 
        fnGetTableFromFile(
            File.Contents(#"current_folder" & "fnGetTableFromFileTestDrive\fnGetTableFromFileSource.xlsx"),
            [
                kind = "Table",
                name = "sourceTable",
                file = "TEST_FILENAME"
            ]
        ),
    test_extract_binary_deafault_filename_error = 
        fnGetTableFromFile(
            File.Contents(#"current_folder" & "fnGetTableFromFileTestDrive\fnGetTableFromFileSource.xlsx"),
            [
                kind = "Table",
                name = "thisTableDoesntExist"
            ]
        ),
    test_extract_google_sheet = 
        fnGetTableFromFile(
            "https://docs.google.com/spreadsheets/d/1U_YwOUA5DjgLEluTy1kzoL3yu2bG49Ejn8a98FZRw3Q/" & "export?format=xlsx",
            [
                kind = "Sheet",
                name = "sheetWithData",
                file = "TEST_FILENAME"
            ]
        )
in
    test_extract_google_sheet