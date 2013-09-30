/* Kure Tautvydas Petkus IFF-1
 * L1 - Gijos java kalboje
 * Duomenu failas - PetkusT.txt (duomenu eiluciu skaicius - 50)
 * Giju ir masyvu dydziai priklauso nuo ivedimo
 */
package petkust_l1;

import java.io.BufferedReader;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.FileReader;
/**
 *
 * @author taupet
 */
public class PetkusT_L1a {

    /**
     * @param args the command line arguments
     */
    public static void main(String[] args) throws IOException {
        String file_name = "PetkusT.txt";
        int process_count = 0;
        System.out.print("Iveskite giju skaiciu: ");
        BufferedReader br = new BufferedReader(new InputStreamReader(System.in));
        process_count =  Integer.parseInt(br.readLine());
        int[] array_size = new int[process_count];
        for (int i = 0; i < process_count; i++){
            System.out.print("Iveskite gijos nr. " + i + " masyvo dydį: ");
            array_size[i] = Integer.parseInt(br.readLine());
        }
        PetkusT_L1a_Veiksmai.execute(file_name, process_count, array_size);
    }
}

//Klase, atsakinga uz pagrindinius programos veiksmus - nuskaityma, isvedima, giju sukurima
class PetkusT_L1a_Veiksmai {
    public static void execute(String file_name, int process_count, int[] array_size){
        PetkusT_L1a_Duomenys[][] file_data = new PetkusT_L1a_Duomenys[process_count][];
        readData(file_name, file_data, process_count, array_size);
        System.out.println("-------------------PRADINIAI DUOMENYS------------------");
        //Duomenys spausdinami į konsolę
        writeData(file_data, process_count, array_size);
        System.out.println("-------------------------------------------------------");
        System.out.println("-------------------PRADEDAMOS GIJOS--------------------");
        System.out.println(String.format("%8s%8s%10s%5s%8s", "Gija", "Nr", "Pavad.", "int", "double"));
        //Sukuriamos gijos
        PetkusT_L1a_gija[] petkus_threads = new PetkusT_L1a_gija[process_count];
        for (int i = 0; i < process_count; i++){
            petkus_threads[i] = new PetkusT_L1a_gija(file_data[i], array_size[i], i);
        }
        //Paleidžiamos gijos
        for (int i = 0; i < process_count; i++){
            petkus_threads[i].start();
        }
        
    }
    
    //Nuskaitomi pradiniai duomenys. Saugomi dvimačiame masyve
    public static void readData(String file_name, PetkusT_L1a_Duomenys[][] file_data, int process_count, int[] array_size){
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
                file_data[i] = new PetkusT_L1a_Duomenys[array_size[i]];
                for (int j = 0; j < array_size[i]; j++){
                    str = in.readLine();
                    String [] tokens =  str.split("\\s+");
                    var1 = tokens[0];
                    var2 = Integer.parseInt(tokens[1]);
                    var3 = Double.parseDouble(tokens[2]);
                    file_data[i][j] = new PetkusT_L1a_Duomenys(var1, var2, var3);
                }
            }
            in.close();
        } catch (IOException e) {
        }
    }
    
    //Išvedami pradiniai duomenys
    public static void writeData(PetkusT_L1a_Duomenys[][] file_data, int process_count, int[] array_size){
        for (int i = 0; i < process_count; i++){
            System.out.println(String.format("%8s", "--------------" + "Gija nr." + i + "-----------------"));
            System.out.println(String.format("%8s%8s%10s%5s%8s", "Gija", "Nr", "Pavad.", "int", "double"));
            for (int j = 0; j < array_size[i]; j++){
                System.out.println(String.format("%8s%8s%10s%5s%8s", i, j, file_data[i][j].getString_field(), file_data[i][j].getInt_field(), file_data[i][j].getDouble_field()));
            }
        }
    }
}

//Duomenu formato klase
class PetkusT_L1a_Duomenys {
    private String string_field;
    private int int_field;
    private double double_field;
    
    //Sukuriama duomenis saugojančioji klasė
    PetkusT_L1a_Duomenys(String C_string_field, int C_int_field, double C_double_field){
        string_field = C_string_field;
        int_field = C_int_field;
        double_field = C_double_field;
    }

    PetkusT_L1a_Duomenys() {
        string_field = "";
        int_field = 0;
        double_field = 0.0;
    }

    public String getString_field() {
        return string_field;
    }

    public int getInt_field() {
        return int_field;
    }

    public double getDouble_field() {
        return double_field;
    }
    
    public void setString_field(String string_field) {
        this.string_field = string_field;
    }

    public void setInt_field(int int_field) {
        this.int_field = int_field;
    }

    public void setDouble_field(double double_field) {
        this.double_field = double_field;
    }
    
}

//Gijos klase
class PetkusT_L1a_gija extends Thread {
    private PetkusT_L1a_Duomenys[] file_data;
    private int array_size;
    private int thread_index;
    
    //Sukuriami gijos duomenys naudojami spausdinimui
    PetkusT_L1a_gija(PetkusT_L1a_Duomenys[] C_file_data, int C_array_size, int C_thread_index){
        file_data = C_file_data;
        array_size = C_array_size;
        thread_index = C_thread_index;
    }
    //Spausdinamos gijos
    public void run ()
   {
      System.out.println("------Prasideda " + thread_index + " gija----------");
      for (int i = 0; i < array_size; i++)
      {
           System.out.println(String.format("%8s%8s%10s%5s%8s" ,"Gija"+thread_index, "Nr"+i, file_data[i].getString_field(), file_data[i].getInt_field(), file_data[i].getDouble_field()));
      }
      System.out.println("------Baigiasi " + thread_index + " gija----------");
   }
}