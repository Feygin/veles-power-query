let
    source_hierarchy = #"_типовые_иерархия",
    source_leading = #"_типовые_ведущие",

    //присоединяем ведущие позиции
    join = Table.NestedJoin(source_hierarchy, "типовые_key", source_leading, "типовые_key", "_joined", JoinKind.LeftOuter),
    expand_leading = Table.ExpandTableColumn(join, "_joined", {"типовые ур0 вед поз", "типовые ур1 вед поз", "типовые ур2 вед поз", "типовые ур3 вед поз", "типовые ур4 вед поз"})
in
    expand_leading