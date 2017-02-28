#include <stdio.h>
#include <mach/vm_page_size.h>


int main() {
	return printf("page-size: %ld mask: %lx shift: %d\n",vm_kernel_page_size,vm_kernel_page_mask,vm_kernel_page_shift);
}
