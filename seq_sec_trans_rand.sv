class gen_item_seq_sec_trans_rand extends uvm_sequence;
    //Inclusion en la fabrica
    `uvm_object_utils(gen_item_seq_sec_trans_rand)

    //Declaracion explícita del constructor
    function new (string name = "gen_item_seq_sec_trans_rand");
        super.new(name);
    endfunction

    //Numero total de items a ser enviados
    rand int num;

    //Limitación de los items
    constraint c1 {soft num inside {[1:10]}; }

    //Generacion de la secuencia
    virtual task body();
        for (int i=0; i<num; i++) begin
            //Instanciacion del objeto a traves de la fabrica
            fifo_item f_item = fifo_item::type_id::create("f_item");
            start_item(f_item);

            //Randomiza el objeto
            f_item.randomize();

            //Imprime su contenido 
            `uvm_info("SEQ", $sformatf("Se genero un nuevo item: ", f_item.convert2str()), UVM_HIGH)
            finish_item(f_item);

        end
    //Se termino la generación de la secuencia de objetos de transaccion
    `uvm_info("SEQ", $sformatf("Se ha generado la secuencia de transacciones aleatoria"), UVM_LOW)
    endtask
endclass