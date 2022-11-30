let
    source = Excel.CurrentWorkbook(){[Name="fnFilterByTextConditionSource"]}[Content],
    test = 
        fnFilterByTextCondition(
            source,
            [
                filter = "row[filter] = ""filter"""
            ]
        )
in
    test