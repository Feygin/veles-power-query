let
    source = Excel.CurrentWorkbook(){[Name="fnAddSortSource"]}[Content],
    test_sort = 
        fnAddSort(
            source,
            [
                columns = {"colWithoutNulls", "colWithNulls", "colWithNullsAtTheEnd"}		
            ]
        ),
    test_sort_with_custom_names = 
        fnAddSort(
            source,
            [
                columns = {"colWithoutNulls", "colWithNulls", "colWithNullsAtTheEnd"},
                sort_columns = {"sort1", "sort2", "sort3"}
            ]
        )
in
    test_sort_with_custom_names