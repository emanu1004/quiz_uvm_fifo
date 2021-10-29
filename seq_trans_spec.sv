class gen_item_seq_trans_spec extends uvm_sequence;
    //Inclusion en la fabrica
    `uvm_object_utils(gen_item_seq_trans_spec) 

    //Declaracion explicita del constructor
    function new (string name = "gen_item_seq_trans_spec");
        super.new(name);
    endfunction

    //Parametros especificos que se pasan desde el test
    int ret_spec;
    tipo_trans tpo_spec;
    bit [16-1:0] dto_spec;

    //Generacion de la transaccion
    virtual task body();
        //Instanciacion del objeto a través de la fábrica
        fifo_item f_item = fifo_item::type_id::create("f_item");
        start_item(f_item);

        //Seteo de los parametros especificos
        f_item.dato = dto_spec;
        f_item.retardo = ret_spec;
        f_item.tipo = tpo_spec;

        //Imprime su contenido 
        `uvm_info("SEQ", $sformatf("Se genero un nuevo item: ", f_item.convert2str()), UVM_HIGH)
        finish_item(f_item);

        //Se termino la generación de la secuencia de objetos de transaccion
        `uvm_info("SEQ", $sformatf("Se ha generado la transaccion especifica"), UVM_LOW)
    endtask
endclass