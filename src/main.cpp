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
	std::cout << "\nYou can use expressions \"quit\", \"exit\" or directly CTRL+C to exit!\n";

	signal(SIGINT, signal_handler);

	auto sm = polish_notation_calculator::stack_machine{};
	while(true)
	{
		std::cout << "\nAdd your expression:\n";
		auto expression = std::string{};
		std::getline(std::cin, expression);

		if (expression == "quit")
			signal_handler(1);

		std::stringstream ss(expression);
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
