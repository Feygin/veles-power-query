(source)=>
    let
        // [
            reason = source[Reason],
            message = source[Message],
            detail = 
                if Value.Is(source[Detail], type record) then
                    Text.Combine({"Name: ", source[Detail][Name], ", Value: ", source[Detail][Value]})
                else source[Detail],
            
            result = Text.Combine({"Reason: ", reason, ", Message: ", message, ", Detail: ", detail})
        // ]
    in
        result