#include <signal.h>
#include <iostream>

#include <polish_notation_calculator/stack_machine.h>

void signal_handler(int signum)
{
	std::cout << "\nExiting...\n";
   	exit(signum);
}

int main(int, char *[])
{
	signal(SIGINT, signal_handler);

	polish_notation_calculator::stack_machine sm;

	while(true)
	{
		std::cout << "\nAdd your calculation:\n";
		auto calculation = std::string{};
		std::getline(std::cin, calculation);

		std::stringstream ss(calculation);
    	std::istream_iterator<std::string> begin(ss);
    	std::istream_iterator<std::string> end;
    	std::vector<std::string> vstrings(begin, end);

		const auto result = sm.execute(vstrings);
		if (result)
		{
			std::cout << "\nResult: " << result.value() << "\n";	
		}
		else
		{
			const auto err = result.error();
			std::cout << "\nError: " << err.to_string() << "\n";
		}
	}

    return 0;
}
