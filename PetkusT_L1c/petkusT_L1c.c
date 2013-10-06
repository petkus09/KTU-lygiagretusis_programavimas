//IFF-1 Tautvydas Petkus
// L1c - Open MPI
//Failo dydis - 50 eiluciu
//Dabartiniai nustatymai: giju sk: 8, maximalus masyvo dydis - 10, didziausias char buferio dydis - 80
//Kiek  iteracijų iš eilės padaro vienas procesas? atsitiktinai
//Kokia tvarka vykdomi procesai? atsitiktine
//Trumpiausias laikas - L1d CUDA
//Kompiuteris: 4 branduolių CPU,  2.30GHz, OA - 3954460 kB, OS - Ubuntu 12.0 (CUDA buvo daromas Windows platformoje)
// GPU - Nvidia GT 525m

#include <mpi.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>

#define MAX_STRING_LEN 80
#define MAX_THREADS 8
#define MAX_FILE_ROW 50
#define MAX_ARRAY_SIZE 10

//duomenu kintamuosius laikantis irasas
struct Data
{
   char text_var[MAX_STRING_LEN];
   int int_var;
   double double_var;
};

//Duomenis laikantis iraso tipas
struct ThreadData{
    struct Data thread_struct_array[MAX_ARRAY_SIZE];
};

int main(int argc, char *argv[])
{
    int array_size[MAX_THREADS] = {5, 7, 6, 9, 4, 8, 4, 6};
    int numprocessors, rank, namelen;
    char processor_name[MPI_MAX_PROCESSOR_NAME];

    //Open MPI iniciavimas
    MPI_Init(&argc, &argv);
    MPI_Comm_size(MPI_COMM_WORLD, &numprocessors);
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);
    MPI_Get_processor_name(processor_name, &namelen);
    struct Data duomenys[MAX_FILE_ROW];

    //Nuskaitomo failo paruosimas
    char * line = NULL;
    size_t len = 0;
    ssize_t read;
    FILE *ifp;
    char *mode = "r";
    ifp = fopen("PetkusT.txt", mode);
    if (ifp == NULL) {
        fprintf(stderr, "Can't open input file in.list!\n");
        exit(1);
    }

    char A1[MAX_STRING_LEN];
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
       }

    int d = 0;
    int ii = 0;
    int j = 0;
    if (rank == 0){
        printf("********************************************************************\n");
        printf("***Pradiniai duomenys***\n");
    }
    struct ThreadData duomenys_gijoms;
    for (ii = 0; ii < numprocessors; ii++){
        if (rank == 0){
            printf("***Gija nr. %d***\n", ii + 1);
            printf("%10s %10s %10s %10s\n", "Eil.Nr.", "String", "int", "double");
        }
        struct Data D_gija[array_size[ii]];
        for (j = 0; j < array_size[ii]; j++){
            D_gija[j] = duomenys[d];
            if (rank == 0){
                printf("%10d %10s %10d %10lf\n", j + 1, D_gija[j].text_var, D_gija[j].int_var, D_gija[j].double_var);
            }
            d++;
        }
        for (j = 0; j < array_size[ii]; j++){
            if (ii == rank){
                duomenys_gijoms.thread_struct_array[j] = D_gija[j];
            }
        }
    }
    if (rank == 0){
        printf("\n**********************\n");
        printf("---------------------------------------------------------------------------------\n");
        printf("***Lygiagrecioji programos dalis***\n");
        printf("%10s %10s %10s %10s %10s\n", "Gijos nr.", "Eil.Nr.", "String", "int", "double");
    }
    //Lygiagretusis spausdinimas
    int iiii;
    for (iiii = 0; ii < 10000000; ii++){
            double bandomasis = ii * ii * ii * ii * ii * ii * ii * ii;
    }
    int jj;
    for (jj = 0; jj < array_size[rank]; jj++){
        printf("%10s%d %10d-Nr %10s %10d %10lf\n","Procesas", rank + 1, jj + 1, duomenys_gijoms.thread_struct_array[jj].text_var, duomenys_gijoms.thread_struct_array[jj].int_var, duomenys_gijoms.thread_struct_array[jj].double_var);
        int ii = 0;
            //funkcija, reikalinga pristabdyti giju veikima ir pastebeti maisos rezultatus
        for (ii = 0; ii < 1000000; ii++){
            double bandomasis = ii * ii * ii * ii * ii * ii * ii * ii;
        }
    }
    printf("***Gija nr. %d baige darba \n", rank + 1);

   MPI_Finalize();
   return 0;
}

