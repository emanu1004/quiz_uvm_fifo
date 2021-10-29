class driver_monitor extends uvm_driver #(fifo_item);
    //Inclusion en la fabrica
    `uvm_component_utils(driver_monitor)

    //Declaracion explicita del constructor
    function new (string name = "driver_monitor", uvm_component parent = null);
        super.new(name,parent);
    endfunction

    //Interfaz de conexion con el DUT
    virtual fifo_if vif;

    // Variable que permite gestionar el retardo de la transaccion
    int espera;  

    //Puero TLM para comunicacion con scoreboard
    uvm_blocking_put_port #(fifo_item) drv_scb;

    //Fase de construccion
    virtual function void build_phase (uvm_phase phase);
        super.build_phase(phase);
        //Busca la interfaz en la base de datos de configuracion
        if (!uvm_config_db#(virtual fifo_if)::get(this, "", "fifo_vif", vif))
            `uvm_fatal("DRV", "No se pudo encontrar la vif")

        //Construye el puerto de comunicacion con el scoreboard
        drv_scb = new("drv_scb", this);
    endfunction

    //Fase de corrida
    virtual task run_phase (uvm_phase phase);
        fifo_item f_item;  //Objeto de transacion

        //Resetea el DUT
        vif.rst = 0;
        @(posedge vif.clk);
        vif.rst = 1;
        @(posedge vif.clk);
        vif.rst = 0;

        //Inicializa señales para controlar el DUT
        vif.push = 0;
        vif.rst = 0;
        vif.pop = 0;
        vif.dato_in = 0;
        espera=0;

        forever begin
            //Espera por una transaccion a traves del puerto TLM
            `uvm_info("DRV", $sformatf("Espera por un item del secuenciador"), UVM_LOW)
            seq_item_port.get_next_item(f_item);
           
            //Activa la señales en el DUT dependiendo de la prueba
            drive_item(f_item);

            //Notifica que recibio el item para completar el handshake
            seq_item_port.item_done();
        end
    endtask
    
    virtual task drive_item (fifo_item f_item);
        @(posedge vif.clk);

            //Inicializa señales para controlar el DUT
            vif.push = 0;
            vif.rst = 0;
            vif.pop = 0;
            vif.dato_in = 0;
            espera=0;
            
            //Gestiona el retardo de la transaccion
            while (espera <= f_item.retardo) begin
                @(posedge vif.clk);
                espera = espera+1;
                vif.dato_in = f_item.dato;
            end

            //Envia la transaccion al DUT dependiendo del tipo de transaccion
            case (f_item.tipo)
                lectura: begin
                    f_item.dato = vif.dato_out;
                    @(posedge vif.clk)
                    vif.pop = 1;
                    `uvm_info("DRV", "Transaccion ejecutada", UVM_HIGH)    
                end
                escritura: begin
                    vif.push = 1;
                    `uvm_info("DRV", "Transaccion ejecutada", UVM_HIGH)                   
                end
                reset: begin
                    vif.rst = 1;
                    `uvm_info("DRV", "Transaccion ejecutada", UVM_HIGH)
                end
            endcase 

            //Se almacena el tiempo de ejecucion de la transaccion
            f_item.tiempo = $time;

            //Se envia la transaccion al scoreboard para ser chequeada
            drv_scb.put(f_item);
    endtask
endclass