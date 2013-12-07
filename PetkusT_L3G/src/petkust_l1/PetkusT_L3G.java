/* 23
 * Kure Tautvydas Petkus IFF-1
 * L3G - Gynimas
 */
package petkust_l1;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.FileReader;
import java.util.ArrayList;
import java.util.List;
import org.jcsp.lang.*;

//Klase, atsakinga uz pagrindinius programos veiksmus - nuskaityma, isvedima, giju sukurima
/**
 *
 * @author taupet
 */
public class PetkusT_L3G {
    public static void main(String[] args) throws IOException {
        One2OneChannel[] channels = new One2OneChannel[5];
        One2OneChannel[] replyChannels = new One2OneChannel[5];
        for (int i = 0; i < 5; i++) {
            channels[i] = Channel.one2one();
            replyChannels[i] = Channel.one2one();
        }
        Parallel parallelProcesses = new Parallel();
        
        int[][] ddd = new int[][]{
            { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 6 },
            { 3, 5, 7, 8, 6, 4, 2, 1, 3, 7, 4 },
            { 10, 10, 10, 9, 8, 3, 4, 5, 8, 9 },
            { 3, 4, 7, 6, 5, 8, 6, 4, 3, 10, 3 },
            { 1, 1, 2, 3, 1, 5, 6, 1, 2, 3, 4 }
        };
        
        int[][] duomenys = new int[4][10];
        for (int i = 0; i < 4; i++)
        {
            for (int j = 0; j < 10; j++)
            {
                duomenys[i][j] = ddd[i][j];
            }
        }
        
        for (int i = 0; i < 4; i++) {
            Writer thread = new Writer(duomenys[i], channels[i].out(), replyChannels[i].in());
            parallelProcesses.addProcess(thread);
        }
        Reader thread = new Reader(channels[4].out(), replyChannels[4].in());
        parallelProcesses.addProcess(thread);
        ProcessManager manager = new ProcessManager(channels, replyChannels);
        parallelProcesses.addProcess(manager);
        parallelProcesses.run();
    }
}

class Writer implements CSProcess {
    private int[] duomenys;
    private ChannelInput replyChannel;
    private ChannelOutput channel;
    
    public Writer(int[] duomenys, ChannelOutput channel, ChannelInput replyChannel) {
        this.duomenys = new int[11];
        for (int i = 0; i < 10; i++){
            this.duomenys[i] = duomenys[i];
        }
        this.duomenys[10] = -1;
        this.channel = channel;
        this.replyChannel = replyChannel;
    }
    public void run() {
        for (int i = 0; i<11; i++) {
            int response = -1;
            while (response == -1) {
                this.channel.write(duomenys[i]);
                response = (int) replyChannel.read();
            }
        }
        //System.out.println("Rašytojas pabaigė");
    }
}

class Reader implements CSProcess {
    private ChannelOutput channel;
    private ChannelInput replyChannel;
    public Reader(ChannelOutput channel, ChannelInput replyChannel) {
        this.channel = channel;
        this.replyChannel = replyChannel;
    }
    public void run() {
        int i = 0;
        double response = -1;
        while (response != -2) {
            this.channel.write(5);
            response = (double) this.replyChannel.read();
            if (response != -1)
            {
                i++;
                System.out.print(response);
                System.out.print("   ");
                System.out.print(i);
                System.out.println();
            }
        }
        //System.out.println("Reader finished");
    }
}

class ProcessManager implements CSProcess {

    private AltingChannelInput[] readerInputs;
    private AltingChannelInput[] writerInputs;
    private ChannelOutput[] readerReplyOutputs;
    private ChannelOutput[] writerReplyOutputs;
    private boolean[] statusBuffer;
    private boolean[] killedThreads;
    private List<Integer> saved_numbers;

    ProcessManager(One2OneChannel[] channels, One2OneChannel[] replyChannels) {
        writerInputs = new AltingChannelInput[4];
        writerReplyOutputs = new ChannelOutput[4];
        for (int i = 0; i < 4; i++) {
            writerInputs[i] = channels[i].in();
            writerReplyOutputs[i] = replyChannels[i].out();
        }
        
        readerInputs = new AltingChannelInput[1];
        readerReplyOutputs = new ChannelOutput[1];
        readerInputs[0] = channels[4].in();
        readerReplyOutputs[0] = replyChannels[4].out();
        
        this.statusBuffer = new boolean[5];
        this.killedThreads = new boolean[5];
        for (int i = 0; i < 5; i++) {
            statusBuffer[i] = true;
            killedThreads[i] = false;
        }
        
        this.saved_numbers = new ArrayList<Integer>();
    }

    public void run() {
        Alternative alternative = createGuards();
        while (!isKilled()) {
            boolean[] alive = isAlive();
            int choice = alternative.fairSelect(alive);
            if (choice >= 4) {
                reader();
            } else {
                writer(choice);
            }
        }
    }
    
    private void writer(int index) {
        //responses:    0- you must quit
        //              1- suceess
        //              -1- no success, try again
        ChannelInput inputChannel = writerInputs[index];
        ChannelOutput channel = writerReplyOutputs[index];
        int var = (int) inputChannel.read();
        if (var == -1)
        {
            statusBuffer[index] = false;
            killedThreads[index] = true;
            //quitMSG(channel);
        }
        statusBuffer[index] = true;
        if (saved_numbers.size() < 2)
        {
            saved_numbers.add(var);
            successMSG(channel);
        }
        else {
            failMSG(channel);
        }
    }
    
    private void reader() {
        ChannelInput inputChannel = readerInputs[0];
        ChannelOutput channel = readerReplyOutputs[0];
        int var = (int) inputChannel.read();
        if (isStop()) {
            stopMSG(channel, -2);
            killedThreads[4] = true;
        }
        if (saved_numbers.size() == 2)
        {
            double average = (saved_numbers.get(0) + saved_numbers.get(1)) / 2;
            saved_numbers.clear();
            continueMSG(channel, average);
        }
        else
        {
            continueMSG(channel, -1);
        }
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
    
    private void stopMSG(ChannelOutput channel, double success) {
        channel.write(success);
    }

    private void continueMSG(ChannelOutput channel, double success) {
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
    
     private Alternative createGuards() {
        Guard guards[] = new Guard[5];
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

}