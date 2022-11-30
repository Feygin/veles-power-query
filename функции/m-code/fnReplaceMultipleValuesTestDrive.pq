let
    source = Excel.CurrentWorkbook(){[Name="fnReplaceMultipleValuesSource"]}[Content],
    test = 
        fnReplaceMultipleValues(
            source,
            [
                columns = {"colWithNulls", "anotherColWithNulls", "colWithNullsAndInvalids"},
                replacement = 
                    {
                        {"", "#не определен"},
                        {null, "#не определен"},
                        {"#REF!", "#не определен"},
                        {"#N/A", "#не определен"}
                    }
            ]
        )
in
    test