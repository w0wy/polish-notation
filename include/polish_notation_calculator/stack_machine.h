#pragma once

#include <iostream>
#include <sstream>
#include <vector>
#include <stack>
#include <unordered_map>
#include <algorithm>
#include <tl/expected.hpp>

#include <polish_notation_calculator/config.h>

#include <polish_notation_calculator/error.h>

POLISH_NOTATION_CALCULATOR_BEGIN_NAMESPACE

struct stack_machine
{
    using operand_t = double;
    using operator_t = std::uint8_t;

public:
    tl::expected<operand_t, error> execute(const std::vector<std::string>& expression);

    static void op_add(stack_machine& self);
    static void op_sub(stack_machine& self);
    static void op_mul(stack_machine& self);
    static void op_div(stack_machine& self);

private:
    void reset();

private:
    std::stack<operand_t> m_stack{};
    bool m_faulted{false};

    const std::unordered_map<operator_t, void(*)(stack_machine&)> m_opers{
        {'+', &stack_machine::op_add},
        {'-', &stack_machine::op_sub},
        {'x', &stack_machine::op_mul},
        {'*', &stack_machine::op_mul},
        {':', &stack_machine::op_div},
        {'/', &stack_machine::op_div}
    };
};

POLISH_NOTATION_CALCULATOR_END_NAMESPACE