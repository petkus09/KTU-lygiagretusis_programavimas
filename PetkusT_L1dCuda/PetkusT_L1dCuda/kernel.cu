//IFF-1 Tautvydas Petkus
// L1d - CUDA
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

using namespace std;

const int MAX_STRING_LEN = 16;
const int MAX_THREADS = 8;
const int MAX_FILE_ROW = 50;
const int MAX_ARRAY_SIZE = 10;


#if defined(__CUDA_ARCH__) && (__CUDA_ARCH__ < 200)
  # error printf is only supported on devices of compute capability 2.0 and higher, please compile with -arch=sm_20 or higher    
#endif


//duomenis saugantis struct formatas
struct Data
{
   char text_var[MAX_STRING_LEN];
   int int_var;
   double double_var;
};

struct ThreadData{
    struct Data thread_struct_array[MAX_ARRAY_SIZE];
};

//gijos spausdinimo funkcija
__global__ void Thread_Print(ThreadData *duomenys_gijoms, int array_size[MAX_ARRAY_SIZE]){
	int gijosNr = threadIdx.x;
	int j = 0;
        for (j = 0; j < array_size[gijosNr]; j++){
            printf("%10s%d %10d %10s %10d %10lf\n","Procesas", gijosNr + 1, j + 1, duomenys_gijoms[gijosNr].thread_struct_array[j].text_var, duomenys_gijoms[gijosNr].thread_struct_array[j].int_var, duomenys_gijoms[gijosNr].thread_struct_array[j].double_var);
            int ii = 0;
            //funkcija, reikalinga pristabdyti giju veikima ir pastebeti maisos rezultatus
            //for (ii = 0; ii < 1000; ii++){
            //    double bandomasis = ii * ii * ii * ii * ii * ii * ii * ii;
            //}
        }
        printf("***Gija nr. %d baige darba \n", gijosNr + 1);
	
}
// Helper function for using CUDA to add vectors in parallel.
__global__ void addKernel(int *c, const int *a, const int *b, int *ind)
{
    int i = threadIdx.x;
	ind[i] = i;
    c[i] = a[i] + b[i];

	//cuPrintf("V alue: %d\n", i);

}

cudaError_t runAll(ThreadData *a, int *size){ //lygiagrecioji dalis
	ThreadData *dev_c = 0;
	int *i =0;
	cudaError_t cudaStatus;

	//perkeliame duomenis ið CPU á vaizdo plokðtæ
	cudaStatus = cudaMalloc((void**)&dev_c, MAX_THREADS * sizeof(ThreadData));
    if (cudaStatus != cudaSuccess) {
        fprintf(stderr, "cudaMalloc failed!");
        goto Error;
    }

	cudaStatus = cudaMemcpy(dev_c, a, MAX_THREADS * sizeof(ThreadData), cudaMemcpyHostToDevice);
    if (cudaStatus != cudaSuccess) {
        fprintf(stderr, "cudaMemcpy failed!");
        goto Error;
    }

	cudaStatus = cudaMalloc((void**)&i, MAX_ARRAY_SIZE * sizeof(int));
    if (cudaStatus != cudaSuccess) {
        fprintf(stderr, "cudaMalloc failed!");
        goto Error;
    }

	cudaStatus = cudaMemcpy(i, size, MAX_ARRAY_SIZE * sizeof(int), cudaMemcpyHostToDevice);
    if (cudaStatus != cudaSuccess) {
        fprintf(stderr, "cudaMemcpy failed!");
        goto Error;
    }

	//paleidþiame gijas
    Thread_Print<<<1, MAX_THREADS - 1>>>(dev_c, i);

	Error:
		cudaFree(dev_c);
		cudaFree(i);
	return cudaStatus;
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
        }
    }
    printf("\n**********************\n");
	//Lygiagrecioji dalis

	printf("***Lygiagrecioji programos dalis***\n");
    printf("%10s %10s %10s %10s %10s\n", "Gijos nr.", "Eil.Nr.", "String", "int", "double");
	runAll(duomenys_gijoms, array_size); //Vyksta CUDA spausdinimas
	return 0;
}

