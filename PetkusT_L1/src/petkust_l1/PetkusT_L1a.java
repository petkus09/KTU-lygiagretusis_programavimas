package petkust_l1;

public class PetkusT_L1a {
    private String string_field;
    private int int_field;
    private double double_field;
    
    PetkusT_L1a(String C_string_field, int C_int_field, double C_double_field){
        string_field = C_string_field;
        int_field = C_int_field;
        double_field = C_double_field;
    }

    PetkusT_L1a() {
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
