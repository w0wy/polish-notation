#include <iostream>

#include <polish_notation_calculator/stack_machine.h>

int main(int, char *[])
{
	while(true)
	{
		std::cout << "\nAdd your calculation:\n";
		auto calculation = std::string{};
		std::getline(std::cin, calculation);

		polish_notation_calculator::stack_machine sm;

		std::cout << "\nResult: " << sm.execute(calculation) << "\n";
	}

    return 0;
}
