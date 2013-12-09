//IFF-1 Tautvydas Petkus
// L4b - Thrust
//Failo dydis - 50 eiluciu
//Dabartiniai nustatymai: giju sk: 5, maximalus masyvo dydis - 5, didziausias char buferio dydis - 70
//Kiek  iteracijø ið eilës padaro vienas procesas? viena pilnai
//Kokia tvarka vykdomi procesai? tokia, kokia startuoja
//

#include "cuda_runtime.h"
//#include "device_launch_parameters.h"

#include <cuda.h>
#include <stdio.h>
#include <iostream>	
#include <fstream>	
#include <sstream>	
#include <thrust/host_vector.h>
#include <thrust/device_vector.h>
//#include <thrust/sort.h>
//#include <thrust/sequence.h> 

using namespace std;

const int MAX_STRING_LEN = 50;
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

Data Plus(Data D1, Data D2, Data D3, Data D4, Data D5);
void addWithCuda(ThreadData *a);

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
	printf("%50s %10s %10s\n", "String", "int", "double");
	addWithCuda(duomenys_gijoms);
	printf("Press any key to continue...");
	fgetchar();
	return 0;
}

void addWithCuda(ThreadData *a)
{

	thrust::host_vector<Data> H1(5);
	H1[0] = a[0].thread_struct_array[0];
	H1[1] = a[0].thread_struct_array[1];
	H1[2] = a[0].thread_struct_array[2];
	H1[3] = a[0].thread_struct_array[3];
	H1[4] = a[0].thread_struct_array[4];
	thrust::device_vector<Data> D1 = H1;

	thrust::host_vector<Data> H2(5);
	H2[0] = a[1].thread_struct_array[0];
	H2[1] = a[1].thread_struct_array[1];
	H2[2] = a[1].thread_struct_array[2];
	H2[3] = a[1].thread_struct_array[3];
	H2[4] = a[1].thread_struct_array[4];
	thrust::device_vector<Data> D2 = H2;

	thrust::host_vector<Data> H3(5);
	H3[0] = a[2].thread_struct_array[0];
	H3[1] = a[2].thread_struct_array[1];
	H3[2] = a[2].thread_struct_array[2];
	H3[3] = a[2].thread_struct_array[3];
	H3[4] = a[2].thread_struct_array[4];
	thrust::device_vector<Data> D3 = H3;

	thrust::host_vector<Data> H4(5);
	H4[0] = a[3].thread_struct_array[0];
	H4[1] = a[3].thread_struct_array[1];
	H4[2] = a[3].thread_struct_array[2];
	H4[3] = a[3].thread_struct_array[3];
	H4[4] = a[3].thread_struct_array[4];
	thrust::device_vector<Data> D4 = H4;

	thrust::host_vector<Data> H5(5);
	H5[0] = a[4].thread_struct_array[0];
	H5[1] = a[4].thread_struct_array[1];
	H5[2] = a[4].thread_struct_array[2];
	H5[3] = a[4].thread_struct_array[3];
	H5[4] = a[4].thread_struct_array[4];
	thrust::device_vector<Data> D5 = H5;

	thrust::device_vector<Data> D(MAX_ARRAY_SIZE);
	for (int i = 0; i < 5; i++)
	{
		D[i] = Plus(D1[i], D2[i], D3[i], D4[i], D5[i]);
	}
	thrust::host_vector<Data> H = D;
	for (int i = 0; i < 5; i++)
	{
		printf("%50s %10d %10lf\n", H[i].text_var, H[i].int_var, H[i].double_var);
	}
}

Data Plus(Data D1, Data D2, Data D3, Data D4, Data D5)
{
	Data result;
	/*for (int i = 0; i < 10; i++)
	{
		result.text_var[i] = D1.text_var[i];
	}
	for (int i = 0; i < 10; i++)
	{
		result.text_var[i+10] = D2.text_var[i];
	}
	for (int i = 0; i < 10; i++)
	{
		result.text_var[i+20] = D3.text_var[i];
	}	for (int i = 0; i < 10; i++)
	{
		result.text_var[i+30] = D4.text_var[i];
	}
	for (int i = 0; i < 10; i++)
	{
		result.text_var[i+40] = D5.text_var[i];
	}*/
	strcpy(result.text_var, D1.text_var);
	strcat(result.text_var, D2.text_var);
	strcat(result.text_var, D3.text_var);
	strcat(result.text_var, D4.text_var);
	strcat(result.text_var, D5.text_var);
	/*strcpy(result.text_var, D2.text_var);
	strcpy(result.text_var, D3.text_var);
	strcpy(result.text_var, D4.text_var);
	strcpy(result.text_var, D5.text_var);*/
	result.int_var = D1.int_var + D2.int_var + D3.int_var + D4.int_var + D5.int_var;
	result.double_var = D1.double_var + D2.double_var + D3.double_var + D4.double_var + D5.double_var;
	return result;
}