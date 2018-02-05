/**********************************************************************/
/*   ____  ____                                                       */
/*  /   /\/   /                                                       */
/* /___/  \  /                                                        */
/* \   \   \/                                                       */
/*  \   \        Copyright (c) 2003-2009 Xilinx, Inc.                */
/*  /   /          All Right Reserved.                                 */
/* /---/   /\                                                         */
/* \   \  /  \                                                      */
/*  \___\/\___\                                                    */
/***********************************************************************/

/* This file is designed for use with ISim build 0x7708f090 */

#define XSI_HIDE_SYMBOL_SPEC true
#include "xsi.h"
#include <memory.h>
#ifdef __GNUC__
#include <stdlib.h>
#else
#include <malloc.h>
#define alloca _alloca
#endif
static const char *ng0 = "C:/Users/e1538867/Desktop/VHDL_GUITAR_PEDAL/VHDL_GUITAR_PEDAL/VHDL/modules/I2S Interface/I2S_TO_PARALLEL.vhd";
extern char *IEEE_P_2592010699;

unsigned char ieee_p_2592010699_sub_1258338084_503743352(char *, char *, unsigned int , unsigned int );
unsigned char ieee_p_2592010699_sub_1744673427_503743352(char *, char *, unsigned int , unsigned int );


static void work_a_3860840486_3212880686_p_0(char *t0)
{
    char *t1;
    char *t2;
    unsigned char t3;
    unsigned char t4;
    char *t5;
    char *t6;
    char *t7;
    char *t8;
    char *t9;
    char *t10;
    int t11;
    int t12;
    int t13;
    int t14;
    unsigned int t15;
    unsigned int t16;
    unsigned int t17;
    unsigned char t18;
    char *t19;
    char *t20;
    unsigned char t21;
    unsigned char t22;

LAB0:    xsi_set_current_line(56, ng0);
    t1 = (t0 + 2312U);
    t2 = *((char **)t1);
    t3 = *((unsigned char *)t2);
    t4 = (t3 == (unsigned char)2);
    if (t4 != 0)
        goto LAB2;

LAB4:    t1 = (t0 + 1152U);
    t3 = ieee_p_2592010699_sub_1258338084_503743352(IEEE_P_2592010699, t1, 0U, 0U);
    if (t3 != 0)
        goto LAB5;

LAB6:    t1 = (t0 + 1152U);
    t3 = ieee_p_2592010699_sub_1744673427_503743352(IEEE_P_2592010699, t1, 0U, 0U);
    if (t3 != 0)
        goto LAB12;

LAB13:
LAB3:    t1 = (t0 + 4952);
    *((int *)t1) = 1;

LAB1:    return;
LAB2:    xsi_set_current_line(58, ng0);
    t1 = xsi_get_transient_memory(24U);
    memset(t1, 0, 24U);
    t5 = t1;
    memset(t5, (unsigned char)2, 24U);
    t6 = (t0 + 5032);
    t7 = (t6 + 56U);
    t8 = *((char **)t7);
    t9 = (t8 + 56U);
    t10 = *((char **)t9);
    memcpy(t10, t1, 24U);
    xsi_driver_first_trans_fast_port(t6);
    xsi_set_current_line(59, ng0);
    t1 = xsi_get_transient_memory(24U);
    memset(t1, 0, 24U);
    t2 = t1;
    memset(t2, (unsigned char)2, 24U);
    t5 = (t0 + 5096);
    t6 = (t5 + 56U);
    t7 = *((char **)t6);
    t8 = (t7 + 56U);
    t9 = *((char **)t8);
    memcpy(t9, t1, 24U);
    xsi_driver_first_trans_fast_port(t5);
    xsi_set_current_line(60, ng0);
    t1 = (t0 + 3528U);
    t2 = *((char **)t1);
    t1 = (t2 + 0);
    *((int *)t1) = 24;
    xsi_set_current_line(61, ng0);
    t1 = (t0 + 3648U);
    t2 = *((char **)t1);
    t1 = (t2 + 0);
    *((int *)t1) = 24;
    xsi_set_current_line(62, ng0);
    t1 = xsi_get_transient_memory(24U);
    memset(t1, 0, 24U);
    t2 = t1;
    memset(t2, (unsigned char)2, 24U);
    t5 = (t0 + 5160);
    t6 = (t5 + 56U);
    t7 = *((char **)t6);
    t8 = (t7 + 56U);
    t9 = *((char **)t8);
    memcpy(t9, t1, 24U);
    xsi_driver_first_trans_fast(t5);
    xsi_set_current_line(63, ng0);
    t1 = xsi_get_transient_memory(24U);
    memset(t1, 0, 24U);
    t2 = t1;
    memset(t2, (unsigned char)2, 24U);
    t5 = (t0 + 5224);
    t6 = (t5 + 56U);
    t7 = *((char **)t6);
    t8 = (t7 + 56U);
    t9 = *((char **)t8);
    memcpy(t9, t1, 24U);
    xsi_driver_first_trans_fast(t5);
    xsi_set_current_line(64, ng0);
    t1 = (t0 + 5288);
    t2 = (t1 + 56U);
    t5 = *((char **)t2);
    t6 = (t5 + 56U);
    t7 = *((char **)t6);
    *((unsigned char *)t7) = (unsigned char)2;
    xsi_driver_first_trans_fast_port(t1);
    goto LAB3;

LAB5:    xsi_set_current_line(67, ng0);
    t2 = (t0 + 3648U);
    t5 = *((char **)t2);
    t11 = *((int *)t5);
    t4 = (t11 > 0);
    if (t4 != 0)
        goto LAB7;

LAB9:    t1 = (t0 + 3648U);
    t2 = *((char **)t1);
    t11 = *((int *)t2);
    t3 = (t11 == 0);
    if (t3 != 0)
        goto LAB10;

LAB11:
LAB8:    goto LAB3;

LAB7:    xsi_set_current_line(69, ng0);
    t2 = (t0 + 2792U);
    t6 = *((char **)t2);
    t2 = (t0 + 3648U);
    t7 = *((char **)t2);
    t12 = *((int *)t7);
    t13 = (t12 - 1);
    t14 = (t13 - 23);
    t15 = (t14 * -1);
    xsi_vhdl_check_range_of_index(23, 0, -1, t13);
    t16 = (1U * t15);
    t17 = (0 + t16);
    t2 = (t6 + t17);
    t18 = *((unsigned char *)t2);
    t8 = (t0 + 5352);
    t9 = (t8 + 56U);
    t10 = *((char **)t9);
    t19 = (t10 + 56U);
    t20 = *((char **)t19);
    *((unsigned char *)t20) = t18;
    xsi_driver_first_trans_fast_port(t8);
    xsi_set_current_line(71, ng0);
    t1 = (t0 + 3648U);
    t2 = *((char **)t1);
    t11 = *((int *)t2);
    t12 = (t11 - 1);
    t1 = (t0 + 3648U);
    t5 = *((char **)t1);
    t1 = (t5 + 0);
    *((int *)t1) = t12;
    goto LAB8;

LAB10:    xsi_set_current_line(73, ng0);
    t1 = (t0 + 5352);
    t5 = (t1 + 56U);
    t6 = *((char **)t5);
    t7 = (t6 + 56U);
    t8 = *((char **)t7);
    *((unsigned char *)t8) = (unsigned char)2;
    xsi_driver_first_trans_fast_port(t1);
    goto LAB8;

LAB12:    xsi_set_current_line(78, ng0);
    t2 = (t0 + 1352U);
    t5 = *((char **)t2);
    t4 = *((unsigned char *)t5);
    t2 = (t0 + 2952U);
    t6 = *((char **)t2);
    t18 = *((unsigned char *)t6);
    t21 = (t4 != t18);
    if (t21 != 0)
        goto LAB14;

LAB16:    t1 = (t0 + 3528U);
    t2 = *((char **)t1);
    t11 = *((int *)t2);
    t3 = (t11 > 0);
    if (t3 != 0)
        goto LAB22;

LAB23:    t1 = (t0 + 3528U);
    t2 = *((char **)t1);
    t11 = *((int *)t2);
    t3 = (t11 == 0);
    if (t3 != 0)
        goto LAB24;

LAB25:
LAB15:    goto LAB3;

LAB14:    xsi_set_current_line(79, ng0);
    t2 = (t0 + 1352U);
    t7 = *((char **)t2);
    t22 = *((unsigned char *)t7);
    t2 = (t0 + 5416);
    t8 = (t2 + 56U);
    t9 = *((char **)t8);
    t10 = (t9 + 56U);
    t19 = *((char **)t10);
    *((unsigned char *)t19) = t22;
    xsi_driver_first_trans_fast(t2);
    xsi_set_current_line(80, ng0);
    t1 = (t0 + 3528U);
    t2 = *((char **)t1);
    t1 = (t2 + 0);
    *((int *)t1) = 24;
    xsi_set_current_line(81, ng0);
    t1 = xsi_get_transient_memory(24U);
    memset(t1, 0, 24U);
    t2 = t1;
    memset(t2, (unsigned char)2, 24U);
    t5 = (t0 + 5224);
    t6 = (t5 + 56U);
    t7 = *((char **)t6);
    t8 = (t7 + 56U);
    t9 = *((char **)t8);
    memcpy(t9, t1, 24U);
    xsi_driver_first_trans_fast(t5);
    xsi_set_current_line(82, ng0);
    t1 = (t0 + 5288);
    t2 = (t1 + 56U);
    t5 = *((char **)t2);
    t6 = (t5 + 56U);
    t7 = *((char **)t6);
    *((unsigned char *)t7) = (unsigned char)2;
    xsi_driver_first_trans_fast_port(t1);
    xsi_set_current_line(84, ng0);
    t1 = (t0 + 1352U);
    t2 = *((char **)t1);
    t3 = *((unsigned char *)t2);
    t4 = (t3 == (unsigned char)2);
    if (t4 != 0)
        goto LAB17;

LAB19:    t1 = (t0 + 1352U);
    t2 = *((char **)t1);
    t3 = *((unsigned char *)t2);
    t4 = (t3 == (unsigned char)3);
    if (t4 != 0)
        goto LAB20;

LAB21:
LAB18:    goto LAB15;

LAB17:    xsi_set_current_line(85, ng0);
    t1 = (t0 + 1992U);
    t5 = *((char **)t1);
    t1 = (t0 + 5160);
    t6 = (t1 + 56U);
    t7 = *((char **)t6);
    t8 = (t7 + 56U);
    t9 = *((char **)t8);
    memcpy(t9, t5, 24U);
    xsi_driver_first_trans_fast(t1);
    goto LAB18;

LAB20:    xsi_set_current_line(87, ng0);
    t1 = (t0 + 2152U);
    t5 = *((char **)t1);
    t1 = (t0 + 5160);
    t6 = (t1 + 56U);
    t7 = *((char **)t6);
    t8 = (t7 + 56U);
    t9 = *((char **)t8);
    memcpy(t9, t5, 24U);
    xsi_driver_first_trans_fast(t1);
    goto LAB18;

LAB22:    xsi_set_current_line(92, ng0);
    t1 = (t0 + 1032U);
    t5 = *((char **)t1);
    t4 = *((unsigned char *)t5);
    t1 = (t0 + 3528U);
    t6 = *((char **)t1);
    t12 = *((int *)t6);
    t13 = (t12 - 23);
    t15 = (t13 * -1);
    t16 = (1 * t15);
    t17 = (0U + t16);
    t1 = (t0 + 5224);
    t7 = (t1 + 56U);
    t8 = *((char **)t7);
    t9 = (t8 + 56U);
    t10 = *((char **)t9);
    *((unsigned char *)t10) = t4;
    xsi_driver_first_trans_delta(t1, t17, 1, 0LL);
    xsi_set_current_line(94, ng0);
    t1 = (t0 + 3528U);
    t2 = *((char **)t1);
    t11 = *((int *)t2);
    t12 = (t11 - 1);
    t1 = (t0 + 3528U);
    t5 = *((char **)t1);
    t1 = (t5 + 0);
    *((int *)t1) = t12;
    goto LAB15;

LAB24:    xsi_set_current_line(98, ng0);
    t1 = (t0 + 5288);
    t5 = (t1 + 56U);
    t6 = *((char **)t5);
    t7 = (t6 + 56U);
    t8 = *((char **)t7);
    *((unsigned char *)t8) = (unsigned char)3;
    xsi_driver_first_trans_fast_port(t1);
    xsi_set_current_line(100, ng0);
    t1 = (t0 + 2952U);
    t2 = *((char **)t1);
    t3 = *((unsigned char *)t2);
    t4 = (t3 == (unsigned char)2);
    if (t4 != 0)
        goto LAB26;

LAB28:    t1 = (t0 + 2952U);
    t2 = *((char **)t1);
    t3 = *((unsigned char *)t2);
    t4 = (t3 == (unsigned char)3);
    if (t4 != 0)
        goto LAB29;

LAB30:
LAB27:    goto LAB15;

LAB26:    xsi_set_current_line(101, ng0);
    t1 = (t0 + 2632U);
    t5 = *((char **)t1);
    t1 = (t0 + 5032);
    t6 = (t1 + 56U);
    t7 = *((char **)t6);
    t8 = (t7 + 56U);
    t9 = *((char **)t8);
    memcpy(t9, t5, 24U);
    xsi_driver_first_trans_fast_port(t1);
    goto LAB27;

LAB29:    xsi_set_current_line(103, ng0);
    t1 = (t0 + 2632U);
    t5 = *((char **)t1);
    t1 = (t0 + 5096);
    t6 = (t1 + 56U);
    t7 = *((char **)t6);
    t8 = (t7 + 56U);
    t9 = *((char **)t8);
    memcpy(t9, t5, 24U);
    xsi_driver_first_trans_fast_port(t1);
    goto LAB27;

}


extern void work_a_3860840486_3212880686_init()
{
	static char *pe[] = {(void *)work_a_3860840486_3212880686_p_0};
	xsi_register_didat("work_a_3860840486_3212880686", "isim/testbench_isim_beh.exe.sim/work/a_3860840486_3212880686.didat");
	xsi_register_executes(pe);
}
