//IFF-1 Tautvydas Petkus
//L-ND - OpenMP
//Dabartiniai nustatymai: stulpeliø skaièius - 100, eiluèiø skaièius - 100
#include <omp.h>
#include <time.h>
#include <stdlib.h>
#include <stdio.h>
const int MAX_ROW = 50;	   //MAX 108
const int MAX_COL = 50;	   //MAX 330

void evolution(int (*pop)[MAX_COL], int generation);
void evolution_paralell(int (*pop)[MAX_COL]);
void evolution_paralell_chaos(int (*pop)[MAX_COL]);
void print(int (*pop)[MAX_COL], int generation);
int generation_pass(int (*pop)[MAX_COL], int i, int j);
int check_neighbour(int pop);

int main(int argc, char **argv)
{
	char ch;
	int population[MAX_ROW][MAX_COL];
    srand(time(NULL));
    int i = 0;
		for (i = 0; i < MAX_ROW; i++)
		{
		    int j = 0;
			for (j = 0; j < MAX_COL; j++)
			{
				if (rand() % 2)
				{
					population[i][j] = 0;
				}
				else
				{
					population[i][j] = 1;
				}
			}
		}
	int generation = 0;
	print(population, generation);
	printf("Press 1 for sequental game, press 2 parallel game, press 3 for chaotic game\n");
	ch = getchar();
	printf("Press any key to continue...");
	getchar(); getchar();
	i = 0;
	if (ch == '1')
	{
		while (i == 0)
		{
			evolution(population, generation);
			generation += 1;
		}
	}
	else if (ch == '2')
	{
	    while (i == 0)
		{
            evolution_paralell(population);
            generation += 1;
            print(population, generation);
		}
	}
	else if (ch == '3')
	{
	    while (i == 0)
	    {
	        evolution_paralell_chaos(population);
            generation += 100;
            print(population, generation);
	    }
	}
	return 0;
}

void evolution(int (*pop)[MAX_COL], int generation)
{
	int new_pop[MAX_ROW][MAX_COL];
	int i = 0;
	for (i = 0; i < MAX_ROW; i++)
	{
	    int j = 0;
		for (j = 0; j < MAX_COL; j++)
		{
			new_pop[i][j] = generation_pass(pop, i, j);
		}
	}
	memcpy(pop,new_pop, MAX_ROW*MAX_COL*sizeof(int));
	print(pop, generation);
}

void evolution_paralell(int (*pop)[MAX_COL])
{
    int gijosNr = omp_get_thread_num();
    int i = 0;
    omp_set_num_threads(MAX_ROW * MAX_COL);
	#pragma omp parallel private(gijosNr)
    {
        gijosNr = omp_get_thread_num();
        int row = gijosNr / MAX_ROW;
        int col = gijosNr - MAX_ROW * row;
        pop[row][col] = generation_pass(pop, row, col);
    }
}

void evolution_paralell_chaos(int (*pop)[MAX_COL])
{
    int gijosNr = omp_get_thread_num();
    int i = 0;
    omp_set_num_threads(MAX_ROW * MAX_COL);
	#pragma omp parallel private(gijosNr)
    {
        gijosNr = omp_get_thread_num();
        int row = gijosNr / MAX_ROW;
        int col = gijosNr - MAX_ROW * row;
        for (i = 0; i < 100; i++)
        {
            pop[row][col] = generation_pass(pop, row, col);
        }
    }
}

void print(int (*pop)[MAX_COL], int generation)
{
	system("clear");
	char row[MAX_ROW*MAX_COL+MAX_ROW];
	printf("Generation: %5d\n", generation);
	int offset = 0;
	int i = 0;
	for (i = 0; i < MAX_ROW; i++)
	{
	    int j = 0;
		for (j = 0; j < MAX_COL; j++)
		{
			if (pop[i][j] == 1)
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

int generation_pass(int (*pop)[MAX_COL], int i, int j)
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
			return 0;
		}
		else if (counter > 3)
		{
			return 0;
		}
		else
		{
			return 1;
		}
	}
	else
	{
		if (counter == 3)
		{
			return 1;
		}
	}
	return 0;
}

int check_neighbour(int pop)
{
	if (pop == 1)
	{
		return 1;
	}
	else
	{
		return 0;
	}
}
