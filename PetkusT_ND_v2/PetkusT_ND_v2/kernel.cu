//IFF-1 Tautvydas Petkus
//L-ND - CUDA
//Failo dydis - 100x100 duomenø
//Dabartiniai nustatymai: stulpeliø skaièius - 100, eiluèiø skaièius - 100

#include "cuda_runtime.h"
#include "device_launch_parameters.h"

#include <time.h>
#include <stdlib.h>
#include <cuda.h>
#include <stdio.h>
#include <iostream>	
#include <fstream>	
#include <sstream>	
#include <thrust/host_vector.h>
#include <thrust/device_vector.h>
#include <time.h>

using namespace std;
const int MAX_ROW = 108;	   //MAX 108
const int MAX_COL = 330;	   //MAX 330
const int counter_hit = 100;

struct bool_data{
	bool data[MAX_COL];
};

void evolution(bool (*pop)[MAX_COL], int generation);
void print(bool (*pop)[MAX_COL], int generation);
bool generation_pass(bool (*pop)[MAX_COL], int i, int j);
bool generation_pass_paralell(bool_data *pop, int i, int j);
int check_neighbour(bool pop);

cudaError_t cudaEvolution(bool (*pop)[MAX_COL], int generation, char mode);

__device__ int check_neighbour_paralell(bool pop)
{
	if (pop)
	{
		return 1;
	}
	else
	{
		return 0;
	}
}

__device__ bool generation_pass_paralell(bool_data *pop, int i, int j)
{
	int counter = 0;
	if (i != 0) {counter += check_neighbour_paralell(pop[i-1].data[j]); }
	if (i != 0 && j != MAX_COL - 1) {counter += check_neighbour_paralell(pop[i-1].data[j + 1]); }
	if (j != MAX_COL - 1) {counter += check_neighbour_paralell(pop[i].data[j + 1]); }
	if (i != MAX_ROW - 1 && j != MAX_COL - 1) {counter += check_neighbour_paralell(pop[i + 1].data[j + 1]); }
	if (i != MAX_ROW - 1) {counter += check_neighbour_paralell(pop[i + 1].data[j]); }
	if (i != MAX_ROW - 1 && j != 0) {counter += check_neighbour_paralell(pop[i+1].data[j-1]); }
	if (j != 0) {counter += check_neighbour_paralell(pop[i].data[j-1]); }
	if (i != 0 && j != 0) {counter += check_neighbour_paralell(pop[i-1].data[j-1]); }
	if (pop[i].data[j])
	{
		if (counter < 2)
		{
			return false;
		}
		else if (counter > 3)
		{
			return false;
		}
		else
		{
			return true;
		}
	}
	else
	{
		if (counter == 3)
		{
			return true;
		}
	}
	return false;
}

__device__ void print_paralell(bool_data *pop)
{
	//system("cls");
	char row[MAX_ROW*MAX_COL+MAX_ROW];
	int offset = 0;
	for (int i = 0; i < MAX_ROW; i++)
	{
		for (int j = 0; j < MAX_COL; j++)
		{
			if (pop[i].data[j])
			{
				row[offset] = '0';
			}
			else{
				row[offset] = ' ';
			}
			offset += 1;
		}
		row[offset] = '\n';
		offset += 1;
	}
	//printf("%s\n", row);
}

__global__ void startEvolution(bool_data *p, bool_data *new_p){                 //1 iteracija
	int row = blockIdx.x;
	int col = threadIdx.x;
	new_p[row].data[col] = generation_pass_paralell(p, row, col);
}

__global__ void startEvolutionCHAOS(bool_data *p, bool_data *new_p){              //100 iteraciju
	int row = blockIdx.x;
	int col = threadIdx.x;
	for (int i = 0; i < 100; i++)
	{
		new_p[row].data[col] = generation_pass_paralell(p, row, col);
	}
}

int main()
{
	char ch;
	bool population[MAX_ROW][MAX_COL];
	printf("Press 1 for random generator, press 2 for file input...\n");
	ch = fgetchar();
	if (ch == '1')
	{
		srand(time(NULL));
		for (int i = 0; i < MAX_ROW; i++)
		{
			for (int j = 0; j < MAX_COL; j++)
			{
				if (rand() % 2)
				{
					population[i][j] = false;
				}
				else
				{
					population[i][j] = true;
				}
			}
		}
	}
	else if (ch == '2')
	{
		ifstream in("PetkusT.txt");
		for(string line; getline(in, line);){	
			for (int i = 0; i < MAX_ROW; i++)
			{
				getline(in, line);
				if (line != ""){
					stringstream ss;
					ss << line;
					int k = 0;
					for (int j = 0; j < MAX_COL; j++)
					{
						ss >> k;
						if (k == 1){
							population[i][j] = true;
						}
						else{
							population[i][j] = false;
						}
					}
				}
			}
		}
	}
	int generation = 0;
	print(population, generation);
	printf("Press 1 for sequental game, press 2 parallel game, press 3 for CHAOS mode...\n");
	ch = fgetchar(); ch = fgetchar();
	printf("Press any key to continue...");
	getchar(); getchar();
	int counter = 0;
	clock_t begin, end;
	double time_spent;
	begin = clock();
	if (ch == '1')
	{
		//while (counter < counter_hit)
		while (true)
		{
			evolution(population, generation);	//Nuosekliai
			generation += 1;
			counter += 1;
		}
	}
	else if (ch == '2' || ch == '3')
	{
		//while (counter < counter_hit)
		while (true)
		{
			cudaError_t cudaStatus = cudaEvolution(population, generation, ch);	//Ivykdome funkcija, kurioje algoritmas bus atliekamas lygiagreciai
			if (cudaStatus != cudaSuccess) {
				fprintf(stderr, "cudaEvolution failed!");
				fgetchar();
				return 1;
			}
			cudaStatus = cudaDeviceReset();
			if (cudaStatus != cudaSuccess) {
				fprintf(stderr, "cudaDeviceReset failed!");
				return 1;
			}
			generation += 1;
			if (ch == '2')
			{
				counter += 1;
			}
			else if (ch == '3')
			{
				counter += 100;
			}
		}
	}
	end = clock();
	time_spent = (double)(end - begin) / CLOCKS_PER_SEC;
	printf("\n%f\n", time_spent);
	getchar();
	return 0;
}

void evolution(bool (*pop)[MAX_COL], int generation)
{
	bool new_pop[MAX_ROW][MAX_COL];
	for (int i = 0; i < MAX_ROW; i++)
	{
		for (int j = 0; j < MAX_COL; j++)
		{
			new_pop[i][j] = generation_pass(pop, i, j);
		}
	}
	memcpy(pop,new_pop, MAX_ROW*MAX_COL*sizeof(bool));
	print(pop, generation);
}

void print(bool (*pop)[MAX_COL], int generation)
{
	system("cls");
	char row[MAX_ROW*MAX_COL+MAX_ROW];
	printf("Generation: %5d\n", generation);
	int offset = 0;
	for (int i = 0; i < MAX_ROW; i++)
	{
		for (int j = 0; j < MAX_COL; j++)
		{
			if (pop[i][j])
			{
				row[offset] = '0';
			}
			else{
				row[offset] = ' ';
			}
			offset += 1;
		}
		row[offset] = '\n';
		offset += 1;
	}
	printf("%s\n", row);
}

bool generation_pass(bool (*pop)[MAX_COL], int i, int j)
{
	int counter = 0;
	if (i != 0) {counter += check_neighbour(pop[i-1][j]); }
	if (i != 0 && j != MAX_COL - 1) {counter += check_neighbour(pop[i-1][j + 1]); }
	if (j != MAX_COL - 1) {counter += check_neighbour(pop[i][j + 1]); }
	if (i != MAX_ROW - 1 && j != MAX_COL - 1) {counter += check_neighbour(pop[i + 1][j + 1]); }
	if (i != MAX_ROW - 1) {counter += check_neighbour(pop[i + 1][j]); }
	if (i != MAX_ROW - 1 && j != 0) {counter += check_neighbour(pop[i+1][j-1]); }
	if (j != 0) {counter += check_neighbour(pop[i][j-1]); }
	if (i != 0 && j != 0) {counter += check_neighbour(pop[i-1][j-1]); }
	if (pop[i][j])
	{
		if (counter < 2)
		{
			return false;
		}
		else if (counter > 3)
		{
			return false;
		}
		else
		{
			return true;
		}
	}
	else
	{
		if (counter == 3)
		{
			return true;
		}
	}
	return false;
}

int check_neighbour(bool pop)
{
	if (pop)
	{
		return 1;
	}
	else
	{
		return 0;
	}
}

cudaError_t cudaEvolution(bool (*pop)[MAX_COL], int generation, char mode)
{
	struct bool_data p[MAX_ROW];
	struct bool_data new_p[MAX_ROW];
	for (int i = 0; i < MAX_ROW; i++)
	{
		for (int j = 0; j < MAX_COL; j++)
		{
			p[i].data[j] = pop[i][j];
		}
	}
	struct bool_data *dev_p;
	struct bool_data *dev_new_p;
	cudaError_t cudaStatus;

	cudaStatus = cudaSetDevice(0);
	if (cudaStatus != cudaSuccess) {
		fprintf(stderr, "cudaSetDevice failed!  Do you have a CUDA-capable GPU installed?");
		goto Error;
	}

	cudaStatus = cudaMalloc((void**)&dev_p, MAX_ROW *  sizeof(bool_data));	//skiriame atminti tiek pradinei matricai
	if (cudaStatus != cudaSuccess) {
		fprintf(stderr, "cudaMalloc failed!");
		goto Error;
	}

	cudaStatus = cudaMalloc((void**)&dev_new_p, MAX_ROW *  sizeof(bool_data));	//tiek naujai matricai
	if (cudaStatus != cudaSuccess) {
		fprintf(stderr, "cudaMalloc failed!");
		goto Error;
	}

	cudaStatus = cudaMemcpy(dev_p, p, MAX_ROW *  sizeof(bool_data), cudaMemcpyHostToDevice);	//perduodam duomenis	
	if (cudaStatus != cudaSuccess) {
		fprintf(stderr, "cudaMemcpy failed!");
		goto Error;
	}

	cudaStatus = cudaMemcpy(dev_new_p, new_p, MAX_ROW *  sizeof(bool_data), cudaMemcpyHostToDevice);
	if (cudaStatus != cudaSuccess) {
		fprintf(stderr, "cudaMemcpy failed!");
		goto Error;
	}

	if (mode == '2')
	{
		startEvolution<<<MAX_ROW, MAX_COL>>>(dev_p, dev_new_p);		//Ivykdom gijas
	}
	if (mode == '3')
	{
		startEvolutionCHAOS<<<MAX_ROW + 1, MAX_COL>>>(dev_p, dev_new_p);
	}


	cudaStatus = cudaGetLastError();
	if (cudaStatus != cudaSuccess) {
		fprintf(stderr, "startEvolution launch failed: %s\n", cudaGetErrorString(cudaStatus));
		goto Error;
	}

	cudaStatus = cudaMemcpy(p, dev_p,   MAX_ROW *  sizeof(bool_data), cudaMemcpyDeviceToHost);		//Susigrazinam rezultatus
	if (cudaStatus != cudaSuccess) {
		fprintf(stderr, "cudaMemcpy failed!");
		goto Error;
	}

	cudaStatus = cudaMemcpy(new_p, dev_new_p,   MAX_ROW *  sizeof(bool_data), cudaMemcpyDeviceToHost);
	if (cudaStatus != cudaSuccess) {
		fprintf(stderr, "cudaMemcpy failed!");
		goto Error;
	}
	for (int i = 0; i < MAX_ROW; i++)
	{
		for (int j = 0; j < MAX_COL; j++)
		{
			pop[i][j] = new_p[i].data[j];		//perrasom is naujo pradine matrica
		}
	}
	print(pop, generation);
Error:
	cudaFree(dev_p);
	return cudaStatus;
}
