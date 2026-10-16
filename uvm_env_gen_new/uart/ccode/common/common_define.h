#ifndef __COMMOM_DEFINE_H__
#define __COMMOM_DEFINE_H__

#define     __I     volatile const    /*!< defines 'read only' permissions     */
#define     __O     volatile          /*!< defines 'write only' permissions    */
#define     __IO    volatile          /*!< defines 'read / write' permissions  */

typedef struct{
    __IO uint32_t END_SIM;      // used for core_sim_end
    __IO uint32_t OK_OR_ERROR;  // used for pint_ok & print_error
    __IO uint32_t LABEL;        // used for send_label & wait_label
    __IO uint32_t INFO;         // used for print_info
    __IO uint32_t DATA[20];
    __IO uint32_t STRING_head;
    __IO uint32_t STRING_info[32];
} Print_Info_TypeDef;

// TODO
#define SRAM0_END       0x20000000

#define PRINT_BASE      SRAM0_END + 1 - sizeof(Print_Info_TypeDef)
#define PRINT           ((volatile Print_Info_TypeDef *) (PRINT_BASE))

typedef enum {DISABLE = 0, ENABLE = !DISABLE} FunctionalState;
typedef enum {RESET = 0, SET = !RESET} FlagStatus;

#endif
