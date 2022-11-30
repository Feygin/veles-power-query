let
    err = Number.From("ab"),
    test = fnExtractErrDescription((try err)[Error])
in
    test