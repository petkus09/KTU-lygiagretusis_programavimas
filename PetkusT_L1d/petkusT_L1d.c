#include <cuda.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>

#define MAX_STRING_LEN 80
#define MAX_THREADS 8
#define MAX_FILE_ROW 50
#define MAX_ARRAY_SIZE 10

struct Data
{
   char text_var[MAX_STRING_LEN];
   int int_var;
   double double_var;
};

struct ThreadData{
    struct Data thread_struct_array[MAX_ARRAY_SIZE];
};

// Prototypes
__global__ void helloWorld(char*);
// Host function
int main(int argc, char** argv)
{
	int i;
	// desired output
	char str[] = "Hello World!";
	// mangle contents of output
	// the null character is left intact for simplicity
	for(i = 0; i < 12; i++)
		str[i] -= i;
	// allocate memory on the device
	char *d_str;
	size_t size = sizeof(str);
	cudaMalloc((void**)&d_str, size);
 

	// copy the string to the device
	cudaMemcpy(d_str, str, size, cudaMemcpyHostToDevice);
 
	// set the grid and block sizes
	dim3 dimGrid(1);   // one block per word
	dim3 dimBlock(MAX_THREADS); // one thread per character
 
	// invoke the kernel
	helloWorld<<< dimGrid, dimBlock >>>(d_str);
 
	// retrieve the results from the device
	cudaMemcpy(str, d_str, size, cudaMemcpyDeviceToHost);
 
	// free up the allocated memory on the device
	cudaFree(d_str);
 
	// everyone's favorite part
	printf("%s\n", str);
 
	return 0;
}
 
// Device kernel
__global__ void helloWorld(char* str)
{
	// determine where in the thread grid we are
	int idx = blockIdx.x * blockDim.x + threadIdx.x;
 
	// unmangle output
	str[idx] += idx;
}