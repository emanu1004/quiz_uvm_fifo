//Objeto que corresponde a trans_fifo del ambiente por capas
class fifo_item extends uvm_sequence_item;
    rand int retardo;
    rand bit [`width-1:0] dato ;
    int tiempo;
    rand tipo_trans tipo;
    int max_retardo;

   constraint c1 {retardo inside {[0:max_retardo]};}


    //Inclusion en la fábrica mediante macros de campo
    `uvm_object_utils_begin(fifo_item)
        `uvm_field_int(retardo, UVM_DEFAULT)
        `uvm_field_int(dato, UVM_DEFAULT)
        `uvm_field_int(tiempo, UVM_DEFAULT)
        `uvm_field_int(tipo, UVM_DEFAULT)
        `uvm_field_int(max_retardo, UVM_DEFAULT)
    `uvm_object_utils_end

    //Declaracion explicita del constructor
    function new (string name = "fifo_item");
        super.new(name);
    endfunction

     //Función para mostrar el contenido en formato string
    virtual function string convert2str();
        return $sformatf("retardo=0%d, dato=0%d, tiempo=0%d", retardo, dato, tiempo);
    endfunction 

endclass