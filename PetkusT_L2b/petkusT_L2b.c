//IFF-1 Tautvydas Petkus
// L2b - OpenMP semaforiai
//Failo dydis - 50 eiluciu
//KATEGORIJA - INTEGER LAUKAI DUOMENU FAILE
//Dabartiniai nustatymai:
//---giju sk(MAX THREADS): 8,
//---maximalus masyvo dydis(MAX_ARRAY_SIZE) - 15,
//---didziausias char buferio dydis(MAX_STRING_LEN) - 80,
//---didziausias buferio dydis(MAX_BUFFER_SIZE) - 30,
//---daugiausiai kategoriju skaicius(MAX_CATEGORY_SIZE) - 10
//

#include <omp.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>

#define MAX_STRING_LEN 80
#define MAX_THREADS 8
#define MAX_FILE_ROW 50
#define MAX_ARRAY_SIZE 15
#define MAX_BUFFER_SIZE 30
#define MAX_CATEGORY_SIZE 10
//Paprastas iraso tipas duomenims is failo saugoti
struct Data
{
   char text_var[MAX_STRING_LEN];
   int int_var;
   double double_var;
};
//Kategoriju saugojimo irasas
struct CategoryData
{
    int category;
    int amount;
};
//NENAUDOJAMA
struct ThreadData{
    struct Data thread_struct_array[MAX_ARRAY_SIZE];
};
//Musu duomenu buferis
struct Buffer{
    int data_array[MAX_BUFFER_SIZE];
    int n;
    struct CategoryData categories[MAX_CATEGORY_SIZE];
    int category_n;
};
//Siuntejo irasas
struct Sender{
    struct Data data_to_send[MAX_ARRAY_SIZE];
    int n;
};
//Gavejo irasas
struct Receiver{
    int initial_data[MAX_ARRAY_SIZE];
    int initial_n;
    int n;
    int data[MAX_ARRAY_SIZE];
};

int putData(int data, struct Buffer *buferis);
int getData(int data, struct Buffer *buferis);

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
    struct Buffer buferis;
    buferis.n = 0;
    buferis.category_n = 0;
    struct Sender siuntejas[MAX_THREADS];
    struct Receiver gavejas[MAX_THREADS];
    for (ii = 0; ii < MAX_THREADS; ii++){
        printf("***Gija nr. %d***\n", ii + 1);
        printf("%10s %10s %10s %10s\n", "Eil.Nr.", "String", "int", "double");
        struct Data D_gija[array_size[ii]];
        for (j = 0; j < array_size[ii]; j++){
            D_gija[j] = duomenys[d];
            //_______PRADINIU DUOMENU ISVEDIMAS______________________
            printf("%10d %10s %10d %10lf\n", j + 1, D_gija[j].text_var, D_gija[j].int_var, D_gija[j].double_var);
            d++;

        }
        for (j = 0; j < array_size[ii]; j++){
            //______________Paduodam duomenis siuntejui ir gavejui___________________________________
            siuntejas[ii].data_to_send[j] = D_gija[j];
            gavejas[ii].initial_data[j]   = D_gija[j].int_var;
        }
        siuntejas[ii].n = array_size[ii];
        gavejas[ii].initial_n = array_size[ii];
        gavejas[ii].n = 0;
    }
    printf("\n**********************\n");
    int maxGijuSk = MAX_THREADS * 2; //Dvigubai daugiau, nes yra gavejas+siuntejas
    int gijosNr = omp_get_thread_num();
    omp_set_num_threads(maxGijuSk);
    //-------
    printf("Max giju sk. = %d\n", maxGijuSk);
    printf("---------------------------------------------------------------------------------\n");
    // ------ Lygiagretus kodas ------------.

    printf("***Lygiagrecioji programos dalis***\n");
    #pragma omp parallel private(gijosNr)
    {
        gijosNr = omp_get_thread_num();
        //SIUNTEJAS
        if (gijosNr < MAX_THREADS){
            int ii = 0;
            for (ii = 0; ii < siuntejas[gijosNr].n; ii+=1){
                int validator = 0;
                while (validator != 1){
                    #pragma omp critical
                    {
                        validator = putData(siuntejas[gijosNr].data_to_send[ii].int_var, &buferis);
                    }
                }
            }
        }
        //GAVEJAS
        else{
            int i = 0;
            for (i = 0; i < gavejas[gijosNr % MAX_THREADS].initial_n; i+=1){
                int validator = -1;
                int initial_data = gavejas[gijosNr % MAX_THREADS].initial_data[i];
                while (validator == - 1){
                    #pragma omp critical
                    {
                        validator = getData(initial_data, &buferis);
                        if (validator != -1){
                            gavejas[gijosNr % MAX_THREADS].data[gavejas[gijosNr % MAX_THREADS].n] = validator;
                            gavejas[gijosNr % MAX_THREADS].n += 1;
                        }
                    }
                }
            }
        }
    }
    // ------ Nuoseklus kodas --------------
    printf("-------------------------------\n");
    printf("------------Gijos baige darba-------------------\n");
    printf("%10s %10s\n", "Kategor.", "Kiekis");
    int categoryIndex;
    for (categoryIndex = 0; categoryIndex < buferis.category_n; categoryIndex+=1){
        printf("%10d %10d\n", buferis.categories[categoryIndex].category, buferis.categories[categoryIndex].amount);
    }
    printf("***********************\n");

return 0;
}

int putData(int data, struct Buffer *buferis){
    struct Buffer buf = *buferis;
    int is_category = -1;
    int current_buffer_size = buf.n;
    if (current_buffer_size < MAX_BUFFER_SIZE){
        buf.data_array[current_buffer_size] = data;
        buf.n = buf.n + 1;
        //Setting categories
        int i = 0;
        //KATEGORIJU SUKURIMAS ARBA ATNAUJINIMAS
        for (i = 0; i < buf.category_n; i++){
            if (buf.categories[i].category == data){
                is_category = i;
            }
        }
        if (is_category == -1){
            struct CategoryData new_category;
            new_category.amount = 1;
            new_category.category = data;
            buf.categories[buf.category_n] = new_category;
            buf.category_n += 1;
        }
        else{
            buf.categories[is_category].amount += 1;
        }
        *buferis = buf;
        return 1;
    }
    else{
        return 0;
    }
}

int getData(int data, struct Buffer *buferis){
    int result = -1;
    struct Buffer buf = *buferis;
    int current_buffer_size = buf.n;
    if (current_buffer_size > 0){
        int i = 0;
        int index = -1;
        for (i = 0; i < buf.n; i+=1){
            if (buf.data_array[i] == data){
                index = i;
            }
        }
        if (index == -1){       //jei nerasta, ko reikia - griztama atgal
            return result;
        }
        else{
            //TRINAMAS PAIMAMAS ELEMENTAS
            if (index < current_buffer_size - 1){   //ne paskutinis
                int j = 0;
                for (j = index + 1; j < MAX_BUFFER_SIZE; j+=1){
                    buf.data_array[j - 1] = buf.data_array[j];
                }
            }
            buf.data_array[current_buffer_size - 1] = -1;
            buf.n -= 1;

            result = data;
            int jj = 0;
            for (jj = 0; jj < buf.category_n; jj+=1){
                if (buf.categories[jj].category == data){
                    buf.categories[jj].amount -= 1;
                }
            }
        }
        *buferis = buf;
    }
    return result;
}
