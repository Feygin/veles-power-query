let
    source = #"параметр"{[параметр_key = "PrLvlDescriptionName"]}[значение],
    normalize = Text.Trim(Text.Clean(Text.Lower(source)))
in
    normalize