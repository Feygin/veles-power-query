let
    source = Excel.Workbook(File.Contents(#"current_folder" & "fnExpandTablesTestDrive\Workbook1.xlsx"), null, true),
    filter_tables = Table.SelectRows(source, each ([Kind] = "Table")),
    test = 
        fnExpandTables(
            filter_tables,
            [
                column = "Data"
            ]
        )
in
    test