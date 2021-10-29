class scoreboard #(parameter depth = 10) extends uvm_scoreboard;
    //Inclusion en la fabrica
    `uvm_component_utils(scoreboard)

    //Declaracion explicita del constructor
    function new (string name = "scoreboard", uvm_component parent = null);
        super.new(name,parent);
    endfunction

    //Objeto de transaccion recibido desde el driver_monitor
    fifo_item f_item;

    //Puerto TLM para comunicacion con el driver_monitor
    uvm_blocking_put_imp #(fifo_item, scoreboard) drv_scb;

    //Emula el comportamiento de la fifo
    fifo_item emul_fifo[$];

    //Almacena las transacciones enviadas hacia el DUT
    fifo_item send_trans[$];

    //Almacena las transacciones recibidas desde el DUT
    fifo_item rcvd_trans[$];

    //Transacion auxiliar utilizada durante el chequeo de las transacciones enviadas
    fifo_item send_aux;

    //Transacion auxiliar utilizada durante el chequeo de las transacciones recibidas
    fifo_item rcvd_aux;

    //Objeto de transaccion para los reportes
    report_item report_trans;

    //Cola Auxiliar para la generacione de los reportes
    report_item cola_report[$];

    //Variables para los reportes
    shortreal ret_prom;     //Retardo promedio
    int trans_complt;       //Numero de transacciones completadas
    int ret_total;          //Retardo total
    int trans_error;        //Numero de transacciones con error

    //Contador para generar los reportes
    int contador;

    //Contador para gestionar el caso de reset
    int contador_auxiliar;

    //Fase de construccion
    virtual function void build_phase (uvm_phase phase);
        super.build_phase(phase);

        //Construye el puerto de comunicacion con el driver_monitor
        drv_scb = new("drv_scb", this);
    endfunction

    //Coloca las transaccion en las colas auxiliares correspondientes (send o rcvd)
    virtual task put (fifo_item f_item);
        `uvm_info("SCBD", "transaction recibida desde driver", UVM_HIGH)
        send_trans.push_back(f_item);
        if (f_item.tipo == lectura) begin
            rcvd_trans.push_back(f_item);
        end
    endtask

    //Fase de chequeo
    function void check_phase(uvm_phase phase);
        //Instanciacion del objeto de transaccion a traves de la fabrica
        report_trans = report_item::type_id::create("report_trans", this);

        //Inicializa los contadores para los reportes
        trans_error = 0;
        trans_complt = 0;

        //Comienza el chequeo dependiendo del tipo de transaccion
        //Mientras haya transacciones para chequear
        while (send_trans.size >0) begin

            //Obtiene la transaccion enviada para chequear
            f_item = send_trans.pop_front;

            //Dependiendo del tipo de transaccion
            case(f_item.tipo)
                lectura: begin
                    //Revisa si la FiFo no esta vacia
                    if (0 !== emul_fifo.size()) begin
                        send_aux = emul_fifo.pop_front();
                        rcvd_aux = rcvd_trans.pop_front();

                        //Realiza la comparacion entre la transaccion enviada y la recibida del DUT
                        //Si son iguales, se notifica una transaccion completada y se genera el reporte 
                        if(rcvd_aux.dato == send_aux.dato) begin
                            //Nuevo objeto de reporte
                            report_trans = new;

                            //Genera el reporte
                            report_trans.dato = send_aux.dato;
                            report_trans.send_time = send_aux.tiempo;
                            report_trans.rcvd_time = rcvd_aux.tiempo;
                            //Confirma que se completo la transaccion
                            trans_complt++;
                            report_trans.estado = 1;
                            report_trans.calc_latencia();
                            
                            //Agrega la transaccion a la cola de reportes
                            cola_report.push_back(report_trans);
                            `uvm_info("SCBD", $sformatf("PASS Transaccion exitosa Dato_leido= %h, Dato_Esperado = %h", send_aux.dato, rcvd_aux.dato),UVM_LOW)
                        end

                        else begin
                            //Si no son iguales, se notifica una transaccion erronea
                            `uvm_error("SCBD", $sformatf("ERROR Transaccion erronea Dato_leido= %h, Dato_Esperado = %h", send_aux.dato, rcvd_aux.dato))
                            trans_error++;
                        end
                    end

                    //Si esta vacia, se genera un underflow
                    else begin
                        //Nuevo objeto de reporte
                        report_trans = new;
                        report_trans.rcvd_time = send_aux.tiempo;
                        report_trans.underflow = 1;

                        //Agrega la transaccion a la cola de reportes
                        cola_report.push_back(report_trans);
                        `uvm_info("SCBD", $sformatf("Condicion de underflow"), UVM_LOW)
                    end
                end

                escritura: begin
                    //Revisa si la FiFo esta llena para generar un overflow
                    if(emul_fifo.size() == depth) begin
                        //Nuevo objeto de reporte
                        report_trans = new;
                        report_trans.dato = send_aux.dato;
                        report_trans.send_time = send_aux.tiempo;
                        report_trans.overflow = 1;

                        //Agrega la transaccion a la cola de reportes
                        cola_report.push_back(report_trans);
                        `uvm_info("SCBD", $sformatf("Condicion de overflow"), UVM_LOW)
                        emul_fifo.push_back(f_item);
                    end
                    //De lo contrario, guarda el dato en la FiFo simulada
                    else begin
                        `uvm_info("SCBD", $sformatf("Escritura"), UVM_LOW)
                        emul_fifo.push_back(f_item);
                    end
                end

                //En caso de reset, vacia la FiFo simulada y envia todos los datos perdidos al scoreboard
                reset: begin
                    contador_auxiliar = emul_fifo.size();
                    for(int i =0; i<contador_auxiliar; i++) begin
                        send_aux = emul_fifo.pop_front();

                        //Nuevo objeto de reporte
                        report_trans = new;
                        report_trans.dato = send_aux.dato;
                        report_trans.send_time = send_aux.tiempo;
                        report_trans.reset = 1;
                        `uvm_info("SCBD", $sformatf("Escritura"), UVM_LOW)

                        //Agrega la transaccion a la cola de reportes
                        cola_report.push_back(report_trans);
                    end  
                end
            endcase
        end
    endfunction

    //Fase de generacion de reportes
    function void report_phase(uvm_phase phase);
        super.report_phase(phase);

        //Reporte de retardo promedio
        if ($test$plusargs("RET_PROM")) begin
            ret_total = 0;

            //Para cada una de las transacciones completadas
            foreach (cola_report[i]) begin
                if (cola_report[i].estado) begin
                    ret_total = ret_total + cola_report[i].latencia; //Va sumando la latencia de cada una de las transacciones
                end
            end

            //Calcula el retardo promedio
            ret_prom = ret_total/trans_complt;

            //Imprime el reporte
            `uvm_info("SCBD", $sformatf("----------Retardo promedio-------"), UVM_LOW)
            `uvm_info("SCBD", $sformatf("Transacciones completadas: 0%d", trans_complt), UVM_LOW)
            `uvm_info("SCBD", $sformatf("Retardo promedio: 0%d [ns]", ret_prom), UVM_LOW)
        
        //Reporte completo
        if ($test$plusargs("RET_PROM")) begin
            `uvm_info("SCBD", $sformatf("----------Reporte completo-------"), UVM_LOW)

            //Para cada reporte imprime el contenido
            foreach (cola_report[i]) begin
                `uvm_info("SCBD", $sformatf("Transacciones [0%d]. Contenido: %s ", i, cola_report[i].sprint()), UVM_LOW)
            end

            //Transacciones totales
            `uvm_info("SCBD", $sformatf("Transacciones totales: 0%d", trans_complt), UVM_LOW)
            `uvm_info("SCBD", $sformatf("Transacciones erroneas: 0%d", trans_complt),UVM_LOW)
            `uvm_info("SCBD", $sformatf("Transacciones satisfactorias: 0%d", trans_complt - trans_error),UVM_LOW)

            //Transacciones con overflow
            contador = 0;
            foreach(cola_report[i]) begin
                if (cola_report[i].overflow) begin
                  contador++;
                end
            end
            `uvm_info("SCBD", $sformatf("Transacciones con overflow: 0%d", contador),UVM_LOW)

            //Transacciones con underflow
            contador = 0;
            foreach(cola_report[i]) begin
                if (cola_report[i].underflow) begin
                  contador++;
                end
            end
            `uvm_info("SCBD", $sformatf("Transacciones con underflow: 0%d", contador),UVM_LOW)

            //Transacciones con reset
            contador = 0;
            foreach(cola_report[i]) begin
                if (cola_report[i].reset) begin
                  contador++;
                end
            end
            `uvm_info("SCBD", $sformatf("Transacciones con reset: 0%d", contador),UVM_LOW)  
        end
    endfunction
endclass