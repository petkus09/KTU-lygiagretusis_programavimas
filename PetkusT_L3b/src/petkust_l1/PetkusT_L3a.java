/* Kure Tautvydas Petkus IFF-1
 * L3 - Kanalai
 * Duomenu failas - PetkusT.txt (duomenu eiluciu skaicius - 50)
 * Giju ir masyvu dydziai priklauso nuo ivedimo
 */
package petkust_l1;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.FileReader;
import org.jcsp.lang.*;

//Klase, atsakinga uz pagrindinius programos veiksmus - nuskaityma, isvedima, giju sukurima
/**
 *
 * @author taupet
 */
public class PetkusT_L3a {

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
        Buffer buffer = new Buffer();
        One2OneChannel[] channels = new One2OneChannel[process_count*2];
        One2OneChannel[] replyChannels = new One2OneChannel[process_count*2];
        for (int i = 0; i < process_count*2; i++) {
            channels[i] = Channel.one2one();
            replyChannels[i] = Channel.one2one();
        }
        Parallel parallelProcesses = new Parallel();
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
        for (int i = 0; i < process_count; i++) {
            Writer thread = new Writer(array_size[i], file_data[i], channels[i].out(), replyChannels[i].in());
            parallelProcesses.addProcess(thread);
        }
        for (int i = 0; i < process_count; i++){
            Reader thread = new Reader(initial_data[i], array_size[i], channels[i + process_count].out(),
                    replyChannels[i + process_count].in());
            parallelProcesses.addProcess(thread);
        }
        //Paleidžiamos gijos
        ProcessManager manager = new ProcessManager(channels, replyChannels, buffer, process_count);
        parallelProcesses.addProcess(manager);
        parallelProcesses.run();
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


class Dom{
    private int int_field;
    private int kiekis;
    Dom() {
        int_field = -1;
        kiekis = 0;
    }
    Dom(int reiksme){
        int_field = reiksme;
        kiekis = 1;
    }
    public int getInt_field() { return int_field; }
    public void setInt_field(int int_field) { this.int_field = int_field; }
    public int getKiekis() { return kiekis; }
    public void setKiekis(int kiekis) { this.kiekis = kiekis; }
    public void increase() {this.kiekis++; }
    public void decrease() {this.kiekis--; }
}

class Writer implements CSProcess {
    private PetkusT_L1a_Duomenys[] file_data;
    private int kiekis;
    private ChannelInput replyChannel;
    private ChannelOutput channel;
    
    public Writer(int kiek, PetkusT_L1a_Duomenys[] data, ChannelOutput channel, ChannelInput replyChannel) {
        this.kiekis = kiek + 1;
        file_data= new PetkusT_L1a_Duomenys[kiek+1];
        for (int i = 0; i < kiek; i++){
            file_data[i] = data[i];
        }
        file_data[kiek] =  new PetkusT_L1a_Duomenys();
        file_data[kiek].setInt_field(-1);
        this.channel = channel;
        this.replyChannel = replyChannel;
    }
    public void run() {
        for (int i = 0; i<kiekis; i++) {
            int response = -1;
            while (response == -1) {
                this.channel.write(file_data[i].getInt_field());
                response = (int) replyChannel.read();
            }
            if (response == 0) {
                System.out.println("Writer finished"); 
                return;
            }
        }
        //this.channel.write(null);
    }
}

class Reader implements CSProcess {
    private int[] initial_data;
    private Dom[] file_data;
    private int initial_kiekis;
    private int dom_kiekis;
    private ChannelOutput channel;
    private ChannelInput replyChannel;
    public Reader(int[] in_data, int kiekis, ChannelOutput channel, ChannelInput replyChannel) {
        this.dom_kiekis = 0;
        file_data= new Dom[10];
        for (int i = 0; i < 10; i++){
            file_data[i] = new Dom();
        }
        initial_data = new int[kiekis+1];
        for (int i = 0; i < kiekis; i++){
            this.initial_data[i] = in_data[i];
        }
        initial_data[kiekis] = -1;
        this.initial_kiekis = kiekis+1;
        this.channel = channel;
        this.replyChannel = replyChannel;
    }
    public void run() {
        for (int i = 0; i < initial_kiekis; i++){
            int response = -1;
            while (response == -1) {
                this.channel.write(initial_data[i]);
                response = (int) this.replyChannel.read();
                
            }
        }
        System.out.println("Reader finished");
    }
}
        
class Buffer{
    private Dom[] file_data;
    private int[] duomenys;
    private int kiekis;
    //------------------------
    public Buffer() {
        file_data = new Dom[10];
        for (int i = 0; i < 10; i++){
            file_data[i] = new Dom();
        }
        duomenys = new int[30];
        for (int i = 0; i < 30; i++){
            duomenys[i] = -1;
        }
        kiekis = 0;
    }

    public boolean add_data(int data){
        int i = 0;
        if (kiekis < 30){
            while (i < 10){
                if (file_data[i].getInt_field() == data){
                    file_data[i].increase();
                    duomenys[kiekis] = data;
                    kiekis++;
                    return true;
                }
                else if (file_data[i].getInt_field() == -1){
                    file_data[i].setInt_field(data);
                    file_data[i].increase();
                    duomenys[kiekis] = data;
                    kiekis++;
                    return true;
                }
                i++;
            }
        }
        else{
            return false;
        }
        return false;
    }
    public int read_data(int data){
        if (kiekis < 30){
            for (int i = 0; i < kiekis; i++){
                if (duomenys[i] == data){
                    int return_var = duomenys[i];
                    reduce(i);
                    reduceInCategory(data);
                    return return_var;
                }
            }
        }
        return -1;
    }
    
    public void reduce(int index){
        for (int i = index; i < kiekis - 1; i++){
            duomenys[i] = duomenys[i + 1];
        }
        duomenys[kiekis] = -1;
        kiekis--;
    }
    
    public void reduceInCategory(int data){
        for (int i = 0; i < 10; i++){
            if (file_data[i].getInt_field() == data){
                file_data[i].decrease();
            }
        }
    }
    
    @Override
    public String toString() {
        String res = "";
        res += "\nBuferis:\n\n";
        res += String.format("%15s%15s\n", "Skaicius", "Kiekis");
        for (Dom group : file_data){
            if (group.getKiekis() != 0){
                res += String.format("%15d%15d\n", group.getInt_field(), group.getKiekis());
            }
        }
        return res;
    }
}

class ProcessManager implements CSProcess {

    private AltingChannelInput[] readerInputs;
    private AltingChannelInput[] writerInputs;
    private Buffer buffer;
    private ChannelOutput[] readerReplyOutputs;
    private ChannelOutput[] writerReplyOutputs;
    private boolean[] statusBuffer;
    private boolean[] killedThreads;
    private int process_count;

    ProcessManager(One2OneChannel[] channels, One2OneChannel[] replyChannels, Buffer buffer, int process_count) {
        writerInputs = new AltingChannelInput[process_count];
        writerReplyOutputs = new ChannelOutput[process_count];
        for (int i = 0; i < process_count; i++) {
            writerInputs[i] = channels[i].in();
            writerReplyOutputs[i] = replyChannels[i].out();
        }
        readerInputs = new AltingChannelInput[process_count];
        readerReplyOutputs = new ChannelOutput[process_count];
        for (int i = 0; i < process_count; i++) {
            readerInputs[i] = channels[i + process_count].in();
            readerReplyOutputs[i] = replyChannels[i + process_count].out();
        }
        this.buffer = buffer;
        this.statusBuffer = new boolean[process_count*2];
        this.killedThreads = new boolean[process_count*2];
        for (int i = 0; i < process_count*2; i++) {
            statusBuffer[i] = true;
            killedThreads[i] = false;
        }
        this.process_count = process_count;
    }

    public void run() {
        Alternative alternative = createGuards();
        while (!isKilled()) {
            boolean[] alive = isAlive();
            int choice = alternative.fairSelect(alive);
            if (choice >= process_count) {
                reader(choice);
            } else {
                writer(choice);
            }
        }
        System.out.println(buffer.toString());
    }
    
    private void writer(int index) {
        //responses:    0- you must quit
        //              1- suceess
        //              -1- no success, try again
        ChannelInput inputChannel = writerInputs[index];
        ChannelOutput channel = writerReplyOutputs[index];
        int var = (int) inputChannel.read();
        if (var == -1) {
            //process has finished it's job
            statusBuffer[index] = false;
            killedThreads[index] = true;
            quitMSG(channel);
        } else {
            boolean answer = putInt(var);
            statusBuffer[index] = answer;
            if (isStop()) {
                quitMSG(channel);
                killedThreads[index] = true;
            } else {
                if (!answer) {
                    failMSG(channel);
                } else {
                    successMSG(channel);
                }
            }
        }
    }
    
    private void reader(int index) {
        ChannelInput inputChannel = readerInputs[index - process_count];
        ChannelOutput channel = readerReplyOutputs[index - process_count];
        int var = (int) inputChannel.read();
        int success = getInt(var);
        //System.out.println(String.format("%4d%4d\n", var, success));
        if (success != -1){
            statusBuffer[index] = true;
        }
        else{
            statusBuffer[index] = false;
        }
        if (isStop()) {
            stopMSG(channel, success);
            killedThreads[index] = true;
        } else {
            continueMSG(channel, success);
        }
    }
    
    private Alternative createGuards() {
        Guard guards[] = new Guard[process_count * 2];
        int i = 0;
        for (AltingChannelInput input : writerInputs) {
            guards[i] = input;
            i++;
        }
        for (AltingChannelInput input : readerInputs) {
            guards[i] = input;
            i++;
        }
        Alternative alternative = new Alternative(guards);
        return alternative;
    }

    private boolean[] isAlive() {
       boolean[] threads = new boolean[killedThreads.length];
        int i = 0;
        for (boolean item : killedThreads) {
            threads[i] = !item;
            i++;
        }
        return threads;
    }

    private boolean isKilled() {
        for (boolean b : killedThreads) {
            if (!b) {
                return false;
            }
        }
        return true;
    }
    
    private boolean putInt(int data) {
        boolean result = buffer.add_data(data);
        return result;
    }
    
    private int getInt(int data) {
        int var = buffer.read_data(data);
        return var;
    }
    
    private void stopMSG(ChannelOutput channel, int success) {
        channel.write(success);
    }

    private void continueMSG(ChannelOutput channel, int success) {
        channel.write(success);
    }

    private boolean isStop() {
        for (boolean status : statusBuffer) {
            if (status) {
                return false;
            }
        }
        return true;
    }
    
    private void quitMSG(ChannelOutput channel) {
        channel.write(0);
    }

    private void failMSG(ChannelOutput channel) {
        channel.write(-1);
    }

    private void successMSG(ChannelOutput channel) {
        channel.write(1);
    }
}