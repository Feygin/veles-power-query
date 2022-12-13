let
    source = Excel.CurrentWorkbook(){[Name="unpivot"]}[Content],

    unpivot = fnUnpivot(source)
in
    unpivot