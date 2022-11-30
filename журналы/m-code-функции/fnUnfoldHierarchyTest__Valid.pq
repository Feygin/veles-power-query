let
    source = Excel.CurrentWorkbook(){[Name="hierarchy"]}[Content],
    source_with_esixting_hierarchy = Table.AddColumn(source, "ркц ур1", each ""),

    unfold_hierarchy = fnUnfoldHierarchy(source, 5, "индекс иерархия", "ркц описание")
in
    unfold_hierarchy