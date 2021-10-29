class env extends uvm_env;
    //Inclusion en la fabrica
    `uvm_component_utils(env)

    //Declaracion explicita del constructor
    function new (string name = "env", uvm_component parent = null);
        super.new(name,parent);
    endfunction

    //Declaracion de los modulos del ambiente
    agent a0;
    scoreboard sb0;

    //Fase de construcción
    virtual function void build_phase (uvm_phase phase);
        super.build_phase(phase);

        //Instanciacion de los modulos a traves de la fabrica
        a0 = agent::type_id::create("a0", this);
        sb0 = scoreboard::type_id::create("sb0", this);
    endfunction

    //Fase de conexion
    virtual function void connect_phase (uvm_phase phase);
        super.connect_phase(phase);

        //Conecta el monitor con el scorboard
        a0.drv_mon.drv_scb.connect(sb0.drv_scb);
    endfunction
endclass