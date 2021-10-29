class gen_item_seq_rand_fill extends uvm_sequence;

    //Inclusion en la fabrica
    `uvm_object_utils(gen_item_seq_rand_fill)

    //Declaracion explícita del constructor
    function new (string name = "gen_item_seq_rand_fill");
        super.new(name);
    endfunction
    //Variables internas
    tipo_trans tpo_spec;

    //Numero total de items a ser enviados
    rand int num;

    //Limitación de los items
    constraint c1 {soft num inside {[1:10]}; }

    //Generacion de la secuencia
    virtual task body();

        //Para las transacciones de escritura
        for (int i=0; i<num; i++) begin
            //Instancia el objeto de transacción a través de la fábrica
            fifo_item f_item = fifo_item::type_id::create("f_item");
            start_item(f_item);

            //Randomiza el objeto de transaccion
            f_item.randomize();

            //Define las escrituras
            tpo_spec = escritura;
            f_item.tipo = tpo_spec;

            //Imprime su contenido
            `uvm_info("SEQ", $sformatf("Se genero un nuevo item: ", f_item.convert2str()), UVM_HIGH)
            finish_item(f_item);
        end
        
        //Para las transacciones de lectura
        for (int i=0; i<num; i++) begin
            //Instancia el objeto de transacción a través de la fábrica
            fifo_item f_item = fifo_item::type_id::create("f_item");
            start_item(f_item);

            //Randomiza el objeto de transaccion
            f_item.randomize();

            //Define las lecturas
            tpo_spec = lectura;
            f_item.tipo = tpo_spec;

            //Imprime su contenido
            `uvm_info("SEQ", $sformatf("Se genero un nuevo item: ", f_item.convert2str()), UVM_HIGH)
            finish_item(f_item);
        end

        //Se termino la generación de la secuencia de objetos de transaccion
        `uvm_info("SEQ", $sformatf("Se han generado %0d items para llenado aleatorio", num), UVM_LOW)
    endtask
endclass
