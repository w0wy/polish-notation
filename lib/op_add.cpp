#include <polish_notation_calculator/stack_machine.h>

POLISH_NOTATION_CALCULATOR_BEGIN_NAMESPACE

void stack_machine::op_add(stack_machine& self)
{   
    if (self.m_stack.size() < 2)
    {
        std::cout << "Failed. There are less than 2 operands!";
    }

    const auto lhs = self.m_stack.top();
    self.m_stack.pop();
    const auto rhs = self.m_stack.top();
    self.m_stack.pop();

    const auto result = lhs + rhs;
    self.m_stack.push(result);
}

POLISH_NOTATION_CALCULATOR_END_NAMESPACE