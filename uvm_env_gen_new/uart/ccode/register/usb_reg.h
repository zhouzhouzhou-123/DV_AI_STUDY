// ----------------------------------------------------
// Copyright(C) 2024 Chipsea All rights reserved.
// File Name: usb_reg.h
// Author:    liucf
// Email:     liucf@chipsea.com
// Date:      2024-11-21
// ----------------------------------------------------

#ifndef __USB_REG_H__
#define __USB_REG_H__

typedef struct {
    __IO uint8_t   SIE_FAddr;        // 0x00
    __IO uint8_t   SIE_Power;        // 0x01
    __IO uint16_t  SIE_IntrIn;        // 0x02
    __IO uint16_t  SIE_IntrOut;        // 0x04
    __IO uint16_t  SIE_IntrInE;        // 0x06
    __IO uint16_t  SIE_IntrOutE;        // 0x08
    __IO uint8_t   SIE_IntrUSB;        // 0x0a
    __IO uint8_t   SIE_IntrUSBE;        // 0x0b
    __IO uint16_t  SIE_FrameNum;        // 0x0c
    __IO uint8_t   SIE_Index;        // 0x0e
    __IO uint8_t   SIE_Testmode;        // 0x0f

    __IO uint16_t  SIE_InMax;        // 0x10
    __IO uint16_t  SIE_InCSR;        // 0x12
    __IO uint16_t  SIE_OutMax;        // 0x14
    __IO uint16_t  SIE_OutCSR;        // 0x16
    __IO uint16_t  SIE_OutCount;        // 0x18
    __IO uint8_t   SIE_TxType;        // 0x1a
    __IO uint8_t   SIE_TxInterval;        // 0x1b
    __IO uint8_t   SIE_RxType;        // 0x1c
    __IO uint8_t   SIE_RxInterval;        // 0x1d
    __IO uint8_t   RESERV5;        // 0x1e
    __IO uint8_t   SIE_Configdata;        // 0x1f

    __IO uint32_t  EP_FIFOEn[9];        // 0x20-40
    __IO uint32_t  RESERV4[7];        // 0x44-5c

    __IO uint16_t  SIE_DevCtl;        // 0x60
    __IO uint8_t   SIE_TxFIFOsz;        // 0x62
    __IO uint8_t   SIE_RxFIFOsz;        // 0x63
    __IO uint16_t  SIE_TxFIFOadd;        // 0x64
    __IO uint16_t  SIE_RxFIFOadd;        // 0x66
    __IO uint16_t  RESERV0[2];        // 0x68-6a
    __IO uint16_t  SIE_HWVers;        // 0x6c //not use
    __IO uint16_t  RESERV1[5];        // 0x6e-76
    __IO uint8_t   SIE_EPInfo;        // 0x78
    __IO uint8_t   SIE_RAMInfo;        // 0x79
    __IO uint8_t   SIE_LinkInfo;        // 0x7a
    __IO uint8_t   SIE_VPLen;        // 0x7b
    __IO uint8_t   SIE_HS_EOPF1;        // 0x7c
    __IO uint8_t   SIE_FS_EOPF1;        // 0x7d
    __IO uint8_t   SIE_LS_EOPF1;        // 0x7e
    __IO uint8_t   RESERV2;        // 0x7f
    __IO uint32_t  RESERV3[320];        // 0x80-300
    __IO uint16_t  SIE_RqPktCount[15];        // 0x302 - 0x330
} USB_TYPEDEF;
#endif
