//IFF-1 Tautvydas Petkus
// L1b - OpenMP
//Failo dydis - 50 eiluciu
//Dabartiniai nustatymai: giju sk: 8, maximalus masyvo dydis - 10, didziausias char buferio dydis - 80
//Kiek  iteracijų iš eilės padaro vienas procesas? atsitiktinai
//Kokia tvarka vykdomi procesai? atsitiktine
//

#include <omp.h>
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

main(int argc, char **argv) {
    //Nustatoma, kiek kiekviena gija tures masyvo elementu
    int array_size[MAX_THREADS] = {5, 7, 6, 9, 4, 8, 4, 6};
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

    //Duomenu priskyrimas giju masyvams. Pradiniu duomenu isvedimas
    int d = 0;
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
    printf("\n**********************\n");
    //int maxGijuSk = omp_get_max_threads();
    int maxGijuSk = MAX_THREADS;
    int gijosNr = omp_get_thread_num();
    omp_set_num_threads(maxGijuSk);
    printf("Max giju sk. = %d\n", maxGijuSk);
    printf("---------------------------------------------------------------------------------\n");
    // ------ Lygiagretus kodas ------------.

    printf("***Lygiagrecioji programos dalis***\n");
    printf("%10s %10s %10s %10s %10s\n", "Gijos nr.", "Eil.Nr.", "String", "int", "double");
    #pragma omp parallel private(gijosNr)
    {
        gijosNr = omp_get_thread_num();
        int j = 0;
        for (j = 0; j < array_size[gijosNr]; j++){
            printf("%10s%d %10d %10s %10d %10lf\n","Procesas", gijosNr + 1, j + 1, duomenys_gijoms[gijosNr].thread_struct_array[j].text_var, duomenys_gijoms[gijosNr].thread_struct_array[j].int_var, duomenys_gijoms[gijosNr].thread_struct_array[j].double_var);
            int ii = 0;
            //funkcija, reikalinga pristabdyti giju veikima ir pastebeti maisos rezultatus
            for (ii = 0; ii < 1000000; ii++){
                double bandomasis = ii * ii * ii * ii * ii * ii * ii * ii;
            }
        }
        printf("***Gija nr. %d baige darba \n", gijosNr + 1);
    }
    // ------ Nuoseklus kodas --------------
    printf("-------------------------------\n");
    printf("------------Gijos baige darba-------------------\n");
    printf("***********************\n");

return 0;

}
