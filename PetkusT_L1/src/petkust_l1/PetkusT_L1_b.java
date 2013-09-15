/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package petkust_l1;

import java.io.BufferedReader;
import java.io.FileReader;
import java.io.IOException;

/**
 *
 * @author taupet
 */
public class PetkusT_L1_b {
    public static void execute(String file_name, int process_count, int array_size){
        PetkusT_L1a[][] file_data = new PetkusT_L1a[process_count][];
        readData(file_name, file_data, process_count, array_size);
        System.out.println("-------------------PRADINIAI DUOMENYS------------------");
        //Duomenys spausdinami į konsolę
        writeData(file_data, process_count, array_size);
        System.out.println("-------------------------------------------------------");
        System.out.println("-------------------PRADEDAMOS GIJOS--------------------");
        System.out.println(String.format("%5s%5s%10s%5s%8s", "Gija", "Nr", "Pavad.", "int", "double"));
        //Sukuriamos gijos
        PetkusT_L1_c[] petkus_threads = new PetkusT_L1_c[process_count];
        for (int i = 0; i < process_count; i++){
            petkus_threads[i] = new PetkusT_L1_c(file_data[i], array_size, i);
        }
        //Paleidžiamos gijos
        for (int i = 0; i < process_count; i++){
            petkus_threads[i].start();
        }
        
    }
    
    //Nuskaitomi pradiniai duomenys. Saugomi dvimačiame masyve
    public static void readData(String file_name, PetkusT_L1a[][] file_data, int process_count, int array_size){
         try {
            BufferedReader in = new BufferedReader(new FileReader(file_name));
            String str;
            String line = null;
            String var1;
            int var2;
            double var3;
            in.readLine();
            //while ((str = in.readLine()) != null){
            for (int i = 0; i < process_count; i++){
                file_data[i] = new PetkusT_L1a[array_size];
                for (int j = 0; j < array_size; j++){
                    str = in.readLine();
                    String [] tokens =  str.split("\\s+");
                    var1 = tokens[0];
                    var2 = Integer.parseInt(tokens[1]);
                    var3 = Double.parseDouble(tokens[2]);
                    file_data[i][j] = new PetkusT_L1a(var1, var2, var3);
                }
            }
            in.close();
        } catch (IOException e) {
        }
    }
    
    //Išvedami pradiniai duomenys
    public static void writeData(PetkusT_L1a[][] file_data, int process_count, int array_size){
        System.out.println(String.format("%10s%5s%8s", "Pavad.", "int", "double"));
        for (int i = 0; i < process_count; i++){
            for (int j = 0; j < array_size; j++){
                System.out.println(String.format("%10s%5s%8s", file_data[i][j].getString_field(), file_data[i][j].getInt_field(), file_data[i][j].getDouble_field()));
            }
        }
    }
}
