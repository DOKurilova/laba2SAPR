`include "APB_master.sv"
`include "APB_BCD.sv"
module APB_BCD_tb;



reg PCLK = 0;                   // сигнал синхронизации
reg PWRITE_MASTER = 0;          // сигнал, выбирающий режим записи или чтения (1 - запись, 0 - чтение)
wire PSEL;                      // сигнал выбора переферии
reg [31:0] PADDR_MASTER = 0;    // Адрес регистра
reg [31:0] PWDATA_MASTER = 0;   // Данные для записи в регистр
wire [31:0] PRDATA_MASTER;       // Данные, прочитанные из слейва
wire PENABLE;                    // сигнал разрешения, формирующийся в мастер APB
reg PRESET = 0;                   // сигнал сброса
wire PREADY;                      // сигнал готовности (флаг того, что всё сделано успешно)
wire [31:0] PADDR;                // адрес, который мы будем передавать в слейв
wire [31:0] PWDATA;               // данные, которые будут передаваться в слейв,
wire [31:0] PRDATA ;              // данные, прочтённые с слейва
wire PWRITE;                      // сигнал записи или чтения на вход слейва

APB_master APB_master_1 (
    .PCLK(PCLK),
    .PWRITE_MASTER(PWRITE_MASTER),
    .PSEL(PSEL),
    .PADDR_MASTER(PADDR_MASTER),
    .PWDATA_MASTER(PWDATA_MASTER),
    .PRDATA_MASTER(PRDATA_MASTER),
    .PENABLE(PENABLE),
    .PRESET(PRESET),
    .PREADY(PREADY),
    .PADDR(PADDR),
    .PWDATA(PWDATA),
    .PRDATA(PRDATA),
    .PWRITE(PWRITE)
);

APB_BCD APB_BCD_1 (
    .PWRITE(PWRITE),
    .PSEL(PSEL),
    .PADDR(PADDR),
    .PWDATA(PWDATA),
    .PRDATA(PRDATA),
    .PENABLE(PENABLE),
    .PREADY(PREADY),
    .PCLK(PCLK)
);



always #200 PCLK = ~PCLK; // генерация входного сигнала Pclk

initial begin
    
PCLK = 0;
@(posedge PCLK);

PWRITE_MASTER = 1;           // выбираем запись
PWDATA_MASTER = 12'b1000_1000_0110;       
PADDR_MASTER = 4'h4;           // выбираем адрес регистра операнда a
@(posedge PCLK);
@(posedge PCLK);

PWRITE_MASTER = 1;           // выбираем запись
PWDATA_MASTER = 12'b0110_1001_0011;       
PADDR_MASTER = 4'h8;           // выбираем адрес регистра операнда b
@(posedge PCLK);
@(posedge PCLK);

PWRITE_MASTER = 1;           // выбираем запись
PWDATA_MASTER = 1;      
PADDR_MASTER = 4'h0;           // выбираем адрес контрольного регистра
@(posedge PCLK);
@(posedge PCLK);




 #500 $finish; // Заканчиваем симуляцию
end




initial begin
$dumpfile("APB_BCD.vcd"); // создание файла для сохранения результатов симуляции
$dumpvars(0, APB_BCD_tb); // установка переменных для сохранения в файле
$dumpvars;
end


endmodule
