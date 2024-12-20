module WaterFlowMonitor (
    input wire clk,                    // System clock
    input wire reset,                  // Reset signal
    input wire [9:0] water_level_sensor,  // Water level sensor input
    input wire mode,                   // Mode: 1 for filling, 0 for draining
    output reg error_flag              // Error flag output
);

    // Parameters for threshold and time limit
    parameter THRESHOLD = 10;     // Minimum level change required
    parameter TIME_LIMIT = 5;  // Number of clock cycles to wait for change

    // Internal registers
    reg [9:0] previous_level;             // Stores previous water level
    reg [2:0] counter;                   // Counter for time limit
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            previous_level <= water_level_sensor;
            counter <= 0;
            error_flag <= 0;
        end else begin
            if (!error_flag) begin
                if (mode) begin
                    // Filling mode: Expect an increase in water level
                    if (water_level_sensor > previous_level + THRESHOLD) begin
                        // Water level increased by the required threshold
                        previous_level <= water_level_sensor;
                        counter <= 0;         // Reset counter on valid increase
                    end else begin
                        if (counter >= TIME_LIMIT) begin
                            // $display("Exceeded!");
                            // If counter exceeds time limit and no valid increase
                            error_flag <= 1;  // Set error flag
                        end else begin
                            counter <= counter + 1; // Increment counter
                        end
                    end
                end else begin
                    // Draining mode: Expect a decrease in water level
                    if (water_level_sensor < previous_level - THRESHOLD) begin
                        // Water level decreased by the required threshold
                        previous_level <= water_level_sensor;
                        counter <= 0;         // Reset counter on valid decrease
                    end else begin
                        if (counter >= TIME_LIMIT) begin
                            // If counter exceeds time limit and no valid decrease
                            error_flag <= 1;  // Set error flag
                        end else begin
                            counter <= counter + 1; // Increment counter
                        end
                    end
                end
            end
        end
    end
/*
psl default clock=rose(clk);
psl property RESET=always (reset==1 -> next(previous_level == prev(water_level_sensor) && !counter && !error_flag));
    psl assert RESET;
*/
/*
psl property NORMAL = always ((mode && !error_flag && !reset && (water_level_sensor > previous_level + THRESHOLD)) ->
    next(counter==0 && (previous_level <= water_level_sensor)));
psl assert NORMAL;
*/
/*
psl property ERROR = always ((counter >= TIME_LIMIT && !error_flag) ->
    next(error_flag));
psl assert ERROR;
*/
/*psl property COUNTER_INCREMENT = always ((!error_flag && !reset && (mode && water_level_sensor <= previous_level + THRESHOLD) && counter < TIME_LIMIT) ->
    next(counter == prev(counter) + 1));
    psl assert COUNTER_INCREMENT;
*/
endmodule