let
    source = Excel.CurrentWorkbook(){[Name="fnAddCompositeKeySource"]}[Content],
    test = 
        fnAddCompositeKey(
            source,
            [
                columns = {"id1", "id2", "id3"},
                key_name = "key"
            ]
        )
in
    test