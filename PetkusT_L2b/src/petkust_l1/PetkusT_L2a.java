/* Kure Tautvydas Petkus IFF-1
 * L12- Java Semaforai
 * Duomenu failas - PetkusT.txt (duomenu eiluciu skaicius - 50)
 * Giju ir masyvu dydziai priklauso nuo ivedimo
 */
package petkust_l1;

import java.io.BufferedReader;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.FileReader;
import java.util.concurrent.Semaphore;
import java.util.logging.Level;
import java.util.logging.Logger;

//Klase, atsakinga uz pagrindinius programos veiksmus - nuskaityma, isvedima, giju sukurima
/**
 *
 * @author taupet
 */
public class PetkusT_L2a {

    /**
     * @param args the command line arguments
     */
    public static void main(String[] args) throws IOException {
        String file_name = "PetkusT.txt";
        int process_count = 0;
        System.out.print("Iveskite giju skaiciu: ");
        BufferedReader br = new BufferedReader(new InputStreamReader(System.in));
        process_count = Integer.parseInt(br.readLine());
        int[] array_size = new int[process_count];
        for (int i = 0; i < process_count; i++) {
            System.out.print("Iveskite gijos nr. " + i + " masyvo dydį: ");
            array_size[i] = Integer.parseInt(br.readLine());
        }
        PetkusT_L1a_Veiksmai.execute(file_name, process_count, array_size);
    }
}
class PetkusT_L1a_Veiksmai {
    public static void execute(String file_name, int process_count, int[] array_size) {
        PetkusT_L1a_Duomenys[][] file_data = new PetkusT_L1a_Duomenys[process_count][];
        int[][] initial_data = new int[process_count][];
        Writer[] write = new Writer[process_count];
        Reader[] read = new Reader[process_count];
        Buffer bufferis = new Buffer();
        readData(file_name, file_data, process_count, array_size);
        System.out.println("-------------------PRADINIAI DUOMENYS------------------");
        //Duomenys spausdinami į konsolę
        PetkusT_L1a_Duomenys c = new PetkusT_L1a_Duomenys();
        for (int i = 0; i < process_count; i++){
            for (int j = 0; j < array_size[i] - 1; j++){
                for (int jj = j+1; jj < array_size[i]; jj++){
                    if (file_data[i][j].getInt_field() < file_data[i][jj].getInt_field()){
                        c = file_data[i][j];
                        file_data[i][j] = file_data[i][jj];
                        file_data[i][jj] = c;
                    }
                }
            }
        }
        for (int i = 0; i < process_count; i++){
            initial_data[i] = new int[array_size[i]];
            for (int j = 0; j < array_size[i]; j++){
                initial_data[i][j] = file_data[i][j].getInt_field();
            }
        }
        writeData(file_data, process_count, array_size);
        System.out.println("-------------------------------------------------------");
        System.out.println("-------------------PRADEDAMOS GIJOS--------------------");
        //Sukuriamos gijos
        bufferis = new Buffer();
        for (int i = 0; i < process_count; i++) {
            write[i] = new Writer(array_size[i], file_data[i], bufferis);
        }
        for (int i = 0; i < process_count; i++){
            read[i] = new Reader(bufferis, initial_data[i] , array_size[i], i);
        }
        //Paleidžiamos gijos
        for (int i = 0; i < process_count; i++) {
            write[i].start();
        }
        for (int i = 0; i < process_count; i++){
            read[i].start();
        }
        while (true){
            int alive = 0;
            for (int i = 0; i < process_count; i++){
                if (!read[i].isAlive()){
                    alive++;
                }
            }
            if (alive==process_count){
                System.out.println("-------------------Gijos baige darba--------------------");
                System.out.println(String.format("%12s", bufferis.getData_count_total()));
                System.out.println(String.format("%12s%12s", "Elementas", "Skaicius"));
                for (int i = 0; i < 10; i++){
                    System.out.println(String.format("%12s%12s", i, bufferis.getData_count(i)));
                }
                break;
            }
        }
    }
    //Nuskaitomi pradiniai duomenys. Saugomi dvimačiame masyve
    public static void readData(String file_name, PetkusT_L1a_Duomenys[][] file_data, int process_count, int[] array_size) {
        try {
            BufferedReader in = new BufferedReader(new FileReader(file_name));
            String str;
            String line = null;
            String var1;
            int var2;
            double var3;
            in.readLine();
            //while ((str = in.readLine()) != null){
            for (int i = 0; i < process_count; i++) {
                file_data[i] = new PetkusT_L1a_Duomenys[array_size[i]];
                for (int j = 0; j < array_size[i]; j++) {
                    str = in.readLine();
                    String[] tokens = str.split("\\s+");
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
    public static void writeData(PetkusT_L1a_Duomenys[][] file_data, int process_count, int[] array_size) {
        for (int i = 0; i < process_count; i++) {
            System.out.println(String.format("%8s", "--------------" + "Gija nr." + i + "-----------------"));
            System.out.println(String.format("%8s%8s%10s%5s%8s", "Gija", "Nr", "Pavad.", "int", "double"));
            for (int j = 0; j < array_size[i]; j++) {
                System.out.println(String.format("%8s%8s%10s%5s%8s", i, j, file_data[i][j].getString_field(), file_data[i][j].getInt_field(), file_data[i][j].getDouble_field()));
            }
        }
    }
}
//Duomenu klase
class PetkusT_L1a_Duomenys {
    private String string_field;
    private int int_field;
    private double double_field;
    //Sukuriama duomenis saugojančioji klasė
    PetkusT_L1a_Duomenys(String C_string_field, int C_int_field, double C_double_field) {
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
//Siuntejo gija
class Writer extends Thread {
    private PetkusT_L1a_Duomenys[] file_data;
    private int kiekis;
    private Buffer buffer;
    public Writer(int kiek, PetkusT_L1a_Duomenys[] data, Buffer bufferis) {
        this.kiekis = kiek;
        file_data= new PetkusT_L1a_Duomenys[kiek];
        for (int i = 0; i < kiek; i++){
            file_data[i] = data[i];
        }
        buffer = bufferis;
    }
    public void run() {
        for (int i = 0; i<kiekis; i++) {
            buffer.add_data(file_data[i].getInt_field());
        }
    }
}
//gavejo gija
class Reader extends Thread {
    private int[] initial_data;
    private int[] file_data;
    private int initial_kiekis;
    private int kiekis;
    private Buffer buffer;
    private int index_number;
    public Reader(Buffer bufferis, int[] in_data, int kiekis, int index_number) {
        this.kiekis = 0;
        file_data= new int[50];
        for (int i = 0; i < 10; i++){
            file_data[i] = 0;
        }
        initial_data = new int[kiekis];
        this.initial_data = in_data;
        buffer = bufferis;
        this.initial_kiekis = kiekis;
        this.index_number = index_number;
        
    }
    public void run() {
        //while (kiekis != initial_kiekis){
        for (int i = 0; i < initial_kiekis; i++){
            int int_reiksme = buffer.read_data(initial_data[i]);
            /*while (int_reiksme == -1){
                System.out.println(int_reiksme);
                int_reiksme = buffer.read_data(initial_data[i]);
            }*/
            file_data[kiekis] = int_reiksme;
            kiekis++;
            // System.out.println(String.format("%8s%8s", index_number, int_reiksme));
        }
    }
}
//Buferio klase
class Buffer{
    private int[] file_data;
    private int[] data_count;
    private int data_count_total;
    private Semaphore ksApsauga;
    private Semaphore laisva;
    private Semaphore užimta;
    private boolean is_empty;
    //------------------------
    public Buffer() {
        file_data = new int[30];
        for (int i = 0; i < 30; i++){
            file_data[i] = 0;
        }
        data_count = new int[10];
        data_count_total = 0;
        ksApsauga = new Semaphore(1);
        laisva = new Semaphore(30);
        užimta = new Semaphore(0);
    }

    public int[] getFile_data() {
        return file_data;
    }

    public int getData_count_total() {
        return data_count_total;
    }
    public int getData_count(int i) {
        return data_count[i];
    }
    public void setData_count(int i, int data_count) {
        this.data_count[i] = data_count;
    }
    //duomenu idėjas
    public void add_data(int data){
        try {
            //laisva.acquire();
            ksApsauga.acquire();
            if (data_count_total < 30){
                file_data[data_count_total] = data;
                data_count[data]++;
                data_count_total++;
            }
            ksApsauga.release();
            //užimta.release();
        } catch (InterruptedException e) { }
    }
    //duomenu isemimas
    public int read_data(int data){
        int read_data = -1;
        try {
            ksApsauga.acquire();
            if (data_count_total > 0){
                for (int i = 0; i < data_count_total; i++){
                    if (file_data[i] == data){
                        //užimta.acquire();
                        read_data = file_data[i];
                        if (i != data_count_total - 1){
                            for (int j = i + 1; j < data_count_total - 1; j++){
                                file_data[j - 1] = file_data[j];
                            }
                        }
                        file_data[data_count_total - 1] = 0;
                        data_count_total--;
                        data_count[data]--;
                        //laisva.release();
                        break;
                    }
                }
                //data = file_data[data_count_total - 1];
                //file_data[data_count_total - 1] = 0;
                //data_count_total--;
                //data_count[data]--;
                
            }
            else{
                ksApsauga.release();
                return read_data;
            }
            ksApsauga.release();
        } catch (InterruptedException e) { }
        return read_data;
    }
}