#ifndef __COMMON__C
#define __COMMON__C

#include "common.h"

extern void nop_repeat (unsigned int time)
{
    uint32_t i;
    for(i=0;i<time;i++)
    {
        __NOP();
    }
}

// ------- ccode print message -------- //
extern void print_ok(int site)
{
    PRINT->OK_OR_ERROR = 0x55550000 | (site&0x0000ffff);
}

//  ccode print ERROR: SV will print UVM_ERROR
extern void print_error(int site)
{
    PRINT->OK_OR_ERROR = 0xAAAA0000 | (site&0x0000ffff);
}
extern void print_info(uint32_t site)
{
    PRINT->INFO = site;
}
extern void print_string(const char *format, ...)    {
    va_list args;
    int arg_num = 0;
    const int *arg[5];
    char *format_char;
    const char *str_copy;
    uint32_t char_num, word_num, *char_tmp;

    str_copy = format;
    format_char = (char *)malloc(128);

    for(;*str_copy != 0x0;str_copy++) { //null
        if (*str_copy != 0x25) //"%"
            continue;
        else
            arg_num++;
    }

    va_start(args,format);
    if(arg_num > 0)
        for(int i=0;i<arg_num;i++) {
            arg[i] = va_arg(args, const int *);
        }
    va_end(args);

    switch(arg_num) {
        case 0: strcpy(format_char,format); break;
        case 1: snprintf(format_char,128,format,arg[0]); break;
        case 2: snprintf(format_char,128,format,arg[0],arg[1]); break;
        case 3: snprintf(format_char,128,format,arg[0],arg[1],arg[2]); break;
        case 4: snprintf(format_char,128,format,arg[0],arg[1],arg[2],arg[3]); break;
        case 5: snprintf(format_char,128,format,arg[0],arg[1],arg[2],arg[3],arg[4]); break;
        default: return;
    }


    char_num = strlen(format_char) + 1;//string lenth

    if(char_num%4 != 0)
    {
        word_num = char_num / 4 + 1;
    } else {
        word_num = char_num / 4;
    }
    char_tmp =  (uint32_t *)malloc(word_num);

    char_tmp = (uint32_t *)format_char;

    PRINT->STRING_head = 0x5aa50000 | (char_num);
    for(int i=0;i<word_num;i++) {
        PRINT->STRING_info[i] = *(char_tmp+i);
    }
    free(format_char);
    format_char = NULL;
    free(char_tmp);
    char_tmp = NULL;

    #ifdef __CACHE_EN__
        SCB_CleanDCache();
    #endif
}

// ------- ccode interaction with SV -------- //
extern void ccode_send_data(int index, int value)
{
    PRINT->DATA[index] = value;
}
extern int ccode_get_data(int index)
{
    return PRINT->DATA[index];
}
// ccode sent label to SV
extern void ccode_send_label(int label)
{
    PRINT->LABEL = label;
}
// ccode wait label from SV
extern void ccode_wait_label(int label)
{
    while(1)
    {
        if(PRINT->LABEL == label)
        {
            break;
        }
        nop_repeat(2);
    }
}
extern void core_sim_end(void)
{
    PRINT->END_SIM = 0x363000aa;
    while(1) {};
}
// ------- check value -------- //
void check(int actual_value, int expect_value, int label)
{
    if(actual_value != expect_value)
    {
        print_error(label);
    } else{
        print_ok(label);
    }
}



#endif


