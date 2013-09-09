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
    public static void execute(String file_name, int process_count){
        PetkusT_L1a[] file_data = new PetkusT_L1a[process_count];
        readData(file_name, file_data, process_count);
        writeData(file_data, process_count);
    }
    
    public static void readData(String file_name, PetkusT_L1a[] file_data, int process_count){
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
                str = in.readLine();
                String [] tokens =  str.split("\\s+");
                var1 = tokens[0];
                var2 = Integer.parseInt(tokens[1]);
                var3 = Double.parseDouble(tokens[2]);
                //file_data[i].setString_field(var1);
                //file_data[i].setInt_field(var2);
                //file_data[i].setDouble_field(var3);
                file_data[i] = new PetkusT_L1a(var1, var2, var3);
            }
            in.close();
        } catch (IOException e) {
        }
    }
    
    public static void writeData(PetkusT_L1a[] file_data, int process_count){
        int i = 0;
    }
}
