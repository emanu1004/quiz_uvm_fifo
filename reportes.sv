//Objeto que corresponde a trans_sb del ambiente por capas
class report_item extends uvm_sequence_item;
    //Variables necesarias
    bit [`width-1:0] dato;         //Dato de la transaccion
    int send_time;                 //Tiempo de envio
    int rcvd_time;                //Tiempo de recibido
    int estado;                    //Estado de transaccion (completado (1) o no (0))
    int overflow;                  //Indicador en caso de overflow
    int underflow;                 //Indicador en caso de underflow
    int reset;                     //Indicador en caso de reset
    int latencia;                  //Latencia de la transaccion

    //Inclusion en la fabrica mediante macros de campo
    `uvm_object_utils_begin(report_item)
        `uvm_field_int(dato, UVM_DEFAULT)
        `uvm_field_int(send_time, UVM_DEFAULT)
        `uvm_field_int(rcvd_time, UVM_DEFAULT)
        `uvm_field_int(estado, UVM_DEFAULT)
        `uvm_field_int(overflow, UVM_DEFAULT)
        `uvm_field_int(underflow, UVM_DEFAULT)
        `uvm_field_int(reset, UVM_DEFAULT)
        `uvm_field_int(latencia, UVM_DEFAULT)
    `uvm_object_utils_end

    //Declaracion explicita del constructor
    function new (string name = "report_item");
        super.new(name);
        this.latencia = 0;
    endfunction

    //Permite calcular la latencia de la transaccion
    task calc_latencia;
        this.latencia = this.rcvd_time - this.send_time;
    endtask



endclass
