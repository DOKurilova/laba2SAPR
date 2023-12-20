module APB_BCD_sub
#(parameter control_reg_ADDR = 4'h0, // адрес контрольного регистра
  parameter output_reg_ADDR = 4'h4, // адрес регистра, где хранится значение 
  parameter operand1 = 4'h6,
  parameter operand2 = 4'h8)
(
  input wire PWRITE, // сигнал, выбирающий режим записи или чтения (1 - 
запись, 0 - чтение)
  input wire PCLK,  // сигнал синхронизации
  input wire PSEL,  // сигнал выбора пееферии 
  input wire [31:0] PADDR, // Адрес регистра
  input wire [31:0] PWDATA,  // Данные для записи в регистр
  output reg [31:0] PRDATA = 0, // Данные, прочитанные из регистра
  input wire PENABLE,   // сигнал разрешения
  output reg PREADY = 0  // сигнал готовности 
);

reg [31:0] control_reg = 0; // регистр для записи значения x, где x принимает значения 0,1,2,3....
reg [31:0] output_reg  = 0; // регистр для хранения результата 
reg [11:0] operand1 = 0;
reg [11:0] operand2 = 0; 

always @(posedge PCLK) 
begin
  if (PSEL && !PWRITE && PENABLE) // Чтение из регистров 
  begin
    case(PADDR)
    4'h0: PRDATA <= control_reg; // чтение по адресу контрольного регистра
    4'h4: PRDATA <= output_reg; // чтение по адресу выходного регистра
    4'h6: PRDATA <= operand1; // чтение по адресу первого операнда
    4'h8: PRDATA <= operand2; // чтение по адресу второго операнда
    endcase
    PREADY <= 1'd1; // поднимаем флаг заверешения операции
  end

  else if(PSEL && PWRITE && PENABLE) // запись производится только в контрольный регистр, который хранит значение шага
  begin
   if(PADDR == control_reg_ADDR)
   begin
    control_reg <= PWDATA;
    PREADY <= 1'd1;  // поднимаем флаг заверешения операции
   end
  end
 
 if (PREADY) // сбрасываем PREADY после выполнения записи или чтения
  begin
   PREADY <= !PREADY;
  end
  
 end

always @(control_reg) begin // вычитание в BCD коде

  integer i;
  integer borrow = 0;
  for (i = 0; i < 12; i = i + 1) begin
    output_reg[i] = operandA[i] - operandB[i] - borrow;
    if (output_reg[i] < 0) begin
      output_reg[i] = output_reg[i] + 10;
      borrow = 1;
    end else begin
      borrow = 0;
    end
  end

end
endmodule
