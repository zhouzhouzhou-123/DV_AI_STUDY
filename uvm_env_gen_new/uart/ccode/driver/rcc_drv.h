#ifndef ___RCC_DRV_H__
#define ___RCC_DRV_H__


typedef enum {HRC=1,HXT,PLL,LXT,LRC} Chip_Clk;

void    RCC_CLK_Enable          (Chip_Clk clk);

#endif
