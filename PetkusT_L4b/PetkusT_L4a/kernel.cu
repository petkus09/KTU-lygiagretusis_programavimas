//IFF-1 Tautvydas Petkus
// L4b - Thrust
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
#include <thrust/sort.h>
#include <thrust/sequence.h> 

using namespace std;

const int MAX_STRING_LEN = 70;
const int MAX_THREADS = 5;
const int MAX_FILE_ROW = 50;
const int MAX_ARRAY_SIZE = 5;

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

Data Plius(Data D1, Data D2, Data D3, Data D4, Data D5);
void addWithCuda(Data *c, ThreadData *a);

int main()
{
	//pradiniu duomenu kintamieji
	int array_size[MAX_THREADS] = {5, 5, 5, 5, 5};
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
	addWithCuda(result_array, duomenys_gijoms);
	for (int i = 0; i < MAX_ARRAY_SIZE; i++)
	{
		printf("%10s %10d %10lf\n", result_array[i].text_var, result_array[i].int_var, result_array[i].double_var);
	}
	printf("Press any key to continue...");
	fgetchar();
	cudaDeviceReset();
	return 0;
}

void addWithCuda(Data *c, ThreadData *a)
{
	//thrust::host_vector<ThreadData> H(MAX_ARRAY_SIZE);
	//thrust::host_vector<Data> CH(MAX_ARRAY_SIZE);
	//for (int i = 0; i < MAX_ARRAY_SIZE; i++)	{H[i] = a[i];}
	//for (int i = 0; i < MAX_ARRAY_SIZE; i++)		{CH[i] = c[i];}
	//thrust::device_vector<Data> D = H;
	//thrust::device_vector<ThreadData> CD;
	thrust::host_vector<Data> H1(5);
	for (int i = 0; i < 5; i++)	{H1[i] = a[0].thread_struct_array[i];}
	thrust::host_vector<Data> H2(5);
	for (int i = 0; i < 5; i++)	{H2[i] = a[1].thread_struct_array[i];}
	thrust::host_vector<Data> H3(5);
	for (int i = 0; i < 5; i++)	{H3[i] = a[2].thread_struct_array[i];}
	thrust::host_vector<Data> H4(5);
	for (int i = 0; i < 5; i++)	{H4[i] = a[3].thread_struct_array[i];}
	thrust::host_vector<Data> H5(5);
	for (int i = 0; i < 5; i++)	{H5[i] = a[4].thread_struct_array[i];}

	printf("%10s\n", H1.size());
	/*thrust::device_vector<Data> D1 = H1;
	thrust::device_vector<Data> D2 = H2;
	thrust::device_vector<Data> D3 = H3;
	thrust::device_vector<Data> D4 = H4;
	thrust::device_vector<Data> D5 = H5;
	thrust::device_vector<Data> D(MAX_ARRAY_SIZE);
	for (int i = 0; i < MAX_ARRAY_SIZE; i++)
	{
		D[i] = Plius(D1[i], D2[i], D3[i], D4[i], D5[i]);
	}
	thrust::host_vector<Data> H = D;*/
}

Data Plius(Data D1, Data D2, Data D3, Data D4, Data D5)
{
	Data result;
	strcpy(result.text_var, D1.text_var);
	strcpy(result.text_var, D2.text_var);
	strcpy(result.text_var, D3.text_var);
	strcpy(result.text_var, D4.text_var);
	strcpy(result.text_var, D5.text_var);
	result.int_var = D1.int_var + D2.int_var + D3.int_var + D4.int_var + D5.int_var;
	result.double_var = D1.double_var + D2.double_var + D3.double_var + D4.double_var + D5.double_var;
	return result;
}