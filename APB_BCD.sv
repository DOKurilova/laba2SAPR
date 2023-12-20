module APB_BCD
#(parameter control_reg_ADDR = 4'h0, // адрес контрольного регистра
  parameter operand_a_ADDR = 4'h4,   // адрес регистра с уменьшаемым
  parameter operand_b_ADDR = 4'h8,   // адрес регистра с вычитаемым
  parameter output_reg_ADDR = 4'hC)  // адрес регистра, где хранится выходное значение
(
    input wire PWRITE,            // сигнал, выбирающий режим записи или чтения (1 - запись, 0 - чтение)
    input wire PCLK,              // сигнал синхронизации
    input wire PSEL,              // сигнал выбора переферии 
    input wire [31:0] PADDR,             // Адрес регистра
    input wire [31:0] PWDATA,     // Данные для записи в регистр
    output reg [31:0] PRDATA = 0, // Данные, прочитанные из регистра
    input wire PENABLE,           // сигнал разрешения
    output reg PREADY = 0,         // сигнал готовности (флаг того, что всё сделано успешно)
	  input PRESET                   // сигнал сброса
);


reg  control_reg  = 0;  // регистр для выполнения операции
reg  [11:0] operand_a    = 0;  // регистр для хранения операнда a (8 слов по 4 бита)
reg  [11:0] operand_b    = 0;    // регистр для хранения операнда b (8 слов по 4 бита)
reg  [11:0] output_reg   = 0;  // регистр для хранения результата


reg [12:0] buf_reg = 0; // вспомогательный регистр


always @(posedge PCLK) 
begin
    if(PRESET)
	  begin
	    control_reg <= 0;
      operand_a   <= 0;
      operand_b   <= 0;
      output_reg  <= 0;
	  end
	  
     else if (PSEL && !PWRITE && PENABLE)   // Чтение из регистров 
     begin
        case(PADDR)
         control_reg_ADDR : PRDATA <= control_reg; // чтение по адресу контрольного регистра
         operand_a_ADDR   : PRDATA <= operand_a;   // чтение регистра с операндом a                   
         operand_b_ADDR   : PRDATA <= operand_b;   // чтение регистра с операндом b
         output_reg_ADDR  : PRDATA <= output_reg;  // чтение выходного регистра
        endcase
        PREADY <= 1'd1; // поднимаем флаг заверешения операции
     end

     else if(PSEL && PWRITE && PENABLE) // запись в регистры control_reg, operand_a, operand_b
     begin
       case(PADDR)
         control_reg_ADDR : control_reg <= PWDATA;   // запись по адресу контрольного регистра
         operand_a_ADDR   : operand_a   <= PWDATA;   // запись в регистр с операндом a
         operand_b_ADDR   : operand_b   <= PWDATA;   // запись в регистр с операндом b
        endcase
        PREADY <= 1'd1;    // поднимаем флаг заверешения операции
     end
   
   if (PREADY) // сбрасываем PREADY после выполнения записи или чтения
    begin
      PREADY <= !PREADY;
    end

   if(control_reg)
    begin
      control_reg <= !control_reg;
    end
  end

always @(posedge control_reg) begin // выполнение вычитания

  operand_b = ~(operand_b)+1; // берём доп код вычитаемого
  

  // проход по всем тетрадам (у нас их 8 т.к 32/4 = 8) для проверки на перенос из тетрад

    buf_reg [4:0] = operand_a[3:0] + operand_b[3:0];
    
    //проверка на наличие переноса из тетрады (4 разряда у тетрады)
    if(buf_reg [4]==0) //  если не было переноса, то прибавляем доп код 6: 1010
     begin
       buf_reg [3:0] = buf_reg [3:0] + 4'b1010; 
     end



  buf_reg [8:4] = buf_reg [4] + operand_a[7:4] + operand_b[7:4]; // сложение следующих тетрад + единицы переноса

    //проверка на наличие переноса из тетрады (4 разряда у тетрады)
    if( buf_reg [8]==0) //  если не было переноса, то прибавляем доп код 6: 1010
     begin
       buf_reg [7:4] = buf_reg [7:4] + 4'b1010;
     end


     buf_reg [12:8] = operand_a[11:8] + operand_b[11:8] + buf_reg [8]; 

    //проверка на наличие переноса из тетрады (4 разряда у тетрады)
    if(buf_reg [12]==0) //  если не было переноса, то прибавляем доп код 6: 1010
     begin
      buf_reg [11:8] = buf_reg[11:8] + 4'b1010;
     end


    output_reg = buf_reg;
  
end

//iverilog -g2012 -o APB_BCD.vvp APB_BCD_tb.sv
//vvp APB_BCD.vvp
endmodule