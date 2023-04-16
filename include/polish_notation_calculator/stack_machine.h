#pragma once

#include <iostream>
#include <sstream>
#include <vector>
#include <stack>
#include <unordered_map>
#include <algorithm>
#include <tl/expected.hpp>

#include <polish_notation_calculator/operation.h>
#include <polish_notation_calculator/error.h>

#include <polish_notation_calculator/config.h>

POLISH_NOTATION_CALCULATOR_BEGIN_NAMESPACE

struct stack_machine
{
    using operand_t = double;
    using operator_t = std::uint8_t;

public:
    tl::expected<operand_t, error> execute(const std::vector<std::string>& expression);

    DECL_OPERATION(add)
    DECL_OPERATION(sub)
    DECL_OPERATION(mul)
    DECL_OPERATION(div)

private:
    void reset();

private:
    std::stack<operand_t> m_stack{};
    bool m_faulted{false};

    const std::unordered_map<operator_t, void(*)(stack_machine&)> m_opers{
        OPERATION_ELEM('+', add),
        OPERATION_ELEM('-', sub),
        OPERATION_ELEM('x', mul),
        OPERATION_ELEM('*', mul),
        OPERATION_ELEM(':', div),
        OPERATION_ELEM('/', div)
    };
};

POLISH_NOTATION_CALCULATOR_END_NAMESPACE