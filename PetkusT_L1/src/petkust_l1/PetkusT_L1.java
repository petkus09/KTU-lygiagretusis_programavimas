/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package petkust_l1;

import java.io.BufferedReader;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStreamReader;

/**
 *
 * @author taupet
 */
public class PetkusT_L1 {

    /**
     * @param args the command line arguments
     */
    public static void main(String[] args) throws IOException {
        String file_name = "PetkusT.txt";
        int process_count = 0;
        int array_size = 0;
        System.out.print("Iveskite giju skaiciu: ");
        BufferedReader br = new BufferedReader(new InputStreamReader(System.in));
        process_count =  Integer.parseInt(br.readLine());
        System.out.print("Iveskite masyvo dydį: ");
        array_size =  Integer.parseInt(br.readLine());
        PetkusT_L1_b.execute(file_name, process_count, array_size);
    }
}
