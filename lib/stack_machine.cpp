#include <polish_notation_calculator/stack_machine.h>

POLISH_NOTATION_CALCULATOR_BEGIN_NAMESPACE

std::int64_t stack_machine::execute(const std::string& calculation)
{
    std::stringstream ss(calculation);
    std::istream_iterator<std::string> begin(ss);
    std::istream_iterator<std::string> end;
    std::vector<std::string> vstrings(begin, end);

    std::int64_t result{0};
    std::for_each(vstrings.rbegin(), vstrings.rend(),
    [this, &result](const auto& elem)
    {
    	if (elem.size() == 1)
    	{
	    	if(const auto& it = m_opers.find(static_cast<std::int64_t>(elem[0])); it != m_opers.end())
	    	{
	    		it->second(*this);
	    		result = m_stack.top();
	    		return;
	    	}
	    }

        std::int64_t integer;
        auto [ptr, ec] { std::from_chars(elem.data(), elem.data() + elem.size(), integer) };
        if (ec == std::errc())
        {
            m_stack.push(integer);
        }
        else
        {
            std::cout << "\nInvalid input!\n";
        }
    });
    
    return result;
}


POLISH_NOTATION_CALCULATOR_END_NAMESPACE