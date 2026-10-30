// Tang Nano 9K vending machine: 10-unit coin button and 50-unit product button.
// Buttons and onboard LEDs are active-low. The 27 MHz clock is on pin 52.
module vending_machine (
    input  wire clk,
    input  wire btn_coin_n,
    input  wire btn_buy50_n,
    output wire led_bought30_n,
    output wire led_bought50_n,
    output wire led_insufficient_n,
    output wire led_reached50_n
);

    wire coin_press;
    wire buy50_press;
    // Store the balance in tens to avoid carrying an unused least-significant bit.
    reg [2:0] balance_tens = 3'd0;
    reg bought30 = 1'b0;
    reg bought50 = 1'b0;
    reg insufficient = 1'b0;

    button_press_debounce coin_button (
        .clk(clk), .button_n(btn_coin_n), .press(coin_press)
    );

    button_press_debounce buy50_button (
        .clk(clk), .button_n(btn_buy50_n), .press(buy50_press)
    );

    // A coin press adds 10 until 50 is available. Pressing the coin button
    // again at 50 buys the 30-unit product and leaves 20 units.
    // The other button buys the 50-unit product or records an error.
    always @(posedge clk) begin
        if (buy50_press) begin
            if (balance_tens >= 3'd5) begin
                balance_tens <= balance_tens - 3'd5;
                bought30 <= 1'b0;
                bought50 <= 1'b1;
                insufficient <= 1'b0;
            end else begin
                insufficient <= 1'b1;
            end
        end else if (coin_press) begin
            if (balance_tens >= 3'd5) begin
                balance_tens <= balance_tens - 3'd3;
                bought30 <= 1'b1;
                bought50 <= 1'b0;
                insufficient <= 1'b0;
            end else begin
                balance_tens <= balance_tens + 3'd1;
            end
        end

    end

    // A simultaneous button press gives the 50-unit purchase command priority.
    // Threshold LED is on whenever the current balance is at least 50.
    assign led_bought30_n = ~bought30;
    assign led_bought50_n = ~bought50;
    assign led_insufficient_n = ~insufficient;
    assign led_reached50_n = ~(balance_tens >= 3'd5);

endmodule

// Synchronize and debounce an active-low mechanical button. press is a
// one-clock pulse on each debounced press, so holding the button counts once.
module button_press_debounce #(
    parameter integer CLK_HZ = 27000000,
    parameter integer DEBOUNCE_MS = 10
) (
    input wire clk,
    input wire button_n,
    output reg press = 1'b0
);
    localparam integer LIMIT = (CLK_HZ / 1000) * DEBOUNCE_MS;
    localparam integer COUNT_W = $clog2(LIMIT + 1);

    reg sync_1 = 1'b1;
    reg sync_2 = 1'b1;
    reg stable_n = 1'b1;
    reg [COUNT_W-1:0] count = {COUNT_W{1'b0}};

    always @(posedge clk) begin
        sync_1 <= button_n;
        sync_2 <= sync_1;
        press <= 1'b0;

        if (sync_2 == stable_n) begin
            count <= {COUNT_W{1'b0}};
        end else if (count == LIMIT - 1) begin
            stable_n <= sync_2;
            count <= {COUNT_W{1'b0}};
            if (sync_2 == 1'b0)
                press <= 1'b1;
        end else begin
            count <= count + 1'b1;
        end
    end
endmodule
