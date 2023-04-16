#pragma once

#include <polish_notation_calculator/config.h>

POLISH_NOTATION_CALCULATOR_BEGIN_NAMESPACE

enum class error_state
{
    no_error,
    invalid_character_input,
    invalid_expression
};

struct error
{
    error_state err;
    std::string msg;

    std::string to_string() const
    {
        switch(err)
        {
            case error_state::invalid_character_input:
                return "Invalid character input. " + msg;
            case error_state::invalid_expression:
                return "Invalid expression. " + msg;
            case error_state::no_error:
            default:
                return msg;
        }
    }
};

POLISH_NOTATION_CALCULATOR_END_NAMESPACE