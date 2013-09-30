
#include "cuda_runtime.h"
#include "device_launch_parameters.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include <istream>
#include <iostream>
#include <fstream>
#include <sstream>

using namespace std;

const int MAX_STRING_LEN = 80;
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
};

cudaError_t addWithCuda(int *c, const int *a, const int *b, unsigned int size);

__global__ void addKernel(int *c, const int *a, const int *b)
{
    int i = threadIdx.x;
    c[i] = a[i] + b[i];
}

int main()
{
	//Nustatoma, kiek kiekviena gija tures masyvo elementu
    int array_size[MAX_THREADS] = {5, 7, 6, 9, 4, 8, 4, 6};
    struct Data duomenys[MAX_FILE_ROW];

    //Nuskaitomo failo paruosimas
    //char * line = NULL;
    //size_t len = 0;
    //ssize_t read;
    //FILE *ifp;
    //char *mode = "r";
    //ifp = fopen("PetkusT.txt", mode);
    //if (ifp == NULL) {
    //    fprintf(stderr, "Can't open input file in.list!\n");
     //   exit(1);
    //}
	ifstream fin("PetkusT.txt");
    char ch;
    while (fin.get(ch)){
	//string ch;
	//while( getline(fin, ch) ) {  
        printf("%s\n", ch);
	}
    fin.close();


    /*char A1[MAX_STRING_LEN];
    int A2;
    double A3;
    int n;
    int i = 0;
    read = getline(&line, &len, ifp);
    //Duomenu nuskaitymas i viena bendra masyva
    while ((read = getline(&line, &len, ifp)) != -1 && i < MAX_FILE_ROW) {
           n = sscanf(line,"%s %d %lf",A1,&A2,&A3);
           struct Data kintamasis = {.int_var = A2, .double_var = A3};
           strncpy(kintamasis.text_var, A1, MAX_STRING_LEN);
           duomenys[i] = kintamasis;
           i = i + 1;
       }*/

    //Duomenu priskyrimas giju masyvams. Pradiniu duomenu isvedimas
    /*int d = 0;
    int ii = 0;
    int j = 0;
    printf("********************************************************************\n");
    printf("***Pradiniai duomenys***\n");
    struct ThreadData duomenys_gijoms[MAX_THREADS];
    for (ii = 0; ii < MAX_THREADS; ii++){
        printf("***Gija nr. %d***\n", ii + 1);
        printf("%10s %10s %10s %10s\n", "Eil.Nr.", "String", "int", "double");
        struct Data D_gija[array_size[ii]];
        for (j = 0; j < array_size[ii]; j++){
            D_gija[j] = duomenys[d];
            printf("%10d %10s %10d %10lf\n", j + 1, D_gija[j].text_var, D_gija[j].int_var, D_gija[j].double_var);
            d++;

        }
        for (j = 0; j < array_size[ii]; j++){
            duomenys_gijoms[ii].thread_struct_array[j] = D_gija[j];
        }
    }
    printf("\n**********************\n");*/

    const int arraySize = 5;
    const int a[arraySize] = { 1, 2, 3, 4, 5 };
    const int b[arraySize] = { 10, 20, 30, 40, 50 };
    int c[arraySize] = { 0 };

    // Add vectors in parallel.
    cudaError_t cudaStatus = addWithCuda(c, a, b, arraySize);
    if (cudaStatus != cudaSuccess) {
        fprintf(stderr, "addWithCuda failed!");
        return 1;
    }

    printf("{1,2,3,4,5} + {10,20,30,40,50} = {%d,%d,%d,%d,%d}\n",
        c[0], c[1], c[2], c[3], c[4]);

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
cudaError_t addWithCuda(int *c, const int *a, const int *b, unsigned int size)
{
    int *dev_a = 0;
    int *dev_b = 0;
    int *dev_c = 0;
    cudaError_t cudaStatus;

    // Choose which GPU to run on, change this on a multi-GPU system.
    cudaStatus = cudaSetDevice(0);
    if (cudaStatus != cudaSuccess) {
        fprintf(stderr, "cudaSetDevice failed!  Do you have a CUDA-capable GPU installed?");
        goto Error;
    }

    // Allocate GPU buffers for three vectors (two input, one output)    .
    cudaStatus = cudaMalloc((void**)&dev_c, size * sizeof(int));
    if (cudaStatus != cudaSuccess) {
        fprintf(stderr, "cudaMalloc failed!");
        goto Error;
    }

    cudaStatus = cudaMalloc((void**)&dev_a, size * sizeof(int));
    if (cudaStatus != cudaSuccess) {
        fprintf(stderr, "cudaMalloc failed!");
        goto Error;
    }

    cudaStatus = cudaMalloc((void**)&dev_b, size * sizeof(int));
    if (cudaStatus != cudaSuccess) {
        fprintf(stderr, "cudaMalloc failed!");
        goto Error;
    }

    // Copy input vectors from host memory to GPU buffers.
    cudaStatus = cudaMemcpy(dev_a, a, size * sizeof(int), cudaMemcpyHostToDevice);
    if (cudaStatus != cudaSuccess) {
        fprintf(stderr, "cudaMemcpy failed!");
        goto Error;
    }

    cudaStatus = cudaMemcpy(dev_b, b, size * sizeof(int), cudaMemcpyHostToDevice);
    if (cudaStatus != cudaSuccess) {
        fprintf(stderr, "cudaMemcpy failed!");
        goto Error;
    }

    // Launch a kernel on the GPU with one thread for each element.
    addKernel<<<1, size>>>(dev_c, dev_a, dev_b);

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
    cudaStatus = cudaMemcpy(c, dev_c, size * sizeof(int), cudaMemcpyDeviceToHost);
    if (cudaStatus != cudaSuccess) {
        fprintf(stderr, "cudaMemcpy failed!");
        goto Error;
    }

Error:
    cudaFree(dev_c);
    cudaFree(dev_a);
    cudaFree(dev_b);
    
    return cudaStatus;
}
