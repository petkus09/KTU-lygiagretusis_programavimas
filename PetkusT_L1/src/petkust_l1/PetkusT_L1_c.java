/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package petkust_l1;

/**
 *
 * @author petku_000
 */
public class PetkusT_L1_c extends Thread {
    private PetkusT_L1a[] file_data;
    private int array_size;
    private int thread_index;
    
    //Sukuriami gijos duomenys naudojami spausdinimui
    PetkusT_L1_c(PetkusT_L1a[] C_file_data, int C_array_size, int C_thread_index){
        file_data = C_file_data;
        array_size = C_array_size;
        thread_index = C_thread_index;
    }
    //Spausdinamos gijos
    public void run ()
   {
      for (int i = 0; i < array_size; i++)
      {
           System.out.println(String.format("%5s%5s%10s%5s%8s" ,thread_index, i, file_data[i].getString_field(), file_data[i].getInt_field(), file_data[i].getDouble_field()));
      }
   }
}
