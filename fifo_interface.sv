//Tipos de transacciones
typedef enum {lectura, escritura, reset} tipo_trans;

//Interfaz para conectar el DUT con el agente
interface fifo_if #(parameter width =16);
  logic clk;
  logic rst;
  logic pndng;
  logic full;
  logic push;
  logic pop;
  logic [width-1:0] dato_in; 
  logic [width-1:0] dato_out;

  // Generacion de reloj
  initial begin
    clk = 0;
    forever begin
       #10;
       clk = ~clk;
    end
 end
endinterface