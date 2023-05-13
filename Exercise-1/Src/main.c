#include <stdint.h>

extern void assembly_function();

int main(void)
{
	assembly_function();
	for(;;);
}
