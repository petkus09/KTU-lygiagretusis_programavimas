//IFF-1 Tautvydas Petkus
// L4a - CUDA
//Failo dydis - 50 eiluciu
//Dabartiniai nustatymai: giju sk: 8, maximalus masyvo dydis - 10, didziausias char buferio dydis - 80
//Kiek  iteracijø ið eilës padaro vienas procesas? viena pilnai
//Kokia tvarka vykdomi procesai? tokia, kokia startuoja
//

#include "cuda_runtime.h"
#include "device_launch_parameters.h"

#include <cuda.h>
#include <stdio.h>
#include <iostream>	
#include <fstream>	
#include <sstream>	
#include <thrust/host_vector.h>
#include <thrust/device_vector.h>

using namespace std;

const int MAX_STRING_LEN = 16;
const int MAX_THREADS = 8;
const int MAX_FILE_ROW = 50;
const int MAX_ARRAY_SIZE = 10;

struct Data
{
	char text_var[MAX_STRING_LEN];
	int int_var;
	double double_var;
};

struct ThreadData{
	struct Data thread_struct_array[MAX_ARRAY_SIZE];
	int n;
};

cudaError_t addWithCuda(Data *c, ThreadData *a);

__global__ void addKernel(Data *c, ThreadData *a)
{
	int i = threadIdx.x;
	for (int j = 0; j < a[i].n; j++)
	{
		for (int k = 0; k < MAX_ARRAY_SIZE; k++)
		{
			bool check = true;
			for (int cc = 0; cc < MAX_STRING_LEN; cc++)
			{
				if (c[k].text_var[cc] != a[i].thread_struct_array[j].text_var[cc])
				{
					check = false;
				}
			}
			if (check)
			{
				c[k].int_var += a[i].thread_struct_array[j].int_var;
				c[k].double_var += a[i].thread_struct_array[j].double_var;
			}
		}
	}
}

int main()
{
	//pradiniu duomenu kintamieji
	int array_size[MAX_THREADS] = {5, 7, 6, 9, 4, 8, 4, 6};
	ifstream in("PetkusT.txt");
	struct Data duomenys[MAX_FILE_ROW];
	struct ThreadData duomenys_gijoms[MAX_THREADS];
	//Skaitomas duomenu failas
	for(string line; getline(in, line);){	
		for (int i = 0; i < MAX_FILE_ROW; i++)
		{
			getline(in, line);
			if (line != ""){
				stringstream ss;
				ss << line;
				Data eilute;
				char string_var[16];
				ss >> string_var >> eilute.int_var >> eilute.double_var;

				strcpy(eilute.text_var, string_var);
				duomenys[i] = eilute;
			}
		}
	}
	//pradiniu duomenu atspausdinimas
	int d = 0;
	int ii = 0;
	int j = 0;
	printf("********************************************************************\n");
	printf("***Pradiniai duomenys***\n");
	for (ii = 0; ii < MAX_THREADS; ii++){
		printf("***Gija nr. %d***\n", ii + 1);
		printf("%10s %10s %10s %10s\n", "Eil.Nr.", "String", "int", "double");
		struct Data D_gija[MAX_ARRAY_SIZE];
		for (j = 0; j < array_size[ii]; j++){
			D_gija[j] = duomenys[d];
			printf("%10d %10s %10d %10lf\n", j + 1, D_gija[j].text_var, D_gija[j].int_var, D_gija[j].double_var);
			d++;

		}
		for (j = 0; j < array_size[ii]; j++){
			duomenys_gijoms[ii].thread_struct_array[j] = D_gija[j];
			duomenys_gijoms[ii].n = array_size[ii];
		}
	}
	printf("\n**********************\n");
	//Lygiagrecioji dalis

	printf("***Lygiagrecioji programos dalis***\n");
	printf("%10s %10s %10s\n", "String", "int", "double");
	struct Data result_array[MAX_ARRAY_SIZE];
	for (int i = 0; i < MAX_ARRAY_SIZE; i++)
	{
		Data duom;
		strcpy(duom.text_var, "");
		duom.int_var = 0;
		duom.double_var = 0.0;
		result_array[i] = duom;
	}
	for (int i = 0; i < MAX_THREADS; i++)
	{
		for (int j = 0; j < duomenys_gijoms[i].n; j++)
		{
			for (int k = 0; k < MAX_ARRAY_SIZE; k++)
			{
				if (strcmp(result_array[k].text_var, "") == 0)
				{
					strcpy(result_array[k].text_var, duomenys_gijoms[i].thread_struct_array[j].text_var);
					break;
				}
				else if (strcmp(result_array[k].text_var, duomenys_gijoms[i].thread_struct_array[j].text_var) == 0)
				{
					break;
				}
			}
		}
	}
	
	// Add vectors in parallel.
	cudaError_t cudaStatus = addWithCuda(result_array, duomenys_gijoms);
	if (cudaStatus != cudaSuccess) {
		fprintf(stderr, "addWithCuda failed!");
		fgetchar();
		return 1;
	}
	for (int i = 0; i < MAX_ARRAY_SIZE; i++)
	{
		printf("%10s %10d %10lf\n", result_array[i].text_var, result_array[i].int_var, result_array[i].double_var);
		//printf(" %10d %10lf\n", result_array[i].int_var, result_array[i].double_var);
	}
	printf("Press any key to continue...");
	fgetchar();
	// cudaDeviceReset must be called before exiting in order for profiling and
	// tracing tools such as Nsight and Visual Profiler to show complete traces.
	cudaStatus = cudaDeviceReset();
	if (cudaStatus != cudaSuccess) {
		fprintf(stderr, "cudaDeviceReset failed!");
		return 1;
	}
	return 0;
}

// Helper function for using CUDA to add vectors in parallel.
cudaError_t addWithCuda(Data *c, ThreadData *a)
{
	ThreadData *dev_a = 0;
	Data *dev_c = 0;
	cudaError_t cudaStatus;

	// Choose which GPU to run on, change this on a multi-GPU system.
	cudaStatus = cudaSetDevice(0);
	if (cudaStatus != cudaSuccess) {
		fprintf(stderr, "cudaSetDevice failed!  Do you have a CUDA-capable GPU installed?");
		goto Error;
	}

	// Allocate GPU buffers for three vectors (two input, one output)
	cudaStatus = cudaMalloc((void**)&dev_c, MAX_ARRAY_SIZE *  sizeof(Data));
	if (cudaStatus != cudaSuccess) {
		fprintf(stderr, "cudaMalloc failed!");
		goto Error;
	}

	cudaStatus = cudaMalloc((void**)&dev_a, MAX_THREADS * sizeof(ThreadData));
	if (cudaStatus != cudaSuccess) {
		fprintf(stderr, "cudaMalloc failed!");
		goto Error;
	}

	//cudaStatus = cudaMalloc((void**)&dev_b, size * sizeof(int));
	//if (cudaStatus != cudaSuccess) {
	//    fprintf(stderr, "cudaMalloc failed!");
	//    goto Error;
	//}

	// Copy input vectors from host memory to GPU buffers.
	cudaStatus = cudaMemcpy(dev_a, a, MAX_THREADS * sizeof(ThreadData), cudaMemcpyHostToDevice);
	if (cudaStatus != cudaSuccess) {
		fprintf(stderr, "cudaMemcpy failed!");
		goto Error;
	}

	cudaStatus = cudaMemcpy(dev_c, c, MAX_ARRAY_SIZE *  sizeof(Data), cudaMemcpyHostToDevice);
	if (cudaStatus != cudaSuccess) {
		fprintf(stderr, "cudaMemcpy failed!");
		goto Error;
	}

	//cudaStatus = cudaMemcpy(dev_b, b, size * sizeof(int), cudaMemcpyHostToDevice);
	//if (cudaStatus != cudaSuccess) {
	//    fprintf(stderr, "cudaMemcpy failed!");
	//    goto Error;
	//}

	// Launch a kernel on the GPU with one thread for each element.
	addKernel<<<1, MAX_THREADS - 1>>>(dev_c, dev_a);

	// Check for any errors launching the kernel
	cudaStatus = cudaGetLastError();
	if (cudaStatus != cudaSuccess) {
		fprintf(stderr, "addKernel launch failed: %s\n", cudaGetErrorString(cudaStatus));
		goto Error;
	}

	// cudaDeviceSynchronize waits for the kernel to finish, and returns
	// any errors encountered during the launch.
	cudaStatus = cudaDeviceSynchronize();
	if (cudaStatus != cudaSuccess) {
		fprintf(stderr, "cudaDeviceSynchronize returned error code %d after launching addKernel!\n", cudaStatus);
		goto Error;
	}
	// Copy output vector from GPU buffer to host memory.
	cudaStatus = cudaMemcpy(c, dev_c,  MAX_ARRAY_SIZE * sizeof(Data), cudaMemcpyDeviceToHost);
	if (cudaStatus != cudaSuccess) {
		fprintf(stderr, "cudaMemcpy failed!");
		goto Error;
	}

Error:
	cudaFree(dev_c);
	cudaFree(dev_a);

	return cudaStatus;
}
