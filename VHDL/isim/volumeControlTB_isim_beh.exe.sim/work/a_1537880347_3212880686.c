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
static const char *ng0 = "C:/Users/e1538867/Desktop/VHDL_GUITAR_PEDAL/VHDL_GUITAR_PEDAL/VHDL/modules/Volume/volumeControl.vhd";
extern char *IEEE_P_2592010699;
extern char *IEEE_P_1242562249;

unsigned char ieee_p_1242562249_sub_2479218856_1035706684(char *, char *, char *, int );
unsigned char ieee_p_1242562249_sub_2479290730_1035706684(char *, char *, char *, int );
char *ieee_p_1242562249_sub_2807594338_1035706684(char *, char *, char *, char *, char *, char *);
unsigned char ieee_p_2592010699_sub_1744673427_503743352(char *, char *, unsigned int , unsigned int );


static void work_a_1537880347_3212880686_p_0(char *t0)
{
    char *t1;
    char *t2;
    char *t3;
    char *t4;
    char *t5;
    char *t6;
    char *t7;

LAB0:    xsi_set_current_line(77, ng0);

LAB3:    t1 = (t0 + 1352U);
    t2 = *((char **)t1);
    t1 = (t0 + 5656);
    t3 = (t1 + 56U);
    t4 = *((char **)t3);
    t5 = (t4 + 56U);
    t6 = *((char **)t5);
    memcpy(t6, t2, 24U);
    xsi_driver_first_trans_fast(t1);

LAB2:    t7 = (t0 + 5560);
    *((int *)t7) = 1;

LAB1:    return;
LAB4:    goto LAB2;

}

static void work_a_1537880347_3212880686_p_1(char *t0)
{
    char t19[16];
    char t20[16];
    char t21[16];
    char *t1;
    char *t2;
    unsigned char t3;
    unsigned char t4;
    char *t5;
    char *t6;
    char *t7;
    char *t8;
    unsigned char t9;
    unsigned char t10;
    unsigned char t11;
    unsigned char t12;
    unsigned char t13;
    char *t14;
    char *t15;
    char *t16;
    char *t17;
    char *t18;
    char *t22;
    char *t23;
    unsigned int t24;
    unsigned int t25;
    char *t26;
    char *t27;
    char *t28;
    char *t29;
    char *t30;
    unsigned int t31;
    int t32;
    unsigned int t33;
    int t34;
    static char *nl0[] = {&&LAB8, &&LAB9};

LAB0:    xsi_set_current_line(81, ng0);
    t1 = (t0 + 1192U);
    t2 = *((char **)t1);
    t3 = *((unsigned char *)t2);
    t4 = (t3 == (unsigned char)2);
    if (t4 != 0)
        goto LAB2;

LAB4:    t1 = (t0 + 992U);
    t3 = ieee_p_2592010699_sub_1744673427_503743352(IEEE_P_2592010699, t1, 0U, 0U);
    if (t3 != 0)
        goto LAB5;

LAB6:
LAB3:    t1 = (t0 + 5576);
    *((int *)t1) = 1;

LAB1:    return;
LAB2:    xsi_set_current_line(82, ng0);
    t1 = (t0 + 5720);
    t5 = (t1 + 56U);
    t6 = *((char **)t5);
    t7 = (t6 + 56U);
    t8 = *((char **)t7);
    *((unsigned char *)t8) = (unsigned char)0;
    xsi_driver_first_trans_fast(t1);
    xsi_set_current_line(83, ng0);
    t1 = (t0 + 5784);
    t2 = (t1 + 56U);
    t5 = *((char **)t2);
    t6 = (t5 + 56U);
    t7 = *((char **)t6);
    *((unsigned char *)t7) = (unsigned char)2;
    xsi_driver_first_trans_fast_port(t1);
    goto LAB3;

LAB5:    xsi_set_current_line(86, ng0);
    t2 = (t0 + 2632U);
    t5 = *((char **)t2);
    t4 = *((unsigned char *)t5);
    t2 = (char *)((nl0) + t4);
    goto **((char **)t2);

LAB7:    goto LAB3;

LAB8:    xsi_set_current_line(89, ng0);
    t6 = (t0 + 1672U);
    t7 = *((char **)t6);
    t10 = *((unsigned char *)t7);
    t11 = (t10 == (unsigned char)2);
    if (t11 == 1)
        goto LAB13;

LAB14:    t9 = (unsigned char)0;

LAB15:    if (t9 != 0)
        goto LAB10;

LAB12:    t1 = (t0 + 1672U);
    t2 = *((char **)t1);
    t4 = *((unsigned char *)t2);
    t9 = (t4 == (unsigned char)3);
    if (t9 == 1)
        goto LAB18;

LAB19:    t3 = (unsigned char)0;

LAB20:    if (t3 != 0)
        goto LAB16;

LAB17:    t1 = (t0 + 1672U);
    t2 = *((char **)t1);
    t4 = *((unsigned char *)t2);
    t9 = (t4 == (unsigned char)3);
    if (t9 == 1)
        goto LAB30;

LAB31:    t3 = (unsigned char)0;

LAB32:    if (t3 != 0)
        goto LAB28;

LAB29:
LAB11:    goto LAB7;

LAB9:    goto LAB7;

LAB10:    xsi_set_current_line(90, ng0);
    t6 = (t0 + 1352U);
    t14 = *((char **)t6);
    t6 = (t0 + 5848);
    t15 = (t6 + 56U);
    t16 = *((char **)t15);
    t17 = (t16 + 56U);
    t18 = *((char **)t17);
    memcpy(t18, t14, 24U);
    xsi_driver_first_trans_fast_port(t6);
    goto LAB11;

LAB13:    t6 = (t0 + 1832U);
    t8 = *((char **)t6);
    t12 = *((unsigned char *)t8);
    t13 = (t12 == (unsigned char)2);
    t9 = t13;
    goto LAB15;

LAB16:    xsi_set_current_line(97, ng0);
    t1 = (t0 + 3432U);
    t6 = *((char **)t1);
    t1 = (t0 + 10096U);
    t7 = (t0 + 3888U);
    t8 = *((char **)t7);
    t7 = (t0 + 10128U);
    t14 = ieee_p_1242562249_sub_2807594338_1035706684(IEEE_P_1242562249, t20, t6, t1, t8, t7);
    t15 = (t0 + 2152U);
    t16 = *((char **)t15);
    t17 = ((IEEE_P_2592010699) + 4024);
    t18 = (t0 + 10000U);
    t15 = xsi_base_array_concat(t15, t21, t17, (char)99, (unsigned char)2, (char)97, t16, t18, (char)101);
    t22 = ieee_p_1242562249_sub_2807594338_1035706684(IEEE_P_1242562249, t19, t14, t20, t15, t21);
    t23 = (t19 + 12U);
    t24 = *((unsigned int *)t23);
    t25 = (1U * t24);
    t12 = (40U != t25);
    if (t12 == 1)
        goto LAB21;

LAB22:    t26 = (t0 + 5912);
    t27 = (t26 + 56U);
    t28 = *((char **)t27);
    t29 = (t28 + 56U);
    t30 = *((char **)t29);
    memcpy(t30, t22, 40U);
    xsi_driver_first_trans_fast(t26);
    xsi_set_current_line(100, ng0);
    t1 = (t0 + 3592U);
    t2 = *((char **)t1);
    t24 = (39 - 39);
    t25 = (t24 * 1U);
    t31 = (0 + t25);
    t1 = (t2 + t31);
    t5 = (t19 + 0U);
    t6 = (t5 + 0U);
    *((int *)t6) = 39;
    t6 = (t5 + 4U);
    *((int *)t6) = 10;
    t6 = (t5 + 8U);
    *((int *)t6) = -1;
    t32 = (10 - 39);
    t33 = (t32 * -1);
    t33 = (t33 + 1);
    t6 = (t5 + 12U);
    *((unsigned int *)t6) = t33;
    t3 = ieee_p_1242562249_sub_2479290730_1035706684(IEEE_P_1242562249, t1, t19, 8388607);
    if (t3 != 0)
        goto LAB23;

LAB25:    t1 = (t0 + 3592U);
    t2 = *((char **)t1);
    t24 = (39 - 39);
    t25 = (t24 * 1U);
    t31 = (0 + t25);
    t1 = (t2 + t31);
    t5 = (t19 + 0U);
    t6 = (t5 + 0U);
    *((int *)t6) = 39;
    t6 = (t5 + 4U);
    *((int *)t6) = 10;
    t6 = (t5 + 8U);
    *((int *)t6) = -1;
    t32 = (10 - 39);
    t33 = (t32 * -1);
    t33 = (t33 + 1);
    t6 = (t5 + 12U);
    *((unsigned int *)t6) = t33;
    t34 = (-(8388608));
    t3 = ieee_p_1242562249_sub_2479218856_1035706684(IEEE_P_1242562249, t1, t19, t34);
    if (t3 != 0)
        goto LAB26;

LAB27:    xsi_set_current_line(109, ng0);
    t1 = (t0 + 3592U);
    t2 = *((char **)t1);
    t24 = (39 - 33);
    t25 = (t24 * 1U);
    t31 = (0 + t25);
    t1 = (t2 + t31);
    t5 = (t0 + 5848);
    t6 = (t5 + 56U);
    t7 = *((char **)t6);
    t8 = (t7 + 56U);
    t14 = *((char **)t8);
    memcpy(t14, t1, 24U);
    xsi_driver_first_trans_fast_port(t5);

LAB24:    goto LAB11;

LAB18:    t1 = (t0 + 1832U);
    t5 = *((char **)t1);
    t10 = *((unsigned char *)t5);
    t11 = (t10 == (unsigned char)2);
    t3 = t11;
    goto LAB20;

LAB21:    xsi_size_not_matching(40U, t25, 0);
    goto LAB22;

LAB23:    xsi_set_current_line(101, ng0);
    t6 = (t0 + 10316);
    t8 = (t0 + 5848);
    t14 = (t8 + 56U);
    t15 = *((char **)t14);
    t16 = (t15 + 56U);
    t17 = *((char **)t16);
    memcpy(t17, t6, 24U);
    xsi_driver_first_trans_fast_port(t8);
    goto LAB24;

LAB26:    xsi_set_current_line(105, ng0);
    t6 = (t0 + 10340);
    t8 = (t0 + 5848);
    t14 = (t8 + 56U);
    t15 = *((char **)t14);
    t16 = (t15 + 56U);
    t17 = *((char **)t16);
    memcpy(t17, t6, 24U);
    xsi_driver_first_trans_fast_port(t8);
    goto LAB24;

LAB28:    xsi_set_current_line(115, ng0);
    t1 = (t0 + 2152U);
    t6 = *((char **)t1);
    t1 = (t0 + 5976);
    t7 = (t1 + 56U);
    t8 = *((char **)t7);
    t14 = (t8 + 56U);
    t15 = *((char **)t14);
    memcpy(t15, t6, 10U);
    xsi_driver_first_trans_fast(t1);
    xsi_set_current_line(116, ng0);
    t1 = (t0 + 5720);
    t2 = (t1 + 56U);
    t5 = *((char **)t2);
    t6 = (t5 + 56U);
    t7 = *((char **)t6);
    *((unsigned char *)t7) = (unsigned char)1;
    xsi_driver_first_trans_fast(t1);
    xsi_set_current_line(117, ng0);
    t1 = (t0 + 6040);
    t2 = (t1 + 56U);
    t5 = *((char **)t2);
    t6 = (t5 + 56U);
    t7 = *((char **)t6);
    *((unsigned char *)t7) = (unsigned char)3;
    xsi_driver_first_trans_fast(t1);
    goto LAB11;

LAB30:    t1 = (t0 + 1832U);
    t5 = *((char **)t1);
    t10 = *((unsigned char *)t5);
    t11 = (t10 == (unsigned char)3);
    t3 = t11;
    goto LAB32;

}


extern void work_a_1537880347_3212880686_init()
{
	static char *pe[] = {(void *)work_a_1537880347_3212880686_p_0,(void *)work_a_1537880347_3212880686_p_1};
	xsi_register_didat("work_a_1537880347_3212880686", "isim/volumeControlTB_isim_beh.exe.sim/work/a_1537880347_3212880686.didat");
	xsi_register_executes(pe);
}
