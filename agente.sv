class agent extends uvm_agent;
    //Inclusion en la fabrica
    `uvm_component_utils(agent);

    //Declaracion explicita del constructor
    function new (string name = "agent", uvm_component parent = null);
        super.new(name,parent);
    endfunction

    //Declaracion de los modulos del agente
    driver_monitor drv_mon;
    uvm_sequencer #(fifo_item) s0;

    //Fase de construccion
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        //Instanciacion de los modulos del agente
        s0 = uvm_sequencer #(fifo_item)::type_id::create("s0", this);
        drv_mon = driver_monitor #(fifo_item)::type_id::create("drv_mon", this);
    endfunction

    //Fase de conexion
    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);

        //Conecta el secuenciador con el driver
        drv_mon.seq_item_port.connect(s0.seq_item_export);
    endfunction
endclass