let
    source = Excel.CurrentWorkbook(){[Name="hierarchyExisting"]}[Content],

    unfold = fnUnfoldHierarhy(source, 5, "ркц описание"),
    err = (try unfold)[Error]
in
    err