#include <limits>

#include <polish_notation_calculator/stack_machine.h>

POLISH_NOTATION_CALCULATOR_BEGIN_NAMESPACE

template<typename Numeric>
bool is_number(const std::string& s)
{
    Numeric n;
    return((std::istringstream(s) >> n >> std::ws).eof());
}

tl::expected<stack_machine::operand_t, error> stack_machine::execute(const std::vector<std::string>& expression)
{
    tl::expected<operand_t, error> result{0};

    auto it = expression.rbegin();
    for (; it != expression.rend(); ++it)
    {
        const auto& elem = *it;
        if (elem.size() == sizeof(operator_t))
        {
            if (const auto& op = m_opers.find(static_cast<operator_t>(elem[0])); op != m_opers.end())
            {
                op->second(*this);
                result = m_stack.top();
                continue;
            }
        }

        if (is_number<operand_t>(elem))
        {
            operand_t oper{std::stod(elem)};
            m_stack.push(oper);
        }
        else
        {
            result = tl::make_unexpected(error{error_state::invalid_character_input, elem});
            return result;
        }
    }

    if (m_stack.size() != 1)
    {
        result = tl::make_unexpected(error{error_state::invalid_expression, ""});
    }

    return result;
}


POLISH_NOTATION_CALCULATOR_END_NAMESPACE