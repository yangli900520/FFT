`define DATA_WIDTH     16
`define SHIFT_AMOUNT   14
`define P_PRODUCT_WIDTH 32
`define MAX_POINT      512
`define INDEX_WIDTH    $clog2(`MAX_POINT) - 1
typedef struct packed {
   logic signed  [`DATA_WIDTH - 1 : 0] data_r;
   logic signed  [`DATA_WIDTH - 1 : 0] data_i;
} DATA_SAMPLE;

typedef struct packed {
   DATA_SAMPLE                  data;
   logic                        valid;
} DATA_BUS;

typedef struct packed {
   logic                        valid;
} RX_TO_CONT;
typedef struct packed {
   logic                        valid;
} TX_TO_CONT;

typedef struct packed {
   logic  [3:0]                 point;
   logic  [17:0]                scaling;
   logic                        ifft;
} CONT_TO_COMP;
typedef struct packed {
   logic  [3:0]                 point;
   logic  [4:0]                final_shift;
   logic                        ifft;
} CONT_TO_TX;
