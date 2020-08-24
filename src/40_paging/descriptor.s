GDT:            dq      0x00_0_0_0_0_000000_0000 ; NULL
.cs_kernel      dq      0x00_C_F_9_A_000000_FFFF ; CODE
.ds_kernel      dq      0x00_C_F_9_2_000000_FFFF ; DATA   
.ldt            dq      0x00_0_0_8_2_000000_0000 ; LDTディスクリプタ
.tss_0          dq      0x00_0_0_8_9_000000_0067 ; TSSディスクリプタ
.tss_1          dq      0x00_0_0_8_9_000000_0067 ; TSSディスクリプタ
.tss_2          dq      0x00_0_0_8_9_000000_0067 ; TSSディスクリプタ
.tss_3          dq      0x00_0_0_8_9_000000_0067 ; TSSディスクリプタ
.call_gate      dq      0x00_0_0_E_C_040008_0000 ; 386コールゲートディスクリプタ
.end:

CS_KERNEL       equ     .cs_kernel - GDT
DS_KERNEL       equ     .ds_kernel - GDT
; SS := Segment Selector
SS_LDT          equ     .ldt - GDT
SS_TASK_0       equ     .tss_0 - GDT
SS_TASK_1       equ     .tss_1 - GDT
SS_TASK_2       equ     .tss_2 - GDT
SS_TASK_3       equ     .tss_3 - GDT
SS_GATE_0       equ     .call_gate - GDT

GDTR:
    dw      GDT.end - GDT - 1
    dd      GDT

LDT:            dq      0x00_0_0_0_0_000000_0000 ; NULL
.cs_task_0      dq      0x00_C_F_9_A_000000_FFFF ; CODE
.ds_task_0      dq      0x00_C_F_9_2_000000_FFFF ; DATA
.cs_task_1      dq      0x00_C_F_F_A_000000_FFFF ; CODE
.ds_task_1      dq      0x00_C_F_F_2_000000_FFFF ; DATA
.cs_task_2      dq      0x00_C_F_F_A_000000_FFFF ; CODE
.ds_task_2      dq      0x00_C_F_F_2_000000_FFFF ; DATA
.cs_task_3      dq      0x00_C_F_F_A_000000_FFFF ; CODE
.ds_task_3      dq      0x00_C_F_F_2_000000_FFFF ; DATA
.end:

CS_TASK_0       equ     (.cs_task_0 - LDT) | 4
DS_TASK_0       equ     (.ds_task_0 - LDT) | 4
CS_TASK_1       equ     (.cs_task_1 - LDT) | 4 | 3
DS_TASK_1       equ     (.ds_task_1 - LDT) | 4 | 3
CS_TASK_2       equ     (.cs_task_2 - LDT) | 4 | 3
DS_TASK_2       equ     (.ds_task_2 - LDT) | 4 | 3
CS_TASK_3       equ     (.cs_task_3 - LDT) | 4 | 3
DS_TASK_3       equ     (.ds_task_3 - LDT) | 4 | 3

LDT_LIMIT       equ     .end - LDT - 1

TSS_0:
.link       dd  0
.esp0       dd  SP_TASK_0 - 512
.ss0        dd  DS_KERNEL
.esp1       dd  0
.ss1        dd  0
.esp2       dd  0
.ss2        dd  0
.cr3        dd  CR3_BASE
.eip        dd  0
.eflags     dd  0
.eax        dd  0
.ecx        dd  0
.edx        dd  0
.ebx        dd  0
.esp        dd  0
.ebp        dd  0
.esi        dd  0
.edi        dd  0
.es         dd  0
.cs         dd  0
.ss         dd  0
.ds         dd  0
.fs         dd  0
.gs         dd  0
.ldt        dd  0
.io         dd  0
.fp_save    times 108 + 4 db    0

TSS_1:
.link       dd  0
.esp0       dd  SP_TASK_1 - 512
.ss0        dd  DS_KERNEL
.esp1       dd  0
.ss1        dd  0
.esp2       dd  0
.ss2        dd  0
.cr3        dd  CR3_BASE
.eip        dd  task_1
.eflags     dd  0x0202
.eax        dd  0
.ecx        dd  0
.edx        dd  0
.ebx        dd  0
.esp        dd  SP_TASK_1
.ebp        dd  0
.esi        dd  0
.edi        dd  0
.es         dd  DS_TASK_1
.cs         dd  CS_TASK_1
.ss         dd  DS_TASK_1
.ds         dd  DS_TASK_1
.fs         dd  DS_TASK_1
.gs         dd  DS_TASK_1
.ldt        dd  SS_LDT
.io         dd  0
.fp_save    times 108 + 4 db    0

TSS_2:
.link       dd  0
.esp0       dd  SP_TASK_2 - 512
.ss0        dd  DS_KERNEL
.esp1       dd  0
.ss1        dd  0
.esp2       dd  0
.ss2        dd  0
.cr3        dd  CR3_BASE
.eip        dd  task_2
.eflags     dd  0x0202
.eax        dd  0
.ecx        dd  0
.edx        dd  0
.ebx        dd  0
.esp        dd  SP_TASK_2
.ebp        dd  0
.esi        dd  0
.edi        dd  0
.es         dd  DS_TASK_2
.cs         dd  CS_TASK_2
.ss         dd  DS_TASK_2
.ds         dd  DS_TASK_2
.fs         dd  DS_TASK_2
.gs         dd  DS_TASK_2
.ldt        dd  SS_LDT
.io         dd  0
.fp_save    times 108 + 4 db    0

TSS_3:
.link       dd  0
.esp0       dd  SP_TASK_3 - 512
.ss0        dd  DS_KERNEL
.esp1       dd  0
.ss1        dd  0
.esp2       dd  0
.ss2        dd  0
.cr3        dd  CR3_BASE
.eip        dd  task_3
.eflags     dd  0x0202
.eax        dd  0
.ecx        dd  0
.edx        dd  0
.ebx        dd  0
.esp        dd  SP_TASK_3
.ebp        dd  0
.esi        dd  0
.edi        dd  0
.es         dd  DS_TASK_3
.cs         dd  CS_TASK_3
.ss         dd  DS_TASK_3
.ds         dd  DS_TASK_3
.fs         dd  DS_TASK_3
.gs         dd  DS_TASK_3
.ldt        dd  SS_LDT
.io         dd  0
.fp_save    times 108 + 4 db    0