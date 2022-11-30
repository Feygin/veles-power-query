let
    source = Excel.CurrentWorkbook(){[Name="fnUnfoldParrentChildHierarchySource"]}[Content],
    change_dtype = Table.TransformColumnTypes(source,{{"child_id", type text}, {"parrent_id", type text}, {"child_description", type text}, {"parrent_description", type text}}),
    invoke_function = fnUnfoldParrentChildHierarchy(source, "parrent_id", "parrent_description", "child_id", "child_description")
in
    invoke_function