/* 
    Цель: извлечение метаданных из имени журнала
 */
 (log_name as text) as record =>
    [
        file_name = log_name, //имя файла

        split_file_name = Text.Split(file_name, "_"), //разделяем имя файла на блоки по разделителю "_"
        count_log_parts = List.Count(split_file_name),
        is_valid_template = (count_log_parts = 7), //кол-во разделов соответствует шаблону
        trim_splitted = 
            List.Transform(
                split_file_name,
                each Text.Trim(_)
            ),
        log_id = //номер журнала
            Text.Trim( 
                Text.AfterDelimiter(trim_splitted{0},"-") 
            ),
        subcontractor = trim_splitted{1},//имя подрядчика
        project_name = trim_splitted{2}, //проект
        area = trim_splitted{3}, //зона
        discipline = trim_splitted{4}, //дисциплина
        log_custom_id = trim_splitted{5}, //пользовательское поле
        log_date = //дата журнала
            Date.FromText(
                Text.BeforeDelimiter(
                    trim_splitted{6},".", {0, RelativePosition.FromEnd}
                )
            ),
        is_valid_date = not (try log_date)[HasError], //верная дата
        is_valid_log_name = (is_valid_template and is_valid_date) //журнал соответствует шаблону
    ]