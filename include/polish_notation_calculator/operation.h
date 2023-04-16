#pragma once

#define OPERATION_ELEM(sign, name)                      \
	{sign, &stack_machine::op_##name}

#define DECL_OPERATION(name)                            \
	static void op_##name(stack_machine& self);

#define IMPL_OPERATION(name, sign)                      \
    void stack_machine::op_##name(stack_machine& self)  \
    {                                                   \
        if (self.m_stack.size() < 2)                    \
        {                                               \
            self.m_faulted = true;                      \
            return;                                     \
        }                                               \
                                                        \
        const auto lhs = self.m_stack.top();            \
        self.m_stack.pop();                             \
        const auto rhs = self.m_stack.top();            \
        self.m_stack.pop();                             \
                                                        \
        const auto result = lhs sign rhs;               \
        self.m_stack.push(result);                      \
    }
