let
    source = Excel.CurrentWorkbook(){[Name="unpivot__DupHeader"]}[Content],

    unpivot = fnUnpivot(source),
    err = (try unpivot)[Error]
in
    err