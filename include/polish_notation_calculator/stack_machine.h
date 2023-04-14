#pragma once

#include <iostream>
#include <charconv>
#include <sstream>
#include <vector>
#include <stack>
#include <unordered_map>
#include <algorithm>

#include <polish_notation_calculator/config.h>

POLISH_NOTATION_CALCULATOR_BEGIN_NAMESPACE

struct stack_machine
{
    std::int64_t execute(const std::string& calculation);

    static void op_add(stack_machine& self);
    static void op_sub(stack_machine& self);
    static void op_mul(stack_machine& self);
    static void op_div(stack_machine& self);

private:
    std::stack<std::int64_t> m_stack;

    const std::unordered_map<std::int64_t, void(*)(stack_machine&)> m_opers{
        {'+', &stack_machine::op_add},
        {'-', &stack_machine::op_sub},
        {'x', &stack_machine::op_mul},
        {':', &stack_machine::op_div}
    };
};

POLISH_NOTATION_CALCULATOR_END_NAMESPACE