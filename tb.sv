`define width 16
`include "fifo_interface.sv"
`include "sequence_item.sv"
`include "reportes.sv"
`include "seq_llenado_aleatorio.sv"
`include "seq_trans_aleatoria.sv"
`include "seq_trans_spec.sv"
`include "seq_sec_trans_rand.sv"
`include "drv_mon.sv"
`include "agente.sv"
`include "scoreboard.sv"
`include "ambiente.sv"
`include "test.sv"

//Testbench
module tb;

    //Definicion de los parametros
    parameter depth = 10;

    //Declaracion de la interfaz
    fifo_if #(.width(`width)) _if ();

    //Instanciacion del DUT
    fifo_flops #(.depth(depth), .bits(width)) uut(
        .Din(_if.dato_in),
        .Dout(_if.dato_out),
        .push(_if.push),
        .pop(_if.pop),
        .clk(_if.clk),
        .full(_if.full),
        .pndng(_if.pndng),
        .rst(_if.rst)
    );

    //Inicio del test
    initial begin
        //Incluye la interfaz dentro de la base de datos configuracion
        uvm_config_db#(virtual fifo_if)::set(null, "uvm_test_top", "fifo_vif", _if);

        //Corre el test
        run_test("test");
    end
endmodule
