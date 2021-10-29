class gen_item_seq_trans_rand extends uvm_sequence;
    //Inclusion en la fabrica
    `uvm_object_utils(gen_item_seq_trans_rand)

    //Declaracion explicita del constructor
    function new (string name = "gen_item_seq_trans_rand ");
        super.new(name);
    endfunction

    //Generacion de la transaccion
    virtual task body();
        //Instanciacion del objeto a través de la fábrica
        fifo_item f_item = fifo_item::type_id::create("f_item");
        start_item(f_item);

        //Randomiza la transaccion
        f_item.randomize();

        //Imprime su contenido 
        `uvm_info("SEQ", $sformatf("Se genero un nuevo item: ", f_item.convert2str()), UVM_HIGH)
        finish_item(f_item);

        //Se termino la generación de la secuencia de objetos de transaccion
        `uvm_info("SEQ", $sformatf("Se ha generado la transaccion aleatoria"), UVM_LOW)
    endtask
endclass