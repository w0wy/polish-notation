#include <polish_notation_calculator/stack_machine.h>

POLISH_NOTATION_CALCULATOR_BEGIN_NAMESPACE

std::int64_t stack_machine::execute_oper(std::int64_t oper)
{
    if (const auto& it = m_opers.find(oper); it != m_opers.end())
    {
        it->second(*this);
    }
    
    const auto result = m_stack.top();
    m_stack.pop();
    
    return result;
}

std::int64_t stack_machine::execute(const std::string& calculation)
{
    std::stringstream ss(calculation);
    std::istream_iterator<std::string> begin(ss);
    std::istream_iterator<std::string> end;
    std::vector<std::string> vstrings(begin, end);
    //std::copy(vstrings.begin(), vstrings.end(), std::ostream_iterator<std::string>(std::cout, "\n"));

    std::int64_t result{0};
    std::for_each(vstrings.rbegin(), vstrings.rend(),
    [this, &result](const auto& elem)
    {
        std::int64_t integer;
        auto [ptr, ec] { std::from_chars(elem.data(), elem.data() + elem.size(), integer) };
        if (ec == std::errc())
        {
            m_stack.push(integer);
        }
        else if(elem.size() == 1)
        {
            result = execute_oper(static_cast<std::int64_t>(elem[0]));
            m_stack.push(result);
        }
        else
        {
            std::cout << "\nInvalid input!\n";
        }
    });
    
    return result;
}


POLISH_NOTATION_CALCULATOR_END_NAMESPACE