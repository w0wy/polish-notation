#include <limits>
#include <iomanip>

#include <polish_notation_calculator/stack_machine.h>

POLISH_NOTATION_CALCULATOR_BEGIN_NAMESPACE

IMPL_OPERATION(add, +)
IMPL_OPERATION(sub, -)
IMPL_OPERATION(div, /)
IMPL_OPERATION(mul, *)

template<typename Numeric>
bool is_number(const std::string& s)
{
    Numeric n;

    if (s == ".")
        return false;

    return((std::istringstream(s) >> n >> std::ws).eof());
}

tl::expected<stack_machine::operand_t, error> stack_machine::execute(const std::vector<std::string>& expression)
{
    tl::expected<operand_t, error> result{0};

    auto it = expression.rbegin();
    for (; it != expression.rend(); ++it)
    {
        if (m_faulted == true)
        {
            reset();
            result = tl::make_unexpected(error{error_state::invalid_expression, ""});
            return result;
        }

        const auto& elem = *it;
        if (elem.size() == sizeof(operator_t))
        {
            if (const auto& op = m_opers.find(static_cast<operator_t>(elem[0])); op != m_opers.end())
            {
                op->second(*this);
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
            reset();
            result = tl::make_unexpected(error{error_state::invalid_character_input, elem});
            return result;
        }
    }

    if (m_stack.size() != 1)
    {
        reset();
        result = tl::make_unexpected(error{error_state::invalid_expression, ""});
    }
    else
    {
        result = m_stack.top();
        m_stack.pop();
    }

    return result;
}

void stack_machine::reset()
{
    m_faulted = false;
    m_stack = std::stack<operand_t>{};
}

POLISH_NOTATION_CALCULATOR_END_NAMESPACE