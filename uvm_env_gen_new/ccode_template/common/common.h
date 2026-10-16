
#ifndef __COMMOM__H
#define __COMMOM__H

#include <string.h>
#include <stdlib.h>
#include <stdarg.h>

extern void nop_repeat (unsigned int time);

// ------- ccode print message -------- //
extern void print_ok        (int site);
extern void print_error     (int site);
extern void print_info      (uint32_t site);
extern void print_string    (const char *format, ...);

// ------- ccode interaction with SV -------- //
extern void ccode_send_label    (int label);
extern void ccode_wait_label    (int label);

extern void ccode_send_data     (int value, int index);
extern int  ccode_get_data      (int index);

extern void core_sim_end        (void);


// ------- check value -------- //
extern void check               (int actual_value, int expect_value, int label);

#endif
