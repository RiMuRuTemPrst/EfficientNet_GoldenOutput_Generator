module pooling_controller (
    input wire clk,
    input wire rst_n,
    input wire valid_layer2,

    output reg init_phase_pooling,
    output reg we_pooling,
    output reg [31:0] read_addr_pooling,
    output reg [31:0] write_addr_pooling,
    output reg [1:0] control_data_pooling
);


reg [31:0] count_init_for_pooling;
reg [2:0] pooling_state;

localparam IDLE  = 3'd0,   // Chờ tín hiệu valid_layer2, kiểm tra count khởi tạo
           STEP0 = 3'd1,   // Ghi lần 1: control_data_pooling = 0
           STEP1 = 3'd2,   // Ghi lần 2: control_data_pooling = 1
           STEP2 = 3'd3,   // Ghi lần 3: control_data_pooling = 2
           STEP3 = 3'd4,   // Ghi lần 4: control_data_pooling = 3
           DONE  = 3'd5;   // Kết thúc ghi, quay lại IDLE

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        count_init_for_pooling <= 0;
        init_phase_pooling <= 1;
        we_pooling <= 0;
        read_addr_pooling <= 0;
        write_addr_pooling <= 0;
        control_data_pooling <= 0;
        pooling_state <= IDLE;
    end else begin
        case (pooling_state)
            // Trạng thái khởi đầu: chờ valid_layer2, tăng counter
            IDLE: begin
                if (valid_layer2) begin
                    count_init_for_pooling <= count_init_for_pooling + 1;
                    if (count_init_for_pooling > 48)
                        init_phase_pooling <= 0;
                    pooling_state <= STEP0;
                end else begin
                    we_pooling <= 0;
                end
            end

            // Bắt đầu ghi phần tử đầu tiên với control = 0
            STEP0: begin
                we_pooling <= 1;
                read_addr_pooling <= read_addr_pooling + 1;
                write_addr_pooling <= read_addr_pooling - 1;
                control_data_pooling <= 0;
                pooling_state <= STEP1;
            end

            // Ghi phần tử thứ hai với control = 1
            STEP1: begin
                read_addr_pooling <= read_addr_pooling + 1;
                write_addr_pooling <= read_addr_pooling - 1;
                control_data_pooling <= 1;
                pooling_state <= STEP2;
            end

            // Ghi phần tử thứ ba với control = 2
            STEP2: begin
                read_addr_pooling <= read_addr_pooling + 1;
                write_addr_pooling <= read_addr_pooling - 1;
                control_data_pooling <= 2;
                pooling_state <= STEP3;
            end

            // Ghi phần tử thứ tư với control = 3
            STEP3: begin
                read_addr_pooling <= read_addr_pooling + 1;
                write_addr_pooling <= read_addr_pooling - 1;
                control_data_pooling <= 3;
                pooling_state <= DONE;
            end

            // Dừng ghi, quay lại IDLE, reset nếu cần
            DONE: begin
                we_pooling <= 0;
                if (read_addr_pooling == 192)
                    read_addr_pooling <= 0;
                pooling_state <= IDLE;
            end

            default: pooling_state <= IDLE;
        endcase
    end
end

endmodule
