`timescale 1ns / 1ps

module spi_lite_slave(
    input wire clk,             // ϵͳʱ��
    input wire rst_n,           // �첽��λ���͵�ƽ��Ч
    input wire spi_start,       // �����ź�
    input wire [7:0] datain,    // ����������
    output reg cs,              // Ƭѡ�ź�
    output reg sck,             // SPIʱ��
    output reg mosi,            // �������
    output reg spi_done         // ��������ź�
    );

// ��������
parameter DIV = 4;             // ��Ƶϵ��������SCK��Ƶ��
localparam IDLE = 2'b00;
localparam SEND = 2'b01;
localparam DONE = 2'b10;

// �ڲ��Ĵ���
reg [1:0] state;
reg [1:0] div_cnt;              // ��Ƶ������
reg [3:0] bit_cnt;              // ����λ������ (0~7��8λ)
reg [7:0] shift_reg;            // ������λ�Ĵ���

// Ψһϵͳʱ��������״̬�����߼�
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        state     <= IDLE;
        cs        <= 1'b1;      // ƬѡĬ������
        sck       <= 1'b0;      // Mode 0: ����ʱSCKΪ��
        mosi      <= 1'b0;
        spi_done  <= 1'b0;
        div_cnt   <= 2'd0;
        bit_cnt   <= 4'd0;
        shift_reg <= 8'd0;
    end else begin
        //spi_done <= 1'b0; 

        case (state)
            IDLE: begin
                cs  <= 1'b1;
                sck <= 1'b0;    // ����ǿ������
                div_cnt <= 2'd0;
                spi_done <= 1'b0;
                bit_cnt <= 4'd0;
                if (spi_start) begin
                    cs        <= 1'b0;        // Ƭѡ���ͣ�ͨ�ſ�ʼ
                    shift_reg <= datain;      // �������������
                    state     <= SEND;
                end
            end

            SEND: begin
                // ��Ƶ���� SCK �Ĳ���
                if (div_cnt == DIV - 1) begin
                    div_cnt <= 2'd0;
                    sck     <= ~sck;          // ��תSCK
                    if (sck == 1'b0) begin              
                        mosi      <= shift_reg[7];      // �Ƴ����λ
                        shift_reg <= {shift_reg[6:0], 1'b0}; // ��λ
                        bit_cnt   <= bit_cnt + 1'b1;    // λ��������
                    end
                end else begin
                    div_cnt <= div_cnt + 1'b1;
                end

                // �ж��Ƿ������ (������8��bit)
                if (bit_cnt == 4'd8 && div_cnt == DIV-1) begin
                    state <= DONE;
                end
            end

            DONE: begin
                sck <= 1'b0;            // ǿ��SCK�ص����е͵�ƽ
                cs  <= 1'b1;            // ������ϣ�����Ƭѡ
                spi_done <= 1'b1;       // �����������
                state <= IDLE;          // �Զ��ص�IDLE
            end

            default: state <= IDLE;
        endcase
    end
end

endmodule