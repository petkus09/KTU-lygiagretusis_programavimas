//23
#include <omp.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>

#define MAX_PROCESS_COUNT 5
#define COUNT_WRITE_PROCESS 2
#define COUNT_READ_PROCESS 3
#define MAX_OUTPUT_COUNT 30
#define CHANGE_COUNTER_RESET 2
#define MAX_OUTPUT_PER_PROCESS 10

main(int argc, char **argv) {
    int c = 10;
    int c_change_counter = 0;
    int d = 100;
    int d_change_counter = 0;
    int total_output_count = 0;
    int output_count[MAX_PROCESS_COUNT];
    int i = 0;
    for (i = 0; i < MAX_PROCESS_COUNT; i+=1){
        output_count[i] = 0;
    }
    int maxGijuSk = MAX_PROCESS_COUNT;
    int gijosNr = omp_get_thread_num();
    printf("***************************************************\n");
    printf("%8s %8s %8s\n", "Proces.", "c", "d");
    omp_set_num_threads(maxGijuSk);
    #pragma omp parallel private(gijosNr)
    {
        gijosNr = omp_get_thread_num();
        if (gijosNr < COUNT_WRITE_PROCESS){
            while (total_output_count < MAX_OUTPUT_COUNT){
                #pragma omp critical
                {
                    c = c + 10;
                    c_change_counter += 1;
                    d = d - 2;
                    d_change_counter += 1;
                }
            }
        }
        if (gijosNr >= COUNT_WRITE_PROCESS){
            while (output_count[gijosNr] < MAX_OUTPUT_PER_PROCESS){
                #pragma omp critical
                {
                    if (c_change_counter >= CHANGE_COUNTER_RESET && d_change_counter >= CHANGE_COUNTER_RESET){
                        printf("%8d %8d %8d\n", gijosNr + 1, c, d);
                        c_change_counter = 0;
                        d_change_counter = 0;
                        output_count[gijosNr] += 1;
                        total_output_count += 1;
                    }
                }
            }
        }
    }
    printf("***************************************************\n");
    printf("Programa baigė darbą - bendras procesų išvedimų skaičius: %3d \n", total_output_count);

}
