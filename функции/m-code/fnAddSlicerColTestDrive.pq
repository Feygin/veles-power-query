let
    source = Excel.CurrentWorkbook(){[Name="fnAddSlicerColSource"]}[Content],
    test = 
        fnAddSlicerCol(
            source,
            [
                columns = {"col1", "col2", "col3"}		
            ]
        )
in
    test