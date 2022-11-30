let
    source = #"параметр"{[параметр_key = "PrSheetName"]}[значение],
    normalize = Text.Trim(Text.Clean(Text.Lower(source)))
in
    normalize