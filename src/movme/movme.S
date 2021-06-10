#       ___     ___            ___    ___     ___     ___     ___          ___     ___      
#      /\  \   /\  \    ___   /\__\  /\  \   /\__\   /\__\   /\  \        /\  \   /\  \    .
#     |::\  \ /::\  \  /\  \ /:/ _/_ \:\  \ /:/ _/_ /:/  /  /::\  \  ___ /::\  \ /::\  \   .
#     |:::\  \:/\:\  \ \:\  \:/ /\__\ \:\  \:/ /\  \:/  /  /:/\:\  \/\__\:/\:\  \:/\:\__\  .
#   __|:|\:\  \  \:\  \ \:\  \ /:/  /  \:\  \ /::\  \  /  _:/ /::\  \/  //  \:\  \ /:/  /   
#  /::::|_\:\__\/ \:\__\ \:\__\:/  / \  \:\__\:/\:\__\/  /\__\:/\:\__\_//__/ \:\__\:/__/___ 
#  \:\~~\  \/__/\ /:/  / |:|  |/  /\  \ /:/  // /:/  /\ /:/  //  \/__/ \\  \ /:/  /::::/  / 
#   \:\  \  \:\  /:/  / \|:|  |__/\:\  /:/  // /:/  /  /:/  //__/:/\:\  \\  /:/  //~~/~~~~  
#    \:\  \  \:\/:/  /\__|:|__|  \ \:\/:/  //_/:/  /:\/:/  /:\  \/__\:\  \\/:/  /:\~~\     .
#     \:\__\  \::/  /\::::/__/:\__\ \::/  /  /:/  / \::/  / \:\__\   \:\__\:/  / \:\__\    .
#      \/__/   \/__/  ~~~~    \/__/  \/__/   \/__/   \/__/   \/__/    \/__/ __/   \/__/    2
#                                                                                           
#
# M/o/Vfuscator2
#
# github.com/xoreaxeaxeax/movfuscator
# chris domas           @xoreaxeaxeax
#


.text
.type print,@function
print:  # <LCI>
# prologue
# push (fp)
movl (fp), %eax
movl %eax, (stack_temp)
movl $sp, %eax
movl (on), %edx
# select data %eax %edx
movl %eax, (data_p)
movl sel_data(,%edx,4), %eax
# end select data
movl (sp), %edx
movl push(%edx), %edx
movl %edx, (%eax)
movl (sp), %eax
movl (on), %edx
# select data %eax %edx
movl %eax, (data_p)
movl sel_data(,%edx,4), %eax
# end select data
movl (stack_temp), %edx
movl %edx, (%eax)
# end push
# push (R1)
movl (R1), %eax
movl %eax, (stack_temp)
movl $sp, %eax
movl (on), %edx
# select data %eax %edx
movl %eax, (data_p)
movl sel_data(,%edx,4), %eax
# end select data
movl (sp), %edx
movl push(%edx), %edx
movl %edx, (%eax)
movl (sp), %eax
movl (on), %edx
# select data %eax %edx
movl %eax, (data_p)
movl sel_data(,%edx,4), %eax
# end select data
movl (stack_temp), %edx
movl %edx, (%eax)
# end push
# push (R2)
movl (R2), %eax
movl %eax, (stack_temp)
movl $sp, %eax
movl (on), %edx
# select data %eax %edx
movl %eax, (data_p)
movl sel_data(,%edx,4), %eax
# end select data
movl (sp), %edx
movl push(%edx), %edx
movl %edx, (%eax)
movl (sp), %eax
movl (on), %edx
# select data %eax %edx
movl %eax, (data_p)
movl sel_data(,%edx,4), %eax
# end select data
movl (stack_temp), %edx
movl %edx, (%eax)
# end push
# push (R3)
movl (R3), %eax
movl %eax, (stack_temp)
movl $sp, %eax
movl (on), %edx
# select data %eax %edx
movl %eax, (data_p)
movl sel_data(,%edx,4), %eax
# end select data
movl (sp), %edx
movl push(%edx), %edx
movl %edx, (%eax)
movl (sp), %eax
movl (on), %edx
# select data %eax %edx
movl %eax, (data_p)
movl sel_data(,%edx,4), %eax
# end select data
movl (stack_temp), %edx
movl %edx, (%eax)
# end push
# push (F1)
movl (F1), %eax
movl %eax, (stack_temp)
movl $sp, %eax
movl (on), %edx
# select data %eax %edx
movl %eax, (data_p)
movl sel_data(,%edx,4), %eax
# end select data
movl (sp), %edx
movl push(%edx), %edx
movl %edx, (%eax)
movl (sp), %eax
movl (on), %edx
# select data %eax %edx
movl %eax, (data_p)
movl sel_data(,%edx,4), %eax
# end select data
movl (stack_temp), %edx
movl %edx, (%eax)
# end push
# push (F2)
movl (F2), %eax
movl %eax, (stack_temp)
movl $sp, %eax
movl (on), %edx
# select data %eax %edx
movl %eax, (data_p)
movl sel_data(,%edx,4), %eax
# end select data
movl (sp), %edx
movl push(%edx), %edx
movl %edx, (%eax)
movl (sp), %eax
movl (on), %edx
# select data %eax %edx
movl %eax, (data_p)
movl sel_data(,%edx,4), %eax
# end select data
movl (stack_temp), %edx
movl %edx, (%eax)
# end push
# push D1
movl (D1), %eax
movl %eax, (stack_temp)
movl (D1+4), %eax
movl %eax, (stack_temp+4)
movl $sp, %eax
movl (on), %edx
# select data %eax %edx
movl %eax, (data_p)
movl sel_data(,%edx,4), %eax
# end select data
movl (sp), %edx
movl push(%edx), %edx
movl push(%edx), %edx
movl %edx, (%eax)
movl (sp), %eax
movl (on), %edx
# select data %eax %edx
movl %eax, (data_p)
movl sel_data(,%edx,4), %eax
# end select data
movl (stack_temp), %edx
movl %edx, (%eax)
movl (stack_temp+4), %edx
movl %edx, 4(%eax)
# end push
# push D2
movl (D2), %eax
movl %eax, (stack_temp)
movl (D2+4), %eax
movl %eax, (stack_temp+4)
movl $sp, %eax
movl (on), %edx
# select data %eax %edx
movl %eax, (data_p)
movl sel_data(,%edx,4), %eax
# end select data
movl (sp), %edx
movl push(%edx), %edx
movl push(%edx), %edx
movl %edx, (%eax)
movl (sp), %eax
movl (on), %edx
# select data %eax %edx
movl %eax, (data_p)
movl sel_data(,%edx,4), %eax
# end select data
movl (stack_temp), %edx
movl %edx, (%eax)
movl (stack_temp+4), %edx
movl %edx, 4(%eax)
# end push
# mov %esp, %ebp
movl $fp, %eax
movl (on), %edx
# select data %eax %edx
movl %eax, (data_p)
movl sel_data(,%edx,4), %eax
# end select data
movl (sp), %edx
movl %edx, (%eax)
# end mov %esp, %ebp
# emit/mov>jumpv(addrgp4(4))

# emit jumpv

jmp .LCI4

# end emit jumpv

# emit/mov>labelv(3)

# emit labelv

.LCI3:

# end emit labelv

# emit/mov>addrfp4(str)

# emit addrfp

# (offset 44)
movl (fp), %eax
movl pop(%eax), %eax
movl pop(%eax), %eax
movl pop(%eax), %eax
movl pop(%eax), %eax
movl pop(%eax), %eax
movl pop(%eax), %eax
movl pop(%eax), %eax
movl pop(%eax), %eax
movl pop(%eax), %eax
movl pop(%eax), %eax
movl pop(%eax), %eax
movl %eax, (R3)

# end emit addrfp

# emit/mov>indirp4(addrfp4(str))

# emit indirp

movl (R3), %eax
movl (on), %edx
# select data %eax %edx
movl %eax, (data_p)
movl sel_data(,%edx,4), %eax
# end select data
movl (%eax), %eax
movl %eax, (R3)

# end emit indirp

# emit/mov>asgnp4(vregp(1),indirp4(addrfp4(str)))

# emit asgnp


# (emit vreg asgn)


# end emit asgnp

# emit/mov>addrfp4(str)

# emit addrfp

# (offset 44)
movl (fp), %eax
movl pop(%eax), %eax
movl pop(%eax), %eax
movl pop(%eax), %eax
movl pop(%eax), %eax
movl pop(%eax), %eax
movl pop(%eax), %eax
movl pop(%eax), %eax
movl pop(%eax), %eax
movl pop(%eax), %eax
movl pop(%eax), %eax
movl pop(%eax), %eax
movl %eax, (R2)

# end emit addrfp

# emit/mov>indirp4(vregp(1))

# emit/mov>cnsti4(1)
movl $1, (R1)
# emit/mov>addp4(indirp4(vregp(1)),cnsti4(1))

# emit addp

movl (R3), %eax
movl (R1), %edx
# alu_add
movl %eax, (alu_x)
movl %edx, (alu_y)
# alu_add32
movl $0, %eax
movl $0, %ecx
movl $0, (alu_c)
# alu_add16_fast
movw (alu_x+0), %ax
movw (alu_y+0), %cx
movl alu_add16(,%eax,4), %edx
movl (%edx,%ecx,4), %edx
movw (alu_c+2), %cx
movl alu_add16(,%edx,4), %edx
movl (%edx,%ecx,4), %edx
movw %dx, (alu_s+0)
movl %edx, (alu_c)
# end alu_add16_fast
# alu_add16_fast
movw (alu_x+2), %ax
movw (alu_y+2), %cx
movl alu_add16(,%eax,4), %edx
movl (%edx,%ecx,4), %edx
movw (alu_c+2), %cx
movl alu_add16(,%edx,4), %edx
movl (%edx,%ecx,4), %edx
movw %dx, (alu_s+2)
movl %edx, (alu_c)
# end alu_add16_fast
# end alu_add32
movl (alu_s), %eax
# end alu_add
movl %eax, (R1)

# end emit addp

# emit/mov>asgnp4(addrfp4(str),addp4(indirp4(vregp(1)),cnsti4(1)))

# emit asgnp

# (!ADDRL)
movl (R2), %eax
movl (on), %edx
# select data %eax %edx
movl %eax, (data_p)
movl sel_data(,%edx,4), %eax
# end select data
movl (R1), %edx
movl %edx, (%eax)

# end emit asgnp

# emit/mov>cnstp4(0x40000000)
movl $0x40000000, (R2)
# emit/mov>indirp4(vregp(1))

# emit/mov>indiri1(indirp4(vregp(1)))

# emit indiri

movl (R3), %eax
movl (on), %edx
# select data %eax %edx
movl %eax, (data_p)
movl sel_data(,%edx,4), %eax
# end select data
movl $0, %edx
movb (%eax), %dl
movl %edx, (R0)

# end emit indiri

# emit/mov>cvii4(indiri1(indirp4(vregp(1))))

# emit cvii

# (sign extend)

movl $0, %edx
movb (R0), %dl
movl alu_sex8(,%edx,4), %edx
movl %edx, (R3)

# end emit cvii

# emit/mov>cnsti4(255)
movl $255, (R1)
# emit/mov>bandi4(cvii4(indiri1(indirp4(vregp(1)))),cnsti4(255))

# emit bandi

movl (R3), %eax
movl (R1), %edx
# alu_band
movl %eax, (alu_x)
movl %edx, (alu_y)
# alu_band32
# alu_band8
movl $0, %eax
movl $0, %edx
movb (alu_x+0), %al
movb (alu_y+0), %dl
movl alu_band8(,%eax,4), %eax
movb (%eax,%edx), %al
movb %al, (alu_s+0)
# end alu_band8
# alu_band8
movl $0, %eax
movl $0, %edx
movb (alu_x+1), %al
movb (alu_y+1), %dl
movl alu_band8(,%eax,4), %eax
movb (%eax,%edx), %al
movb %al, (alu_s+1)
# end alu_band8
# alu_band8
movl $0, %eax
movl $0, %edx
movb (alu_x+2), %al
movb (alu_y+2), %dl
movl alu_band8(,%eax,4), %eax
movb (%eax,%edx), %al
movb %al, (alu_s+2)
# end alu_band8
# alu_band8
movl $0, %eax
movl $0, %edx
movb (alu_x+3), %al
movb (alu_y+3), %dl
movl alu_band8(,%eax,4), %eax
movb (%eax,%edx), %al
movb %al, (alu_s+3)
# end alu_band8
# end alu_band32
movl (alu_s), %eax
# end alu_band
movl %eax, (R3)

# end emit bandi

# emit/mov>load(bandi4(cvii4(indiri1(indirp4(vregp(1)))),cnsti4(255)))

# emit loadu

movl (R3), %eax
movl %eax, (R3)

# end emit loadu

# emit/mov>asgnu4(cnstp4(0x40000000),load(bandi4(cvii4(indiri1(indirp4(vregp(1)))),cnsti4(255))))

# emit asgnu

# (!ADDRL)
movl (R2), %eax
movl (on), %edx
# select data %eax %edx
movl %eax, (data_p)
movl sel_data(,%edx,4), %eax
# end select data
movl (R3), %edx
movl %edx, (%eax)

# end emit asgnu

# emit/mov>labelv(4)

# emit labelv

.LCI4:

# end emit labelv

# emit/mov>addrfp4(str)

# emit addrfp

# (offset 44)
movl (fp), %eax
movl pop(%eax), %eax
movl pop(%eax), %eax
movl pop(%eax), %eax
movl pop(%eax), %eax
movl pop(%eax), %eax
movl pop(%eax), %eax
movl pop(%eax), %eax
movl pop(%eax), %eax
movl pop(%eax), %eax
movl pop(%eax), %eax
movl pop(%eax), %eax
movl %eax, (R3)

# end emit addrfp

# emit/mov>indirp4(addrfp4(str))

# emit indirp

movl (R3), %eax
movl (on), %edx
# select data %eax %edx
movl %eax, (data_p)
movl sel_data(,%edx,4), %eax
# end select data
movl (%eax), %eax
movl %eax, (R3)

# end emit indirp

# emit/mov>indiri1(indirp4(addrfp4(str)))

# emit indiri

movl (R3), %eax
movl (on), %edx
# select data %eax %edx
movl %eax, (data_p)
movl sel_data(,%edx,4), %eax
# end select data
movl $0, %edx
movb (%eax), %dl
movl %edx, (R0)

# end emit indiri

# emit/mov>cvii4(indiri1(indirp4(addrfp4(str))))

# emit cvii

# (sign extend)

movl $0, %edx
movb (R0), %dl
movl alu_sex8(,%edx,4), %edx
movl %edx, (R3)

# end emit cvii

# emit/mov>cnsti4(0)
movl $0, (R2)
# emit/mov>nei4(cvii4(indiri1(indirp4(addrfp4(str)))),cnsti4(0))

# emit nei

movl (R3), %eax
cmpl (R2), %eax
jne .LCI3

# end emit nei

# emit/mov>labelv(2)

# emit labelv

.LCI2:

# end emit labelv

# epilogue
# movl %ebp, %esp
movl $sp, %eax
movl (on), %edx
# select data %eax %edx
movl %eax, (data_p)
movl sel_data(,%edx,4), %eax
# end select data
movl (fp), %edx
movl %edx, (%eax)
# end movl %ebp, %esp
# pop8 D2
movl (sp), %eax
movl (%eax), %edx
movl %edx, (stack_temp)
movl 4(%eax), %edx
movl %edx, (stack_temp+4)
movl $sp, %eax
movl (on), %edx
# select data %eax %edx
movl %eax, (data_p)
movl sel_data(,%edx,4), %eax
# end select data
movl (sp), %edx
movl pop(%edx), %edx
movl pop(%edx), %edx
movl %edx, (%eax)
movl $D2, %eax
movl (on), %edx
# select data %eax %edx
movl %eax, (data_p)
movl sel_data(,%edx,4), %eax
# end select data
movl (stack_temp), %edx
movl %edx, (%eax)
movl (stack_temp+4), %edx
movl %edx, 4(%eax)
# end pop8
# pop8 D1
movl (sp), %eax
movl (%eax), %edx
movl %edx, (stack_temp)
movl 4(%eax), %edx
movl %edx, (stack_temp+4)
movl $sp, %eax
movl (on), %edx
# select data %eax %edx
movl %eax, (data_p)
movl sel_data(,%edx,4), %eax
# end select data
movl (sp), %edx
movl pop(%edx), %edx
movl pop(%edx), %edx
movl %edx, (%eax)
movl $D1, %eax
movl (on), %edx
# select data %eax %edx
movl %eax, (data_p)
movl sel_data(,%edx,4), %eax
# end select data
movl (stack_temp), %edx
movl %edx, (%eax)
movl (stack_temp+4), %edx
movl %edx, 4(%eax)
# end pop8
# pop F2
movl (sp), %eax
movl (%eax), %edx
movl %edx, (stack_temp)
movl $sp, %eax
movl (on), %edx
# select data %eax %edx
movl %eax, (data_p)
movl sel_data(,%edx,4), %eax
# end select data
movl (sp), %edx
movl pop(%edx), %edx
movl %edx, (%eax)
movl $F2, %eax
movl (on), %edx
# select data %eax %edx
movl %eax, (data_p)
movl sel_data(,%edx,4), %eax
# end select data
movl (stack_temp), %edx
movl %edx, (%eax)
# end pop
# pop F1
movl (sp), %eax
movl (%eax), %edx
movl %edx, (stack_temp)
movl $sp, %eax
movl (on), %edx
# select data %eax %edx
movl %eax, (data_p)
movl sel_data(,%edx,4), %eax
# end select data
movl (sp), %edx
movl pop(%edx), %edx
movl %edx, (%eax)
movl $F1, %eax
movl (on), %edx
# select data %eax %edx
movl %eax, (data_p)
movl sel_data(,%edx,4), %eax
# end select data
movl (stack_temp), %edx
movl %edx, (%eax)
# end pop
# pop R3
movl (sp), %eax
movl (%eax), %edx
movl %edx, (stack_temp)
movl $sp, %eax
movl (on), %edx
# select data %eax %edx
movl %eax, (data_p)
movl sel_data(,%edx,4), %eax
# end select data
movl (sp), %edx
movl pop(%edx), %edx
movl %edx, (%eax)
movl $R3, %eax
movl (on), %edx
# select data %eax %edx
movl %eax, (data_p)
movl sel_data(,%edx,4), %eax
# end select data
movl (stack_temp), %edx
movl %edx, (%eax)
# end pop
# pop R2
movl (sp), %eax
movl (%eax), %edx
movl %edx, (stack_temp)
movl $sp, %eax
movl (on), %edx
# select data %eax %edx
movl %eax, (data_p)
movl sel_data(,%edx,4), %eax
# end select data
movl (sp), %edx
movl pop(%edx), %edx
movl %edx, (%eax)
movl $R2, %eax
movl (on), %edx
# select data %eax %edx
movl %eax, (data_p)
movl sel_data(,%edx,4), %eax
# end select data
movl (stack_temp), %edx
movl %edx, (%eax)
# end pop
# pop R1
movl (sp), %eax
movl (%eax), %edx
movl %edx, (stack_temp)
movl $sp, %eax
movl (on), %edx
# select data %eax %edx
movl %eax, (data_p)
movl sel_data(,%edx,4), %eax
# end select data
movl (sp), %edx
movl pop(%edx), %edx
movl %edx, (%eax)
movl $R1, %eax
movl (on), %edx
# select data %eax %edx
movl %eax, (data_p)
movl sel_data(,%edx,4), %eax
# end select data
movl (stack_temp), %edx
movl %edx, (%eax)
# end pop
# pop fp
movl (sp), %eax
movl (%eax), %edx
movl %edx, (stack_temp)
movl $sp, %eax
movl (on), %edx
# select data %eax %edx
movl %eax, (data_p)
movl sel_data(,%edx,4), %eax
# end select data
movl (sp), %edx
movl pop(%edx), %edx
movl %edx, (%eax)
movl $fp, %eax
movl (on), %edx
# select data %eax %edx
movl %eax, (data_p)
movl sel_data(,%edx,4), %eax
# end select data
movl (stack_temp), %edx
movl %edx, (%eax)
# end pop
# ret
# pop %eax
movl (sp), %eax
movl (%eax), %edx
movl %edx, (stack_temp)
movl $sp, %eax
movl (on), %edx
# select data %eax %edx
movl %eax, (data_p)
movl sel_data(,%edx,4), %eax
# end select data
movl (sp), %edx
movl pop(%edx), %edx
movl %edx, (%eax)
movl (stack_temp), %edx
movl %edx, %eax
# end pop
jmp *%eax
# end ret
.Lf6:
.size print,.Lf6-print

# export 'main'
.globl main
.type main,@function
main:  # <LCI>
# prologue
# push (fp)
movl (fp), %eax
movl %eax, (stack_temp)
movl $sp, %eax
movl (on), %edx
# select data %eax %edx
movl %eax, (data_p)
movl sel_data(,%edx,4), %eax
# end select data
movl (sp), %edx
movl push(%edx), %edx
movl %edx, (%eax)
movl (sp), %eax
movl (on), %edx
# select data %eax %edx
movl %eax, (data_p)
movl sel_data(,%edx,4), %eax
# end select data
movl (stack_temp), %edx
movl %edx, (%eax)
# end push
# push (R1)
movl (R1), %eax
movl %eax, (stack_temp)
movl $sp, %eax
movl (on), %edx
# select data %eax %edx
movl %eax, (data_p)
movl sel_data(,%edx,4), %eax
# end select data
movl (sp), %edx
movl push(%edx), %edx
movl %edx, (%eax)
movl (sp), %eax
movl (on), %edx
# select data %eax %edx
movl %eax, (data_p)
movl sel_data(,%edx,4), %eax
# end select data
movl (stack_temp), %edx
movl %edx, (%eax)
# end push
# push (R2)
movl (R2), %eax
movl %eax, (stack_temp)
movl $sp, %eax
movl (on), %edx
# select data %eax %edx
movl %eax, (data_p)
movl sel_data(,%edx,4), %eax
# end select data
movl (sp), %edx
movl push(%edx), %edx
movl %edx, (%eax)
movl (sp), %eax
movl (on), %edx
# select data %eax %edx
movl %eax, (data_p)
movl sel_data(,%edx,4), %eax
# end select data
movl (stack_temp), %edx
movl %edx, (%eax)
# end push
# push (R3)
movl (R3), %eax
movl %eax, (stack_temp)
movl $sp, %eax
movl (on), %edx
# select data %eax %edx
movl %eax, (data_p)
movl sel_data(,%edx,4), %eax
# end select data
movl (sp), %edx
movl push(%edx), %edx
movl %edx, (%eax)
movl (sp), %eax
movl (on), %edx
# select data %eax %edx
movl %eax, (data_p)
movl sel_data(,%edx,4), %eax
# end select data
movl (stack_temp), %edx
movl %edx, (%eax)
# end push
# push (F1)
movl (F1), %eax
movl %eax, (stack_temp)
movl $sp, %eax
movl (on), %edx
# select data %eax %edx
movl %eax, (data_p)
movl sel_data(,%edx,4), %eax
# end select data
movl (sp), %edx
movl push(%edx), %edx
movl %edx, (%eax)
movl (sp), %eax
movl (on), %edx
# select data %eax %edx
movl %eax, (data_p)
movl sel_data(,%edx,4), %eax
# end select data
movl (stack_temp), %edx
movl %edx, (%eax)
# end push
# push (F2)
movl (F2), %eax
movl %eax, (stack_temp)
movl $sp, %eax
movl (on), %edx
# select data %eax %edx
movl %eax, (data_p)
movl sel_data(,%edx,4), %eax
# end select data
movl (sp), %edx
movl push(%edx), %edx
movl %edx, (%eax)
movl (sp), %eax
movl (on), %edx
# select data %eax %edx
movl %eax, (data_p)
movl sel_data(,%edx,4), %eax
# end select data
movl (stack_temp), %edx
movl %edx, (%eax)
# end push
# push D1
movl (D1), %eax
movl %eax, (stack_temp)
movl (D1+4), %eax
movl %eax, (stack_temp+4)
movl $sp, %eax
movl (on), %edx
# select data %eax %edx
movl %eax, (data_p)
movl sel_data(,%edx,4), %eax
# end select data
movl (sp), %edx
movl push(%edx), %edx
movl push(%edx), %edx
movl %edx, (%eax)
movl (sp), %eax
movl (on), %edx
# select data %eax %edx
movl %eax, (data_p)
movl sel_data(,%edx,4), %eax
# end select data
movl (stack_temp), %edx
movl %edx, (%eax)
movl (stack_temp+4), %edx
movl %edx, 4(%eax)
# end push
# push D2
movl (D2), %eax
movl %eax, (stack_temp)
movl (D2+4), %eax
movl %eax, (stack_temp+4)
movl $sp, %eax
movl (on), %edx
# select data %eax %edx
movl %eax, (data_p)
movl sel_data(,%edx,4), %eax
# end select data
movl (sp), %edx
movl push(%edx), %edx
movl push(%edx), %edx
movl %edx, (%eax)
movl (sp), %eax
movl (on), %edx
# select data %eax %edx
movl %eax, (data_p)
movl sel_data(,%edx,4), %eax
# end select data
movl (stack_temp), %edx
movl %edx, (%eax)
movl (stack_temp+4), %edx
movl %edx, 4(%eax)
# end push
# mov %esp, %ebp
movl $fp, %eax
movl (on), %edx
# select data %eax %edx
movl %eax, (data_p)
movl sel_data(,%edx,4), %eax
# end select data
movl (sp), %edx
movl %edx, (%eax)
# end mov %esp, %ebp
# frame
movl (sp), %eax
movl push(%eax), %eax
movl %eax, (stack_temp)
movl $sp, %eax
movl (on), %edx
# select data %eax %edx
movl %eax, (data_p)
movl sel_data(,%edx,4), %eax
# end select data
movl (stack_temp), %edx
movl %edx, (%eax)
#end frame
# emit/mov>addrgp4(8)

# emit addrgp

movl $.LCS8, %eax
movl %eax, (R3)

# end emit addrgp

# emit/mov>argp4(addrgp4(8))

# emit argp

movl (R3), %eax
# push %eax
movl %eax, %eax
movl %eax, (stack_temp)
movl $sp, %eax
movl (on), %edx
# select data %eax %edx
movl %eax, (data_p)
movl sel_data(,%edx,4), %eax
# end select data
movl (sp), %edx
movl push(%edx), %edx
movl %edx, (%eax)
movl (sp), %eax
movl (on), %edx
# select data %eax %edx
movl %eax, (data_p)
movl sel_data(,%edx,4), %eax
# end select data
movl (stack_temp), %edx
movl %edx, (%eax)
# end push

# end emit argp

# emit/mov>callv(addrgp4(print))

# emit callv

# call 'print'
# (direct call)
# print is internal
# push return
movl $.LCI18, %eax
# push %eax
movl %eax, %eax
movl %eax, (stack_temp)
movl $sp, %eax
movl (on), %edx
# select data %eax %edx
movl %eax, (data_p)
movl sel_data(,%edx,4), %eax
# end select data
movl (sp), %edx
movl push(%edx), %edx
movl %edx, (%eax)
movl (sp), %eax
movl (on), %edx
# select data %eax %edx
movl %eax, (data_p)
movl sel_data(,%edx,4), %eax
# end select data
movl (stack_temp), %edx
movl %edx, (%eax)
# end push
# end push return

jmp print
.LCI18:
# pop args (4)
movl (sp), %eax
movl pop(%eax), %eax
movl %eax, (stack_temp)
movl $sp, %eax
movl (on), %edx
# select data %eax %edx
movl %eax, (data_p)
movl sel_data(,%edx,4), %eax
# end select data
movl (stack_temp), %edx
movl %edx, (%eax)
# end pop args

# end emit callv

# emit/mov>jumpv(addrgp4(10))

# emit jumpv

jmp .LCI10

# end emit jumpv

# emit/mov>labelv(9)

# emit labelv

.LCI9:

# end emit labelv

# emit/mov>cnstp4(0x40000004)
movl $0x40000004, (R3)
# emit/mov>indiru4(cnstp4(0x40000004))

# emit indiru

movl (R3), %eax
movl (on), %edx
# select data %eax %edx
movl %eax, (data_p)
movl sel_data(,%edx,4), %eax
# end select data
movl (%eax), %eax
movl %eax, (R3)

# end emit indiru

# emit/mov>cnstu4(255)
movl $255, (R2)
# emit/mov>bandu4(indiru4(cnstp4(0x40000004)),cnstu4(255))

# emit bandu

movl (R3), %eax
movl (R2), %edx
# alu_band
movl %eax, (alu_x)
movl %edx, (alu_y)
# alu_band32
# alu_band8
movl $0, %eax
movl $0, %edx
movb (alu_x+0), %al
movb (alu_y+0), %dl
movl alu_band8(,%eax,4), %eax
movb (%eax,%edx), %al
movb %al, (alu_s+0)
# end alu_band8
# alu_band8
movl $0, %eax
movl $0, %edx
movb (alu_x+1), %al
movb (alu_y+1), %dl
movl alu_band8(,%eax,4), %eax
movb (%eax,%edx), %al
movb %al, (alu_s+1)
# end alu_band8
# alu_band8
movl $0, %eax
movl $0, %edx
movb (alu_x+2), %al
movb (alu_y+2), %dl
movl alu_band8(,%eax,4), %eax
movb (%eax,%edx), %al
movb %al, (alu_s+2)
# end alu_band8
# alu_band8
movl $0, %eax
movl $0, %edx
movb (alu_x+3), %al
movb (alu_y+3), %dl
movl alu_band8(,%eax,4), %eax
movb (%eax,%edx), %al
movb %al, (alu_s+3)
# end alu_band8
# end alu_band32
movl (alu_s), %eax
# end alu_band
movl %eax, (R3)

# end emit bandu

# emit/mov>asgnu4(addrlp4(v),bandu4(indiru4(cnstp4(0x40000004)),cnstu4(255)))

# emit asgnu

# (ADDRL)
# (offset -4)
movl (fp), %eax
movl push(%eax), %eax
movl (on), %edx
# select data %eax %edx
movl %eax, (data_p)
movl sel_data(,%edx,4), %eax
# end select data
movl (R3), %edx
movl %edx, (%eax)

# end emit asgnu

# emit/mov>addrlp4(v)

# emit addrlp

# (offset -4)
movl (fp), %eax
movl push(%eax), %eax
movl %eax, (R3)

# end emit addrlp

# emit/mov>indiru4(addrlp4(v))

# emit indiru

movl (R3), %eax
movl (on), %edx
# select data %eax %edx
movl %eax, (data_p)
movl sel_data(,%edx,4), %eax
# end select data
movl (%eax), %eax
movl %eax, (R3)

# end emit indiru

# emit/mov>cnstu4(0)
movl $0, (R2)
# emit/mov>equ4(indiru4(addrlp4(v)),cnstu4(0))

# emit equ

movl (R3), %eax
cmpl (R2), %eax
je .LCI12

# end emit equ

# emit/mov>addrlp4(v)

# emit addrlp

# (offset -4)
movl (fp), %eax
movl push(%eax), %eax
movl %eax, (R3)

# end emit addrlp

# emit/mov>indiru4(addrlp4(v))

# emit indiru

movl (R3), %eax
movl (on), %edx
# select data %eax %edx
movl %eax, (data_p)
movl sel_data(,%edx,4), %eax
# end select data
movl (%eax), %eax
movl %eax, (R3)

# end emit indiru

# emit/mov>asgnu4(vregp(1),indiru4(addrlp4(v)))

# emit asgnu


# (emit vreg asgn)


# end emit asgnu

# emit/mov>indiru4(vregp(1))

# emit/mov>cnstu4(97)
movl $97, (R2)
# emit/mov>ltu4(indiru4(vregp(1)),cnstu4(97))

# emit ltu

movl (R3), %eax
cmpl (R2), %eax
jb .LCI14

# end emit ltu

# emit/mov>indiru4(vregp(1))

# emit/mov>cnstu4(122)
movl $122, (R2)
# emit/mov>gtu4(indiru4(vregp(1)),cnstu4(122))

# emit gtu

movl (R3), %eax
cmpl (R2), %eax
ja .LCI14

# end emit gtu

# emit/mov>cnstu4(97)
movl $97, (R3)
# emit/mov>asgnu4(vregp(2),cnstu4(97))

# emit asgnu


# (emit vreg asgn)


# end emit asgnu

# emit/mov>addrlp4(v)

# emit addrlp

# (offset -4)
movl (fp), %eax
movl push(%eax), %eax
movl %eax, (R2)

# end emit addrlp

# emit/mov>indiru4(addrlp4(v))

# emit indiru

movl (R2), %eax
movl (on), %edx
# select data %eax %edx
movl %eax, (data_p)
movl sel_data(,%edx,4), %eax
# end select data
movl (%eax), %eax
movl %eax, (R2)

# end emit indiru

# emit/mov>indiru4(vregp(2))

# emit/mov>subu4(indiru4(addrlp4(v)),indiru4(vregp(2)))

# emit subu

movl (R2), %eax
movl (R3), %edx
# alu_sub
movl %eax, (alu_x)
movl %edx, (alu_y)
# alu_sub32
movl $0, %eax
movl $0, %ecx
movl $0x1, (alu_c)
# alu_sub16_fast
movw (alu_x+0), %ax
movw (alu_y+0), %cx
movw alu_inv16(,%ecx,2), %cx
movl alu_add16(,%eax,4), %edx
movl (%edx,%ecx,4), %edx
movl alu_add16(,%edx,4), %edx
movl (alu_c), %ecx
movl (%edx,%ecx,4), %edx
movw %dx, (alu_s+0)
movl %edx, (alu_c-2)
# end alu_sub16_fast
# alu_sub16_fast
movw (alu_x+2), %ax
movw (alu_y+2), %cx
movw alu_inv16(,%ecx,2), %cx
movl alu_add16(,%eax,4), %edx
movl (%edx,%ecx,4), %edx
movl alu_add16(,%edx,4), %edx
movl (alu_c), %ecx
movl (%edx,%ecx,4), %edx
movw %dx, (alu_s+2)
movl %edx, (alu_c-2)
# end alu_sub16_fast
# end alu_sub32
movl (alu_s), %eax
# end alu_sub
movl %eax, (R2)

# end emit subu

# emit/mov>cnstu4(13)
movl $13, (R1)
# emit/mov>addu4(subu4(indiru4(addrlp4(v)),indiru4(vregp(2))),cnstu4(13))

# emit addu

movl (R2), %eax
movl (R1), %edx
# alu_add
movl %eax, (alu_x)
movl %edx, (alu_y)
# alu_add32
movl $0, %eax
movl $0, %ecx
movl $0, (alu_c)
# alu_add16_fast
movw (alu_x+0), %ax
movw (alu_y+0), %cx
movl alu_add16(,%eax,4), %edx
movl (%edx,%ecx,4), %edx
movw (alu_c+2), %cx
movl alu_add16(,%edx,4), %edx
movl (%edx,%ecx,4), %edx
movw %dx, (alu_s+0)
movl %edx, (alu_c)
# end alu_add16_fast
# alu_add16_fast
movw (alu_x+2), %ax
movw (alu_y+2), %cx
movl alu_add16(,%eax,4), %edx
movl (%edx,%ecx,4), %edx
movw (alu_c+2), %cx
movl alu_add16(,%edx,4), %edx
movl (%edx,%ecx,4), %edx
movw %dx, (alu_s+2)
movl %edx, (alu_c)
# end alu_add16_fast
# end alu_add32
movl (alu_s), %eax
# end alu_add
movl %eax, (R2)

# end emit addu

# emit/mov>cnstu4(26)
movl $26, (R1)
# emit/mov>modu4(addu4(subu4(indiru4(addrlp4(v)),indiru4(vregp(2))),cnstu4(13)),cnstu4(26))

# emit modu

movl (R2), %eax
movl (R1), %edx
# alu_umod
# alu_divrem
movl %eax, (alu_n)
movl %edx, (alu_d)
movl $0, (alu_q)
movl $0, (alu_r)
# alu_bit
movl $0, %edx
movb (alu_n+3), %dl
movl alu_b7(,%edx,4), %eax
movl %eax, (alu_c)
# end alu_bit
# alu_div_shl1_32_c
# alu_div_shl1_8_c
movl $0, %eax
movl $0, %edx
movb (alu_r+0), %al
movb (alu_c), %dl
movl alu_div_shl3_8_d(,%eax,4), %eax
movl alu_div_shl1_8_c_d(%eax,%edx,4), %eax
movb %al, (alu_r+0)
movb %ah, (alu_c)
# end alu_div_shl1_8_c
# alu_div_shl1_8_c
movl $0, %eax
movl $0, %edx
movb (alu_r+1), %al
movb (alu_c), %dl
movl alu_div_shl3_8_d(,%eax,4), %eax
movl alu_div_shl1_8_c_d(%eax,%edx,4), %eax
movb %al, (alu_r+1)
movb %ah, (alu_c)
# end alu_div_shl1_8_c
# alu_div_shl1_8_c
movl $0, %eax
movl $0, %edx
movb (alu_r+2), %al
movb (alu_c), %dl
movl alu_div_shl3_8_d(,%eax,4), %eax
movl alu_div_shl1_8_c_d(%eax,%edx,4), %eax
movb %al, (alu_r+2)
movb %ah, (alu_c)
# end alu_div_shl1_8_c
# alu_div_shl1_8_c
movl $0, %eax
movl $0, %edx
movb (alu_r+3), %al
movb (alu_c), %dl
movl alu_div_shl3_8_d(,%eax,4), %eax
movl alu_div_shl1_8_c_d(%eax,%edx,4), %eax
movb %al, (alu_r+3)
movb %ah, (alu_c)
# end alu_div_shl1_8_c
# end alu_div_shl1_32_c
# alu_div_gte32
movl $0, (alu_c)
movl (alu_r), %eax
movl %eax, (alu_x)
movl (alu_d), %eax
movl %eax, (alu_y)
# alu_sub32
movl $0, %eax
movl $0, %ecx
movl $0x1, (alu_c)
# alu_sub16_fast
movw (alu_x+0), %ax
movw (alu_y+0), %cx
movw alu_inv16(,%ecx,2), %cx
movl alu_add16(,%eax,4), %edx
movl (%edx,%ecx,4), %edx
movl alu_add16(,%edx,4), %edx
movl (alu_c), %ecx
movl (%edx,%ecx,4), %edx
movw %dx, (alu_t+0)
movl %edx, (alu_c-2)
# end alu_sub16_fast
# alu_sub16_fast
movw (alu_x+2), %ax
movw (alu_y+2), %cx
movw alu_inv16(,%ecx,2), %cx
movl alu_add16(,%eax,4), %edx
movl (%edx,%ecx,4), %edx
movl alu_add16(,%edx,4), %edx
movl (alu_c), %ecx
movl (%edx,%ecx,4), %edx
movw %dx, (alu_t+2)
movl %edx, (alu_c-2)
# end alu_sub16_fast
# end alu_sub32
movl $0, %eax
movb (alu_c), %al
movb alu_true(%eax), %al
movl %eax, (alu_t)
# end alu_div_gte32
movl (alu_t), %eax
movl alu_sel_r(,%eax,4), %edx
movl %edx, (alu_psel_r)
movl alu_sel_q(,%eax,4), %edx
movl %edx, (alu_psel_q)
movl (alu_psel_r), %eax
movl (%eax), %eax
movl %eax, (alu_sr)
movl (alu_sr), %eax
movl %eax, (alu_x)
movl (alu_d), %eax
movl %eax, (alu_y)
# alu_sub32
movl $0, %eax
movl $0, %ecx
movl $0x1, (alu_c)
# alu_sub16_fast
movw (alu_x+0), %ax
movw (alu_y+0), %cx
movw alu_inv16(,%ecx,2), %cx
movl alu_add16(,%eax,4), %edx
movl (%edx,%ecx,4), %edx
movl alu_add16(,%edx,4), %edx
movl (alu_c), %ecx
movl (%edx,%ecx,4), %edx
movw %dx, (alu_sr+0)
movl %edx, (alu_c-2)
# end alu_sub16_fast
# alu_sub16_fast
movw (alu_x+2), %ax
movw (alu_y+2), %cx
movw alu_inv16(,%ecx,2), %cx
movl alu_add16(,%eax,4), %edx
movl (%edx,%ecx,4), %edx
movl alu_add16(,%edx,4), %edx
movl (alu_c), %ecx
movl (%edx,%ecx,4), %edx
movw %dx, (alu_sr+2)
movl %edx, (alu_c-2)
# end alu_sub16_fast
# end alu_sub32
movl (alu_psel_r), %eax
movl (alu_sr), %edx
movl %edx, (%eax)
movl (alu_psel_q), %eax
movl (%eax), %eax
movl %eax, (alu_sq)
# alu_div_setb32
movl $0, %eax
movb (alu_sq+3), %al
movb alu_b_s_7(%eax), %al
movb %al, (alu_sq+3)
# end alu_div_setb32
movl (alu_psel_q), %eax
movl (alu_sq), %edx
movl %edx, (%eax)
# alu_bit
movl $0, %edx
movb (alu_n+3), %dl
movl alu_b6(,%edx,4), %eax
movl %eax, (alu_c)
# end alu_bit
# alu_div_shl1_32_c
# alu_div_shl1_8_c
movl $0, %eax
movl $0, %edx
movb (alu_r+0), %al
movb (alu_c), %dl
movl alu_div_shl3_8_d(,%eax,4), %eax
movl alu_div_shl1_8_c_d(%eax,%edx,4), %eax
movb %al, (alu_r+0)
movb %ah, (alu_c)
# end alu_div_shl1_8_c
# alu_div_shl1_8_c
movl $0, %eax
movl $0, %edx
movb (alu_r+1), %al
movb (alu_c), %dl
movl alu_div_shl3_8_d(,%eax,4), %eax
movl alu_div_shl1_8_c_d(%eax,%edx,4), %eax
movb %al, (alu_r+1)
movb %ah, (alu_c)
# end alu_div_shl1_8_c
# alu_div_shl1_8_c
movl $0, %eax
movl $0, %edx
movb (alu_r+2), %al
movb (alu_c), %dl
movl alu_div_shl3_8_d(,%eax,4), %eax
movl alu_div_shl1_8_c_d(%eax,%edx,4), %eax
movb %al, (alu_r+2)
movb %ah, (alu_c)
# end alu_div_shl1_8_c
# alu_div_shl1_8_c
movl $0, %eax
movl $0, %edx
movb (alu_r+3), %al
movb (alu_c), %dl
movl alu_div_shl3_8_d(,%eax,4), %eax
movl alu_div_shl1_8_c_d(%eax,%edx,4), %eax
movb %al, (alu_r+3)
movb %ah, (alu_c)
# end alu_div_shl1_8_c
# end alu_div_shl1_32_c
# alu_div_gte32
movl $0, (alu_c)
movl (alu_r), %eax
movl %eax, (alu_x)
movl (alu_d), %eax
movl %eax, (alu_y)
# alu_sub32
movl $0, %eax
movl $0, %ecx
movl $0x1, (alu_c)
# alu_sub16_fast
movw (alu_x+0), %ax
movw (alu_y+0), %cx
movw alu_inv16(,%ecx,2), %cx
movl alu_add16(,%eax,4), %edx
movl (%edx,%ecx,4), %edx
movl alu_add16(,%edx,4), %edx
movl (alu_c), %ecx
movl (%edx,%ecx,4), %edx
movw %dx, (alu_t+0)
movl %edx, (alu_c-2)
# end alu_sub16_fast
# alu_sub16_fast
movw (alu_x+2), %ax
movw (alu_y+2), %cx
movw alu_inv16(,%ecx,2), %cx
movl alu_add16(,%eax,4), %edx
movl (%edx,%ecx,4), %edx
movl alu_add16(,%edx,4), %edx
movl (alu_c), %ecx
movl (%edx,%ecx,4), %edx
movw %dx, (alu_t+2)
movl %edx, (alu_c-2)
# end alu_sub16_fast
# end alu_sub32
movl $0, %eax
movb (alu_c), %al
movb alu_true(%eax), %al
movl %eax, (alu_t)
# end alu_div_gte32
movl (alu_t), %eax
movl alu_sel_r(,%eax,4), %edx
movl %edx, (alu_psel_r)
movl alu_sel_q(,%eax,4), %edx
movl %edx, (alu_psel_q)
movl (alu_psel_r), %eax
movl (%eax), %eax
movl %eax, (alu_sr)
movl (alu_sr), %eax
movl %eax, (alu_x)
movl (alu_d), %eax
movl %eax, (alu_y)
# alu_sub32
movl $0, %eax
movl $0, %ecx
movl $0x1, (alu_c)
# alu_sub16_fast
movw (alu_x+0), %ax
movw (alu_y+0), %cx
movw alu_inv16(,%ecx,2), %cx
movl alu_add16(,%eax,4), %edx
movl (%edx,%ecx,4), %edx
movl alu_add16(,%edx,4), %edx
movl (alu_c), %ecx
movl (%edx,%ecx,4), %edx
movw %dx, (alu_sr+0)
movl %edx, (alu_c-2)
# end alu_sub16_fast
# alu_sub16_fast
movw (alu_x+2), %ax
movw (alu_y+2), %cx
movw alu_inv16(,%ecx,2), %cx
movl alu_add16(,%eax,4), %edx
movl (%edx,%ecx,4), %edx
movl alu_add16(,%edx,4), %edx
movl (alu_c), %ecx
movl (%edx,%ecx,4), %edx
movw %dx, (alu_sr+2)
movl %edx, (alu_c-2)
# end alu_sub16_fast
# end alu_sub32
movl (alu_psel_r), %eax
movl (alu_sr), %edx
movl %edx, (%eax)
movl (alu_psel_q), %eax
movl (%eax), %eax
movl %eax, (alu_sq)
# alu_div_setb32
movl $0, %eax
movb (alu_sq+3), %al
movb alu_b_s_6(%eax), %al
movb %al, (alu_sq+3)
# end alu_div_setb32
movl (alu_psel_q), %eax
movl (alu_sq), %edx
movl %edx, (%eax)
# alu_bit
movl $0, %edx
movb (alu_n+3), %dl
movl alu_b5(,%edx,4), %eax
movl %eax, (alu_c)
# end alu_bit
# alu_div_shl1_32_c
# alu_div_shl1_8_c
movl $0, %eax
movl $0, %edx
movb (alu_r+0), %al
movb (alu_c), %dl
movl alu_div_shl3_8_d(,%eax,4), %eax
movl alu_div_shl1_8_c_d(%eax,%edx,4), %eax
movb %al, (alu_r+0)
movb %ah, (alu_c)
# end alu_div_shl1_8_c
# alu_div_shl1_8_c
movl $0, %eax
movl $0, %edx
movb (alu_r+1), %al
movb (alu_c), %dl
movl alu_div_shl3_8_d(,%eax,4), %eax
movl alu_div_shl1_8_c_d(%eax,%edx,4), %eax
movb %al, (alu_r+1)
movb %ah, (alu_c)
# end alu_div_shl1_8_c
# alu_div_shl1_8_c
movl $0, %eax
movl $0, %edx
movb (alu_r+2), %al
movb (alu_c), %dl
movl alu_div_shl3_8_d(,%eax,4), %eax
movl alu_div_shl1_8_c_d(%eax,%edx,4), %eax
movb %al, (alu_r+2)
movb %ah, (alu_c)
# end alu_div_shl1_8_c
# alu_div_shl1_8_c
movl $0, %eax
movl $0, %edx
movb (alu_r+3), %al
movb (alu_c), %dl
movl alu_div_shl3_8_d(,%eax,4), %eax
movl alu_div_shl1_8_c_d(%eax,%edx,4), %eax
movb %al, (alu_r+3)
movb %ah, (alu_c)
# end alu_div_shl1_8_c
# end alu_div_shl1_32_c
# alu_div_gte32
movl $0, (alu_c)
movl (alu_r), %eax
movl %eax, (alu_x)
movl (alu_d), %eax
movl %eax, (alu_y)
# alu_sub32
movl $0, %eax
movl $0, %ecx
movl $0x1, (alu_c)
# alu_sub16_fast
movw (alu_x+0), %ax
movw (alu_y+0), %cx
movw alu_inv16(,%ecx,2), %cx
movl alu_add16(,%eax,4), %edx
movl (%edx,%ecx,4), %edx
movl alu_add16(,%edx,4), %edx
movl (alu_c), %ecx
movl (%edx,%ecx,4), %edx
movw %dx, (alu_t+0)
movl %edx, (alu_c-2)
# end alu_sub16_fast
# alu_sub16_fast
movw (alu_x+2), %ax
movw (alu_y+2), %cx
movw alu_inv16(,%ecx,2), %cx
movl alu_add16(,%eax,4), %edx
movl (%edx,%ecx,4), %edx
movl alu_add16(,%edx,4), %edx
movl (alu_c), %ecx
movl (%edx,%ecx,4), %edx
movw %dx, (alu_t+2)
movl %edx, (alu_c-2)
# end alu_sub16_fast
# end alu_sub32
movl $0, %eax
movb (alu_c), %al
movb alu_true(%eax), %al
movl %eax, (alu_t)
# end alu_div_gte32
movl (alu_t), %eax
movl alu_sel_r(,%eax,4), %edx
movl %edx, (alu_psel_r)
movl alu_sel_q(,%eax,4), %edx
movl %edx, (alu_psel_q)
movl (alu_psel_r), %eax
movl (%eax), %eax
movl %eax, (alu_sr)
movl (alu_sr), %eax
movl %eax, (alu_x)
movl (alu_d), %eax
movl %eax, (alu_y)
# alu_sub32
movl $0, %eax
movl $0, %ecx
movl $0x1, (alu_c)
# alu_sub16_fast
movw (alu_x+0), %ax
movw (alu_y+0), %cx
movw alu_inv16(,%ecx,2), %cx
movl alu_add16(,%eax,4), %edx
movl (%edx,%ecx,4), %edx
movl alu_add16(,%edx,4), %edx
movl (alu_c), %ecx
movl (%edx,%ecx,4), %edx
movw %dx, (alu_sr+0)
movl %edx, (alu_c-2)
# end alu_sub16_fast
# alu_sub16_fast
movw (alu_x+2), %ax
movw (alu_y+2), %cx
movw alu_inv16(,%ecx,2), %cx
movl alu_add16(,%eax,4), %edx
movl (%edx,%ecx,4), %edx
movl alu_add16(,%edx,4), %edx
movl (alu_c), %ecx
movl (%edx,%ecx,4), %edx
movw %dx, (alu_sr+2)
movl %edx, (alu_c-2)
# end alu_sub16_fast
# end alu_sub32
movl (alu_psel_r), %eax
movl (alu_sr), %edx
movl %edx, (%eax)
movl (alu_psel_q), %eax
movl (%eax), %eax
movl %eax, (alu_sq)
# alu_div_setb32
movl $0, %eax
movb (alu_sq+3), %al
movb alu_b_s_5(%eax), %al
movb %al, (alu_sq+3)
# end alu_div_setb32
movl (alu_psel_q), %eax
movl (alu_sq), %edx
movl %edx, (%eax)
# alu_bit
movl $0, %edx
movb (alu_n+3), %dl
movl alu_b4(,%edx,4), %eax
movl %eax, (alu_c)
# end alu_bit
# alu_div_shl1_32_c
# alu_div_shl1_8_c
movl $0, %eax
movl $0, %edx
movb (alu_r+0), %al
movb (alu_c), %dl
movl alu_div_shl3_8_d(,%eax,4), %eax
movl alu_div_shl1_8_c_d(%eax,%edx,4), %eax
movb %al, (alu_r+0)
movb %ah, (alu_c)
# end alu_div_shl1_8_c
# alu_div_shl1_8_c
movl $0, %eax
movl $0, %edx
movb (alu_r+1), %al
movb (alu_c), %dl
movl alu_div_shl3_8_d(,%eax,4), %eax
movl alu_div_shl1_8_c_d(%eax,%edx,4), %eax
movb %al, (alu_r+1)
movb %ah, (alu_c)
# end alu_div_shl1_8_c
# alu_div_shl1_8_c
movl $0, %eax
movl $0, %edx
movb (alu_r+2), %al
movb (alu_c), %dl
movl alu_div_shl3_8_d(,%eax,4), %eax
movl alu_div_shl1_8_c_d(%eax,%edx,4), %eax
movb %al, (alu_r+2)
movb %ah, (alu_c)
# end alu_div_shl1_8_c
# alu_div_shl1_8_c
movl $0, %eax
movl $0, %edx
movb (alu_r+3), %al
movb (alu_c), %dl
movl alu_div_shl3_8_d(,%eax,4), %eax
movl alu_div_shl1_8_c_d(%eax,%edx,4), %eax
movb %al, (alu_r+3)
movb %ah, (alu_c)
# end alu_div_shl1_8_c
# end alu_div_shl1_32_c
# alu_div_gte32
movl $0, (alu_c)
movl (alu_r), %eax
movl %eax, (alu_x)
movl (alu_d), %eax
movl %eax, (alu_y)
# alu_sub32
movl $0, %eax
movl $0, %ecx
movl $0x1, (alu_c)
# alu_sub16_fast
movw (alu_x+0), %ax
movw (alu_y+0), %cx
movw alu_inv16(,%ecx,2), %cx
movl alu_add16(,%eax,4), %edx
movl (%edx,%ecx,4), %edx
movl alu_add16(,%edx,4), %edx
movl (alu_c), %ecx
movl (%edx,%ecx,4), %edx
movw %dx, (alu_t+0)
movl %edx, (alu_c-2)
# end alu_sub16_fast
# alu_sub16_fast
movw (alu_x+2), %ax
movw (alu_y+2), %cx
movw alu_inv16(,%ecx,2), %cx
movl alu_add16(,%eax,4), %edx
movl (%edx,%ecx,4), %edx
movl alu_add16(,%edx,4), %edx
movl (alu_c), %ecx
movl (%edx,%ecx,4), %edx
movw %dx, (alu_t+2)
movl %edx, (alu_c-2)
# end alu_sub16_fast
# end alu_sub32
movl $0, %eax
movb (alu_c), %al
movb alu_true(%eax), %al
movl %eax, (alu_t)
# end alu_div_gte32
movl (alu_t), %eax
movl alu_sel_r(,%eax,4), %edx
movl %edx, (alu_psel_r)
movl alu_sel_q(,%eax,4), %edx
movl %edx, (alu_psel_q)
movl (alu_psel_r), %eax
movl (%eax), %eax
movl %eax, (alu_sr)
movl (alu_sr), %eax
movl %eax, (alu_x)
movl (alu_d), %eax
movl %eax, (alu_y)
# alu_sub32
movl $0, %eax
movl $0, %ecx
movl $0x1, (alu_c)
# alu_sub16_fast
movw (alu_x+0), %ax
movw (alu_y+0), %cx
movw alu_inv16(,%ecx,2), %cx
movl alu_add16(,%eax,4), %edx
movl (%edx,%ecx,4), %edx
movl alu_add16(,%edx,4), %edx
movl (alu_c), %ecx
movl (%edx,%ecx,4), %edx
movw %dx, (alu_sr+0)
movl %edx, (alu_c-2)
# end alu_sub16_fast
# alu_sub16_fast
movw (alu_x+2), %ax
movw (alu_y+2), %cx
movw alu_inv16(,%ecx,2), %cx
movl alu_add16(,%eax,4), %edx
movl (%edx,%ecx,4), %edx
movl alu_add16(,%edx,4), %edx
movl (alu_c), %ecx
movl (%edx,%ecx,4), %edx
movw %dx, (alu_sr+2)
movl %edx, (alu_c-2)
# end alu_sub16_fast
# end alu_sub32
movl (alu_psel_r), %eax
movl (alu_sr), %edx
movl %edx, (%eax)
movl (alu_psel_q), %eax
movl (%eax), %eax
movl %eax, (alu_sq)
# alu_div_setb32
movl $0, %eax
movb (alu_sq+3), %al
movb alu_b_s_4(%eax), %al
movb %al, (alu_sq+3)
# end alu_div_setb32
movl (alu_psel_q), %eax
movl (alu_sq), %edx
movl %edx, (%eax)
# alu_bit
movl $0, %edx
movb (alu_n+3), %dl
movl alu_b3(,%edx,4), %eax
movl %eax, (alu_c)
# end alu_bit
# alu_div_shl1_32_c
# alu_div_shl1_8_c
movl $0, %eax
movl $0, %edx
movb (alu_r+0), %al
movb (alu_c), %dl
movl alu_div_shl3_8_d(,%eax,4), %eax
movl alu_div_shl1_8_c_d(%eax,%edx,4), %eax
movb %al, (alu_r+0)
movb %ah, (alu_c)
# end alu_div_shl1_8_c
# alu_div_shl1_8_c
movl $0, %eax
movl $0, %edx
movb (alu_r+1), %al
movb (alu_c), %dl
movl alu_div_shl3_8_d(,%eax,4), %eax
movl alu_div_shl1_8_c_d(%eax,%edx,4), %eax
movb %al, (alu_r+1)
movb %ah, (alu_c)
# end alu_div_shl1_8_c
# alu_div_shl1_8_c
movl $0, %eax
movl $0, %edx
movb (alu_r+2), %al
movb (alu_c), %dl
movl alu_div_shl3_8_d(,%eax,4), %eax
movl alu_div_shl1_8_c_d(%eax,%edx,4), %eax
movb %al, (alu_r+2)
movb %ah, (alu_c)
# end alu_div_shl1_8_c
# alu_div_shl1_8_c
movl $0, %eax
movl $0, %edx
movb (alu_r+3), %al
movb (alu_c), %dl
movl alu_div_shl3_8_d(,%eax,4), %eax
movl alu_div_shl1_8_c_d(%eax,%edx,4), %eax
movb %al, (alu_r+3)
movb %ah, (alu_c)
# end alu_div_shl1_8_c
# end alu_div_shl1_32_c
# alu_div_gte32
movl $0, (alu_c)
movl (alu_r), %eax
movl %eax, (alu_x)
movl (alu_d), %eax
movl %eax, (alu_y)
# alu_sub32
movl $0, %eax
movl $0, %ecx
movl $0x1, (alu_c)
# alu_sub16_fast
movw (alu_x+0), %ax
movw (alu_y+0), %cx
movw alu_inv16(,%ecx,2), %cx
movl alu_add16(,%eax,4), %edx
movl (%edx,%ecx,4), %edx
movl alu_add16(,%edx,4), %edx
movl (alu_c), %ecx
movl (%edx,%ecx,4), %edx
movw %dx, (alu_t+0)
movl %edx, (alu_c-2)
# end alu_sub16_fast
# alu_sub16_fast
movw (alu_x+2), %ax
movw (alu_y+2), %cx
movw alu_inv16(,%ecx,2), %cx
movl alu_add16(,%eax,4), %edx
movl (%edx,%ecx,4), %edx
movl alu_add16(,%edx,4), %edx
movl (alu_c), %ecx
movl (%edx,%ecx,4), %edx
movw %dx, (alu_t+2)
movl %edx, (alu_c-2)
# end alu_sub16_fast
# end alu_sub32
movl $0, %eax
movb (alu_c), %al
movb alu_true(%eax), %al
movl %eax, (alu_t)
# end alu_div_gte32
movl (alu_t), %eax
movl alu_sel_r(,%eax,4), %edx
movl %edx, (alu_psel_r)
movl alu_sel_q(,%eax,4), %edx
movl %edx, (alu_psel_q)
movl (alu_psel_r), %eax
movl (%eax), %eax
movl %eax, (alu_sr)
movl (alu_sr), %eax
movl %eax, (alu_x)
movl (alu_d), %eax
movl %eax, (alu_y)
# alu_sub32
movl $0, %eax
movl $0, %ecx
movl $0x1, (alu_c)
# alu_sub16_fast
movw (alu_x+0), %ax
movw (alu_y+0), %cx
movw alu_inv16(,%ecx,2), %cx
movl alu_add16(,%eax,4), %edx
movl (%edx,%ecx,4), %edx
movl alu_add16(,%edx,4), %edx
movl (alu_c), %ecx
movl (%edx,%ecx,4), %edx
movw %dx, (alu_sr+0)
movl %edx, (alu_c-2)
# end alu_sub16_fast
# alu_sub16_fast
movw (alu_x+2), %ax
movw (alu_y+2), %cx
movw alu_inv16(,%ecx,2), %cx
movl alu_add16(,%eax,4), %edx
movl (%edx,%ecx,4), %edx
movl alu_add16(,%edx,4), %edx
movl (alu_c), %ecx
movl (%edx,%ecx,4), %edx
movw %dx, (alu_sr+2)
movl %edx, (alu_c-2)
# end alu_sub16_fast
# end alu_sub32
movl (alu_psel_r), %eax
movl (alu_sr), %edx
movl %edx, (%eax)
movl (alu_psel_q), %eax
movl (%eax), %eax
movl %eax, (alu_sq)
# alu_div_setb32
movl $0, %eax
movb (alu_sq+3), %al
movb alu_b_s_3(%eax), %al
movb %al, (alu_sq+3)
# end alu_div_setb32
movl (alu_psel_q), %eax
movl (alu_sq), %edx
movl %edx, (%eax)
# alu_bit
movl $0, %edx
movb (alu_n+3), %dl
movl alu_b2(,%edx,4), %eax
movl %eax, (alu_c)
# end alu_bit
# alu_div_shl1_32_c
# alu_div_shl1_8_c
movl $0, %eax
movl $0, %edx
movb (alu_r+0), %al
movb (alu_c), %dl
movl alu_div_shl3_8_d(,%eax,4), %eax
movl alu_div_shl1_8_c_d(%eax,%edx,4), %eax
movb %al, (alu_r+0)
movb %ah, (alu_c)
# end alu_div_shl1_8_c
# alu_div_shl1_8_c
movl $0, %eax
movl $0, %edx
movb (alu_r+1), %al
movb (alu_c), %dl
movl alu_div_shl3_8_d(,%eax,4), %eax
movl alu_div_shl1_8_c_d(%eax,%edx,4), %eax
movb %al, (alu_r+1)
movb %ah, (alu_c)
# end alu_div_shl1_8_c
# alu_div_shl1_8_c
movl $0, %eax
movl $0, %edx
movb (alu_r+2), %al
movb (alu_c), %dl
movl alu_div_shl3_8_d(,%eax,4), %eax
movl alu_div_shl1_8_c_d(%eax,%edx,4), %eax
movb %al, (alu_r+2)
movb %ah, (alu_c)
# end alu_div_shl1_8_c
# alu_div_shl1_8_c
movl $0, %eax
movl $0, %edx
movb (alu_r+3), %al
movb (alu_c), %dl
movl alu_div_shl3_8_d(,%eax,4), %eax
movl alu_div_shl1_8_c_d(%eax,%edx,4), %eax
movb %al, (alu_r+3)
movb %ah, (alu_c)
# end alu_div_shl1_8_c
# end alu_div_shl1_32_c
# alu_div_gte32
movl $0, (alu_c)
movl (alu_r), %eax
movl %eax, (alu_x)
movl (alu_d), %eax
movl %eax, (alu_y)
# alu_sub32
movl $0, %eax
movl $0, %ecx
movl $0x1, (alu_c)
# alu_sub16_fast
movw (alu_x+0), %ax
movw (alu_y+0), %cx
movw alu_inv16(,%ecx,2), %cx
movl alu_add16(,%eax,4), %edx
movl (%edx,%ecx,4), %edx
movl alu_add16(,%edx,4), %edx
movl (alu_c), %ecx
movl (%edx,%ecx,4), %edx
movw %dx, (alu_t+0)
movl %edx, (alu_c-2)
# end alu_sub16_fast
# alu_sub16_fast
movw (alu_x+2), %ax
movw (alu_y+2), %cx
movw alu_inv16(,%ecx,2), %cx
movl alu_add16(,%eax,4), %edx
movl (%edx,%ecx,4), %edx
movl alu_add16(,%edx,4), %edx
movl (alu_c), %ecx
movl (%edx,%ecx,4), %edx
movw %dx, (alu_t+2)
movl %edx, (alu_c-2)
# end alu_sub16_fast
# end alu_sub32
movl $0, %eax
movb (alu_c), %al
movb alu_true(%eax), %al
movl %eax, (alu_t)
# end alu_div_gte32
movl (alu_t), %eax
movl alu_sel_r(,%eax,4), %edx
movl %edx, (alu_psel_r)
movl alu_sel_q(,%eax,4), %edx
movl %edx, (alu_psel_q)
movl (alu_psel_r), %eax
movl (%eax), %eax
movl %eax, (alu_sr)
movl (alu_sr), %eax
movl %eax, (alu_x)
movl (alu_d), %eax
movl %eax, (alu_y)
# alu_sub32
movl $0, %eax
movl $0, %ecx
movl $0x1, (alu_c)
# alu_sub16_fast
movw (alu_x+0), %ax
movw (alu_y+0), %cx
movw alu_inv16(,%ecx,2), %cx
movl alu_add16(,%eax,4), %edx
movl (%edx,%ecx,4), %edx
movl alu_add16(,%edx,4), %edx
movl (alu_c), %ecx
movl (%edx,%ecx,4), %edx
movw %dx, (alu_sr+0)
movl %edx, (alu_c-2)
# end alu_sub16_fast
# alu_sub16_fast
movw (alu_x+2), %ax
movw (alu_y+2), %cx
movw alu_inv16(,%ecx,2), %cx
movl alu_add16(,%eax,4), %edx
movl (%edx,%ecx,4), %edx
movl alu_add16(,%edx,4), %edx
movl (alu_c), %ecx
movl (%edx,%ecx,4), %edx
movw %dx, (alu_sr+2)
movl %edx, (alu_c-2)
# end alu_sub16_fast
# end alu_sub32
movl (alu_psel_r), %eax
movl (alu_sr), %edx
movl %edx, (%eax)
movl (alu_psel_q), %eax
movl (%eax), %eax
movl %eax, (alu_sq)
# alu_div_setb32
movl $0, %eax
movb (alu_sq+3), %al
movb alu_b_s_2(%eax), %al
movb %al, (alu_sq+3)
# end alu_div_setb32
movl (alu_psel_q), %eax
movl (alu_sq), %edx
movl %edx, (%eax)
# alu_bit
movl $0, %edx
movb (alu_n+3), %dl
movl alu_b1(,%edx,4), %eax
movl %eax, (alu_c)
# end alu_bit
# alu_div_shl1_32_c
# alu_div_shl1_8_c
movl $0, %eax
movl $0, %edx
movb (alu_r+0), %al
movb (alu_c), %dl
movl alu_div_shl3_8_d(,%eax,4), %eax
movl alu_div_shl1_8_c_d(%eax,%edx,4), %eax
movb %al, (alu_r+0)
movb %ah, (alu_c)
# end alu_div_shl1_8_c
# alu_div_shl1_8_c
movl $0, %eax
movl $0, %edx
movb (alu_r+1), %al
movb (alu_c), %dl
movl alu_div_shl3_8_d(,%eax,4), %eax
movl alu_div_shl1_8_c_d(%eax,%edx,4), %eax
movb %al, (alu_r+1)
movb %ah, (alu_c)
# end alu_div_shl1_8_c
# alu_div_shl1_8_c
movl $0, %eax
movl $0, %edx
movb (alu_r+2), %al
movb (alu_c), %dl
movl alu_div_shl3_8_d(,%eax,4), %eax
movl alu_div_shl1_8_c_d(%eax,%edx,4), %eax
movb %al, (alu_r+2)
movb %ah, (alu_c)
# end alu_div_shl1_8_c
# alu_div_shl1_8_c
movl $0, %eax
movl $0, %edx
movb (alu_r+3), %al
movb (alu_c), %dl
movl alu_div_shl3_8_d(,%eax,4), %eax
movl alu_div_shl1_8_c_d(%eax,%edx,4), %eax
movb %al, (alu_r+3)
movb %ah, (alu_c)
# end alu_div_shl1_8_c
# end alu_div_shl1_32_c
# alu_div_gte32
movl $0, (alu_c)
movl (alu_r), %eax
movl %eax, (alu_x)
movl (alu_d), %eax
movl %eax, (alu_y)
# alu_sub32
movl $0, %eax
movl $0, %ecx
movl $0x1, (alu_c)
# alu_sub16_fast
movw (alu_x+0), %ax
movw (alu_y+0), %cx
movw alu_inv16(,%ecx,2), %cx
movl alu_add16(,%eax,4), %edx
movl (%edx,%ecx,4), %edx
movl alu_add16(,%edx,4), %edx
movl (alu_c), %ecx
movl (%edx,%ecx,4), %edx
movw %dx, (alu_t+0)
movl %edx, (alu_c-2)
# end alu_sub16_fast
# alu_sub16_fast
movw (alu_x+2), %ax
movw (alu_y+2), %cx
movw alu_inv16(,%ecx,2), %cx
movl alu_add16(,%eax,4), %edx
movl (%edx,%ecx,4), %edx
movl alu_add16(,%edx,4), %edx
movl (alu_c), %ecx
movl (%edx,%ecx,4), %edx
movw %dx, (alu_t+2)
movl %edx, (alu_c-2)
# end alu_sub16_fast
# end alu_sub32
movl $0, %eax
movb (alu_c), %al
movb alu_true(%eax), %al
movl %eax, (alu_t)
# end alu_div_gte32
movl (alu_t), %eax
movl alu_sel_r(,%eax,4), %edx
movl %edx, (alu_psel_r)
movl alu_sel_q(,%eax,4), %edx
movl %edx, (alu_psel_q)
movl (alu_psel_r), %eax
movl (%eax), %eax
movl %eax, (alu_sr)
movl (alu_sr), %eax
movl %eax, (alu_x)
movl (alu_d), %eax
movl %eax, (alu_y)
# alu_sub32
movl $0, %eax
movl $0, %ecx
movl $0x1, (alu_c)
# alu_sub16_fast
movw (alu_x+0), %ax
movw (alu_y+0), %cx
movw alu_inv16(,%ecx,2), %cx
movl alu_add16(,%eax,4), %edx
movl (%edx,%ecx,4), %edx
movl alu_add16(,%edx,4), %edx
movl (alu_c), %ecx
movl (%edx,%ecx,4), %edx
movw %dx, (alu_sr+0)
movl %edx, (alu_c-2)
# end alu_sub16_fast
# alu_sub16_fast
movw (alu_x+2), %ax
movw (alu_y+2), %cx
movw alu_inv16(,%ecx,2), %cx
movl alu_add16(,%eax,4), %edx
movl (%edx,%ecx,4), %edx
movl alu_add16(,%edx,4), %edx
movl (alu_c), %ecx
movl (%edx,%ecx,4), %edx
movw %dx, (alu_sr+2)
movl %edx, (alu_c-2)
# end alu_sub16_fast
# end alu_sub32
movl (alu_psel_r), %eax
movl (alu_sr), %edx
movl %edx, (%eax)
movl (alu_psel_q), %eax
movl (%eax), %eax
movl %eax, (alu_sq)
# alu_div_setb32
movl $0, %eax
movb (alu_sq+3), %al
movb alu_b_s_1(%eax), %al
movb %al, (alu_sq+3)
# end alu_div_setb32
movl (alu_psel_q), %eax
movl (alu_sq), %edx
movl %edx, (%eax)
# alu_bit
movl $0, %edx
movb (alu_n+3), %dl
movl alu_b0(,%edx,4), %eax
movl %eax, (alu_c)
# end alu_bit
# alu_div_shl1_32_c
# alu_div_shl1_8_c
movl $0, %eax
movl $0, %edx
movb (alu_r+0), %al
movb (alu_c), %dl
movl alu_div_shl3_8_d(,%eax,4), %eax
movl alu_div_shl1_8_c_d(%eax,%edx,4), %eax
movb %al, (alu_r+0)
movb %ah, (alu_c)
# end alu_div_shl1_8_c
# alu_div_shl1_8_c
movl $0, %eax
movl $0, %edx
movb (alu_r+1), %al
movb (alu_c), %dl
movl alu_div_shl3_8_d(,%eax,4), %eax
movl alu_div_shl1_8_c_d(%eax,%edx,4), %eax
movb %al, (alu_r+1)
movb %ah, (alu_c)
# end alu_div_shl1_8_c
# alu_div_shl1_8_c
movl $0, %eax
movl $0, %edx
movb (alu_r+2), %al
movb (alu_c), %dl
movl alu_div_shl3_8_d(,%eax,4), %eax
movl alu_div_shl1_8_c_d(%eax,%edx,4), %eax
movb %al, (alu_r+2)
movb %ah, (alu_c)
# end alu_div_shl1_8_c
# alu_div_shl1_8_c
movl $0, %eax
movl $0, %edx
movb (alu_r+3), %al
movb (alu_c), %dl
movl alu_div_shl3_8_d(,%eax,4), %eax
movl alu_div_shl1_8_c_d(%eax,%edx,4), %eax
movb %al, (alu_r+3)
movb %ah, (alu_c)
# end alu_div_shl1_8_c
# end alu_div_shl1_32_c
# alu_div_gte32
movl $0, (alu_c)
movl (alu_r), %eax
movl %eax, (alu_x)
movl (alu_d), %eax
movl %eax, (alu_y)
# alu_sub32
movl $0, %eax
movl $0, %ecx
movl $0x1, (alu_c)
# alu_sub16_fast
movw (alu_x+0), %ax
movw (alu_y+0), %cx
movw alu_inv16(,%ecx,2), %cx
movl alu_add16(,%eax,4), %edx
movl (%edx,%ecx,4), %edx
movl alu_add16(,%edx,4), %edx
movl (alu_c), %ecx
movl (%edx,%ecx,4), %edx
movw %dx, (alu_t+0)
movl %edx, (alu_c-2)
# end alu_sub16_fast
# alu_sub16_fast
movw (alu_x+2), %ax
movw (alu_y+2), %cx
movw alu_inv16(,%ecx,2), %cx
movl alu_add16(,%eax,4), %edx
movl (%edx,%ecx,4), %edx
movl alu_add16(,%edx,4), %edx
movl (alu_c), %ecx
movl (%edx,%ecx,4), %edx
movw %dx, (alu_t+2)
movl %edx, (alu_c-2)
# end alu_sub16_fast
# end alu_sub32
movl $0, %eax
movb (alu_c), %al
movb alu_true(%eax), %al
movl %eax, (alu_t)
# end alu_div_gte32
movl (alu_t), %eax
movl alu_sel_r(,%eax,4), %edx
movl %edx, (alu_psel_r)
movl alu_sel_q(,%eax,4), %edx
movl %edx, (alu_psel_q)
movl (alu_psel_r), %eax
movl (%eax), %eax
movl %eax, (alu_sr)
movl (alu_sr), %eax
movl %eax, (alu_x)
movl (alu_d), %eax
movl %eax, (alu_y)
# alu_sub32
movl $0, %eax
movl $0, %ecx
movl $0x1, (alu_c)
# alu_sub16_fast
movw (alu_x+0), %ax
movw (alu_y+0), %cx
movw alu_inv16(,%ecx,2), %cx
movl alu_add16(,%eax,4), %edx
movl (%edx,%ecx,4), %edx
movl alu_add16(,%edx,4), %edx
movl (alu_c), %ecx
movl (%edx,%ecx,4), %edx
movw %dx, (alu_sr+0)
movl %edx, (alu_c-2)
# end alu_sub16_fast
# alu_sub16_fast
movw (alu_x+2), %ax
movw (alu_y+2), %cx
movw alu_inv16(,%ecx,2), %cx
movl alu_add16(,%eax,4), %edx
movl (%edx,%ecx,4), %edx
movl alu_add16(,%edx,4), %edx
movl (alu_c), %ecx
movl (%edx,%ecx,4), %edx
movw %dx, (alu_sr+2)
movl %edx, (alu_c-2)
# end alu_sub16_fast
# end alu_sub32
movl (alu_psel_r), %eax
movl (alu_sr), %edx
movl %edx, (%eax)
movl (alu_psel_q), %eax
movl (%eax), %eax
movl %eax, (alu_sq)
# alu_div_setb32
movl $0, %eax
movb (alu_sq+3), %al
movb alu_b_s_0(%eax), %al
movb %al, (alu_sq+3)
# end alu_div_setb32
movl (alu_psel_q), %eax
movl (alu_sq), %edx
movl %edx, (%eax)
# alu_bit
movl $0, %edx
movb (alu_n+2), %dl
movl alu_b7(,%edx,4), %eax
movl %eax, (alu_c)
# end alu_bit
# alu_div_shl1_32_c
# alu_div_shl1_8_c
movl $0, %eax
movl $0, %edx
movb (alu_r+0), %al
movb (alu_c), %dl
movl alu_div_shl3_8_d(,%eax,4), %eax
movl alu_div_shl1_8_c_d(%eax,%edx,4), %eax
movb %al, (alu_r+0)
movb %ah, (alu_c)
# end alu_div_shl1_8_c
# alu_div_shl1_8_c
movl $0, %eax
movl $0, %edx
movb (alu_r+1), %al
movb (alu_c), %dl
movl alu_div_shl3_8_d(,%eax,4), %eax
movl alu_div_shl1_8_c_d(%eax,%edx,4), %eax
movb %al, (alu_r+1)
movb %ah, (alu_c)
# end alu_div_shl1_8_c
# alu_div_shl1_8_c
movl $0, %eax
movl $0, %edx
movb (alu_r+2), %al
movb (alu_c), %dl
movl alu_div_shl3_8_d(,%eax,4), %eax
movl alu_div_shl1_8_c_d(%eax,%edx,4), %eax
movb %al, (alu_r+2)
movb %ah, (alu_c)
# end alu_div_shl1_8_c
# alu_div_shl1_8_c
movl $0, %eax
movl $0, %edx
movb (alu_r+3), %al
movb (alu_c), %dl
movl alu_div_shl3_8_d(,%eax,4), %eax
movl alu_div_shl1_8_c_d(%eax,%edx,4), %eax
movb %al, (alu_r+3)
movb %ah, (alu_c)
# end alu_div_shl1_8_c
# end alu_div_shl1_32_c
# alu_div_gte32
movl $0, (alu_c)
movl (alu_r), %eax
movl %eax, (alu_x)
movl (alu_d), %eax
movl %eax, (alu_y)
# alu_sub32
movl $0, %eax
movl $0, %ecx
movl $0x1, (alu_c)
# alu_sub16_fast
movw (alu_x+0), %ax
movw (alu_y+0), %cx
movw alu_inv16(,%ecx,2), %cx
movl alu_add16(,%eax,4), %edx
movl (%edx,%ecx,4), %edx
movl alu_add16(,%edx,4), %edx
movl (alu_c), %ecx
movl (%edx,%ecx,4), %edx
movw %dx, (alu_t+0)
movl %edx, (alu_c-2)
# end alu_sub16_fast
# alu_sub16_fast
movw (alu_x+2), %ax
movw (alu_y+2), %cx
movw alu_inv16(,%ecx,2), %cx
movl alu_add16(,%eax,4), %edx
movl (%edx,%ecx,4), %edx
movl alu_add16(,%edx,4), %edx
movl (alu_c), %ecx
movl (%edx,%ecx,4), %edx
movw %dx, (alu_t+2)
movl %edx, (alu_c-2)
# end alu_sub16_fast
# end alu_sub32
movl $0, %eax
movb (alu_c), %al
movb alu_true(%eax), %al
movl %eax, (alu_t)
# end alu_div_gte32
movl (alu_t), %eax
movl alu_sel_r(,%eax,4), %edx
movl %edx, (alu_psel_r)
movl alu_sel_q(,%eax,4), %edx
movl %edx, (alu_psel_q)
movl (alu_psel_r), %eax
movl (%eax), %eax
movl %eax, (alu_sr)
movl (alu_sr), %eax
movl %eax, (alu_x)
movl (alu_d), %eax
movl %eax, (alu_y)
# alu_sub32
movl $0, %eax
movl $0, %ecx
movl $0x1, (alu_c)
# alu_sub16_fast
movw (alu_x+0), %ax
movw (alu_y+0), %cx
movw alu_inv16(,%ecx,2), %cx
movl alu_add16(,%eax,4), %edx
movl (%edx,%ecx,4), %edx
movl alu_add16(,%edx,4), %edx
movl (alu_c), %ecx
movl (%edx,%ecx,4), %edx
movw %dx, (alu_sr+0)
movl %edx, (alu_c-2)
# end alu_sub16_fast
# alu_sub16_fast
movw (alu_x+2), %ax
movw (alu_y+2), %cx
movw alu_inv16(,%ecx,2), %cx
movl alu_add16(,%eax,4), %edx
movl (%edx,%ecx,4), %edx
movl alu_add16(,%edx,4), %edx
movl (alu_c), %ecx
movl (%edx,%ecx,4), %edx
movw %dx, (alu_sr+2)
movl %edx, (alu_c-2)
# end alu_sub16_fast
# end alu_sub32
movl (alu_psel_r), %eax
movl (alu_sr), %edx
movl %edx, (%eax)
movl (alu_psel_q), %eax
movl (%eax), %eax
movl %eax, (alu_sq)
# alu_div_setb32
movl $0, %eax
movb (alu_sq+2), %al
movb alu_b_s_7(%eax), %al
movb %al, (alu_sq+2)
# end alu_div_setb32
movl (alu_psel_q), %eax
movl (alu_sq), %edx
movl %edx, (%eax)
# alu_bit
movl $0, %edx
movb (alu_n+2), %dl
movl alu_b6(,%edx,4), %eax
movl %eax, (alu_c)
# end alu_bit
# alu_div_shl1_32_c
# alu_div_shl1_8_c
movl $0, %eax
movl $0, %edx
movb (alu_r+0), %al
movb (alu_c), %dl
movl alu_div_shl3_8_d(,%eax,4), %eax
movl alu_div_shl1_8_c_d(%eax,%edx,4), %eax
movb %al, (alu_r+0)
movb %ah, (alu_c)
# end alu_div_shl1_8_c
# alu_div_shl1_8_c
movl $0, %eax
movl $0, %edx
movb (alu_r+1), %al
movb (alu_c), %dl
movl alu_div_shl3_8_d(,%eax,4), %eax
movl alu_div_shl1_8_c_d(%eax,%edx,4), %eax
movb %al, (alu_r+1)
movb %ah, (alu_c)
# end alu_div_shl1_8_c
# alu_div_shl1_8_c
movl $0, %eax
movl $0, %edx
movb (alu_r+2), %al
movb (alu_c), %dl
movl alu_div_shl3_8_d(,%eax,4), %eax
movl alu_div_shl1_8_c_d(%eax,%edx,4), %eax
movb %al, (alu_r+2)
movb %ah, (alu_c)
# end alu_div_shl1_8_c
# alu_div_shl1_8_c
movl $0, %eax
movl $0, %edx
movb (alu_r+3), %al
movb (alu_c), %dl
movl alu_div_shl3_8_d(,%eax,4), %eax
movl alu_div_shl1_8_c_d(%eax,%edx,4), %eax
movb %al, (alu_r+3)
movb %ah, (alu_c)
# end alu_div_shl1_8_c
# end alu_div_shl1_32_c
# alu_div_gte32
movl $0, (alu_c)
movl (alu_r), %eax
movl %eax, (alu_x)
movl (alu_d), %eax
movl %eax, (alu_y)
# alu_sub32
movl $0, %eax
movl $0, %ecx
movl $0x1, (alu_c)
# alu_sub16_fast
movw (alu_x+0), %ax
movw (alu_y+0), %cx
movw alu_inv16(,%ecx,2), %cx
movl alu_add16(,%eax,4), %edx
movl (%edx,%ecx,4), %edx
movl alu_add16(,%edx,4), %edx
movl (alu_c), %ecx
movl (%edx,%ecx,4), %edx
movw %dx, (alu_t+0)
movl %edx, (alu_c-2)
# end alu_sub16_fast
# alu_sub16_fast
movw (alu_x+2), %ax
movw (alu_y+2), %cx
movw alu_inv16(,%ecx,2), %cx
movl alu_add16(,%eax,4), %edx
movl (%edx,%ecx,4), %edx
movl alu_add16(,%edx,4), %edx
movl (alu_c), %ecx
movl (%edx,%ecx,4), %edx
movw %dx, (alu_t+2)
movl %edx, (alu_c-2)
# end alu_sub16_fast
# end alu_sub32
movl $0, %eax
movb (alu_c), %al
movb alu_true(%eax), %al
movl %eax, (alu_t)
# end alu_div_gte32
movl (alu_t), %eax
movl alu_sel_r(,%eax,4), %edx
movl %edx, (alu_psel_r)
movl alu_sel_q(,%eax,4), %edx
movl %edx, (alu_psel_q)
movl (alu_psel_r), %eax
movl (%eax), %eax
movl %eax, (alu_sr)
movl (alu_sr), %eax
movl %eax, (alu_x)
movl (alu_d), %eax
movl %eax, (alu_y)
# alu_sub32
movl $0, %eax
movl $0, %ecx
movl $0x1, (alu_c)
# alu_sub16_fast
movw (alu_x+0), %ax
movw (alu_y+0), %cx
movw alu_inv16(,%ecx,2), %cx
movl alu_add16(,%eax,4), %edx
movl (%edx,%ecx,4), %edx
movl alu_add16(,%edx,4), %edx
movl (alu_c), %ecx
movl (%edx,%ecx,4), %edx
movw %dx, (alu_sr+0)
movl %edx, (alu_c-2)
# end alu_sub16_fast
# alu_sub16_fast
movw (alu_x+2), %ax
movw (alu_y+2), %cx
movw alu_inv16(,%ecx,2), %cx
movl alu_add16(,%eax,4), %edx
movl (%edx,%ecx,4), %edx
movl alu_add16(,%edx,4), %edx
movl (alu_c), %ecx
movl (%edx,%ecx,4), %edx
movw %dx, (alu_sr+2)
movl %edx, (alu_c-2)
# end alu_sub16_fast
# end alu_sub32
movl (alu_psel_r), %eax
movl (alu_sr), %edx
movl %edx, (%eax)
movl (alu_psel_q), %eax
movl (%eax), %eax
movl %eax, (alu_sq)
# alu_div_setb32
movl $0, %eax
movb (alu_sq+2), %al
movb alu_b_s_6(%eax), %al
movb %al, (alu_sq+2)
# end alu_div_setb32
movl (alu_psel_q), %eax
movl (alu_sq), %edx
movl %edx, (%eax)
# alu_bit
movl $0, %edx
movb (alu_n+2), %dl
movl alu_b5(,%edx,4), %eax
movl %eax, (alu_c)
# end alu_bit
# alu_div_shl1_32_c
# alu_div_shl1_8_c
movl $0, %eax
movl $0, %edx
movb (alu_r+0), %al
movb (alu_c), %dl
movl alu_div_shl3_8_d(,%eax,4), %eax
movl alu_div_shl1_8_c_d(%eax,%edx,4), %eax
movb %al, (alu_r+0)
movb %ah, (alu_c)
# end alu_div_shl1_8_c
# alu_div_shl1_8_c
movl $0, %eax
movl $0, %edx
movb (alu_r+1), %al
movb (alu_c), %dl
movl alu_div_shl3_8_d(,%eax,4), %eax
movl alu_div_shl1_8_c_d(%eax,%edx,4), %eax
movb %al, (alu_r+1)
movb %ah, (alu_c)
# end alu_div_shl1_8_c
# alu_div_shl1_8_c
movl $0, %eax
movl $0, %edx
movb (alu_r+2), %al
movb (alu_c), %dl
movl alu_div_shl3_8_d(,%eax,4), %eax
movl alu_div_shl1_8_c_d(%eax,%edx,4), %eax
movb %al, (alu_r+2)
movb %ah, (alu_c)
# end alu_div_shl1_8_c
# alu_div_shl1_8_c
movl $0, %eax
movl $0, %edx
movb (alu_r+3), %al
movb (alu_c), %dl
movl alu_div_shl3_8_d(,%eax,4), %eax
movl alu_div_shl1_8_c_d(%eax,%edx,4), %eax
movb %al, (alu_r+3)
movb %ah, (alu_c)
# end alu_div_shl1_8_c
# end alu_div_shl1_32_c
# alu_div_gte32
movl $0, (alu_c)
movl (alu_r), %eax
movl %eax, (alu_x)
movl (alu_d), %eax
movl %eax, (alu_y)
# alu_sub32
movl $0, %eax
movl $0, %ecx
movl $0x1, (alu_c)
# alu_sub16_fast
movw (alu_x+0), %ax
movw (alu_y+0), %cx
movw alu_inv16(,%ecx,2), %cx
movl alu_add16(,%eax,4), %edx
movl (%edx,%ecx,4), %edx
movl alu_add16(,%edx,4), %edx
movl (alu_c), %ecx
movl (%edx,%ecx,4), %edx
movw %dx, (alu_t+0)
movl %edx, (alu_c-2)
# end alu_sub16_fast
# alu_sub16_fast
movw (alu_x+2), %ax
movw (alu_y+2), %cx
movw alu_inv16(,%ecx,2), %cx
movl alu_add16(,%eax,4), %edx
movl (%edx,%ecx,4), %edx
movl alu_add16(,%edx,4), %edx
movl (alu_c), %ecx
movl (%edx,%ecx,4), %edx
movw %dx, (alu_t+2)
movl %edx, (alu_c-2)
# end alu_sub16_fast
# end alu_sub32
movl $0, %eax
movb (alu_c), %al
movb alu_true(%eax), %al
movl %eax, (alu_t)
# end alu_div_gte32
movl (alu_t), %eax
movl alu_sel_r(,%eax,4), %edx
movl %edx, (alu_psel_r)
movl alu_sel_q(,%eax,4), %edx
movl %edx, (alu_psel_q)
movl (alu_psel_r), %eax
movl (%eax), %eax
movl %eax, (alu_sr)
movl (alu_sr), %eax
movl %eax, (alu_x)
movl (alu_d), %eax
movl %eax, (alu_y)
# alu_sub32
movl $0, %eax
movl $0, %ecx
movl $0x1, (alu_c)
# alu_sub16_fast
movw (alu_x+0), %ax
movw (alu_y+0), %cx
movw alu_inv16(,%ecx,2), %cx
movl alu_add16(,%eax,4), %edx
movl (%edx,%ecx,4), %edx
movl alu_add16(,%edx,4), %edx
movl (alu_c), %ecx
movl (%edx,%ecx,4), %edx
movw %dx, (alu_sr+0)
movl %edx, (alu_c-2)
# end alu_sub16_fast
# alu_sub16_fast
movw (alu_x+2), %ax
movw (alu_y+2), %cx
movw alu_inv16(,%ecx,2), %cx
movl alu_add16(,%eax,4), %edx
movl (%edx,%ecx,4), %edx
movl alu_add16(,%edx,4), %edx
movl (alu_c), %ecx
movl (%edx,%ecx,4), %edx
movw %dx, (alu_sr+2)
movl %edx, (alu_c-2)
# end alu_sub16_fast
# end alu_sub32
movl (alu_psel_r), %eax
movl (alu_sr), %edx
movl %edx, (%eax)
movl (alu_psel_q), %eax
movl (%eax), %eax
movl %eax, (alu_sq)
# alu_div_setb32
movl $0, %eax
movb (alu_sq+2), %al
movb alu_b_s_5(%eax), %al
movb %al, (alu_sq+2)
# end alu_div_setb32
movl (alu_psel_q), %eax
movl (alu_sq), %edx
movl %edx, (%eax)
# alu_bit
movl $0, %edx
movb (alu_n+2), %dl
movl alu_b4(,%edx,4), %eax
movl %eax, (alu_c)
# end alu_bit
# alu_div_shl1_32_c
# alu_div_shl1_8_c
movl $0, %eax
movl $0, %edx
movb (alu_r+0), %al
movb (alu_c), %dl
movl alu_div_shl3_8_d(,%eax,4), %eax
movl alu_div_shl1_8_c_d(%eax,%edx,4), %eax
movb %al, (alu_r+0)
movb %ah, (alu_c)
# end alu_div_shl1_8_c
# alu_div_shl1_8_c
movl $0, %eax
movl $0, %edx
movb (alu_r+1), %al
movb (alu_c), %dl
movl alu_div_shl3_8_d(,%eax,4), %eax
movl alu_div_shl1_8_c_d(%eax,%edx,4), %eax
movb %al, (alu_r+1)
movb %ah, (alu_c)
# end alu_div_shl1_8_c
# alu_div_shl1_8_c
movl $0, %eax
movl $0, %edx
movb (alu_r+2), %al
movb (alu_c), %dl
movl alu_div_shl3_8_d(,%eax,4), %eax
movl alu_div_shl1_8_c_d(%eax,%edx,4), %eax
movb %al, (alu_r+2)
movb %ah, (alu_c)
# end alu_div_shl1_8_c
# alu_div_shl1_8_c
movl $0, %eax
movl $0, %edx
movb (alu_r+3), %al
movb (alu_c), %dl
movl alu_div_shl3_8_d(,%eax,4), %eax
movl alu_div_shl1_8_c_d(%eax,%edx,4), %eax
movb %al, (alu_r+3)
movb %ah, (alu_c)
# end alu_div_shl1_8_c
# end alu_div_shl1_32_c
# alu_div_gte32
movl $0, (alu_c)
movl (alu_r), %eax
movl %eax, (alu_x)
movl (alu_d), %eax
movl %eax, (alu_y)
# alu_sub32
movl $0, %eax
movl $0, %ecx
movl $0x1, (alu_c)
# alu_sub16_fast
movw (alu_x+0), %ax
movw (alu_y+0), %cx
movw alu_inv16(,%ecx,2), %cx
movl alu_add16(,%eax,4), %edx
movl (%edx,%ecx,4), %edx
movl alu_add16(,%edx,4), %edx
movl (alu_c), %ecx
movl (%edx,%ecx,4), %edx
movw %dx, (alu_t+0)
movl %edx, (alu_c-2)
# end alu_sub16_fast
# alu_sub16_fast
movw (alu_x+2), %ax
movw (alu_y+2), %cx
movw alu_inv16(,%ecx,2), %cx
movl alu_add16(,%eax,4), %edx
movl (%edx,%ecx,4), %edx
movl alu_add16(,%edx,4), %edx
movl (alu_c), %ecx
movl (%edx,%ecx,4), %edx
movw %dx, (alu_t+2)
movl %edx, (alu_c-2)
# end alu_sub16_fast
# end alu_sub32
movl $0, %eax
movb (alu_c), %al
movb alu_true(%eax), %al
movl %eax, (alu_t)
# end alu_div_gte32
movl (alu_t), %eax
movl alu_sel_r(,%eax,4), %edx
movl %edx, (alu_psel_r)
movl alu_sel_q(,%eax,4), %edx
movl %edx, (alu_psel_q)
movl (alu_psel_r), %eax
movl (%eax), %eax
movl %eax, (alu_sr)
movl (alu_sr), %eax
movl %eax, (alu_x)
movl (alu_d), %eax
movl %eax, (alu_y)
# alu_sub32
movl $0, %eax
movl $0, %ecx
movl $0x1, (alu_c)
# alu_sub16_fast
movw (alu_x+0), %ax
movw (alu_y+0), %cx
movw alu_inv16(,%ecx,2), %cx
movl alu_add16(,%eax,4), %edx
movl (%edx,%ecx,4), %edx
movl alu_add16(,%edx,4), %edx
movl (alu_c), %ecx
movl (%edx,%ecx,4), %edx
movw %dx, (alu_sr+0)
movl %edx, (alu_c-2)
# end alu_sub16_fast
# alu_sub16_fast
movw (alu_x+2), %ax
movw (alu_y+2), %cx
movw alu_inv16(,%ecx,2), %cx
movl alu_add16(,%eax,4), %edx
movl (%edx,%ecx,4), %edx
movl alu_add16(,%edx,4), %edx
movl (alu_c), %ecx
movl (%edx,%ecx,4), %edx
movw %dx, (alu_sr+2)
movl %edx, (alu_c-2)
# end alu_sub16_fast
# end alu_sub32
movl (alu_psel_r), %eax
movl (alu_sr), %edx
movl %edx, (%eax)
movl (alu_psel_q), %eax
movl (%eax), %eax
movl %eax, (alu_sq)
# alu_div_setb32
movl $0, %eax
movb (alu_sq+2), %al
movb alu_b_s_4(%eax), %al
movb %al, (alu_sq+2)
# end alu_div_setb32
movl (alu_psel_q), %eax
movl (alu_sq), %edx
movl %edx, (%eax)
# alu_bit
movl $0, %edx
movb (alu_n+2), %dl
movl alu_b3(,%edx,4), %eax
movl %eax, (alu_c)
# end alu_bit
# alu_div_shl1_32_c
# alu_div_shl1_8_c
movl $0, %eax
movl $0, %edx
movb (alu_r+0), %al
movb (alu_c), %dl
movl alu_div_shl3_8_d(,%eax,4), %eax
movl alu_div_shl1_8_c_d(%eax,%edx,4), %eax
movb %al, (alu_r+0)
movb %ah, (alu_c)
# end alu_div_shl1_8_c
# alu_div_shl1_8_c
movl $0, %eax
movl $0, %edx
movb (alu_r+1), %al
movb (alu_c), %dl
movl alu_div_shl3_8_d(,%eax,4), %eax
movl alu_div_shl1_8_c_d(%eax,%edx,4), %eax
movb %al, (alu_r+1)
movb %ah, (alu_c)
# end alu_div_shl1_8_c
# alu_div_shl1_8_c
movl $0, %eax
movl $0, %edx
movb (alu_r+2), %al
movb (alu_c), %dl
movl alu_div_shl3_8_d(,%eax,4), %eax
movl alu_div_shl1_8_c_d(%eax,%edx,4), %eax
movb %al, (alu_r+2)
movb %ah, (alu_c)
# end alu_div_shl1_8_c
# alu_div_shl1_8_c
movl $0, %eax
movl $0, %edx
movb (alu_r+3), %al
movb (alu_c), %dl
movl alu_div_shl3_8_d(,%eax,4), %eax
movl alu_div_shl1_8_c_d(%eax,%edx,4), %eax
movb %al, (alu_r+3)
movb %ah, (alu_c)
# end alu_div_shl1_8_c
# end alu_div_shl1_32_c
# alu_div_gte32
movl $0, (alu_c)
movl (alu_r), %eax
movl %eax, (alu_x)
movl (alu_d), %eax
movl %eax, (alu_y)
# alu_sub32
movl $0, %eax
movl $0, %ecx
movl $0x1, (alu_c)
# alu_sub16_fast
movw (alu_x+0), %ax
movw (alu_y+0), %cx
movw alu_inv16(,%ecx,2), %cx
movl alu_add16(,%eax,4), %edx
movl (%edx,%ecx,4), %edx
movl alu_add16(,%edx,4), %edx
movl (alu_c), %ecx
movl (%edx,%ecx,4), %edx
movw %dx, (alu_t+0)
movl %edx, (alu_c-2)
# end alu_sub16_fast
# alu_sub16_fast
movw (alu_x+2), %ax
movw (alu_y+2), %cx
movw alu_inv16(,%ecx,2), %cx
movl alu_add16(,%eax,4), %edx
movl (%edx,%ecx,4), %edx
movl alu_add16(,%edx,4), %edx
movl (alu_c), %ecx
movl (%edx,%ecx,4), %edx
movw %dx, (alu_t+2)
movl %edx, (alu_c-2)
# end alu_sub16_fast
# end alu_sub32
movl $0, %eax
movb (alu_c), %al
movb alu_true(%eax), %al
movl %eax, (alu_t)
# end alu_div_gte32
movl (alu_t), %eax
movl alu_sel_r(,%eax,4), %edx
movl %edx, (alu_psel_r)
movl alu_sel_q(,%eax,4), %edx
movl %edx, (alu_psel_q)
movl (alu_psel_r), %eax
movl (%eax), %eax
movl %eax, (alu_sr)
movl (alu_sr), %eax
movl %eax, (alu_x)
movl (alu_d), %eax
movl %eax, (alu_y)
# alu_sub32
movl $0, %eax
movl $0, %ecx
movl $0x1, (alu_c)
# alu_sub16_fast
movw (alu_x+0), %ax
movw (alu_y+0), %cx
movw alu_inv16(,%ecx,2), %cx
movl alu_add16(,%eax,4), %edx
movl (%edx,%ecx,4), %edx
movl alu_add16(,%edx,4), %edx
movl (alu_c), %ecx
movl (%edx,%ecx,4), %edx
movw %dx, (alu_sr+0)
movl %edx, (alu_c-2)
# end alu_sub16_fast
# alu_sub16_fast
movw (alu_x+2), %ax
movw (alu_y+2), %cx
movw alu_inv16(,%ecx,2), %cx
movl alu_add16(,%eax,4), %edx
movl (%edx,%ecx,4), %edx
movl alu_add16(,%edx,4), %edx
movl (alu_c), %ecx
movl (%edx,%ecx,4), %edx
movw %dx, (alu_sr+2)
movl %edx, (alu_c-2)
# end alu_sub16_fast
# end alu_sub32
movl (alu_psel_r), %eax
movl (alu_sr), %edx
movl %edx, (%eax)
movl (alu_psel_q), %eax
movl (%eax), %eax
movl %eax, (alu_sq)
# alu_div_setb32
movl $0, %eax
movb (alu_sq+2), %al
movb alu_b_s_3(%eax), %al
movb %al, (alu_sq+2)
# end alu_div_setb32
movl (alu_psel_q), %eax
movl (alu_sq), %edx
movl %edx, (%eax)
# alu_bit
movl $0, %edx
movb (alu_n+2), %dl
movl alu_b2(,%edx,4), %eax
movl %eax, (alu_c)
# end alu_bit
# alu_div_shl1_32_c
# alu_div_shl1_8_c
movl $0, %eax
movl $0, %edx
movb (alu_r+0), %al
movb (alu_c), %dl
movl alu_div_shl3_8_d(,%eax,4), %eax
movl alu_div_shl1_8_c_d(%eax,%edx,4), %eax
movb %al, (alu_r+0)
movb %ah, (alu_c)
# end alu_div_shl1_8_c
# alu_div_shl1_8_c
movl $0, %eax
movl $0, %edx
movb (alu_r+1), %al
movb (alu_c), %dl
movl alu_div_shl3_8_d(,%eax,4), %eax
movl alu_div_shl1_8_c_d(%eax,%edx,4), %eax
movb %al, (alu_r+1)
movb %ah, (alu_c)
# end alu_div_shl1_8_c
# alu_div_shl1_8_c
movl $0, %eax
movl $0, %edx
movb (alu_r+2), %al
movb (alu_c), %dl
movl alu_div_shl3_8_d(,%eax,4), %eax
movl alu_div_shl1_8_c_d(%eax,%edx,4), %eax
movb %al, (alu_r+2)
movb %ah, (alu_c)
# end alu_div_shl1_8_c
# alu_div_shl1_8_c
movl $0, %eax
movl $0, %edx
movb (alu_r+3), %al
movb (alu_c), %dl
movl alu_div_shl3_8_d(,%eax,4), %eax
movl alu_div_shl1_8_c_d(%eax,%edx,4), %eax
movb %al, (alu_r+3)
movb %ah, (alu_c)
# end alu_div_shl1_8_c
# end alu_div_shl1_32_c
# alu_div_gte32
movl $0, (alu_c)
movl (alu_r), %eax
movl %eax, (alu_x)
movl (alu_d), %eax
movl %eax, (alu_y)
# alu_sub32
movl $0, %eax
movl $0, %ecx
movl $0x1, (alu_c)
# alu_sub16_fast
movw (alu_x+0), %ax
movw (alu_y+0), %cx
movw alu_inv16(,%ecx,2), %cx
movl alu_add16(,%eax,4), %edx
movl (%edx,%ecx,4), %edx
movl alu_add16(,%edx,4), %edx
movl (alu_c), %ecx
movl (%edx,%ecx,4), %edx
movw %dx, (alu_t+0)
movl %edx, (alu_c-2)
# end alu_sub16_fast
# alu_sub16_fast
movw (alu_x+2), %ax
movw (alu_y+2), %cx
movw alu_inv16(,%ecx,2), %cx
movl alu_add16(,%eax,4), %edx
movl (%edx,%ecx,4), %edx
movl alu_add16(,%edx,4), %edx
movl (alu_c), %ecx
movl (%edx,%ecx,4), %edx
movw %dx, (alu_t+2)
movl %edx, (alu_c-2)
# end alu_sub16_fast
# end alu_sub32
movl $0, %eax
movb (alu_c), %al
movb alu_true(%eax), %al
movl %eax, (alu_t)
# end alu_div_gte32
movl (alu_t), %eax
movl alu_sel_r(,%eax,4), %edx
movl %edx, (alu_psel_r)
movl alu_sel_q(,%eax,4), %edx
movl %edx, (alu_psel_q)
movl (alu_psel_r), %eax
movl (%eax), %eax
movl %eax, (alu_sr)
movl (alu_sr), %eax
movl %eax, (alu_x)
movl (alu_d), %eax
movl %eax, (alu_y)
# alu_sub32
movl $0, %eax
movl $0, %ecx
movl $0x1, (alu_c)
# alu_sub16_fast
movw (alu_x+0), %ax
movw (alu_y+0), %cx
movw alu_inv16(,%ecx,2), %cx
movl alu_add16(,%eax,4), %edx
movl (%edx,%ecx,4), %edx
movl alu_add16(,%edx,4), %edx
movl (alu_c), %ecx
movl (%edx,%ecx,4), %edx
movw %dx, (alu_sr+0)
movl %edx, (alu_c-2)
# end alu_sub16_fast
# alu_sub16_fast
movw (alu_x+2), %ax
movw (alu_y+2), %cx
movw alu_inv16(,%ecx,2), %cx
movl alu_add16(,%eax,4), %edx
movl (%edx,%ecx,4), %edx
movl alu_add16(,%edx,4), %edx
movl (alu_c), %ecx
movl (%edx,%ecx,4), %edx
movw %dx, (alu_sr+2)
movl %edx, (alu_c-2)
# end alu_sub16_fast
# end alu_sub32
movl (alu_psel_r), %eax
movl (alu_sr), %edx
movl %edx, (%eax)
movl (alu_psel_q), %eax
movl (%eax), %eax
movl %eax, (alu_sq)
# alu_div_setb32
movl $0, %eax
movb (alu_sq+2), %al
movb alu_b_s_2(%eax), %al
movb %al, (alu_sq+2)
# end alu_div_setb32
movl (alu_psel_q), %eax
movl (alu_sq), %edx
movl %edx, (%eax)
# alu_bit
movl $0, %edx
movb (alu_n+2), %dl
movl alu_b1(,%edx,4), %eax
movl %eax, (alu_c)
# end alu_bit
# alu_div_shl1_32_c
# alu_div_shl1_8_c
movl $0, %eax
movl $0, %edx
movb (alu_r+0), %al
movb (alu_c), %dl
movl alu_div_shl3_8_d(,%eax,4), %eax
movl alu_div_shl1_8_c_d(%eax,%edx,4), %eax
movb %al, (alu_r+0)
movb %ah, (alu_c)
# end alu_div_shl1_8_c
# alu_div_shl1_8_c
movl $0, %eax
movl $0, %edx
movb (alu_r+1), %al
movb (alu_c), %dl
movl alu_div_shl3_8_d(,%eax,4), %eax
movl alu_div_shl1_8_c_d(%eax,%edx,4), %eax
movb %al, (alu_r+1)
movb %ah, (alu_c)
# end alu_div_shl1_8_c
# alu_div_shl1_8_c
movl $0, %eax
movl $0, %edx
movb (alu_r+2), %al
movb (alu_c), %dl
movl alu_div_shl3_8_d(,%eax,4), %eax
movl alu_div_shl1_8_c_d(%eax,%edx,4), %eax
movb %al, (alu_r+2)
movb %ah, (alu_c)
# end alu_div_shl1_8_c
# alu_div_shl1_8_c
movl $0, %eax
movl $0, %edx
movb (alu_r+3), %al
movb (alu_c), %dl
movl alu_div_shl3_8_d(,%eax,4), %eax
movl alu_div_shl1_8_c_d(%eax,%edx,4), %eax
movb %al, (alu_r+3)
movb %ah, (alu_c)
# end alu_div_shl1_8_c
# end alu_div_shl1_32_c
# alu_div_gte32
movl $0, (alu_c)
movl (alu_r), %eax
movl %eax, (alu_x)
movl (alu_d), %eax
movl %eax, (alu_y)
# alu_sub32
movl $0, %eax
movl $0, %ecx
movl $0x1, (alu_c)
# alu_sub16_fast
movw (alu_x+0), %ax
movw (alu_y+0), %cx
movw alu_inv16(,%ecx,2), %cx
movl alu_add16(,%eax,4), %edx
movl (%edx,%ecx,4), %edx
movl alu_add16(,%edx,4), %edx
movl (alu_c), %ecx
movl (%edx,%ecx,4), %edx
movw %dx, (alu_t+0)
movl %edx, (alu_c-2)
# end alu_sub16_fast
# alu_sub16_fast
movw (alu_x+2), %ax
movw (alu_y+2), %cx
movw alu_inv16(,%ecx,2), %cx
movl alu_add16(,%eax,4), %edx
movl (%edx,%ecx,4), %edx
movl alu_add16(,%edx,4), %edx
movl (alu_c), %ecx
movl (%edx,%ecx,4), %edx
movw %dx, (alu_t+2)
movl %edx, (alu_c-2)
# end alu_sub16_fast
# end alu_sub32
movl $0, %eax
movb (alu_c), %al
movb alu_true(%eax), %al
movl %eax, (alu_t)
# end alu_div_gte32
movl (alu_t), %eax
movl alu_sel_r(,%eax,4), %edx
movl %edx, (alu_psel_r)
movl alu_sel_q(,%eax,4), %edx
movl %edx, (alu_psel_q)
movl (alu_psel_r), %eax
movl (%eax), %eax
movl %eax, (alu_sr)
movl (alu_sr), %eax
movl %eax, (alu_x)
movl (alu_d), %eax
movl %eax, (alu_y)
# alu_sub32
movl $0, %eax
movl $0, %ecx
movl $0x1, (alu_c)
# alu_sub16_fast
movw (alu_x+0), %ax
movw (alu_y+0), %cx
movw alu_inv16(,%ecx,2), %cx
movl alu_add16(,%eax,4), %edx
movl (%edx,%ecx,4), %edx
movl alu_add16(,%edx,4), %edx
movl (alu_c), %ecx
movl (%edx,%ecx,4), %edx
movw %dx, (alu_sr+0)
movl %edx, (alu_c-2)
# end alu_sub16_fast
# alu_sub16_fast
movw (alu_x+2), %ax
movw (alu_y+2), %cx
movw alu_inv16(,%ecx,2), %cx
movl alu_add16(,%eax,4), %edx
movl (%edx,%ecx,4), %edx
movl alu_add16(,%edx,4), %edx
movl (alu_c), %ecx
movl (%edx,%ecx,4), %edx
movw %dx, (alu_sr+2)
movl %edx, (alu_c-2)
# end alu_sub16_fast
# end alu_sub32
movl (alu_psel_r), %eax
movl (alu_sr), %edx
movl %edx, (%eax)
movl (alu_psel_q), %eax
movl (%eax), %eax
movl %eax, (alu_sq)
# alu_div_setb32
movl $0, %eax
movb (alu_sq+2), %al
movb alu_b_s_1(%eax), %al
movb %al, (alu_sq+2)
# end alu_div_setb32
movl (alu_psel_q), %eax
movl (alu_sq), %edx
movl %edx, (%eax)
# alu_bit
movl $0, %edx
movb (alu_n+2), %dl
movl alu_b0(,%edx,4), %eax
movl %eax, (alu_c)
# end alu_bit
# alu_div_shl1_32_c
# alu_div_shl1_8_c
movl $0, %eax
movl $0, %edx
movb (alu_r+0), %al
movb (alu_c), %dl
movl alu_div_shl3_8_d(,%eax,4), %eax
movl alu_div_shl1_8_c_d(%eax,%edx,4), %eax
movb %al, (alu_r+0)
movb %ah, (alu_c)
# end alu_div_shl1_8_c
# alu_div_shl1_8_c
movl $0, %eax
movl $0, %edx
movb (alu_r+1), %al
movb (alu_c), %dl
movl alu_div_shl3_8_d(,%eax,4), %eax
movl alu_div_shl1_8_c_d(%eax,%edx,4), %eax
movb %al, (alu_r+1)
movb %ah, (alu_c)
# end alu_div_shl1_8_c
# alu_div_shl1_8_c
movl $0, %eax
movl $0, %edx
movb (alu_r+2), %al
movb (alu_c), %dl
movl alu_div_shl3_8_d(,%eax,4), %eax
movl alu_div_shl1_8_c_d(%eax,%edx,4), %eax
movb %al, (alu_r+2)
movb %ah, (alu_c)
# end alu_div_shl1_8_c
# alu_div_shl1_8_c
movl $0, %eax
movl $0, %edx
movb (alu_r+3), %al
movb (alu_c), %dl
movl alu_div_shl3_8_d(,%eax,4), %eax
movl alu_div_shl1_8_c_d(%eax,%edx,4), %eax
movb %al, (alu_r+3)
movb %ah, (alu_c)
# end alu_div_shl1_8_c
# end alu_div_shl1_32_c
# alu_div_gte32
movl $0, (alu_c)
movl (alu_r), %eax
movl %eax, (alu_x)
movl (alu_d), %eax
movl %eax, (alu_y)
# alu_sub32
movl $0, %eax
movl $0, %ecx
movl $0x1, (alu_c)
# alu_sub16_fast
movw (alu_x+0), %ax
movw (alu_y+0), %cx
movw alu_inv16(,%ecx,2), %cx
movl alu_add16(,%eax,4), %edx
movl (%edx,%ecx,4), %edx
movl alu_add16(,%edx,4), %edx
movl (alu_c), %ecx
movl (%edx,%ecx,4), %edx
movw %dx, (alu_t+0)
movl %edx, (alu_c-2)
# end alu_sub16_fast
# alu_sub16_fast
movw (alu_x+2), %ax
movw (alu_y+2), %cx
movw alu_inv16(,%ecx,2), %cx
movl alu_add16(,%eax,4), %edx
movl (%edx,%ecx,4), %edx
movl alu_add16(,%edx,4), %edx
movl (alu_c), %ecx
movl (%edx,%ecx,4), %edx
movw %dx, (alu_t+2)
movl %edx, (alu_c-2)
# end alu_sub16_fast
# end alu_sub32
movl $0, %eax
movb (alu_c), %al
movb alu_true(%eax), %al
movl %eax, (alu_t)
# end alu_div_gte32
movl (alu_t), %eax
movl alu_sel_r(,%eax,4), %edx
movl %edx, (alu_psel_r)
movl alu_sel_q(,%eax,4), %edx
movl %edx, (alu_psel_q)
movl (alu_psel_r), %eax
movl (%eax), %eax
movl %eax, (alu_sr)
movl (alu_sr), %eax
movl %eax, (alu_x)
movl (alu_d), %eax
movl %eax, (alu_y)
# alu_sub32
movl $0, %eax
movl $0, %ecx
movl $0x1, (alu_c)
# alu_sub16_fast
movw (alu_x+0), %ax
movw (alu_y+0), %cx
movw alu_inv16(,%ecx,2), %cx
movl alu_add16(,%eax,4), %edx
movl (%edx,%ecx,4), %edx
movl alu_add16(,%edx,4), %edx
movl (alu_c), %ecx
movl (%edx,%ecx,4), %edx
movw %dx, (alu_sr+0)
movl %edx, (alu_c-2)
# end alu_sub16_fast
# alu_sub16_fast
movw (alu_x+2), %ax
movw (alu_y+2), %cx
movw alu_inv16(,%ecx,2), %cx
movl alu_add16(,%eax,4), %edx
movl (%edx,%ecx,4), %edx
movl alu_add16(,%edx,4), %edx
movl (alu_c), %ecx
movl (%edx,%ecx,4), %edx
movw %dx, (alu_sr+2)
movl %edx, (alu_c-2)
# end alu_sub16_fast
# end alu_sub32
movl (alu_psel_r), %eax
movl (alu_sr), %edx
movl %edx, (%eax)
movl (alu_psel_q), %eax
movl (%eax), %eax
movl %eax, (alu_sq)
# alu_div_setb32
movl $0, %eax
movb (alu_sq+2), %al
movb alu_b_s_0(%eax), %al
movb %al, (alu_sq+2)
# end alu_div_setb32
movl (alu_psel_q), %eax
movl (alu_sq), %edx
movl %edx, (%eax)
# alu_bit
movl $0, %edx
movb (alu_n+1), %dl
movl alu_b7(,%edx,4), %eax
movl %eax, (alu_c)
# end alu_bit
# alu_div_shl1_32_c
# alu_div_shl1_8_c
movl $0, %eax
movl $0, %edx
movb (alu_r+0), %al
movb (alu_c), %dl
movl alu_div_shl3_8_d(,%eax,4), %eax
movl alu_div_shl1_8_c_d(%eax,%edx,4), %eax
movb %al, (alu_r+0)
movb %ah, (alu_c)
# end alu_div_shl1_8_c
# alu_div_shl1_8_c
movl $0, %eax
movl $0, %edx
movb (alu_r+1), %al
movb (alu_c), %dl
movl alu_div_shl3_8_d(,%eax,4), %eax
movl alu_div_shl1_8_c_d(%eax,%edx,4), %eax
movb %al, (alu_r+1)
movb %ah, (alu_c)
# end alu_div_shl1_8_c
# alu_div_shl1_8_c
movl $0, %eax
movl $0, %edx
movb (alu_r+2), %al
movb (alu_c), %dl
movl alu_div_shl3_8_d(,%eax,4), %eax
movl alu_div_shl1_8_c_d(%eax,%edx,4), %eax
movb %al, (alu_r+2)
movb %ah, (alu_c)
# end alu_div_shl1_8_c
# alu_div_shl1_8_c
movl $0, %eax
movl $0, %edx
movb (alu_r+3), %al
movb (alu_c), %dl
movl alu_div_shl3_8_d(,%eax,4), %eax
movl alu_div_shl1_8_c_d(%eax,%edx,4), %eax
movb %al, (alu_r+3)
movb %ah, (alu_c)
# end alu_div_shl1_8_c
# end alu_div_shl1_32_c
# alu_div_gte32
movl $0, (alu_c)
movl (alu_r), %eax
movl %eax, (alu_x)
movl (alu_d), %eax
movl %eax, (alu_y)
# alu_sub32
movl $0, %eax
movl $0, %ecx
movl $0x1, (alu_c)
# alu_sub16_fast
movw (alu_x+0), %ax
movw (alu_y+0), %cx
movw alu_inv16(,%ecx,2), %cx
movl alu_add16(,%eax,4), %edx
movl (%edx,%ecx,4), %edx
movl alu_add16(,%edx,4), %edx
movl (alu_c), %ecx
movl (%edx,%ecx,4), %edx
movw %dx, (alu_t+0)
movl %edx, (alu_c-2)
# end alu_sub16_fast
# alu_sub16_fast
movw (alu_x+2), %ax
movw (alu_y+2), %cx
movw alu_inv16(,%ecx,2), %cx
movl alu_add16(,%eax,4), %edx
movl (%edx,%ecx,4), %edx
movl alu_add16(,%edx,4), %edx
movl (alu_c), %ecx
movl (%edx,%ecx,4), %edx
movw %dx, (alu_t+2)
movl %edx, (alu_c-2)
# end alu_sub16_fast
# end alu_sub32
movl $0, %eax
movb (alu_c), %al
movb alu_true(%eax), %al
movl %eax, (alu_t)
# end alu_div_gte32
movl (alu_t), %eax
movl alu_sel_r(,%eax,4), %edx
movl %edx, (alu_psel_r)
movl alu_sel_q(,%eax,4), %edx
movl %edx, (alu_psel_q)
movl (alu_psel_r), %eax
movl (%eax), %eax
movl %eax, (alu_sr)
movl (alu_sr), %eax
movl %eax, (alu_x)
movl (alu_d), %eax
movl %eax, (alu_y)
# alu_sub32
movl $0, %eax
movl $0, %ecx
movl $0x1, (alu_c)
# alu_sub16_fast
movw (alu_x+0), %ax
movw (alu_y+0), %cx
movw alu_inv16(,%ecx,2), %cx
movl alu_add16(,%eax,4), %edx
movl (%edx,%ecx,4), %edx
movl alu_add16(,%edx,4), %edx
movl (alu_c), %ecx
movl (%edx,%ecx,4), %edx
movw %dx, (alu_sr+0)
movl %edx, (alu_c-2)
# end alu_sub16_fast
# alu_sub16_fast
movw (alu_x+2), %ax
movw (alu_y+2), %cx
movw alu_inv16(,%ecx,2), %cx
movl alu_add16(,%eax,4), %edx
movl (%edx,%ecx,4), %edx
movl alu_add16(,%edx,4), %edx
movl (alu_c), %ecx
movl (%edx,%ecx,4), %edx
movw %dx, (alu_sr+2)
movl %edx, (alu_c-2)
# end alu_sub16_fast
# end alu_sub32
movl (alu_psel_r), %eax
movl (alu_sr), %edx
movl %edx, (%eax)
movl (alu_psel_q), %eax
movl (%eax), %eax
movl %eax, (alu_sq)
# alu_div_setb32
movl $0, %eax
movb (alu_sq+1), %al
movb alu_b_s_7(%eax), %al
movb %al, (alu_sq+1)
# end alu_div_setb32
movl (alu_psel_q), %eax
movl (alu_sq), %edx
movl %edx, (%eax)
# alu_bit
movl $0, %edx
movb (alu_n+1), %dl
movl alu_b6(,%edx,4), %eax
movl %eax, (alu_c)
# end alu_bit
# alu_div_shl1_32_c
# alu_div_shl1_8_c
movl $0, %eax
movl $0, %edx
movb (alu_r+0), %al
movb (alu_c), %dl
movl alu_div_shl3_8_d(,%eax,4), %eax
movl alu_div_shl1_8_c_d(%eax,%edx,4), %eax
movb %al, (alu_r+0)
movb %ah, (alu_c)
# end alu_div_shl1_8_c
# alu_div_shl1_8_c
movl $0, %eax
movl $0, %edx
movb (alu_r+1), %al
movb (alu_c), %dl
movl alu_div_shl3_8_d(,%eax,4), %eax
movl alu_div_shl1_8_c_d(%eax,%edx,4), %eax
movb %al, (alu_r+1)
movb %ah, (alu_c)
# end alu_div_shl1_8_c
# alu_div_shl1_8_c
movl $0, %eax
movl $0, %edx
movb (alu_r+2), %al
movb (alu_c), %dl
movl alu_div_shl3_8_d(,%eax,4), %eax
movl alu_div_shl1_8_c_d(%eax,%edx,4), %eax
movb %al, (alu_r+2)
movb %ah, (alu_c)
# end alu_div_shl1_8_c
# alu_div_shl1_8_c
movl $0, %eax
movl $0, %edx
movb (alu_r+3), %al
movb (alu_c), %dl
movl alu_div_shl3_8_d(,%eax,4), %eax
movl alu_div_shl1_8_c_d(%eax,%edx,4), %eax
movb %al, (alu_r+3)
movb %ah, (alu_c)
# end alu_div_shl1_8_c
# end alu_div_shl1_32_c
# alu_div_gte32
movl $0, (alu_c)
movl (alu_r), %eax
movl %eax, (alu_x)
movl (alu_d), %eax
movl %eax, (alu_y)
# alu_sub32
movl $0, %eax
movl $0, %ecx
movl $0x1, (alu_c)
# alu_sub16_fast
movw (alu_x+0), %ax
movw (alu_y+0), %cx
movw alu_inv16(,%ecx,2), %cx
movl alu_add16(,%eax,4), %edx
movl (%edx,%ecx,4), %edx
movl alu_add16(,%edx,4), %edx
movl (alu_c), %ecx
movl (%edx,%ecx,4), %edx
movw %dx, (alu_t+0)
movl %edx, (alu_c-2)
# end alu_sub16_fast
# alu_sub16_fast
movw (alu_x+2), %ax
movw (alu_y+2), %cx
movw alu_inv16(,%ecx,2), %cx
movl alu_add16(,%eax,4), %edx
movl (%edx,%ecx,4), %edx
movl alu_add16(,%edx,4), %edx
movl (alu_c), %ecx
movl (%edx,%ecx,4), %edx
movw %dx, (alu_t+2)
movl %edx, (alu_c-2)
# end alu_sub16_fast
# end alu_sub32
movl $0, %eax
movb (alu_c), %al
movb alu_true(%eax), %al
movl %eax, (alu_t)
# end alu_div_gte32
movl (alu_t), %eax
movl alu_sel_r(,%eax,4), %edx
movl %edx, (alu_psel_r)
movl alu_sel_q(,%eax,4), %edx
movl %edx, (alu_psel_q)
movl (alu_psel_r), %eax
movl (%eax), %eax
movl %eax, (alu_sr)
movl (alu_sr), %eax
movl %eax, (alu_x)
movl (alu_d), %eax
movl %eax, (alu_y)
# alu_sub32
movl $0, %eax
movl $0, %ecx
movl $0x1, (alu_c)
# alu_sub16_fast
movw (alu_x+0), %ax
movw (alu_y+0), %cx
movw alu_inv16(,%ecx,2), %cx
movl alu_add16(,%eax,4), %edx
movl (%edx,%ecx,4), %edx
movl alu_add16(,%edx,4), %edx
movl (alu_c), %ecx
movl (%edx,%ecx,4), %edx
movw %dx, (alu_sr+0)
movl %edx, (alu_c-2)
# end alu_sub16_fast
# alu_sub16_fast
movw (alu_x+2), %ax
movw (alu_y+2), %cx
movw alu_inv16(,%ecx,2), %cx
movl alu_add16(,%eax,4), %edx
movl (%edx,%ecx,4), %edx
movl alu_add16(,%edx,4), %edx
movl (alu_c), %ecx
movl (%edx,%ecx,4), %edx
movw %dx, (alu_sr+2)
movl %edx, (alu_c-2)
# end alu_sub16_fast
# end alu_sub32
movl (alu_psel_r), %eax
movl (alu_sr), %edx
movl %edx, (%eax)
movl (alu_psel_q), %eax
movl (%eax), %eax
movl %eax, (alu_sq)
# alu_div_setb32
movl $0, %eax
movb (alu_sq+1), %al
movb alu_b_s_6(%eax), %al
movb %al, (alu_sq+1)
# end alu_div_setb32
movl (alu_psel_q), %eax
movl (alu_sq), %edx
movl %edx, (%eax)
# alu_bit
movl $0, %edx
movb (alu_n+1), %dl
movl alu_b5(,%edx,4), %eax
movl %eax, (alu_c)
# end alu_bit
# alu_div_shl1_32_c
# alu_div_shl1_8_c
movl $0, %eax
movl $0, %edx
movb (alu_r+0), %al
movb (alu_c), %dl
movl alu_div_shl3_8_d(,%eax,4), %eax
movl alu_div_shl1_8_c_d(%eax,%edx,4), %eax
movb %al, (alu_r+0)
movb %ah, (alu_c)
# end alu_div_shl1_8_c
# alu_div_shl1_8_c
movl $0, %eax
movl $0, %edx
movb (alu_r+1), %al
movb (alu_c), %dl
movl alu_div_shl3_8_d(,%eax,4), %eax
movl alu_div_shl1_8_c_d(%eax,%edx,4), %eax
movb %al, (alu_r+1)
movb %ah, (alu_c)
# end alu_div_shl1_8_c
# alu_div_shl1_8_c
movl $0, %eax
movl $0, %edx
movb (alu_r+2), %al
movb (alu_c), %dl
movl alu_div_shl3_8_d(,%eax,4), %eax
movl alu_div_shl1_8_c_d(%eax,%edx,4), %eax
movb %al, (alu_r+2)
movb %ah, (alu_c)
# end alu_div_shl1_8_c
# alu_div_shl1_8_c
movl $0, %eax
movl $0, %edx
movb (alu_r+3), %al
movb (alu_c), %dl
movl alu_div_shl3_8_d(,%eax,4), %eax
movl alu_div_shl1_8_c_d(%eax,%edx,4), %eax
movb %al, (alu_r+3)
movb %ah, (alu_c)
# end alu_div_shl1_8_c
# end alu_div_shl1_32_c
# alu_div_gte32
movl $0, (alu_c)
movl (alu_r), %eax
movl %eax, (alu_x)
movl (alu_d), %eax
movl %eax, (alu_y)
# alu_sub32
movl $0, %eax
movl $0, %ecx
movl $0x1, (alu_c)
# alu_sub16_fast
movw (alu_x+0), %ax
movw (alu_y+0), %cx
movw alu_inv16(,%ecx,2), %cx
movl alu_add16(,%eax,4), %edx
movl (%edx,%ecx,4), %edx
movl alu_add16(,%edx,4), %edx
movl (alu_c), %ecx
movl (%edx,%ecx,4), %edx
movw %dx, (alu_t+0)
movl %edx, (alu_c-2)
# end alu_sub16_fast
# alu_sub16_fast
movw (alu_x+2), %ax
movw (alu_y+2), %cx
movw alu_inv16(,%ecx,2), %cx
movl alu_add16(,%eax,4), %edx
movl (%edx,%ecx,4), %edx
movl alu_add16(,%edx,4), %edx
movl (alu_c), %ecx
movl (%edx,%ecx,4), %edx
movw %dx, (alu_t+2)
movl %edx, (alu_c-2)
# end alu_sub16_fast
# end alu_sub32
movl $0, %eax
movb (alu_c), %al
movb alu_true(%eax), %al
movl %eax, (alu_t)
# end alu_div_gte32
movl (alu_t), %eax
movl alu_sel_r(,%eax,4), %edx
movl %edx, (alu_psel_r)
movl alu_sel_q(,%eax,4), %edx
movl %edx, (alu_psel_q)
movl (alu_psel_r), %eax
movl (%eax), %eax
movl %eax, (alu_sr)
movl (alu_sr), %eax
movl %eax, (alu_x)
movl (alu_d), %eax
movl %eax, (alu_y)
# alu_sub32
movl $0, %eax
movl $0, %ecx
movl $0x1, (alu_c)
# alu_sub16_fast
movw (alu_x+0), %ax
movw (alu_y+0), %cx
movw alu_inv16(,%ecx,2), %cx
movl alu_add16(,%eax,4), %edx
movl (%edx,%ecx,4), %edx
movl alu_add16(,%edx,4), %edx
movl (alu_c), %ecx
movl (%edx,%ecx,4), %edx
movw %dx, (alu_sr+0)
movl %edx, (alu_c-2)
# end alu_sub16_fast
# alu_sub16_fast
movw (alu_x+2), %ax
movw (alu_y+2), %cx
movw alu_inv16(,%ecx,2), %cx
movl alu_add16(,%eax,4), %edx
movl (%edx,%ecx,4), %edx
movl alu_add16(,%edx,4), %edx
movl (alu_c), %ecx
movl (%edx,%ecx,4), %edx
movw %dx, (alu_sr+2)
movl %edx, (alu_c-2)
# end alu_sub16_fast
# end alu_sub32
movl (alu_psel_r), %eax
movl (alu_sr), %edx
movl %edx, (%eax)
movl (alu_psel_q), %eax
movl (%eax), %eax
movl %eax, (alu_sq)
# alu_div_setb32
movl $0, %eax
movb (alu_sq+1), %al
movb alu_b_s_5(%eax), %al
movb %al, (alu_sq+1)
# end alu_div_setb32
movl (alu_psel_q), %eax
movl (alu_sq), %edx
movl %edx, (%eax)
# alu_bit
movl $0, %edx
movb (alu_n+1), %dl
movl alu_b4(,%edx,4), %eax
movl %eax, (alu_c)
# end alu_bit
# alu_div_shl1_32_c
# alu_div_shl1_8_c
movl $0, %eax
movl $0, %edx
movb (alu_r+0), %al
movb (alu_c), %dl
movl alu_div_shl3_8_d(,%eax,4), %eax
movl alu_div_shl1_8_c_d(%eax,%edx,4), %eax
movb %al, (alu_r+0)
movb %ah, (alu_c)
# end alu_div_shl1_8_c
# alu_div_shl1_8_c
movl $0, %eax
movl $0, %edx
movb (alu_r+1), %al
movb (alu_c), %dl
movl alu_div_shl3_8_d(,%eax,4), %eax
movl alu_div_shl1_8_c_d(%eax,%edx,4), %eax
movb %al, (alu_r+1)
movb %ah, (alu_c)
# end alu_div_shl1_8_c
# alu_div_shl1_8_c
movl $0, %eax
movl $0, %edx
movb (alu_r+2), %al
movb (alu_c), %dl
movl alu_div_shl3_8_d(,%eax,4), %eax
movl alu_div_shl1_8_c_d(%eax,%edx,4), %eax
movb %al, (alu_r+2)
movb %ah, (alu_c)
# end alu_div_shl1_8_c
# alu_div_shl1_8_c
movl $0, %eax
movl $0, %edx
movb (alu_r+3), %al
movb (alu_c), %dl
movl alu_div_shl3_8_d(,%eax,4), %eax
movl alu_div_shl1_8_c_d(%eax,%edx,4), %eax
movb %al, (alu_r+3)
movb %ah, (alu_c)
# end alu_div_shl1_8_c
# end alu_div_shl1_32_c
# alu_div_gte32
movl $0, (alu_c)
movl (alu_r), %eax
movl %eax, (alu_x)
movl (alu_d), %eax
movl %eax, (alu_y)
# alu_sub32
movl $0, %eax
movl $0, %ecx
movl $0x1, (alu_c)
# alu_sub16_fast
movw (alu_x+0), %ax
movw (alu_y+0), %cx
movw alu_inv16(,%ecx,2), %cx
movl alu_add16(,%eax,4), %edx
movl (%edx,%ecx,4), %edx
movl alu_add16(,%edx,4), %edx
movl (alu_c), %ecx
movl (%edx,%ecx,4), %edx
movw %dx, (alu_t+0)
movl %edx, (alu_c-2)
# end alu_sub16_fast
# alu_sub16_fast
movw (alu_x+2), %ax
movw (alu_y+2), %cx
movw alu_inv16(,%ecx,2), %cx
movl alu_add16(,%eax,4), %edx
movl (%edx,%ecx,4), %edx
movl alu_add16(,%edx,4), %edx
movl (alu_c), %ecx
movl (%edx,%ecx,4), %edx
movw %dx, (alu_t+2)
movl %edx, (alu_c-2)
# end alu_sub16_fast
# end alu_sub32
movl $0, %eax
movb (alu_c), %al
movb alu_true(%eax), %al
movl %eax, (alu_t)
# end alu_div_gte32
movl (alu_t), %eax
movl alu_sel_r(,%eax,4), %edx
movl %edx, (alu_psel_r)
movl alu_sel_q(,%eax,4), %edx
movl %edx, (alu_psel_q)
movl (alu_psel_r), %eax
movl (%eax), %eax
movl %eax, (alu_sr)
movl (alu_sr), %eax
movl %eax, (alu_x)
movl (alu_d), %eax
movl %eax, (alu_y)
# alu_sub32
movl $0, %eax
movl $0, %ecx
movl $0x1, (alu_c)
# alu_sub16_fast
movw (alu_x+0), %ax
movw (alu_y+0), %cx
movw alu_inv16(,%ecx,2), %cx
movl alu_add16(,%eax,4), %edx
movl (%edx,%ecx,4), %edx
movl alu_add16(,%edx,4), %edx
movl (alu_c), %ecx
movl (%edx,%ecx,4), %edx
movw %dx, (alu_sr+0)
movl %edx, (alu_c-2)
# end alu_sub16_fast
# alu_sub16_fast
movw (alu_x+2), %ax
movw (alu_y+2), %cx
movw alu_inv16(,%ecx,2), %cx
movl alu_add16(,%eax,4), %edx
movl (%edx,%ecx,4), %edx
movl alu_add16(,%edx,4), %edx
movl (alu_c), %ecx
movl (%edx,%ecx,4), %edx
movw %dx, (alu_sr+2)
movl %edx, (alu_c-2)
# end alu_sub16_fast
# end alu_sub32
movl (alu_psel_r), %eax
movl (alu_sr), %edx
movl %edx, (%eax)
movl (alu_psel_q), %eax
movl (%eax), %eax
movl %eax, (alu_sq)
# alu_div_setb32
movl $0, %eax
movb (alu_sq+1), %al
movb alu_b_s_4(%eax), %al
movb %al, (alu_sq+1)
# end alu_div_setb32
movl (alu_psel_q), %eax
movl (alu_sq), %edx
movl %edx, (%eax)
# alu_bit
movl $0, %edx
movb (alu_n+1), %dl
movl alu_b3(,%edx,4), %eax
movl %eax, (alu_c)
# end alu_bit
# alu_div_shl1_32_c
# alu_div_shl1_8_c
movl $0, %eax
movl $0, %edx
movb (alu_r+0), %al
movb (alu_c), %dl
movl alu_div_shl3_8_d(,%eax,4), %eax
movl alu_div_shl1_8_c_d(%eax,%edx,4), %eax
movb %al, (alu_r+0)
movb %ah, (alu_c)
# end alu_div_shl1_8_c
# alu_div_shl1_8_c
movl $0, %eax
movl $0, %edx
movb (alu_r+1), %al
movb (alu_c), %dl
movl alu_div_shl3_8_d(,%eax,4), %eax
movl alu_div_shl1_8_c_d(%eax,%edx,4), %eax
movb %al, (alu_r+1)
movb %ah, (alu_c)
# end alu_div_shl1_8_c
# alu_div_shl1_8_c
movl $0, %eax
movl $0, %edx
movb (alu_r+2), %al
movb (alu_c), %dl
movl alu_div_shl3_8_d(,%eax,4), %eax
movl alu_div_shl1_8_c_d(%eax,%edx,4), %eax
movb %al, (alu_r+2)
movb %ah, (alu_c)
# end alu_div_shl1_8_c
# alu_div_shl1_8_c
movl $0, %eax
movl $0, %edx
movb (alu_r+3), %al
movb (alu_c), %dl
movl alu_div_shl3_8_d(,%eax,4), %eax
movl alu_div_shl1_8_c_d(%eax,%edx,4), %eax
movb %al, (alu_r+3)
movb %ah, (alu_c)
# end alu_div_shl1_8_c
# end alu_div_shl1_32_c
# alu_div_gte32
movl $0, (alu_c)
movl (alu_r), %eax
movl %eax, (alu_x)
movl (alu_d), %eax
movl %eax, (alu_y)
# alu_sub32
movl $0, %eax
movl $0, %ecx
movl $0x1, (alu_c)
# alu_sub16_fast
movw (alu_x+0), %ax
movw (alu_y+0), %cx
movw alu_inv16(,%ecx,2), %cx
movl alu_add16(,%eax,4), %edx
movl (%edx,%ecx,4), %edx
movl alu_add16(,%edx,4), %edx
movl (alu_c), %ecx
movl (%edx,%ecx,4), %edx
movw %dx, (alu_t+0)
movl %edx, (alu_c-2)
# end alu_sub16_fast
# alu_sub16_fast
movw (alu_x+2), %ax
movw (alu_y+2), %cx
movw alu_inv16(,%ecx,2), %cx
movl alu_add16(,%eax,4), %edx
movl (%edx,%ecx,4), %edx
movl alu_add16(,%edx,4), %edx
movl (alu_c), %ecx
movl (%edx,%ecx,4), %edx
movw %dx, (alu_t+2)
movl %edx, (alu_c-2)
# end alu_sub16_fast
# end alu_sub32
movl $0, %eax
movb (alu_c), %al
movb alu_true(%eax), %al
movl %eax, (alu_t)
# end alu_div_gte32
movl (alu_t), %eax
movl alu_sel_r(,%eax,4), %edx
movl %edx, (alu_psel_r)
movl alu_sel_q(,%eax,4), %edx
movl %edx, (alu_psel_q)
movl (alu_psel_r), %eax
movl (%eax), %eax
movl %eax, (alu_sr)
movl (alu_sr), %eax
movl %eax, (alu_x)
movl (alu_d), %eax
movl %eax, (alu_y)
# alu_sub32
movl $0, %eax
movl $0, %ecx
movl $0x1, (alu_c)
# alu_sub16_fast
movw (alu_x+0), %ax
movw (alu_y+0), %cx
movw alu_inv16(,%ecx,2), %cx
movl alu_add16(,%eax,4), %edx
movl (%edx,%ecx,4), %edx
movl alu_add16(,%edx,4), %edx
movl (alu_c), %ecx
movl (%edx,%ecx,4), %edx
movw %dx, (alu_sr+0)
movl %edx, (alu_c-2)
# end alu_sub16_fast
# alu_sub16_fast
movw (alu_x+2), %ax
movw (alu_y+2), %cx
movw alu_inv16(,%ecx,2), %cx
movl alu_add16(,%eax,4), %edx
movl (%edx,%ecx,4), %edx
movl alu_add16(,%edx,4), %edx
movl (alu_c), %ecx
movl (%edx,%ecx,4), %edx
movw %dx, (alu_sr+2)
movl %edx, (alu_c-2)
# end alu_sub16_fast
# end alu_sub32
movl (alu_psel_r), %eax
movl (alu_sr), %edx
movl %edx, (%eax)
movl (alu_psel_q), %eax
movl (%eax), %eax
movl %eax, (alu_sq)
# alu_div_setb32
movl $0, %eax
movb (alu_sq+1), %al
movb alu_b_s_3(%eax), %al
movb %al, (alu_sq+1)
# end alu_div_setb32
movl (alu_psel_q), %eax
movl (alu_sq), %edx
movl %edx, (%eax)
# alu_bit
movl $0, %edx
movb (alu_n+1), %dl
movl alu_b2(,%edx,4), %eax
movl %eax, (alu_c)
# end alu_bit
# alu_div_shl1_32_c
# alu_div_shl1_8_c
movl $0, %eax
movl $0, %edx
movb (alu_r+0), %al
movb (alu_c), %dl
movl alu_div_shl3_8_d(,%eax,4), %eax
movl alu_div_shl1_8_c_d(%eax,%edx,4), %eax
movb %al, (alu_r+0)
movb %ah, (alu_c)
# end alu_div_shl1_8_c
# alu_div_shl1_8_c
movl $0, %eax
movl $0, %edx
movb (alu_r+1), %al
movb (alu_c), %dl
movl alu_div_shl3_8_d(,%eax,4), %eax
movl alu_div_shl1_8_c_d(%eax,%edx,4), %eax
movb %al, (alu_r+1)
movb %ah, (alu_c)
# end alu_div_shl1_8_c
# alu_div_shl1_8_c
movl $0, %eax
movl $0, %edx
movb (alu_r+2), %al
movb (alu_c), %dl
movl alu_div_shl3_8_d(,%eax,4), %eax
movl alu_div_shl1_8_c_d(%eax,%edx,4), %eax
movb %al, (alu_r+2)
movb %ah, (alu_c)
# end alu_div_shl1_8_c
# alu_div_shl1_8_c
movl $0, %eax
movl $0, %edx
movb (alu_r+3), %al
movb (alu_c), %dl
movl alu_div_shl3_8_d(,%eax,4), %eax
movl alu_div_shl1_8_c_d(%eax,%edx,4), %eax
movb %al, (alu_r+3)
movb %ah, (alu_c)
# end alu_div_shl1_8_c
# end alu_div_shl1_32_c
# alu_div_gte32
movl $0, (alu_c)
movl (alu_r), %eax
movl %eax, (alu_x)
movl (alu_d), %eax
movl %eax, (alu_y)
# alu_sub32
movl $0, %eax
movl $0, %ecx
movl $0x1, (alu_c)
# alu_sub16_fast
movw (alu_x+0), %ax
movw (alu_y+0), %cx
movw alu_inv16(,%ecx,2), %cx
movl alu_add16(,%eax,4), %edx
movl (%edx,%ecx,4), %edx
movl alu_add16(,%edx,4), %edx
movl (alu_c), %ecx
movl (%edx,%ecx,4), %edx
movw %dx, (alu_t+0)
movl %edx, (alu_c-2)
# end alu_sub16_fast
# alu_sub16_fast
movw (alu_x+2), %ax
movw (alu_y+2), %cx
movw alu_inv16(,%ecx,2), %cx
movl alu_add16(,%eax,4), %edx
movl (%edx,%ecx,4), %edx
movl alu_add16(,%edx,4), %edx
movl (alu_c), %ecx
movl (%edx,%ecx,4), %edx
movw %dx, (alu_t+2)
movl %edx, (alu_c-2)
# end alu_sub16_fast
# end alu_sub32
movl $0, %eax
movb (alu_c), %al
movb alu_true(%eax), %al
movl %eax, (alu_t)
# end alu_div_gte32
movl (alu_t), %eax
movl alu_sel_r(,%eax,4), %edx
movl %edx, (alu_psel_r)
movl alu_sel_q(,%eax,4), %edx
movl %edx, (alu_psel_q)
movl (alu_psel_r), %eax
movl (%eax), %eax
movl %eax, (alu_sr)
movl (alu_sr), %eax
movl %eax, (alu_x)
movl (alu_d), %eax
movl %eax, (alu_y)
# alu_sub32
movl $0, %eax
movl $0, %ecx
movl $0x1, (alu_c)
# alu_sub16_fast
movw (alu_x+0), %ax
movw (alu_y+0), %cx
movw alu_inv16(,%ecx,2), %cx
movl alu_add16(,%eax,4), %edx
movl (%edx,%ecx,4), %edx
movl alu_add16(,%edx,4), %edx
movl (alu_c), %ecx
movl (%edx,%ecx,4), %edx
movw %dx, (alu_sr+0)
movl %edx, (alu_c-2)
# end alu_sub16_fast
# alu_sub16_fast
movw (alu_x+2), %ax
movw (alu_y+2), %cx
movw alu_inv16(,%ecx,2), %cx
movl alu_add16(,%eax,4), %edx
movl (%edx,%ecx,4), %edx
movl alu_add16(,%edx,4), %edx
movl (alu_c), %ecx
movl (%edx,%ecx,4), %edx
movw %dx, (alu_sr+2)
movl %edx, (alu_c-2)
# end alu_sub16_fast
# end alu_sub32
movl (alu_psel_r), %eax
movl (alu_sr), %edx
movl %edx, (%eax)
movl (alu_psel_q), %eax
movl (%eax), %eax
movl %eax, (alu_sq)
# alu_div_setb32
movl $0, %eax
movb (alu_sq+1), %al
movb alu_b_s_2(%eax), %al
movb %al, (alu_sq+1)
# end alu_div_setb32
movl (alu_psel_q), %eax
movl (alu_sq), %edx
movl %edx, (%eax)
# alu_bit
movl $0, %edx
movb (alu_n+1), %dl
movl alu_b1(,%edx,4), %eax
movl %eax, (alu_c)
# end alu_bit
# alu_div_shl1_32_c
# alu_div_shl1_8_c
movl $0, %eax
movl $0, %edx
movb (alu_r+0), %al
movb (alu_c), %dl
movl alu_div_shl3_8_d(,%eax,4), %eax
movl alu_div_shl1_8_c_d(%eax,%edx,4), %eax
movb %al, (alu_r+0)
movb %ah, (alu_c)
# end alu_div_shl1_8_c
# alu_div_shl1_8_c
movl $0, %eax
movl $0, %edx
movb (alu_r+1), %al
movb (alu_c), %dl
movl alu_div_shl3_8_d(,%eax,4), %eax
movl alu_div_shl1_8_c_d(%eax,%edx,4), %eax
movb %al, (alu_r+1)
movb %ah, (alu_c)
# end alu_div_shl1_8_c
# alu_div_shl1_8_c
movl $0, %eax
movl $0, %edx
movb (alu_r+2), %al
movb (alu_c), %dl
movl alu_div_shl3_8_d(,%eax,4), %eax
movl alu_div_shl1_8_c_d(%eax,%edx,4), %eax
movb %al, (alu_r+2)
movb %ah, (alu_c)
# end alu_div_shl1_8_c
# alu_div_shl1_8_c
movl $0, %eax
movl $0, %edx
movb (alu_r+3), %al
movb (alu_c), %dl
movl alu_div_shl3_8_d(,%eax,4), %eax
movl alu_div_shl1_8_c_d(%eax,%edx,4), %eax
movb %al, (alu_r+3)
movb %ah, (alu_c)
# end alu_div_shl1_8_c
# end alu_div_shl1_32_c
# alu_div_gte32
movl $0, (alu_c)
movl (alu_r), %eax
movl %eax, (alu_x)
movl (alu_d), %eax
movl %eax, (alu_y)
# alu_sub32
movl $0, %eax
movl $0, %ecx
movl $0x1, (alu_c)
# alu_sub16_fast
movw (alu_x+0), %ax
movw (alu_y+0), %cx
movw alu_inv16(,%ecx,2), %cx
movl alu_add16(,%eax,4), %edx
movl (%edx,%ecx,4), %edx
movl alu_add16(,%edx,4), %edx
movl (alu_c), %ecx
movl (%edx,%ecx,4), %edx
movw %dx, (alu_t+0)
movl %edx, (alu_c-2)
# end alu_sub16_fast
# alu_sub16_fast
movw (alu_x+2), %ax
movw (alu_y+2), %cx
movw alu_inv16(,%ecx,2), %cx
movl alu_add16(,%eax,4), %edx
movl (%edx,%ecx,4), %edx
movl alu_add16(,%edx,4), %edx
movl (alu_c), %ecx
movl (%edx,%ecx,4), %edx
movw %dx, (alu_t+2)
movl %edx, (alu_c-2)
# end alu_sub16_fast
# end alu_sub32
movl $0, %eax
movb (alu_c), %al
movb alu_true(%eax), %al
movl %eax, (alu_t)
# end alu_div_gte32
movl (alu_t), %eax
movl alu_sel_r(,%eax,4), %edx
movl %edx, (alu_psel_r)
movl alu_sel_q(,%eax,4), %edx
movl %edx, (alu_psel_q)
movl (alu_psel_r), %eax
movl (%eax), %eax
movl %eax, (alu_sr)
movl (alu_sr), %eax
movl %eax, (alu_x)
movl (alu_d), %eax
movl %eax, (alu_y)
# alu_sub32
movl $0, %eax
movl $0, %ecx
movl $0x1, (alu_c)
# alu_sub16_fast
movw (alu_x+0), %ax
movw (alu_y+0), %cx
movw alu_inv16(,%ecx,2), %cx
movl alu_add16(,%eax,4), %edx
movl (%edx,%ecx,4), %edx
movl alu_add16(,%edx,4), %edx
movl (alu_c), %ecx
movl (%edx,%ecx,4), %edx
movw %dx, (alu_sr+0)
movl %edx, (alu_c-2)
# end alu_sub16_fast
# alu_sub16_fast
movw (alu_x+2), %ax
movw (alu_y+2), %cx
movw alu_inv16(,%ecx,2), %cx
movl alu_add16(,%eax,4), %edx
movl (%edx,%ecx,4), %edx
movl alu_add16(,%edx,4), %edx
movl (alu_c), %ecx
movl (%edx,%ecx,4), %edx
movw %dx, (alu_sr+2)
movl %edx, (alu_c-2)
# end alu_sub16_fast
# end alu_sub32
movl (alu_psel_r), %eax
movl (alu_sr), %edx
movl %edx, (%eax)
movl (alu_psel_q), %eax
movl (%eax), %eax
movl %eax, (alu_sq)
# alu_div_setb32
movl $0, %eax
movb (alu_sq+1), %al
movb alu_b_s_1(%eax), %al
movb %al, (alu_sq+1)
# end alu_div_setb32
movl (alu_psel_q), %eax
movl (alu_sq), %edx
movl %edx, (%eax)
# alu_bit
movl $0, %edx
movb (alu_n+1), %dl
movl alu_b0(,%edx,4), %eax
movl %eax, (alu_c)
# end alu_bit
# alu_div_shl1_32_c
# alu_div_shl1_8_c
movl $0, %eax
movl $0, %edx
movb (alu_r+0), %al
movb (alu_c), %dl
movl alu_div_shl3_8_d(,%eax,4), %eax
movl alu_div_shl1_8_c_d(%eax,%edx,4), %eax
movb %al, (alu_r+0)
movb %ah, (alu_c)
# end alu_div_shl1_8_c
# alu_div_shl1_8_c
movl $0, %eax
movl $0, %edx
movb (alu_r+1), %al
movb (alu_c), %dl
movl alu_div_shl3_8_d(,%eax,4), %eax
movl alu_div_shl1_8_c_d(%eax,%edx,4), %eax
movb %al, (alu_r+1)
movb %ah, (alu_c)
# end alu_div_shl1_8_c
# alu_div_shl1_8_c
movl $0, %eax
movl $0, %edx
movb (alu_r+2), %al
movb (alu_c), %dl
movl alu_div_shl3_8_d(,%eax,4), %eax
movl alu_div_shl1_8_c_d(%eax,%edx,4), %eax
movb %al, (alu_r+2)
movb %ah, (alu_c)
# end alu_div_shl1_8_c
# alu_div_shl1_8_c
movl $0, %eax
movl $0, %edx
movb (alu_r+3), %al
movb (alu_c), %dl
movl alu_div_shl3_8_d(,%eax,4), %eax
movl alu_div_shl1_8_c_d(%eax,%edx,4), %eax
movb %al, (alu_r+3)
movb %ah, (alu_c)
# end alu_div_shl1_8_c
# end alu_div_shl1_32_c
# alu_div_gte32
movl $0, (alu_c)
movl (alu_r), %eax
movl %eax, (alu_x)
movl (alu_d), %eax
movl %eax, (alu_y)
# alu_sub32
movl $0, %eax
movl $0, %ecx
movl $0x1, (alu_c)
# alu_sub16_fast
movw (alu_x+0), %ax
movw (alu_y+0), %cx
movw alu_inv16(,%ecx,2), %cx
movl alu_add16(,%eax,4), %edx
movl (%edx,%ecx,4), %edx
movl alu_add16(,%edx,4), %edx
movl (alu_c), %ecx
movl (%edx,%ecx,4), %edx
movw %dx, (alu_t+0)
movl %edx, (alu_c-2)
# end alu_sub16_fast
# alu_sub16_fast
movw (alu_x+2), %ax
movw (alu_y+2), %cx
movw alu_inv16(,%ecx,2), %cx
movl alu_add16(,%eax,4), %edx
movl (%edx,%ecx,4), %edx
movl alu_add16(,%edx,4), %edx
movl (alu_c), %ecx
movl (%edx,%ecx,4), %edx
movw %dx, (alu_t+2)
movl %edx, (alu_c-2)
# end alu_sub16_fast
# end alu_sub32
movl $0, %eax
movb (alu_c), %al
movb alu_true(%eax), %al
movl %eax, (alu_t)
# end alu_div_gte32
movl (alu_t), %eax
movl alu_sel_r(,%eax,4), %edx
movl %edx, (alu_psel_r)
movl alu_sel_q(,%eax,4), %edx
movl %edx, (alu_psel_q)
movl (alu_psel_r), %eax
movl (%eax), %eax
movl %eax, (alu_sr)
movl (alu_sr), %eax
movl %eax, (alu_x)
movl (alu_d), %eax
movl %eax, (alu_y)
# alu_sub32
movl $0, %eax
movl $0, %ecx
movl $0x1, (alu_c)
# alu_sub16_fast
movw (alu_x+0), %ax
movw (alu_y+0), %cx
movw alu_inv16(,%ecx,2), %cx
movl alu_add16(,%eax,4), %edx
movl (%edx,%ecx,4), %edx
movl alu_add16(,%edx,4), %edx
movl (alu_c), %ecx
movl (%edx,%ecx,4), %edx
movw %dx, (alu_sr+0)
movl %edx, (alu_c-2)
# end alu_sub16_fast
# alu_sub16_fast
movw (alu_x+2), %ax
movw (alu_y+2), %cx
movw alu_inv16(,%ecx,2), %cx
movl alu_add16(,%eax,4), %edx
movl (%edx,%ecx,4), %edx
movl alu_add16(,%edx,4), %edx
movl (alu_c), %ecx
movl (%edx,%ecx,4), %edx
movw %dx, (alu_sr+2)
movl %edx, (alu_c-2)
# end alu_sub16_fast
# end alu_sub32
movl (alu_psel_r), %eax
movl (alu_sr), %edx
movl %edx, (%eax)
movl (alu_psel_q), %eax
movl (%eax), %eax
movl %eax, (alu_sq)
# alu_div_setb32
movl $0, %eax
movb (alu_sq+1), %al
movb alu_b_s_0(%eax), %al
movb %al, (alu_sq+1)
# end alu_div_setb32
movl (alu_psel_q), %eax
movl (alu_sq), %edx
movl %edx, (%eax)
# alu_bit
movl $0, %edx
movb (alu_n+0), %dl
movl alu_b7(,%edx,4), %eax
movl %eax, (alu_c)
# end alu_bit
# alu_div_shl1_32_c
# alu_div_shl1_8_c
movl $0, %eax
movl $0, %edx
movb (alu_r+0), %al
movb (alu_c), %dl
movl alu_div_shl3_8_d(,%eax,4), %eax
movl alu_div_shl1_8_c_d(%eax,%edx,4), %eax
movb %al, (alu_r+0)
movb %ah, (alu_c)
# end alu_div_shl1_8_c
# alu_div_shl1_8_c
movl $0, %eax
movl $0, %edx
movb (alu_r+1), %al
movb (alu_c), %dl
movl alu_div_shl3_8_d(,%eax,4), %eax
movl alu_div_shl1_8_c_d(%eax,%edx,4), %eax
movb %al, (alu_r+1)
movb %ah, (alu_c)
# end alu_div_shl1_8_c
# alu_div_shl1_8_c
movl $0, %eax
movl $0, %edx
movb (alu_r+2), %al
movb (alu_c), %dl
movl alu_div_shl3_8_d(,%eax,4), %eax
movl alu_div_shl1_8_c_d(%eax,%edx,4), %eax
movb %al, (alu_r+2)
movb %ah, (alu_c)
# end alu_div_shl1_8_c
# alu_div_shl1_8_c
movl $0, %eax
movl $0, %edx
movb (alu_r+3), %al
movb (alu_c), %dl
movl alu_div_shl3_8_d(,%eax,4), %eax
movl alu_div_shl1_8_c_d(%eax,%edx,4), %eax
movb %al, (alu_r+3)
movb %ah, (alu_c)
# end alu_div_shl1_8_c
# end alu_div_shl1_32_c
# alu_div_gte32
movl $0, (alu_c)
movl (alu_r), %eax
movl %eax, (alu_x)
movl (alu_d), %eax
movl %eax, (alu_y)
# alu_sub32
movl $0, %eax
movl $0, %ecx
movl $0x1, (alu_c)
# alu_sub16_fast
movw (alu_x+0), %ax
movw (alu_y+0), %cx
movw alu_inv16(,%ecx,2), %cx
movl alu_add16(,%eax,4), %edx
movl (%edx,%ecx,4), %edx
movl alu_add16(,%edx,4), %edx
movl (alu_c), %ecx
movl (%edx,%ecx,4), %edx
movw %dx, (alu_t+0)
movl %edx, (alu_c-2)
# end alu_sub16_fast
# alu_sub16_fast
movw (alu_x+2), %ax
movw (alu_y+2), %cx
movw alu_inv16(,%ecx,2), %cx
movl alu_add16(,%eax,4), %edx
movl (%edx,%ecx,4), %edx
movl alu_add16(,%edx,4), %edx
movl (alu_c), %ecx
movl (%edx,%ecx,4), %edx
movw %dx, (alu_t+2)
movl %edx, (alu_c-2)
# end alu_sub16_fast
# end alu_sub32
movl $0, %eax
movb (alu_c), %al
movb alu_true(%eax), %al
movl %eax, (alu_t)
# end alu_div_gte32
movl (alu_t), %eax
movl alu_sel_r(,%eax,4), %edx
movl %edx, (alu_psel_r)
movl alu_sel_q(,%eax,4), %edx
movl %edx, (alu_psel_q)
movl (alu_psel_r), %eax
movl (%eax), %eax
movl %eax, (alu_sr)
movl (alu_sr), %eax
movl %eax, (alu_x)
movl (alu_d), %eax
movl %eax, (alu_y)
# alu_sub32
movl $0, %eax
movl $0, %ecx
movl $0x1, (alu_c)
# alu_sub16_fast
movw (alu_x+0), %ax
movw (alu_y+0), %cx
movw alu_inv16(,%ecx,2), %cx
movl alu_add16(,%eax,4), %edx
movl (%edx,%ecx,4), %edx
movl alu_add16(,%edx,4), %edx
movl (alu_c), %ecx
movl (%edx,%ecx,4), %edx
movw %dx, (alu_sr+0)
movl %edx, (alu_c-2)
# end alu_sub16_fast
# alu_sub16_fast
movw (alu_x+2), %ax
movw (alu_y+2), %cx
movw alu_inv16(,%ecx,2), %cx
movl alu_add16(,%eax,4), %edx
movl (%edx,%ecx,4), %edx
movl alu_add16(,%edx,4), %edx
movl (alu_c), %ecx
movl (%edx,%ecx,4), %edx
movw %dx, (alu_sr+2)
movl %edx, (alu_c-2)
# end alu_sub16_fast
# end alu_sub32
movl (alu_psel_r), %eax
movl (alu_sr), %edx
movl %edx, (%eax)
movl (alu_psel_q), %eax
movl (%eax), %eax
movl %eax, (alu_sq)
# alu_div_setb32
movl $0, %eax
movb (alu_sq+0), %al
movb alu_b_s_7(%eax), %al
movb %al, (alu_sq+0)
# end alu_div_setb32
movl (alu_psel_q), %eax
movl (alu_sq), %edx
movl %edx, (%eax)
# alu_bit
movl $0, %edx
movb (alu_n+0), %dl
movl alu_b6(,%edx,4), %eax
movl %eax, (alu_c)
# end alu_bit
# alu_div_shl1_32_c
# alu_div_shl1_8_c
movl $0, %eax
movl $0, %edx
movb (alu_r+0), %al
movb (alu_c), %dl
movl alu_div_shl3_8_d(,%eax,4), %eax
movl alu_div_shl1_8_c_d(%eax,%edx,4), %eax
movb %al, (alu_r+0)
movb %ah, (alu_c)
# end alu_div_shl1_8_c
# alu_div_shl1_8_c
movl $0, %eax
movl $0, %edx
movb (alu_r+1), %al
movb (alu_c), %dl
movl alu_div_shl3_8_d(,%eax,4), %eax
movl alu_div_shl1_8_c_d(%eax,%edx,4), %eax
movb %al, (alu_r+1)
movb %ah, (alu_c)
# end alu_div_shl1_8_c
# alu_div_shl1_8_c
movl $0, %eax
movl $0, %edx
movb (alu_r+2), %al
movb (alu_c), %dl
movl alu_div_shl3_8_d(,%eax,4), %eax
movl alu_div_shl1_8_c_d(%eax,%edx,4), %eax
movb %al, (alu_r+2)
movb %ah, (alu_c)
# end alu_div_shl1_8_c
# alu_div_shl1_8_c
movl $0, %eax
movl $0, %edx
movb (alu_r+3), %al
movb (alu_c), %dl
movl alu_div_shl3_8_d(,%eax,4), %eax
movl alu_div_shl1_8_c_d(%eax,%edx,4), %eax
movb %al, (alu_r+3)
movb %ah, (alu_c)
# end alu_div_shl1_8_c
# end alu_div_shl1_32_c
# alu_div_gte32
movl $0, (alu_c)
movl (alu_r), %eax
movl %eax, (alu_x)
movl (alu_d), %eax
movl %eax, (alu_y)
# alu_sub32
movl $0, %eax
movl $0, %ecx
movl $0x1, (alu_c)
# alu_sub16_fast
movw (alu_x+0), %ax
movw (alu_y+0), %cx
movw alu_inv16(,%ecx,2), %cx
movl alu_add16(,%eax,4), %edx
movl (%edx,%ecx,4), %edx
movl alu_add16(,%edx,4), %edx
movl (alu_c), %ecx
movl (%edx,%ecx,4), %edx
movw %dx, (alu_t+0)
movl %edx, (alu_c-2)
# end alu_sub16_fast
# alu_sub16_fast
movw (alu_x+2), %ax
movw (alu_y+2), %cx
movw alu_inv16(,%ecx,2), %cx
movl alu_add16(,%eax,4), %edx
movl (%edx,%ecx,4), %edx
movl alu_add16(,%edx,4), %edx
movl (alu_c), %ecx
movl (%edx,%ecx,4), %edx
movw %dx, (alu_t+2)
movl %edx, (alu_c-2)
# end alu_sub16_fast
# end alu_sub32
movl $0, %eax
movb (alu_c), %al
movb alu_true(%eax), %al
movl %eax, (alu_t)
# end alu_div_gte32
movl (alu_t), %eax
movl alu_sel_r(,%eax,4), %edx
movl %edx, (alu_psel_r)
movl alu_sel_q(,%eax,4), %edx
movl %edx, (alu_psel_q)
movl (alu_psel_r), %eax
movl (%eax), %eax
movl %eax, (alu_sr)
movl (alu_sr), %eax
movl %eax, (alu_x)
movl (alu_d), %eax
movl %eax, (alu_y)
# alu_sub32
movl $0, %eax
movl $0, %ecx
movl $0x1, (alu_c)
# alu_sub16_fast
movw (alu_x+0), %ax
movw (alu_y+0), %cx
movw alu_inv16(,%ecx,2), %cx
movl alu_add16(,%eax,4), %edx
movl (%edx,%ecx,4), %edx
movl alu_add16(,%edx,4), %edx
movl (alu_c), %ecx
movl (%edx,%ecx,4), %edx
movw %dx, (alu_sr+0)
movl %edx, (alu_c-2)
# end alu_sub16_fast
# alu_sub16_fast
movw (alu_x+2), %ax
movw (alu_y+2), %cx
movw alu_inv16(,%ecx,2), %cx
movl alu_add16(,%eax,4), %edx
movl (%edx,%ecx,4), %edx
movl alu_add16(,%edx,4), %edx
movl (alu_c), %ecx
movl (%edx,%ecx,4), %edx
movw %dx, (alu_sr+2)
movl %edx, (alu_c-2)
# end alu_sub16_fast
# end alu_sub32
movl (alu_psel_r), %eax
movl (alu_sr), %edx
movl %edx, (%eax)
movl (alu_psel_q), %eax
movl (%eax), %eax
movl %eax, (alu_sq)
# alu_div_setb32
movl $0, %eax
movb (alu_sq+0), %al
movb alu_b_s_6(%eax), %al
movb %al, (alu_sq+0)
# end alu_div_setb32
movl (alu_psel_q), %eax
movl (alu_sq), %edx
movl %edx, (%eax)
# alu_bit
movl $0, %edx
movb (alu_n+0), %dl
movl alu_b5(,%edx,4), %eax
movl %eax, (alu_c)
# end alu_bit
# alu_div_shl1_32_c
# alu_div_shl1_8_c
movl $0, %eax
movl $0, %edx
movb (alu_r+0), %al
movb (alu_c), %dl
movl alu_div_shl3_8_d(,%eax,4), %eax
movl alu_div_shl1_8_c_d(%eax,%edx,4), %eax
movb %al, (alu_r+0)
movb %ah, (alu_c)
# end alu_div_shl1_8_c
# alu_div_shl1_8_c
movl $0, %eax
movl $0, %edx
movb (alu_r+1), %al
movb (alu_c), %dl
movl alu_div_shl3_8_d(,%eax,4), %eax
movl alu_div_shl1_8_c_d(%eax,%edx,4), %eax
movb %al, (alu_r+1)
movb %ah, (alu_c)
# end alu_div_shl1_8_c
# alu_div_shl1_8_c
movl $0, %eax
movl $0, %edx
movb (alu_r+2), %al
movb (alu_c), %dl
movl alu_div_shl3_8_d(,%eax,4), %eax
movl alu_div_shl1_8_c_d(%eax,%edx,4), %eax
movb %al, (alu_r+2)
movb %ah, (alu_c)
# end alu_div_shl1_8_c
# alu_div_shl1_8_c
movl $0, %eax
movl $0, %edx
movb (alu_r+3), %al
movb (alu_c), %dl
movl alu_div_shl3_8_d(,%eax,4), %eax
movl alu_div_shl1_8_c_d(%eax,%edx,4), %eax
movb %al, (alu_r+3)
movb %ah, (alu_c)
# end alu_div_shl1_8_c
# end alu_div_shl1_32_c
# alu_div_gte32
movl $0, (alu_c)
movl (alu_r), %eax
movl %eax, (alu_x)
movl (alu_d), %eax
movl %eax, (alu_y)
# alu_sub32
movl $0, %eax
movl $0, %ecx
movl $0x1, (alu_c)
# alu_sub16_fast
movw (alu_x+0), %ax
movw (alu_y+0), %cx
movw alu_inv16(,%ecx,2), %cx
movl alu_add16(,%eax,4), %edx
movl (%edx,%ecx,4), %edx
movl alu_add16(,%edx,4), %edx
movl (alu_c), %ecx
movl (%edx,%ecx,4), %edx
movw %dx, (alu_t+0)
movl %edx, (alu_c-2)
# end alu_sub16_fast
# alu_sub16_fast
movw (alu_x+2), %ax
movw (alu_y+2), %cx
movw alu_inv16(,%ecx,2), %cx
movl alu_add16(,%eax,4), %edx
movl (%edx,%ecx,4), %edx
movl alu_add16(,%edx,4), %edx
movl (alu_c), %ecx
movl (%edx,%ecx,4), %edx
movw %dx, (alu_t+2)
movl %edx, (alu_c-2)
# end alu_sub16_fast
# end alu_sub32
movl $0, %eax
movb (alu_c), %al
movb alu_true(%eax), %al
movl %eax, (alu_t)
# end alu_div_gte32
movl (alu_t), %eax
movl alu_sel_r(,%eax,4), %edx
movl %edx, (alu_psel_r)
movl alu_sel_q(,%eax,4), %edx
movl %edx, (alu_psel_q)
movl (alu_psel_r), %eax
movl (%eax), %eax
movl %eax, (alu_sr)
movl (alu_sr), %eax
movl %eax, (alu_x)
movl (alu_d), %eax
movl %eax, (alu_y)
# alu_sub32
movl $0, %eax
movl $0, %ecx
movl $0x1, (alu_c)
# alu_sub16_fast
movw (alu_x+0), %ax
movw (alu_y+0), %cx
movw alu_inv16(,%ecx,2), %cx
movl alu_add16(,%eax,4), %edx
movl (%edx,%ecx,4), %edx
movl alu_add16(,%edx,4), %edx
movl (alu_c), %ecx
movl (%edx,%ecx,4), %edx
movw %dx, (alu_sr+0)
movl %edx, (alu_c-2)
# end alu_sub16_fast
# alu_sub16_fast
movw (alu_x+2), %ax
movw (alu_y+2), %cx
movw alu_inv16(,%ecx,2), %cx
movl alu_add16(,%eax,4), %edx
movl (%edx,%ecx,4), %edx
movl alu_add16(,%edx,4), %edx
movl (alu_c), %ecx
movl (%edx,%ecx,4), %edx
movw %dx, (alu_sr+2)
movl %edx, (alu_c-2)
# end alu_sub16_fast
# end alu_sub32
movl (alu_psel_r), %eax
movl (alu_sr), %edx
movl %edx, (%eax)
movl (alu_psel_q), %eax
movl (%eax), %eax
movl %eax, (alu_sq)
# alu_div_setb32
movl $0, %eax
movb (alu_sq+0), %al
movb alu_b_s_5(%eax), %al
movb %al, (alu_sq+0)
# end alu_div_setb32
movl (alu_psel_q), %eax
movl (alu_sq), %edx
movl %edx, (%eax)
# alu_bit
movl $0, %edx
movb (alu_n+0), %dl
movl alu_b4(,%edx,4), %eax
movl %eax, (alu_c)
# end alu_bit
# alu_div_shl1_32_c
# alu_div_shl1_8_c
movl $0, %eax
movl $0, %edx
movb (alu_r+0), %al
movb (alu_c), %dl
movl alu_div_shl3_8_d(,%eax,4), %eax
movl alu_div_shl1_8_c_d(%eax,%edx,4), %eax
movb %al, (alu_r+0)
movb %ah, (alu_c)
# end alu_div_shl1_8_c
# alu_div_shl1_8_c
movl $0, %eax
movl $0, %edx
movb (alu_r+1), %al
movb (alu_c), %dl
movl alu_div_shl3_8_d(,%eax,4), %eax
movl alu_div_shl1_8_c_d(%eax,%edx,4), %eax
movb %al, (alu_r+1)
movb %ah, (alu_c)
# end alu_div_shl1_8_c
# alu_div_shl1_8_c
movl $0, %eax
movl $0, %edx
movb (alu_r+2), %al
movb (alu_c), %dl
movl alu_div_shl3_8_d(,%eax,4), %eax
movl alu_div_shl1_8_c_d(%eax,%edx,4), %eax
movb %al, (alu_r+2)
movb %ah, (alu_c)
# end alu_div_shl1_8_c
# alu_div_shl1_8_c
movl $0, %eax
movl $0, %edx
movb (alu_r+3), %al
movb (alu_c), %dl
movl alu_div_shl3_8_d(,%eax,4), %eax
movl alu_div_shl1_8_c_d(%eax,%edx,4), %eax
movb %al, (alu_r+3)
movb %ah, (alu_c)
# end alu_div_shl1_8_c
# end alu_div_shl1_32_c
# alu_div_gte32
movl $0, (alu_c)
movl (alu_r), %eax
movl %eax, (alu_x)
movl (alu_d), %eax
movl %eax, (alu_y)
# alu_sub32
movl $0, %eax
movl $0, %ecx
movl $0x1, (alu_c)
# alu_sub16_fast
movw (alu_x+0), %ax
movw (alu_y+0), %cx
movw alu_inv16(,%ecx,2), %cx
movl alu_add16(,%eax,4), %edx
movl (%edx,%ecx,4), %edx
movl alu_add16(,%edx,4), %edx
movl (alu_c), %ecx
movl (%edx,%ecx,4), %edx
movw %dx, (alu_t+0)
movl %edx, (alu_c-2)
# end alu_sub16_fast
# alu_sub16_fast
movw (alu_x+2), %ax
movw (alu_y+2), %cx
movw alu_inv16(,%ecx,2), %cx
movl alu_add16(,%eax,4), %edx
movl (%edx,%ecx,4), %edx
movl alu_add16(,%edx,4), %edx
movl (alu_c), %ecx
movl (%edx,%ecx,4), %edx
movw %dx, (alu_t+2)
movl %edx, (alu_c-2)
# end alu_sub16_fast
# end alu_sub32
movl $0, %eax
movb (alu_c), %al
movb alu_true(%eax), %al
movl %eax, (alu_t)
# end alu_div_gte32
movl (alu_t), %eax
movl alu_sel_r(,%eax,4), %edx
movl %edx, (alu_psel_r)
movl alu_sel_q(,%eax,4), %edx
movl %edx, (alu_psel_q)
movl (alu_psel_r), %eax
movl (%eax), %eax
movl %eax, (alu_sr)
movl (alu_sr), %eax
movl %eax, (alu_x)
movl (alu_d), %eax
movl %eax, (alu_y)
# alu_sub32
movl $0, %eax
movl $0, %ecx
movl $0x1, (alu_c)
# alu_sub16_fast
movw (alu_x+0), %ax
movw (alu_y+0), %cx
movw alu_inv16(,%ecx,2), %cx
movl alu_add16(,%eax,4), %edx
movl (%edx,%ecx,4), %edx
movl alu_add16(,%edx,4), %edx
movl (alu_c), %ecx
movl (%edx,%ecx,4), %edx
movw %dx, (alu_sr+0)
movl %edx, (alu_c-2)
# end alu_sub16_fast
# alu_sub16_fast
movw (alu_x+2), %ax
movw (alu_y+2), %cx
movw alu_inv16(,%ecx,2), %cx
movl alu_add16(,%eax,4), %edx
movl (%edx,%ecx,4), %edx
movl alu_add16(,%edx,4), %edx
movl (alu_c), %ecx
movl (%edx,%ecx,4), %edx
movw %dx, (alu_sr+2)
movl %edx, (alu_c-2)
# end alu_sub16_fast
# end alu_sub32
movl (alu_psel_r), %eax
movl (alu_sr), %edx
movl %edx, (%eax)
movl (alu_psel_q), %eax
movl (%eax), %eax
movl %eax, (alu_sq)
# alu_div_setb32
movl $0, %eax
movb (alu_sq+0), %al
movb alu_b_s_4(%eax), %al
movb %al, (alu_sq+0)
# end alu_div_setb32
movl (alu_psel_q), %eax
movl (alu_sq), %edx
movl %edx, (%eax)
# alu_bit
movl $0, %edx
movb (alu_n+0), %dl
movl alu_b3(,%edx,4), %eax
movl %eax, (alu_c)
# end alu_bit
# alu_div_shl1_32_c
# alu_div_shl1_8_c
movl $0, %eax
movl $0, %edx
movb (alu_r+0), %al
movb (alu_c), %dl
movl alu_div_shl3_8_d(,%eax,4), %eax
movl alu_div_shl1_8_c_d(%eax,%edx,4), %eax
movb %al, (alu_r+0)
movb %ah, (alu_c)
# end alu_div_shl1_8_c
# alu_div_shl1_8_c
movl $0, %eax
movl $0, %edx
movb (alu_r+1), %al
movb (alu_c), %dl
movl alu_div_shl3_8_d(,%eax,4), %eax
movl alu_div_shl1_8_c_d(%eax,%edx,4), %eax
movb %al, (alu_r+1)
movb %ah, (alu_c)
# end alu_div_shl1_8_c
# alu_div_shl1_8_c
movl $0, %eax
movl $0, %edx
movb (alu_r+2), %al
movb (alu_c), %dl
movl alu_div_shl3_8_d(,%eax,4), %eax
movl alu_div_shl1_8_c_d(%eax,%edx,4), %eax
movb %al, (alu_r+2)
movb %ah, (alu_c)
# end alu_div_shl1_8_c
# alu_div_shl1_8_c
movl $0, %eax
movl $0, %edx
movb (alu_r+3), %al
movb (alu_c), %dl
movl alu_div_shl3_8_d(,%eax,4), %eax
movl alu_div_shl1_8_c_d(%eax,%edx,4), %eax
movb %al, (alu_r+3)
movb %ah, (alu_c)
# end alu_div_shl1_8_c
# end alu_div_shl1_32_c
# alu_div_gte32
movl $0, (alu_c)
movl (alu_r), %eax
movl %eax, (alu_x)
movl (alu_d), %eax
movl %eax, (alu_y)
# alu_sub32
movl $0, %eax
movl $0, %ecx
movl $0x1, (alu_c)
# alu_sub16_fast
movw (alu_x+0), %ax
movw (alu_y+0), %cx
movw alu_inv16(,%ecx,2), %cx
movl alu_add16(,%eax,4), %edx
movl (%edx,%ecx,4), %edx
movl alu_add16(,%edx,4), %edx
movl (alu_c), %ecx
movl (%edx,%ecx,4), %edx
movw %dx, (alu_t+0)
movl %edx, (alu_c-2)
# end alu_sub16_fast
# alu_sub16_fast
movw (alu_x+2), %ax
movw (alu_y+2), %cx
movw alu_inv16(,%ecx,2), %cx
movl alu_add16(,%eax,4), %edx
movl (%edx,%ecx,4), %edx
movl alu_add16(,%edx,4), %edx
movl (alu_c), %ecx
movl (%edx,%ecx,4), %edx
movw %dx, (alu_t+2)
movl %edx, (alu_c-2)
# end alu_sub16_fast
# end alu_sub32
movl $0, %eax
movb (alu_c), %al
movb alu_true(%eax), %al
movl %eax, (alu_t)
# end alu_div_gte32
movl (alu_t), %eax
movl alu_sel_r(,%eax,4), %edx
movl %edx, (alu_psel_r)
movl alu_sel_q(,%eax,4), %edx
movl %edx, (alu_psel_q)
movl (alu_psel_r), %eax
movl (%eax), %eax
movl %eax, (alu_sr)
movl (alu_sr), %eax
movl %eax, (alu_x)
movl (alu_d), %eax
movl %eax, (alu_y)
# alu_sub32
movl $0, %eax
movl $0, %ecx
movl $0x1, (alu_c)
# alu_sub16_fast
movw (alu_x+0), %ax
movw (alu_y+0), %cx
movw alu_inv16(,%ecx,2), %cx
movl alu_add16(,%eax,4), %edx
movl (%edx,%ecx,4), %edx
movl alu_add16(,%edx,4), %edx
movl (alu_c), %ecx
movl (%edx,%ecx,4), %edx
movw %dx, (alu_sr+0)
movl %edx, (alu_c-2)
# end alu_sub16_fast
# alu_sub16_fast
movw (alu_x+2), %ax
movw (alu_y+2), %cx
movw alu_inv16(,%ecx,2), %cx
movl alu_add16(,%eax,4), %edx
movl (%edx,%ecx,4), %edx
movl alu_add16(,%edx,4), %edx
movl (alu_c), %ecx
movl (%edx,%ecx,4), %edx
movw %dx, (alu_sr+2)
movl %edx, (alu_c-2)
# end alu_sub16_fast
# end alu_sub32
movl (alu_psel_r), %eax
movl (alu_sr), %edx
movl %edx, (%eax)
movl (alu_psel_q), %eax
movl (%eax), %eax
movl %eax, (alu_sq)
# alu_div_setb32
movl $0, %eax
movb (alu_sq+0), %al
movb alu_b_s_3(%eax), %al
movb %al, (alu_sq+0)
# end alu_div_setb32
movl (alu_psel_q), %eax
movl (alu_sq), %edx
movl %edx, (%eax)
# alu_bit
movl $0, %edx
movb (alu_n+0), %dl
movl alu_b2(,%edx,4), %eax
movl %eax, (alu_c)
# end alu_bit
# alu_div_shl1_32_c
# alu_div_shl1_8_c
movl $0, %eax
movl $0, %edx
movb (alu_r+0), %al
movb (alu_c), %dl
movl alu_div_shl3_8_d(,%eax,4), %eax
movl alu_div_shl1_8_c_d(%eax,%edx,4), %eax
movb %al, (alu_r+0)
movb %ah, (alu_c)
# end alu_div_shl1_8_c
# alu_div_shl1_8_c
movl $0, %eax
movl $0, %edx
movb (alu_r+1), %al
movb (alu_c), %dl
movl alu_div_shl3_8_d(,%eax,4), %eax
movl alu_div_shl1_8_c_d(%eax,%edx,4), %eax
movb %al, (alu_r+1)
movb %ah, (alu_c)
# end alu_div_shl1_8_c
# alu_div_shl1_8_c
movl $0, %eax
movl $0, %edx
movb (alu_r+2), %al
movb (alu_c), %dl
movl alu_div_shl3_8_d(,%eax,4), %eax
movl alu_div_shl1_8_c_d(%eax,%edx,4), %eax
movb %al, (alu_r+2)
movb %ah, (alu_c)
# end alu_div_shl1_8_c
# alu_div_shl1_8_c
movl $0, %eax
movl $0, %edx
movb (alu_r+3), %al
movb (alu_c), %dl
movl alu_div_shl3_8_d(,%eax,4), %eax
movl alu_div_shl1_8_c_d(%eax,%edx,4), %eax
movb %al, (alu_r+3)
movb %ah, (alu_c)
# end alu_div_shl1_8_c
# end alu_div_shl1_32_c
# alu_div_gte32
movl $0, (alu_c)
movl (alu_r), %eax
movl %eax, (alu_x)
movl (alu_d), %eax
movl %eax, (alu_y)
# alu_sub32
movl $0, %eax
movl $0, %ecx
movl $0x1, (alu_c)
# alu_sub16_fast
movw (alu_x+0), %ax
movw (alu_y+0), %cx
movw alu_inv16(,%ecx,2), %cx
movl alu_add16(,%eax,4), %edx
movl (%edx,%ecx,4), %edx
movl alu_add16(,%edx,4), %edx
movl (alu_c), %ecx
movl (%edx,%ecx,4), %edx
movw %dx, (alu_t+0)
movl %edx, (alu_c-2)
# end alu_sub16_fast
# alu_sub16_fast
movw (alu_x+2), %ax
movw (alu_y+2), %cx
movw alu_inv16(,%ecx,2), %cx
movl alu_add16(,%eax,4), %edx
movl (%edx,%ecx,4), %edx
movl alu_add16(,%edx,4), %edx
movl (alu_c), %ecx
movl (%edx,%ecx,4), %edx
movw %dx, (alu_t+2)
movl %edx, (alu_c-2)
# end alu_sub16_fast
# end alu_sub32
movl $0, %eax
movb (alu_c), %al
movb alu_true(%eax), %al
movl %eax, (alu_t)
# end alu_div_gte32
movl (alu_t), %eax
movl alu_sel_r(,%eax,4), %edx
movl %edx, (alu_psel_r)
movl alu_sel_q(,%eax,4), %edx
movl %edx, (alu_psel_q)
movl (alu_psel_r), %eax
movl (%eax), %eax
movl %eax, (alu_sr)
movl (alu_sr), %eax
movl %eax, (alu_x)
movl (alu_d), %eax
movl %eax, (alu_y)
# alu_sub32
movl $0, %eax
movl $0, %ecx
movl $0x1, (alu_c)
# alu_sub16_fast
movw (alu_x+0), %ax
movw (alu_y+0), %cx
movw alu_inv16(,%ecx,2), %cx
movl alu_add16(,%eax,4), %edx
movl (%edx,%ecx,4), %edx
movl alu_add16(,%edx,4), %edx
movl (alu_c), %ecx
movl (%edx,%ecx,4), %edx
movw %dx, (alu_sr+0)
movl %edx, (alu_c-2)
# end alu_sub16_fast
# alu_sub16_fast
movw (alu_x+2), %ax
movw (alu_y+2), %cx
movw alu_inv16(,%ecx,2), %cx
movl alu_add16(,%eax,4), %edx
movl (%edx,%ecx,4), %edx
movl alu_add16(,%edx,4), %edx
movl (alu_c), %ecx
movl (%edx,%ecx,4), %edx
movw %dx, (alu_sr+2)
movl %edx, (alu_c-2)
# end alu_sub16_fast
# end alu_sub32
movl (alu_psel_r), %eax
movl (alu_sr), %edx
movl %edx, (%eax)
movl (alu_psel_q), %eax
movl (%eax), %eax
movl %eax, (alu_sq)
# alu_div_setb32
movl $0, %eax
movb (alu_sq+0), %al
movb alu_b_s_2(%eax), %al
movb %al, (alu_sq+0)
# end alu_div_setb32
movl (alu_psel_q), %eax
movl (alu_sq), %edx
movl %edx, (%eax)
# alu_bit
movl $0, %edx
movb (alu_n+0), %dl
movl alu_b1(,%edx,4), %eax
movl %eax, (alu_c)
# end alu_bit
# alu_div_shl1_32_c
# alu_div_shl1_8_c
movl $0, %eax
movl $0, %edx
movb (alu_r+0), %al
movb (alu_c), %dl
movl alu_div_shl3_8_d(,%eax,4), %eax
movl alu_div_shl1_8_c_d(%eax,%edx,4), %eax
movb %al, (alu_r+0)
movb %ah, (alu_c)
# end alu_div_shl1_8_c
# alu_div_shl1_8_c
movl $0, %eax
movl $0, %edx
movb (alu_r+1), %al
movb (alu_c), %dl
movl alu_div_shl3_8_d(,%eax,4), %eax
movl alu_div_shl1_8_c_d(%eax,%edx,4), %eax
movb %al, (alu_r+1)
movb %ah, (alu_c)
# end alu_div_shl1_8_c
# alu_div_shl1_8_c
movl $0, %eax
movl $0, %edx
movb (alu_r+2), %al
movb (alu_c), %dl
movl alu_div_shl3_8_d(,%eax,4), %eax
movl alu_div_shl1_8_c_d(%eax,%edx,4), %eax
movb %al, (alu_r+2)
movb %ah, (alu_c)
# end alu_div_shl1_8_c
# alu_div_shl1_8_c
movl $0, %eax
movl $0, %edx
movb (alu_r+3), %al
movb (alu_c), %dl
movl alu_div_shl3_8_d(,%eax,4), %eax
movl alu_div_shl1_8_c_d(%eax,%edx,4), %eax
movb %al, (alu_r+3)
movb %ah, (alu_c)
# end alu_div_shl1_8_c
# end alu_div_shl1_32_c
# alu_div_gte32
movl $0, (alu_c)
movl (alu_r), %eax
movl %eax, (alu_x)
movl (alu_d), %eax
movl %eax, (alu_y)
# alu_sub32
movl $0, %eax
movl $0, %ecx
movl $0x1, (alu_c)
# alu_sub16_fast
movw (alu_x+0), %ax
movw (alu_y+0), %cx
movw alu_inv16(,%ecx,2), %cx
movl alu_add16(,%eax,4), %edx
movl (%edx,%ecx,4), %edx
movl alu_add16(,%edx,4), %edx
movl (alu_c), %ecx
movl (%edx,%ecx,4), %edx
movw %dx, (alu_t+0)
movl %edx, (alu_c-2)
# end alu_sub16_fast
# alu_sub16_fast
movw (alu_x+2), %ax
movw (alu_y+2), %cx
movw alu_inv16(,%ecx,2), %cx
movl alu_add16(,%eax,4), %edx
movl (%edx,%ecx,4), %edx
movl alu_add16(,%edx,4), %edx
movl (alu_c), %ecx
movl (%edx,%ecx,4), %edx
movw %dx, (alu_t+2)
movl %edx, (alu_c-2)
# end alu_sub16_fast
# end alu_sub32
movl $0, %eax
movb (alu_c), %al
movb alu_true(%eax), %al
movl %eax, (alu_t)
# end alu_div_gte32
movl (alu_t), %eax
movl alu_sel_r(,%eax,4), %edx
movl %edx, (alu_psel_r)
movl alu_sel_q(,%eax,4), %edx
movl %edx, (alu_psel_q)
movl (alu_psel_r), %eax
movl (%eax), %eax
movl %eax, (alu_sr)
movl (alu_sr), %eax
movl %eax, (alu_x)
movl (alu_d), %eax
movl %eax, (alu_y)
# alu_sub32
movl $0, %eax
movl $0, %ecx
movl $0x1, (alu_c)
# alu_sub16_fast
movw (alu_x+0), %ax
movw (alu_y+0), %cx
movw alu_inv16(,%ecx,2), %cx
movl alu_add16(,%eax,4), %edx
movl (%edx,%ecx,4), %edx
movl alu_add16(,%edx,4), %edx
movl (alu_c), %ecx
movl (%edx,%ecx,4), %edx
movw %dx, (alu_sr+0)
movl %edx, (alu_c-2)
# end alu_sub16_fast
# alu_sub16_fast
movw (alu_x+2), %ax
movw (alu_y+2), %cx
movw alu_inv16(,%ecx,2), %cx
movl alu_add16(,%eax,4), %edx
movl (%edx,%ecx,4), %edx
movl alu_add16(,%edx,4), %edx
movl (alu_c), %ecx
movl (%edx,%ecx,4), %edx
movw %dx, (alu_sr+2)
movl %edx, (alu_c-2)
# end alu_sub16_fast
# end alu_sub32
movl (alu_psel_r), %eax
movl (alu_sr), %edx
movl %edx, (%eax)
movl (alu_psel_q), %eax
movl (%eax), %eax
movl %eax, (alu_sq)
# alu_div_setb32
movl $0, %eax
movb (alu_sq+0), %al
movb alu_b_s_1(%eax), %al
movb %al, (alu_sq+0)
# end alu_div_setb32
movl (alu_psel_q), %eax
movl (alu_sq), %edx
movl %edx, (%eax)
# alu_bit
movl $0, %edx
movb (alu_n+0), %dl
movl alu_b0(,%edx,4), %eax
movl %eax, (alu_c)
# end alu_bit
# alu_div_shl1_32_c
# alu_div_shl1_8_c
movl $0, %eax
movl $0, %edx
movb (alu_r+0), %al
movb (alu_c), %dl
movl alu_div_shl3_8_d(,%eax,4), %eax
movl alu_div_shl1_8_c_d(%eax,%edx,4), %eax
movb %al, (alu_r+0)
movb %ah, (alu_c)
# end alu_div_shl1_8_c
# alu_div_shl1_8_c
movl $0, %eax
movl $0, %edx
movb (alu_r+1), %al
movb (alu_c), %dl
movl alu_div_shl3_8_d(,%eax,4), %eax
movl alu_div_shl1_8_c_d(%eax,%edx,4), %eax
movb %al, (alu_r+1)
movb %ah, (alu_c)
# end alu_div_shl1_8_c
# alu_div_shl1_8_c
movl $0, %eax
movl $0, %edx
movb (alu_r+2), %al
movb (alu_c), %dl
movl alu_div_shl3_8_d(,%eax,4), %eax
movl alu_div_shl1_8_c_d(%eax,%edx,4), %eax
movb %al, (alu_r+2)
movb %ah, (alu_c)
# end alu_div_shl1_8_c
# alu_div_shl1_8_c
movl $0, %eax
movl $0, %edx
movb (alu_r+3), %al
movb (alu_c), %dl
movl alu_div_shl3_8_d(,%eax,4), %eax
movl alu_div_shl1_8_c_d(%eax,%edx,4), %eax
movb %al, (alu_r+3)
movb %ah, (alu_c)
# end alu_div_shl1_8_c
# end alu_div_shl1_32_c
# alu_div_gte32
movl $0, (alu_c)
movl (alu_r), %eax
movl %eax, (alu_x)
movl (alu_d), %eax
movl %eax, (alu_y)
# alu_sub32
movl $0, %eax
movl $0, %ecx
movl $0x1, (alu_c)
# alu_sub16_fast
movw (alu_x+0), %ax
movw (alu_y+0), %cx
movw alu_inv16(,%ecx,2), %cx
movl alu_add16(,%eax,4), %edx
movl (%edx,%ecx,4), %edx
movl alu_add16(,%edx,4), %edx
movl (alu_c), %ecx
movl (%edx,%ecx,4), %edx
movw %dx, (alu_t+0)
movl %edx, (alu_c-2)
# end alu_sub16_fast
# alu_sub16_fast
movw (alu_x+2), %ax
movw (alu_y+2), %cx
movw alu_inv16(,%ecx,2), %cx
movl alu_add16(,%eax,4), %edx
movl (%edx,%ecx,4), %edx
movl alu_add16(,%edx,4), %edx
movl (alu_c), %ecx
movl (%edx,%ecx,4), %edx
movw %dx, (alu_t+2)
movl %edx, (alu_c-2)
# end alu_sub16_fast
# end alu_sub32
movl $0, %eax
movb (alu_c), %al
movb alu_true(%eax), %al
movl %eax, (alu_t)
# end alu_div_gte32
movl (alu_t), %eax
movl alu_sel_r(,%eax,4), %edx
movl %edx, (alu_psel_r)
movl alu_sel_q(,%eax,4), %edx
movl %edx, (alu_psel_q)
movl (alu_psel_r), %eax
movl (%eax), %eax
movl %eax, (alu_sr)
movl (alu_sr), %eax
movl %eax, (alu_x)
movl (alu_d), %eax
movl %eax, (alu_y)
# alu_sub32
movl $0, %eax
movl $0, %ecx
movl $0x1, (alu_c)
# alu_sub16_fast
movw (alu_x+0), %ax
movw (alu_y+0), %cx
movw alu_inv16(,%ecx,2), %cx
movl alu_add16(,%eax,4), %edx
movl (%edx,%ecx,4), %edx
movl alu_add16(,%edx,4), %edx
movl (alu_c), %ecx
movl (%edx,%ecx,4), %edx
movw %dx, (alu_sr+0)
movl %edx, (alu_c-2)
# end alu_sub16_fast
# alu_sub16_fast
movw (alu_x+2), %ax
movw (alu_y+2), %cx
movw alu_inv16(,%ecx,2), %cx
movl alu_add16(,%eax,4), %edx
movl (%edx,%ecx,4), %edx
movl alu_add16(,%edx,4), %edx
movl (alu_c), %ecx
movl (%edx,%ecx,4), %edx
movw %dx, (alu_sr+2)
movl %edx, (alu_c-2)
# end alu_sub16_fast
# end alu_sub32
movl (alu_psel_r), %eax
movl (alu_sr), %edx
movl %edx, (%eax)
movl (alu_psel_q), %eax
movl (%eax), %eax
movl %eax, (alu_sq)
# alu_div_setb32
movl $0, %eax
movb (alu_sq+0), %al
movb alu_b_s_0(%eax), %al
movb %al, (alu_sq+0)
# end alu_div_setb32
movl (alu_psel_q), %eax
movl (alu_sq), %edx
movl %edx, (%eax)
# end alu_divrem
movl (alu_r), %eax
# end alu_umod
movl %eax, (R2)

# end emit modu

# emit/mov>indiru4(vregp(2))

# emit/mov>addu4(modu4(addu4(subu4(indiru4(addrlp4(v)),indiru4(vregp(2))),cnstu4(13)),cnstu4(26)),indiru4(vregp(2)))

# emit addu

movl (R2), %eax
movl (R3), %edx
# alu_add
movl %eax, (alu_x)
movl %edx, (alu_y)
# alu_add32
movl $0, %eax
movl $0, %ecx
movl $0, (alu_c)
# alu_add16_fast
movw (alu_x+0), %ax
movw (alu_y+0), %cx
movl alu_add16(,%eax,4), %edx
movl (%edx,%ecx,4), %edx
movw (alu_c+2), %cx
movl alu_add16(,%edx,4), %edx
movl (%edx,%ecx,4), %edx
movw %dx, (alu_s+0)
movl %edx, (alu_c)
# end alu_add16_fast
# alu_add16_fast
movw (alu_x+2), %ax
movw (alu_y+2), %cx
movl alu_add16(,%eax,4), %edx
movl (%edx,%ecx,4), %edx
movw (alu_c+2), %cx
movl alu_add16(,%edx,4), %edx
movl (%edx,%ecx,4), %edx
movw %dx, (alu_s+2)
movl %edx, (alu_c)
# end alu_add16_fast
# end alu_add32
movl (alu_s), %eax
# end alu_add
movl %eax, (R3)

# end emit addu

# emit/mov>asgnu4(addrlp4(v),addu4(modu4(addu4(subu4(indiru4(addrlp4(v)),indiru4(vregp(2))),cnstu4(13)),cnstu4(26)),indiru4(vregp(2))))

# emit asgnu

# (ADDRL)
# (offset -4)
movl (fp), %eax
movl push(%eax), %eax
movl (on), %edx
# select data %eax %edx
movl %eax, (data_p)
movl sel_data(,%edx,4), %eax
# end select data
movl (R3), %edx
movl %edx, (%eax)

# end emit asgnu

# emit/mov>jumpv(addrgp4(15))

# emit jumpv

jmp .LCI15

# end emit jumpv

# emit/mov>labelv(14)

# emit labelv

.LCI14:

# end emit labelv

# emit/mov>addrlp4(v)

# emit addrlp

# (offset -4)
movl (fp), %eax
movl push(%eax), %eax
movl %eax, (R3)

# end emit addrlp

# emit/mov>indiru4(addrlp4(v))

# emit indiru

movl (R3), %eax
movl (on), %edx
# select data %eax %edx
movl %eax, (data_p)
movl sel_data(,%edx,4), %eax
# end select data
movl (%eax), %eax
movl %eax, (R3)

# end emit indiru

# emit/mov>asgnu4(vregp(3),indiru4(addrlp4(v)))

# emit asgnu


# (emit vreg asgn)


# end emit asgnu

# emit/mov>indiru4(vregp(3))

# emit/mov>cnstu4(65)
movl $65, (R2)
# emit/mov>ltu4(indiru4(vregp(3)),cnstu4(65))

# emit ltu

movl (R3), %eax
cmpl (R2), %eax
jb .LCI16

# end emit ltu

# emit/mov>indiru4(vregp(3))

# emit/mov>cnstu4(90)
movl $90, (R2)
# emit/mov>gtu4(indiru4(vregp(3)),cnstu4(90))

# emit gtu

movl (R3), %eax
cmpl (R2), %eax
ja .LCI16

# end emit gtu

# emit/mov>cnstu4(65)
movl $65, (R3)
# emit/mov>asgnu4(vregp(4),cnstu4(65))

# emit asgnu


# (emit vreg asgn)


# end emit asgnu

# emit/mov>indiru4(vregp(4))

# emit/mov>addrlp4(v)

# emit addrlp

# (offset -4)
movl (fp), %eax
movl push(%eax), %eax
movl %eax, (R2)

# end emit addrlp

# emit/mov>indiru4(addrlp4(v))

# emit indiru

movl (R2), %eax
movl (on), %edx
# select data %eax %edx
movl %eax, (data_p)
movl sel_data(,%edx,4), %eax
# end select data
movl (%eax), %eax
movl %eax, (R2)

# end emit indiru

# emit/mov>indiru4(vregp(4))

# emit/mov>subu4(indiru4(addrlp4(v)),indiru4(vregp(4)))

# emit subu

movl (R2), %eax
movl (R3), %edx
# alu_sub
movl %eax, (alu_x)
movl %edx, (alu_y)
# alu_sub32
movl $0, %eax
movl $0, %ecx
movl $0x1, (alu_c)
# alu_sub16_fast
movw (alu_x+0), %ax
movw (alu_y+0), %cx
movw alu_inv16(,%ecx,2), %cx
movl alu_add16(,%eax,4), %edx
movl (%edx,%ecx,4), %edx
movl alu_add16(,%edx,4), %edx
movl (alu_c), %ecx
movl (%edx,%ecx,4), %edx
movw %dx, (alu_s+0)
movl %edx, (alu_c-2)
# end alu_sub16_fast
# alu_sub16_fast
movw (alu_x+2), %ax
movw (alu_y+2), %cx
movw alu_inv16(,%ecx,2), %cx
movl alu_add16(,%eax,4), %edx
movl (%edx,%ecx,4), %edx
movl alu_add16(,%edx,4), %edx
movl (alu_c), %ecx
movl (%edx,%ecx,4), %edx
movw %dx, (alu_s+2)
movl %edx, (alu_c-2)
# end alu_sub16_fast
# end alu_sub32
movl (alu_s), %eax
# end alu_sub
movl %eax, (R2)

# end emit subu

# emit/mov>cnstu4(13)
movl $13, (R1)
# emit/mov>addu4(subu4(indiru4(addrlp4(v)),indiru4(vregp(4))),cnstu4(13))

# emit addu

movl (R2), %eax
movl (R1), %edx
# alu_add
movl %eax, (alu_x)
movl %edx, (alu_y)
# alu_add32
movl $0, %eax
movl $0, %ecx
movl $0, (alu_c)
# alu_add16_fast
movw (alu_x+0), %ax
movw (alu_y+0), %cx
movl alu_add16(,%eax,4), %edx
movl (%edx,%ecx,4), %edx
movw (alu_c+2), %cx
movl alu_add16(,%edx,4), %edx
movl (%edx,%ecx,4), %edx
movw %dx, (alu_s+0)
movl %edx, (alu_c)
# end alu_add16_fast
# alu_add16_fast
movw (alu_x+2), %ax
movw (alu_y+2), %cx
movl alu_add16(,%eax,4), %edx
movl (%edx,%ecx,4), %edx
movw (alu_c+2), %cx
movl alu_add16(,%edx,4), %edx
movl (%edx,%ecx,4), %edx
movw %dx, (alu_s+2)
movl %edx, (alu_c)
# end alu_add16_fast
# end alu_add32
movl (alu_s), %eax
# end alu_add
movl %eax, (R2)

# end emit addu

# emit/mov>cnstu4(26)
movl $26, (R1)
# emit/mov>modu4(addu4(subu4(indiru4(addrlp4(v)),indiru4(vregp(4))),cnstu4(13)),cnstu4(26))

# emit modu

movl (R2), %eax
movl (R1), %edx
# alu_umod
# alu_divrem
movl %eax, (alu_n)
movl %edx, (alu_d)
movl $0, (alu_q)
movl $0, (alu_r)
# alu_bit
movl $0, %edx
movb (alu_n+3), %dl
movl alu_b7(,%edx,4), %eax
movl %eax, (alu_c)
# end alu_bit
# alu_div_shl1_32_c
# alu_div_shl1_8_c
movl $0, %eax
movl $0, %edx
movb (alu_r+0), %al
movb (alu_c), %dl
movl alu_div_shl3_8_d(,%eax,4), %eax
movl alu_div_shl1_8_c_d(%eax,%edx,4), %eax
movb %al, (alu_r+0)
movb %ah, (alu_c)
# end alu_div_shl1_8_c
# alu_div_shl1_8_c
movl $0, %eax
movl $0, %edx
movb (alu_r+1), %al
movb (alu_c), %dl
movl alu_div_shl3_8_d(,%eax,4), %eax
movl alu_div_shl1_8_c_d(%eax,%edx,4), %eax
movb %al, (alu_r+1)
movb %ah, (alu_c)
# end alu_div_shl1_8_c
# alu_div_shl1_8_c
movl $0, %eax
movl $0, %edx
movb (alu_r+2), %al
movb (alu_c), %dl
movl alu_div_shl3_8_d(,%eax,4), %eax
movl alu_div_shl1_8_c_d(%eax,%edx,4), %eax
movb %al, (alu_r+2)
movb %ah, (alu_c)
# end alu_div_shl1_8_c
# alu_div_shl1_8_c
movl $0, %eax
movl $0, %edx
movb (alu_r+3), %al
movb (alu_c), %dl
movl alu_div_shl3_8_d(,%eax,4), %eax
movl alu_div_shl1_8_c_d(%eax,%edx,4), %eax
movb %al, (alu_r+3)
movb %ah, (alu_c)
# end alu_div_shl1_8_c
# end alu_div_shl1_32_c
# alu_div_gte32
movl $0, (alu_c)
movl (alu_r), %eax
movl %eax, (alu_x)
movl (alu_d), %eax
movl %eax, (alu_y)
# alu_sub32
movl $0, %eax
movl $0, %ecx
movl $0x1, (alu_c)
# alu_sub16_fast
movw (alu_x+0), %ax
movw (alu_y+0), %cx
movw alu_inv16(,%ecx,2), %cx
movl alu_add16(,%eax,4), %edx
movl (%edx,%ecx,4), %edx
movl alu_add16(,%edx,4), %edx
movl (alu_c), %ecx
movl (%edx,%ecx,4), %edx
movw %dx, (alu_t+0)
movl %edx, (alu_c-2)
# end alu_sub16_fast
# alu_sub16_fast
movw (alu_x+2), %ax
movw (alu_y+2), %cx
movw alu_inv16(,%ecx,2), %cx
movl alu_add16(,%eax,4), %edx
movl (%edx,%ecx,4), %edx
movl alu_add16(,%edx,4), %edx
movl (alu_c), %ecx
movl (%edx,%ecx,4), %edx
movw %dx, (alu_t+2)
movl %edx, (alu_c-2)
# end alu_sub16_fast
# end alu_sub32
movl $0, %eax
movb (alu_c), %al
movb alu_true(%eax), %al
movl %eax, (alu_t)
# end alu_div_gte32
movl (alu_t), %eax
movl alu_sel_r(,%eax,4), %edx
movl %edx, (alu_psel_r)
movl alu_sel_q(,%eax,4), %edx
movl %edx, (alu_psel_q)
movl (alu_psel_r), %eax
movl (%eax), %eax
movl %eax, (alu_sr)
movl (alu_sr), %eax
movl %eax, (alu_x)
movl (alu_d), %eax
movl %eax, (alu_y)
# alu_sub32
movl $0, %eax
movl $0, %ecx
movl $0x1, (alu_c)
# alu_sub16_fast
movw (alu_x+0), %ax
movw (alu_y+0), %cx
movw alu_inv16(,%ecx,2), %cx
movl alu_add16(,%eax,4), %edx
movl (%edx,%ecx,4), %edx
movl alu_add16(,%edx,4), %edx
movl (alu_c), %ecx
movl (%edx,%ecx,4), %edx
movw %dx, (alu_sr+0)
movl %edx, (alu_c-2)
# end alu_sub16_fast
# alu_sub16_fast
movw (alu_x+2), %ax
movw (alu_y+2), %cx
movw alu_inv16(,%ecx,2), %cx
movl alu_add16(,%eax,4), %edx
movl (%edx,%ecx,4), %edx
movl alu_add16(,%edx,4), %edx
movl (alu_c), %ecx
movl (%edx,%ecx,4), %edx
movw %dx, (alu_sr+2)
movl %edx, (alu_c-2)
# end alu_sub16_fast
# end alu_sub32
movl (alu_psel_r), %eax
movl (alu_sr), %edx
movl %edx, (%eax)
movl (alu_psel_q), %eax
movl (%eax), %eax
movl %eax, (alu_sq)
# alu_div_setb32
movl $0, %eax
movb (alu_sq+3), %al
movb alu_b_s_7(%eax), %al
movb %al, (alu_sq+3)
# end alu_div_setb32
movl (alu_psel_q), %eax
movl (alu_sq), %edx
movl %edx, (%eax)
# alu_bit
movl $0, %edx
movb (alu_n+3), %dl
movl alu_b6(,%edx,4), %eax
movl %eax, (alu_c)
# end alu_bit
# alu_div_shl1_32_c
# alu_div_shl1_8_c
movl $0, %eax
movl $0, %edx
movb (alu_r+0), %al
movb (alu_c), %dl
movl alu_div_shl3_8_d(,%eax,4), %eax
movl alu_div_shl1_8_c_d(%eax,%edx,4), %eax
movb %al, (alu_r+0)
movb %ah, (alu_c)
# end alu_div_shl1_8_c
# alu_div_shl1_8_c
movl $0, %eax
movl $0, %edx
movb (alu_r+1), %al
movb (alu_c), %dl
movl alu_div_shl3_8_d(,%eax,4), %eax
movl alu_div_shl1_8_c_d(%eax,%edx,4), %eax
movb %al, (alu_r+1)
movb %ah, (alu_c)
# end alu_div_shl1_8_c
# alu_div_shl1_8_c
movl $0, %eax
movl $0, %edx
movb (alu_r+2), %al
movb (alu_c), %dl
movl alu_div_shl3_8_d(,%eax,4), %eax
movl alu_div_shl1_8_c_d(%eax,%edx,4), %eax
movb %al, (alu_r+2)
movb %ah, (alu_c)
# end alu_div_shl1_8_c
# alu_div_shl1_8_c
movl $0, %eax
movl $0, %edx
movb (alu_r+3), %al
movb (alu_c), %dl
movl alu_div_shl3_8_d(,%eax,4), %eax
movl alu_div_shl1_8_c_d(%eax,%edx,4), %eax
movb %al, (alu_r+3)
movb %ah, (alu_c)
# end alu_div_shl1_8_c
# end alu_div_shl1_32_c
# alu_div_gte32
movl $0, (alu_c)
movl (alu_r), %eax
movl %eax, (alu_x)
movl (alu_d), %eax
movl %eax, (alu_y)
# alu_sub32
movl $0, %eax
movl $0, %ecx
movl $0x1, (alu_c)
# alu_sub16_fast
movw (alu_x+0), %ax
movw (alu_y+0), %cx
movw alu_inv16(,%ecx,2), %cx
movl alu_add16(,%eax,4), %edx
movl (%edx,%ecx,4), %edx
movl alu_add16(,%edx,4), %edx
movl (alu_c), %ecx
movl (%edx,%ecx,4), %edx
movw %dx, (alu_t+0)
movl %edx, (alu_c-2)
# end alu_sub16_fast
# alu_sub16_fast
movw (alu_x+2), %ax
movw (alu_y+2), %cx
movw alu_inv16(,%ecx,2), %cx
movl alu_add16(,%eax,4), %edx
movl (%edx,%ecx,4), %edx
movl alu_add16(,%edx,4), %edx
movl (alu_c), %ecx
movl (%edx,%ecx,4), %edx
movw %dx, (alu_t+2)
movl %edx, (alu_c-2)
# end alu_sub16_fast
# end alu_sub32
movl $0, %eax
movb (alu_c), %al
movb alu_true(%eax), %al
movl %eax, (alu_t)
# end alu_div_gte32
movl (alu_t), %eax
movl alu_sel_r(,%eax,4), %edx
movl %edx, (alu_psel_r)
movl alu_sel_q(,%eax,4), %edx
movl %edx, (alu_psel_q)
movl (alu_psel_r), %eax
movl (%eax), %eax
movl %eax, (alu_sr)
movl (alu_sr), %eax
movl %eax, (alu_x)
movl (alu_d), %eax
movl %eax, (alu_y)
# alu_sub32
movl $0, %eax
movl $0, %ecx
movl $0x1, (alu_c)
# alu_sub16_fast
movw (alu_x+0), %ax
movw (alu_y+0), %cx
movw alu_inv16(,%ecx,2), %cx
movl alu_add16(,%eax,4), %edx
movl (%edx,%ecx,4), %edx
movl alu_add16(,%edx,4), %edx
movl (alu_c), %ecx
movl (%edx,%ecx,4), %edx
movw %dx, (alu_sr+0)
movl %edx, (alu_c-2)
# end alu_sub16_fast
# alu_sub16_fast
movw (alu_x+2), %ax
movw (alu_y+2), %cx
movw alu_inv16(,%ecx,2), %cx
movl alu_add16(,%eax,4), %edx
movl (%edx,%ecx,4), %edx
movl alu_add16(,%edx,4), %edx
movl (alu_c), %ecx
movl (%edx,%ecx,4), %edx
movw %dx, (alu_sr+2)
movl %edx, (alu_c-2)
# end alu_sub16_fast
# end alu_sub32
movl (alu_psel_r), %eax
movl (alu_sr), %edx
movl %edx, (%eax)
movl (alu_psel_q), %eax
movl (%eax), %eax
movl %eax, (alu_sq)
# alu_div_setb32
movl $0, %eax
movb (alu_sq+3), %al
movb alu_b_s_6(%eax), %al
movb %al, (alu_sq+3)
# end alu_div_setb32
movl (alu_psel_q), %eax
movl (alu_sq), %edx
movl %edx, (%eax)
# alu_bit
movl $0, %edx
movb (alu_n+3), %dl
movl alu_b5(,%edx,4), %eax
movl %eax, (alu_c)
# end alu_bit
# alu_div_shl1_32_c
# alu_div_shl1_8_c
movl $0, %eax
movl $0, %edx
movb (alu_r+0), %al
movb (alu_c), %dl
movl alu_div_shl3_8_d(,%eax,4), %eax
movl alu_div_shl1_8_c_d(%eax,%edx,4), %eax
movb %al, (alu_r+0)
movb %ah, (alu_c)
# end alu_div_shl1_8_c
# alu_div_shl1_8_c
movl $0, %eax
movl $0, %edx
movb (alu_r+1), %al
movb (alu_c), %dl
movl alu_div_shl3_8_d(,%eax,4), %eax
movl alu_div_shl1_8_c_d(%eax,%edx,4), %eax
movb %al, (alu_r+1)
movb %ah, (alu_c)
# end alu_div_shl1_8_c
# alu_div_shl1_8_c
movl $0, %eax
movl $0, %edx
movb (alu_r+2), %al
movb (alu_c), %dl
movl alu_div_shl3_8_d(,%eax,4), %eax
movl alu_div_shl1_8_c_d(%eax,%edx,4), %eax
movb %al, (alu_r+2)
movb %ah, (alu_c)
# end alu_div_shl1_8_c
# alu_div_shl1_8_c
movl $0, %eax
movl $0, %edx
movb (alu_r+3), %al
movb (alu_c), %dl
movl alu_div_shl3_8_d(,%eax,4), %eax
movl alu_div_shl1_8_c_d(%eax,%edx,4), %eax
movb %al, (alu_r+3)
movb %ah, (alu_c)
# end alu_div_shl1_8_c
# end alu_div_shl1_32_c
# alu_div_gte32
movl $0, (alu_c)
movl (alu_r), %eax
movl %eax, (alu_x)
movl (alu_d), %eax
movl %eax, (alu_y)
# alu_sub32
movl $0, %eax
movl $0, %ecx
movl $0x1, (alu_c)
# alu_sub16_fast
movw (alu_x+0), %ax
movw (alu_y+0), %cx
movw alu_inv16(,%ecx,2), %cx
movl alu_add16(,%eax,4), %edx
movl (%edx,%ecx,4), %edx
movl alu_add16(,%edx,4), %edx
movl (alu_c), %ecx
movl (%edx,%ecx,4), %edx
movw %dx, (alu_t+0)
movl %edx, (alu_c-2)
# end alu_sub16_fast
# alu_sub16_fast
movw (alu_x+2), %ax
movw (alu_y+2), %cx
movw alu_inv16(,%ecx,2), %cx
movl alu_add16(,%eax,4), %edx
movl (%edx,%ecx,4), %edx
movl alu_add16(,%edx,4), %edx
movl (alu_c), %ecx
movl (%edx,%ecx,4), %edx
movw %dx, (alu_t+2)
movl %edx, (alu_c-2)
# end alu_sub16_fast
# end alu_sub32
movl $0, %eax
movb (alu_c), %al
movb alu_true(%eax), %al
movl %eax, (alu_t)
# end alu_div_gte32
movl (alu_t), %eax
movl alu_sel_r(,%eax,4), %edx
movl %edx, (alu_psel_r)
movl alu_sel_q(,%eax,4), %edx
movl %edx, (alu_psel_q)
movl (alu_psel_r), %eax
movl (%eax), %eax
movl %eax, (alu_sr)
movl (alu_sr), %eax
movl %eax, (alu_x)
movl (alu_d), %eax
movl %eax, (alu_y)
# alu_sub32
movl $0, %eax
movl $0, %ecx
movl $0x1, (alu_c)
# alu_sub16_fast
movw (alu_x+0), %ax
movw (alu_y+0), %cx
movw alu_inv16(,%ecx,2), %cx
movl alu_add16(,%eax,4), %edx
movl (%edx,%ecx,4), %edx
movl alu_add16(,%edx,4), %edx
movl (alu_c), %ecx
movl (%edx,%ecx,4), %edx
movw %dx, (alu_sr+0)
movl %edx, (alu_c-2)
# end alu_sub16_fast
# alu_sub16_fast
movw (alu_x+2), %ax
movw (alu_y+2), %cx
movw alu_inv16(,%ecx,2), %cx
movl alu_add16(,%eax,4), %edx
movl (%edx,%ecx,4), %edx
movl alu_add16(,%edx,4), %edx
movl (alu_c), %ecx
movl (%edx,%ecx,4), %edx
movw %dx, (alu_sr+2)
movl %edx, (alu_c-2)
# end alu_sub16_fast
# end alu_sub32
movl (alu_psel_r), %eax
movl (alu_sr), %edx
movl %edx, (%eax)
movl (alu_psel_q), %eax
movl (%eax), %eax
movl %eax, (alu_sq)
# alu_div_setb32
movl $0, %eax
movb (alu_sq+3), %al
movb alu_b_s_5(%eax), %al
movb %al, (alu_sq+3)
# end alu_div_setb32
movl (alu_psel_q), %eax
movl (alu_sq), %edx
movl %edx, (%eax)
# alu_bit
movl $0, %edx
movb (alu_n+3), %dl
movl alu_b4(,%edx,4), %eax
movl %eax, (alu_c)
# end alu_bit
# alu_div_shl1_32_c
# alu_div_shl1_8_c
movl $0, %eax
movl $0, %edx
movb (alu_r+0), %al
movb (alu_c), %dl
movl alu_div_shl3_8_d(,%eax,4), %eax
movl alu_div_shl1_8_c_d(%eax,%edx,4), %eax
movb %al, (alu_r+0)
movb %ah, (alu_c)
# end alu_div_shl1_8_c
# alu_div_shl1_8_c
movl $0, %eax
movl $0, %edx
movb (alu_r+1), %al
movb (alu_c), %dl
movl alu_div_shl3_8_d(,%eax,4), %eax
movl alu_div_shl1_8_c_d(%eax,%edx,4), %eax
movb %al, (alu_r+1)
movb %ah, (alu_c)
# end alu_div_shl1_8_c
# alu_div_shl1_8_c
movl $0, %eax
movl $0, %edx
movb (alu_r+2), %al
movb (alu_c), %dl
movl alu_div_shl3_8_d(,%eax,4), %eax
movl alu_div_shl1_8_c_d(%eax,%edx,4), %eax
movb %al, (alu_r+2)
movb %ah, (alu_c)
# end alu_div_shl1_8_c
# alu_div_shl1_8_c
movl $0, %eax
movl $0, %edx
movb (alu_r+3), %al
movb (alu_c), %dl
movl alu_div_shl3_8_d(,%eax,4), %eax
movl alu_div_shl1_8_c_d(%eax,%edx,4), %eax
movb %al, (alu_r+3)
movb %ah, (alu_c)
# end alu_div_shl1_8_c
# end alu_div_shl1_32_c
# alu_div_gte32
movl $0, (alu_c)
movl (alu_r), %eax
movl %eax, (alu_x)
movl (alu_d), %eax
movl %eax, (alu_y)
# alu_sub32
movl $0, %eax
movl $0, %ecx
movl $0x1, (alu_c)
# alu_sub16_fast
movw (alu_x+0), %ax
movw (alu_y+0), %cx
movw alu_inv16(,%ecx,2), %cx
movl alu_add16(,%eax,4), %edx
movl (%edx,%ecx,4), %edx
movl alu_add16(,%edx,4), %edx
movl (alu_c), %ecx
movl (%edx,%ecx,4), %edx
movw %dx, (alu_t+0)
movl %edx, (alu_c-2)
# end alu_sub16_fast
# alu_sub16_fast
movw (alu_x+2), %ax
movw (alu_y+2), %cx
movw alu_inv16(,%ecx,2), %cx
movl alu_add16(,%eax,4), %edx
movl (%edx,%ecx,4), %edx
movl alu_add16(,%edx,4), %edx
movl (alu_c), %ecx
movl (%edx,%ecx,4), %edx
movw %dx, (alu_t+2)
movl %edx, (alu_c-2)
# end alu_sub16_fast
# end alu_sub32
movl $0, %eax
movb (alu_c), %al
movb alu_true(%eax), %al
movl %eax, (alu_t)
# end alu_div_gte32
movl (alu_t), %eax
movl alu_sel_r(,%eax,4), %edx
movl %edx, (alu_psel_r)
movl alu_sel_q(,%eax,4), %edx
movl %edx, (alu_psel_q)
movl (alu_psel_r), %eax
movl (%eax), %eax
movl %eax, (alu_sr)
movl (alu_sr), %eax
movl %eax, (alu_x)
movl (alu_d), %eax
movl %eax, (alu_y)
# alu_sub32
movl $0, %eax
movl $0, %ecx
movl $0x1, (alu_c)
# alu_sub16_fast
movw (alu_x+0), %ax
movw (alu_y+0), %cx
movw alu_inv16(,%ecx,2), %cx
movl alu_add16(,%eax,4), %edx
movl (%edx,%ecx,4), %edx
movl alu_add16(,%edx,4), %edx
movl (alu_c), %ecx
movl (%edx,%ecx,4), %edx
movw %dx, (alu_sr+0)
movl %edx, (alu_c-2)
# end alu_sub16_fast
# alu_sub16_fast
movw (alu_x+2), %ax
movw (alu_y+2), %cx
movw alu_inv16(,%ecx,2), %cx
movl alu_add16(,%eax,4), %edx
movl (%edx,%ecx,4), %edx
movl alu_add16(,%edx,4), %edx
movl (alu_c), %ecx
movl (%edx,%ecx,4), %edx
movw %dx, (alu_sr+2)
movl %edx, (alu_c-2)
# end alu_sub16_fast
# end alu_sub32
movl (alu_psel_r), %eax
movl (alu_sr), %edx
movl %edx, (%eax)
movl (alu_psel_q), %eax
movl (%eax), %eax
movl %eax, (alu_sq)
# alu_div_setb32
movl $0, %eax
movb (alu_sq+3), %al
movb alu_b_s_4(%eax), %al
movb %al, (alu_sq+3)
# end alu_div_setb32
movl (alu_psel_q), %eax
movl (alu_sq), %edx
movl %edx, (%eax)
# alu_bit
movl $0, %edx
movb (alu_n+3), %dl
movl alu_b3(,%edx,4), %eax
movl %eax, (alu_c)
# end alu_bit
# alu_div_shl1_32_c
# alu_div_shl1_8_c
movl $0, %eax
movl $0, %edx
movb (alu_r+0), %al
movb (alu_c), %dl
movl alu_div_shl3_8_d(,%eax,4), %eax
movl alu_div_shl1_8_c_d(%eax,%edx,4), %eax
movb %al, (alu_r+0)
movb %ah, (alu_c)
# end alu_div_shl1_8_c
# alu_div_shl1_8_c
movl $0, %eax
movl $0, %edx
movb (alu_r+1), %al
movb (alu_c), %dl
movl alu_div_shl3_8_d(,%eax,4), %eax
movl alu_div_shl1_8_c_d(%eax,%edx,4), %eax
movb %al, (alu_r+1)
movb %ah, (alu_c)
# end alu_div_shl1_8_c
# alu_div_shl1_8_c
movl $0, %eax
movl $0, %edx
movb (alu_r+2), %al
movb (alu_c), %dl
movl alu_div_shl3_8_d(,%eax,4), %eax
movl alu_div_shl1_8_c_d(%eax,%edx,4), %eax
movb %al, (alu_r+2)
movb %ah, (alu_c)
# end alu_div_shl1_8_c
# alu_div_shl1_8_c
movl $0, %eax
movl $0, %edx
movb (alu_r+3), %al
movb (alu_c), %dl
movl alu_div_shl3_8_d(,%eax,4), %eax
movl alu_div_shl1_8_c_d(%eax,%edx,4), %eax
movb %al, (alu_r+3)
movb %ah, (alu_c)
# end alu_div_shl1_8_c
# end alu_div_shl1_32_c
# alu_div_gte32
movl $0, (alu_c)
movl (alu_r), %eax
movl %eax, (alu_x)
movl (alu_d), %eax
movl %eax, (alu_y)
# alu_sub32
movl $0, %eax
movl $0, %ecx
movl $0x1, (alu_c)
# alu_sub16_fast
movw (alu_x+0), %ax
movw (alu_y+0), %cx
movw alu_inv16(,%ecx,2), %cx
movl alu_add16(,%eax,4), %edx
movl (%edx,%ecx,4), %edx
movl alu_add16(,%edx,4), %edx
movl (alu_c), %ecx
movl (%edx,%ecx,4), %edx
movw %dx, (alu_t+0)
movl %edx, (alu_c-2)
# end alu_sub16_fast
# alu_sub16_fast
movw (alu_x+2), %ax
movw (alu_y+2), %cx
movw alu_inv16(,%ecx,2), %cx
movl alu_add16(,%eax,4), %edx
movl (%edx,%ecx,4), %edx
movl alu_add16(,%edx,4), %edx
movl (alu_c), %ecx
movl (%edx,%ecx,4), %edx
movw %dx, (alu_t+2)
movl %edx, (alu_c-2)
# end alu_sub16_fast
# end alu_sub32
movl $0, %eax
movb (alu_c), %al
movb alu_true(%eax), %al
movl %eax, (alu_t)
# end alu_div_gte32
movl (alu_t), %eax
movl alu_sel_r(,%eax,4), %edx
movl %edx, (alu_psel_r)
movl alu_sel_q(,%eax,4), %edx
movl %edx, (alu_psel_q)
movl (alu_psel_r), %eax
movl (%eax), %eax
movl %eax, (alu_sr)
movl (alu_sr), %eax
movl %eax, (alu_x)
movl (alu_d), %eax
movl %eax, (alu_y)
# alu_sub32
movl $0, %eax
movl $0, %ecx
movl $0x1, (alu_c)
# alu_sub16_fast
movw (alu_x+0), %ax
movw (alu_y+0), %cx
movw alu_inv16(,%ecx,2), %cx
movl alu_add16(,%eax,4), %edx
movl (%edx,%ecx,4), %edx
movl alu_add16(,%edx,4), %edx
movl (alu_c), %ecx
movl (%edx,%ecx,4), %edx
movw %dx, (alu_sr+0)
movl %edx, (alu_c-2)
# end alu_sub16_fast
# alu_sub16_fast
movw (alu_x+2), %ax
movw (alu_y+2), %cx
movw alu_inv16(,%ecx,2), %cx
movl alu_add16(,%eax,4), %edx
movl (%edx,%ecx,4), %edx
movl alu_add16(,%edx,4), %edx
movl (alu_c), %ecx
movl (%edx,%ecx,4), %edx
movw %dx, (alu_sr+2)
movl %edx, (alu_c-2)
# end alu_sub16_fast
# end alu_sub32
movl (alu_psel_r), %eax
movl (alu_sr), %edx
movl %edx, (%eax)
movl (alu_psel_q), %eax
movl (%eax), %eax
movl %eax, (alu_sq)
# alu_div_setb32
movl $0, %eax
movb (alu_sq+3), %al
movb alu_b_s_3(%eax), %al
movb %al, (alu_sq+3)
# end alu_div_setb32
movl (alu_psel_q), %eax
movl (alu_sq), %edx
movl %edx, (%eax)
# alu_bit
movl $0, %edx
movb (alu_n+3), %dl
movl alu_b2(,%edx,4), %eax
movl %eax, (alu_c)
# end alu_bit
# alu_div_shl1_32_c
# alu_div_shl1_8_c
movl $0, %eax
movl $0, %edx
movb (alu_r+0), %al
movb (alu_c), %dl
movl alu_div_shl3_8_d(,%eax,4), %eax
movl alu_div_shl1_8_c_d(%eax,%edx,4), %eax
movb %al, (alu_r+0)
movb %ah, (alu_c)
# end alu_div_shl1_8_c
# alu_div_shl1_8_c
movl $0, %eax
movl $0, %edx
movb (alu_r+1), %al
movb (alu_c), %dl
movl alu_div_shl3_8_d(,%eax,4), %eax
movl alu_div_shl1_8_c_d(%eax,%edx,4), %eax
movb %al, (alu_r+1)
movb %ah, (alu_c)
# end alu_div_shl1_8_c
# alu_div_shl1_8_c
movl $0, %eax
movl $0, %edx
movb (alu_r+2), %al
movb (alu_c), %dl
movl alu_div_shl3_8_d(,%eax,4), %eax
movl alu_div_shl1_8_c_d(%eax,%edx,4), %eax
movb %al, (alu_r+2)
movb %ah, (alu_c)
# end alu_div_shl1_8_c
# alu_div_shl1_8_c
movl $0, %eax
movl $0, %edx
movb (alu_r+3), %al
movb (alu_c), %dl
movl alu_div_shl3_8_d(,%eax,4), %eax
movl alu_div_shl1_8_c_d(%eax,%edx,4), %eax
movb %al, (alu_r+3)
movb %ah, (alu_c)
# end alu_div_shl1_8_c
# end alu_div_shl1_32_c
# alu_div_gte32
movl $0, (alu_c)
movl (alu_r), %eax
movl %eax, (alu_x)
movl (alu_d), %eax
movl %eax, (alu_y)
# alu_sub32
movl $0, %eax
movl $0, %ecx
movl $0x1, (alu_c)
# alu_sub16_fast
movw (alu_x+0), %ax
movw (alu_y+0), %cx
movw alu_inv16(,%ecx,2), %cx
movl alu_add16(,%eax,4), %edx
movl (%edx,%ecx,4), %edx
movl alu_add16(,%edx,4), %edx
movl (alu_c), %ecx
movl (%edx,%ecx,4), %edx
movw %dx, (alu_t+0)
movl %edx, (alu_c-2)
# end alu_sub16_fast
# alu_sub16_fast
movw (alu_x+2), %ax
movw (alu_y+2), %cx
movw alu_inv16(,%ecx,2), %cx
movl alu_add16(,%eax,4), %edx
movl (%edx,%ecx,4), %edx
movl alu_add16(,%edx,4), %edx
movl (alu_c), %ecx
movl (%edx,%ecx,4), %edx
movw %dx, (alu_t+2)
movl %edx, (alu_c-2)
# end alu_sub16_fast
# end alu_sub32
movl $0, %eax
movb (alu_c), %al
movb alu_true(%eax), %al
movl %eax, (alu_t)
# end alu_div_gte32
movl (alu_t), %eax
movl alu_sel_r(,%eax,4), %edx
movl %edx, (alu_psel_r)
movl alu_sel_q(,%eax,4), %edx
movl %edx, (alu_psel_q)
movl (alu_psel_r), %eax
movl (%eax), %eax
movl %eax, (alu_sr)
movl (alu_sr), %eax
movl %eax, (alu_x)
movl (alu_d), %eax
movl %eax, (alu_y)
# alu_sub32
movl $0, %eax
movl $0, %ecx
movl $0x1, (alu_c)
# alu_sub16_fast
movw (alu_x+0), %ax
movw (alu_y+0), %cx
movw alu_inv16(,%ecx,2), %cx
movl alu_add16(,%eax,4), %edx
movl (%edx,%ecx,4), %edx
movl alu_add16(,%edx,4), %edx
movl (alu_c), %ecx
movl (%edx,%ecx,4), %edx
movw %dx, (alu_sr+0)
movl %edx, (alu_c-2)
# end alu_sub16_fast
# alu_sub16_fast
movw (alu_x+2), %ax
movw (alu_y+2), %cx
movw alu_inv16(,%ecx,2), %cx
movl alu_add16(,%eax,4), %edx
movl (%edx,%ecx,4), %edx
movl alu_add16(,%edx,4), %edx
movl (alu_c), %ecx
movl (%edx,%ecx,4), %edx
movw %dx, (alu_sr+2)
movl %edx, (alu_c-2)
# end alu_sub16_fast
# end alu_sub32
movl (alu_psel_r), %eax
movl (alu_sr), %edx
movl %edx, (%eax)
movl (alu_psel_q), %eax
movl (%eax), %eax
movl %eax, (alu_sq)
# alu_div_setb32
movl $0, %eax
movb (alu_sq+3), %al
movb alu_b_s_2(%eax), %al
movb %al, (alu_sq+3)
# end alu_div_setb32
movl (alu_psel_q), %eax
movl (alu_sq), %edx
movl %edx, (%eax)
# alu_bit
movl $0, %edx
movb (alu_n+3), %dl
movl alu_b1(,%edx,4), %eax
movl %eax, (alu_c)
# end alu_bit
# alu_div_shl1_32_c
# alu_div_shl1_8_c
movl $0, %eax
movl $0, %edx
movb (alu_r+0), %al
movb (alu_c), %dl
movl alu_div_shl3_8_d(,%eax,4), %eax
movl alu_div_shl1_8_c_d(%eax,%edx,4), %eax
movb %al, (alu_r+0)
movb %ah, (alu_c)
# end alu_div_shl1_8_c
# alu_div_shl1_8_c
movl $0, %eax
movl $0, %edx
movb (alu_r+1), %al
movb (alu_c), %dl
movl alu_div_shl3_8_d(,%eax,4), %eax
movl alu_div_shl1_8_c_d(%eax,%edx,4), %eax
movb %al, (alu_r+1)
movb %ah, (alu_c)
# end alu_div_shl1_8_c
# alu_div_shl1_8_c
movl $0, %eax
movl $0, %edx
movb (alu_r+2), %al
movb (alu_c), %dl
movl alu_div_shl3_8_d(,%eax,4), %eax
movl alu_div_shl1_8_c_d(%eax,%edx,4), %eax
movb %al, (alu_r+2)
movb %ah, (alu_c)
# end alu_div_shl1_8_c
# alu_div_shl1_8_c
movl $0, %eax
movl $0, %edx
movb (alu_r+3), %al
movb (alu_c), %dl
movl alu_div_shl3_8_d(,%eax,4), %eax
movl alu_div_shl1_8_c_d(%eax,%edx,4), %eax
movb %al, (alu_r+3)
movb %ah, (alu_c)
# end alu_div_shl1_8_c
# end alu_div_shl1_32_c
# alu_div_gte32
movl $0, (alu_c)
movl (alu_r), %eax
movl %eax, (alu_x)
movl (alu_d), %eax
movl %eax, (alu_y)
# alu_sub32
movl $0, %eax
movl $0, %ecx
movl $0x1, (alu_c)
# alu_sub16_fast
movw (alu_x+0), %ax
movw (alu_y+0), %cx
movw alu_inv16(,%ecx,2), %cx
movl alu_add16(,%eax,4), %edx
movl (%edx,%ecx,4), %edx
movl alu_add16(,%edx,4), %edx
movl (alu_c), %ecx
movl (%edx,%ecx,4), %edx
movw %dx, (alu_t+0)
movl %edx, (alu_c-2)
# end alu_sub16_fast
# alu_sub16_fast
movw (alu_x+2), %ax
movw (alu_y+2), %cx
movw alu_inv16(,%ecx,2), %cx
movl alu_add16(,%eax,4), %edx
movl (%edx,%ecx,4), %edx
movl alu_add16(,%edx,4), %edx
movl (alu_c), %ecx
movl (%edx,%ecx,4), %edx
movw %dx, (alu_t+2)
movl %edx, (alu_c-2)
# end alu_sub16_fast
# end alu_sub32
movl $0, %eax
movb (alu_c), %al
movb alu_true(%eax), %al
movl %eax, (alu_t)
# end alu_div_gte32
movl (alu_t), %eax
movl alu_sel_r(,%eax,4), %edx
movl %edx, (alu_psel_r)
movl alu_sel_q(,%eax,4), %edx
movl %edx, (alu_psel_q)
movl (alu_psel_r), %eax
movl (%eax), %eax
movl %eax, (alu_sr)
movl (alu_sr), %eax
movl %eax, (alu_x)
movl (alu_d), %eax
movl %eax, (alu_y)
# alu_sub32
movl $0, %eax
movl $0, %ecx
movl $0x1, (alu_c)
# alu_sub16_fast
movw (alu_x+0), %ax
movw (alu_y+0), %cx
movw alu_inv16(,%ecx,2), %cx
movl alu_add16(,%eax,4), %edx
movl (%edx,%ecx,4), %edx
movl alu_add16(,%edx,4), %edx
movl (alu_c), %ecx
movl (%edx,%ecx,4), %edx
movw %dx, (alu_sr+0)
movl %edx, (alu_c-2)
# end alu_sub16_fast
# alu_sub16_fast
movw (alu_x+2), %ax
movw (alu_y+2), %cx
movw alu_inv16(,%ecx,2), %cx
movl alu_add16(,%eax,4), %edx
movl (%edx,%ecx,4), %edx
movl alu_add16(,%edx,4), %edx
movl (alu_c), %ecx
movl (%edx,%ecx,4), %edx
movw %dx, (alu_sr+2)
movl %edx, (alu_c-2)
# end alu_sub16_fast
# end alu_sub32
movl (alu_psel_r), %eax
movl (alu_sr), %edx
movl %edx, (%eax)
movl (alu_psel_q), %eax
movl (%eax), %eax
movl %eax, (alu_sq)
# alu_div_setb32
movl $0, %eax
movb (alu_sq+3), %al
movb alu_b_s_1(%eax), %al
movb %al, (alu_sq+3)
# end alu_div_setb32
movl (alu_psel_q), %eax
movl (alu_sq), %edx
movl %edx, (%eax)
# alu_bit
movl $0, %edx
movb (alu_n+3), %dl
movl alu_b0(,%edx,4), %eax
movl %eax, (alu_c)
# end alu_bit
# alu_div_shl1_32_c
# alu_div_shl1_8_c
movl $0, %eax
movl $0, %edx
movb (alu_r+0), %al
movb (alu_c), %dl
movl alu_div_shl3_8_d(,%eax,4), %eax
movl alu_div_shl1_8_c_d(%eax,%edx,4), %eax
movb %al, (alu_r+0)
movb %ah, (alu_c)
# end alu_div_shl1_8_c
# alu_div_shl1_8_c
movl $0, %eax
movl $0, %edx
movb (alu_r+1), %al
movb (alu_c), %dl
movl alu_div_shl3_8_d(,%eax,4), %eax
movl alu_div_shl1_8_c_d(%eax,%edx,4), %eax
movb %al, (alu_r+1)
movb %ah, (alu_c)
# end alu_div_shl1_8_c
# alu_div_shl1_8_c
movl $0, %eax
movl $0, %edx
movb (alu_r+2), %al
movb (alu_c), %dl
movl alu_div_shl3_8_d(,%eax,4), %eax
movl alu_div_shl1_8_c_d(%eax,%edx,4), %eax
movb %al, (alu_r+2)
movb %ah, (alu_c)
# end alu_div_shl1_8_c
# alu_div_shl1_8_c
movl $0, %eax
movl $0, %edx
movb (alu_r+3), %al
movb (alu_c), %dl
movl alu_div_shl3_8_d(,%eax,4), %eax
movl alu_div_shl1_8_c_d(%eax,%edx,4), %eax
movb %al, (alu_r+3)
movb %ah, (alu_c)
# end alu_div_shl1_8_c
# end alu_div_shl1_32_c
# alu_div_gte32
movl $0, (alu_c)
movl (alu_r), %eax
movl %eax, (alu_x)
movl (alu_d), %eax
movl %eax, (alu_y)
# alu_sub32
movl $0, %eax
movl $0, %ecx
movl $0x1, (alu_c)
# alu_sub16_fast
movw (alu_x+0), %ax
movw (alu_y+0), %cx
movw alu_inv16(,%ecx,2), %cx
movl alu_add16(,%eax,4), %edx
movl (%edx,%ecx,4), %edx
movl alu_add16(,%edx,4), %edx
movl (alu_c), %ecx
movl (%edx,%ecx,4), %edx
movw %dx, (alu_t+0)
movl %edx, (alu_c-2)
# end alu_sub16_fast
# alu_sub16_fast
movw (alu_x+2), %ax
movw (alu_y+2), %cx
movw alu_inv16(,%ecx,2), %cx
movl alu_add16(,%eax,4), %edx
movl (%edx,%ecx,4), %edx
movl alu_add16(,%edx,4), %edx
movl (alu_c), %ecx
movl (%edx,%ecx,4), %edx
movw %dx, (alu_t+2)
movl %edx, (alu_c-2)
# end alu_sub16_fast
# end alu_sub32
movl $0, %eax
movb (alu_c), %al
movb alu_true(%eax), %al
movl %eax, (alu_t)
# end alu_div_gte32
movl (alu_t), %eax
movl alu_sel_r(,%eax,4), %edx
movl %edx, (alu_psel_r)
movl alu_sel_q(,%eax,4), %edx
movl %edx, (alu_psel_q)
movl (alu_psel_r), %eax
movl (%eax), %eax
movl %eax, (alu_sr)
movl (alu_sr), %eax
movl %eax, (alu_x)
movl (alu_d), %eax
movl %eax, (alu_y)
# alu_sub32
movl $0, %eax
movl $0, %ecx
movl $0x1, (alu_c)
# alu_sub16_fast
movw (alu_x+0), %ax
movw (alu_y+0), %cx
movw alu_inv16(,%ecx,2), %cx
movl alu_add16(,%eax,4), %edx
movl (%edx,%ecx,4), %edx
movl alu_add16(,%edx,4), %edx
movl (alu_c), %ecx
movl (%edx,%ecx,4), %edx
movw %dx, (alu_sr+0)
movl %edx, (alu_c-2)
# end alu_sub16_fast
# alu_sub16_fast
movw (alu_x+2), %ax
movw (alu_y+2), %cx
movw alu_inv16(,%ecx,2), %cx
movl alu_add16(,%eax,4), %edx
movl (%edx,%ecx,4), %edx
movl alu_add16(,%edx,4), %edx
movl (alu_c), %ecx
movl (%edx,%ecx,4), %edx
movw %dx, (alu_sr+2)
movl %edx, (alu_c-2)
# end alu_sub16_fast
# end alu_sub32
movl (alu_psel_r), %eax
movl (alu_sr), %edx
movl %edx, (%eax)
movl (alu_psel_q), %eax
movl (%eax), %eax
movl %eax, (alu_sq)
# alu_div_setb32
movl $0, %eax
movb (alu_sq+3), %al
movb alu_b_s_0(%eax), %al
movb %al, (alu_sq+3)
# end alu_div_setb32
movl (alu_psel_q), %eax
movl (alu_sq), %edx
movl %edx, (%eax)
# alu_bit
movl $0, %edx
movb (alu_n+2), %dl
movl alu_b7(,%edx,4), %eax
movl %eax, (alu_c)
# end alu_bit
# alu_div_shl1_32_c
# alu_div_shl1_8_c
movl $0, %eax
movl $0, %edx
movb (alu_r+0), %al
movb (alu_c), %dl
movl alu_div_shl3_8_d(,%eax,4), %eax
movl alu_div_shl1_8_c_d(%eax,%edx,4), %eax
movb %al, (alu_r+0)
movb %ah, (alu_c)
# end alu_div_shl1_8_c
# alu_div_shl1_8_c
movl $0, %eax
movl $0, %edx
movb (alu_r+1), %al
movb (alu_c), %dl
movl alu_div_shl3_8_d(,%eax,4), %eax
movl alu_div_shl1_8_c_d(%eax,%edx,4), %eax
movb %al, (alu_r+1)
movb %ah, (alu_c)
# end alu_div_shl1_8_c
# alu_div_shl1_8_c
movl $0, %eax
movl $0, %edx
movb (alu_r+2), %al
movb (alu_c), %dl
movl alu_div_shl3_8_d(,%eax,4), %eax
movl alu_div_shl1_8_c_d(%eax,%edx,4), %eax
movb %al, (alu_r+2)
movb %ah, (alu_c)
# end alu_div_shl1_8_c
# alu_div_shl1_8_c
movl $0, %eax
movl $0, %edx
movb (alu_r+3), %al
movb (alu_c), %dl
movl alu_div_shl3_8_d(,%eax,4), %eax
movl alu_div_shl1_8_c_d(%eax,%edx,4), %eax
movb %al, (alu_r+3)
movb %ah, (alu_c)
# end alu_div_shl1_8_c
# end alu_div_shl1_32_c
# alu_div_gte32
movl $0, (alu_c)
movl (alu_r), %eax
movl %eax, (alu_x)
movl (alu_d), %eax
movl %eax, (alu_y)
# alu_sub32
movl $0, %eax
movl $0, %ecx
movl $0x1, (alu_c)
# alu_sub16_fast
movw (alu_x+0), %ax
movw (alu_y+0), %cx
movw alu_inv16(,%ecx,2), %cx
movl alu_add16(,%eax,4), %edx
movl (%edx,%ecx,4), %edx
movl alu_add16(,%edx,4), %edx
movl (alu_c), %ecx
movl (%edx,%ecx,4), %edx
movw %dx, (alu_t+0)
movl %edx, (alu_c-2)
# end alu_sub16_fast
# alu_sub16_fast
movw (alu_x+2), %ax
movw (alu_y+2), %cx
movw alu_inv16(,%ecx,2), %cx
movl alu_add16(,%eax,4), %edx
movl (%edx,%ecx,4), %edx
movl alu_add16(,%edx,4), %edx
movl (alu_c), %ecx
movl (%edx,%ecx,4), %edx
movw %dx, (alu_t+2)
movl %edx, (alu_c-2)
# end alu_sub16_fast
# end alu_sub32
movl $0, %eax
movb (alu_c), %al
movb alu_true(%eax), %al
movl %eax, (alu_t)
# end alu_div_gte32
movl (alu_t), %eax
movl alu_sel_r(,%eax,4), %edx
movl %edx, (alu_psel_r)
movl alu_sel_q(,%eax,4), %edx
movl %edx, (alu_psel_q)
movl (alu_psel_r), %eax
movl (%eax), %eax
movl %eax, (alu_sr)
movl (alu_sr), %eax
movl %eax, (alu_x)
movl (alu_d), %eax
movl %eax, (alu_y)
# alu_sub32
movl $0, %eax
movl $0, %ecx
movl $0x1, (alu_c)
# alu_sub16_fast
movw (alu_x+0), %ax
movw (alu_y+0), %cx
movw alu_inv16(,%ecx,2), %cx
movl alu_add16(,%eax,4), %edx
movl (%edx,%ecx,4), %edx
movl alu_add16(,%edx,4), %edx
movl (alu_c), %ecx
movl (%edx,%ecx,4), %edx
movw %dx, (alu_sr+0)
movl %edx, (alu_c-2)
# end alu_sub16_fast
# alu_sub16_fast
movw (alu_x+2), %ax
movw (alu_y+2), %cx
movw alu_inv16(,%ecx,2), %cx
movl alu_add16(,%eax,4), %edx
movl (%edx,%ecx,4), %edx
movl alu_add16(,%edx,4), %edx
movl (alu_c), %ecx
movl (%edx,%ecx,4), %edx
movw %dx, (alu_sr+2)
movl %edx, (alu_c-2)
# end alu_sub16_fast
# end alu_sub32
movl (alu_psel_r), %eax
movl (alu_sr), %edx
movl %edx, (%eax)
movl (alu_psel_q), %eax
movl (%eax), %eax
movl %eax, (alu_sq)
# alu_div_setb32
movl $0, %eax
movb (alu_sq+2), %al
movb alu_b_s_7(%eax), %al
movb %al, (alu_sq+2)
# end alu_div_setb32
movl (alu_psel_q), %eax
movl (alu_sq), %edx
movl %edx, (%eax)
# alu_bit
movl $0, %edx
movb (alu_n+2), %dl
movl alu_b6(,%edx,4), %eax
movl %eax, (alu_c)
# end alu_bit
# alu_div_shl1_32_c
# alu_div_shl1_8_c
movl $0, %eax
movl $0, %edx
movb (alu_r+0), %al
movb (alu_c), %dl
movl alu_div_shl3_8_d(,%eax,4), %eax
movl alu_div_shl1_8_c_d(%eax,%edx,4), %eax
movb %al, (alu_r+0)
movb %ah, (alu_c)
# end alu_div_shl1_8_c
# alu_div_shl1_8_c
movl $0, %eax
movl $0, %edx
movb (alu_r+1), %al
movb (alu_c), %dl
movl alu_div_shl3_8_d(,%eax,4), %eax
movl alu_div_shl1_8_c_d(%eax,%edx,4), %eax
movb %al, (alu_r+1)
movb %ah, (alu_c)
# end alu_div_shl1_8_c
# alu_div_shl1_8_c
movl $0, %eax
movl $0, %edx
movb (alu_r+2), %al
movb (alu_c), %dl
movl alu_div_shl3_8_d(,%eax,4), %eax
movl alu_div_shl1_8_c_d(%eax,%edx,4), %eax
movb %al, (alu_r+2)
movb %ah, (alu_c)
# end alu_div_shl1_8_c
# alu_div_shl1_8_c
movl $0, %eax
movl $0, %edx
movb (alu_r+3), %al
movb (alu_c), %dl
movl alu_div_shl3_8_d(,%eax,4), %eax
movl alu_div_shl1_8_c_d(%eax,%edx,4), %eax
movb %al, (alu_r+3)
movb %ah, (alu_c)
# end alu_div_shl1_8_c
# end alu_div_shl1_32_c
# alu_div_gte32
movl $0, (alu_c)
movl (alu_r), %eax
movl %eax, (alu_x)
movl (alu_d), %eax
movl %eax, (alu_y)
# alu_sub32
movl $0, %eax
movl $0, %ecx
movl $0x1, (alu_c)
# alu_sub16_fast
movw (alu_x+0), %ax
movw (alu_y+0), %cx
movw alu_inv16(,%ecx,2), %cx
movl alu_add16(,%eax,4), %edx
movl (%edx,%ecx,4), %edx
movl alu_add16(,%edx,4), %edx
movl (alu_c), %ecx
movl (%edx,%ecx,4), %edx
movw %dx, (alu_t+0)
movl %edx, (alu_c-2)
# end alu_sub16_fast
# alu_sub16_fast
movw (alu_x+2), %ax
movw (alu_y+2), %cx
movw alu_inv16(,%ecx,2), %cx
movl alu_add16(,%eax,4), %edx
movl (%edx,%ecx,4), %edx
movl alu_add16(,%edx,4), %edx
movl (alu_c), %ecx
movl (%edx,%ecx,4), %edx
movw %dx, (alu_t+2)
movl %edx, (alu_c-2)
# end alu_sub16_fast
# end alu_sub32
movl $0, %eax
movb (alu_c), %al
movb alu_true(%eax), %al
movl %eax, (alu_t)
# end alu_div_gte32
movl (alu_t), %eax
movl alu_sel_r(,%eax,4), %edx
movl %edx, (alu_psel_r)
movl alu_sel_q(,%eax,4), %edx
movl %edx, (alu_psel_q)
movl (alu_psel_r), %eax
movl (%eax), %eax
movl %eax, (alu_sr)
movl (alu_sr), %eax
movl %eax, (alu_x)
movl (alu_d), %eax
movl %eax, (alu_y)
# alu_sub32
movl $0, %eax
movl $0, %ecx
movl $0x1, (alu_c)
# alu_sub16_fast
movw (alu_x+0), %ax
movw (alu_y+0), %cx
movw alu_inv16(,%ecx,2), %cx
movl alu_add16(,%eax,4), %edx
movl (%edx,%ecx,4), %edx
movl alu_add16(,%edx,4), %edx
movl (alu_c), %ecx
movl (%edx,%ecx,4), %edx
movw %dx, (alu_sr+0)
movl %edx, (alu_c-2)
# end alu_sub16_fast
# alu_sub16_fast
movw (alu_x+2), %ax
movw (alu_y+2), %cx
movw alu_inv16(,%ecx,2), %cx
movl alu_add16(,%eax,4), %edx
movl (%edx,%ecx,4), %edx
movl alu_add16(,%edx,4), %edx
movl (alu_c), %ecx
movl (%edx,%ecx,4), %edx
movw %dx, (alu_sr+2)
movl %edx, (alu_c-2)
# end alu_sub16_fast
# end alu_sub32
movl (alu_psel_r), %eax
movl (alu_sr), %edx
movl %edx, (%eax)
movl (alu_psel_q), %eax
movl (%eax), %eax
movl %eax, (alu_sq)
# alu_div_setb32
movl $0, %eax
movb (alu_sq+2), %al
movb alu_b_s_6(%eax), %al
movb %al, (alu_sq+2)
# end alu_div_setb32
movl (alu_psel_q), %eax
movl (alu_sq), %edx
movl %edx, (%eax)
# alu_bit
movl $0, %edx
movb (alu_n+2), %dl
movl alu_b5(,%edx,4), %eax
movl %eax, (alu_c)
# end alu_bit
# alu_div_shl1_32_c
# alu_div_shl1_8_c
movl $0, %eax
movl $0, %edx
movb (alu_r+0), %al
movb (alu_c), %dl
movl alu_div_shl3_8_d(,%eax,4), %eax
movl alu_div_shl1_8_c_d(%eax,%edx,4), %eax
movb %al, (alu_r+0)
movb %ah, (alu_c)
# end alu_div_shl1_8_c
# alu_div_shl1_8_c
movl $0, %eax
movl $0, %edx
movb (alu_r+1), %al
movb (alu_c), %dl
movl alu_div_shl3_8_d(,%eax,4), %eax
movl alu_div_shl1_8_c_d(%eax,%edx,4), %eax
movb %al, (alu_r+1)
movb %ah, (alu_c)
# end alu_div_shl1_8_c
# alu_div_shl1_8_c
movl $0, %eax
movl $0, %edx
movb (alu_r+2), %al
movb (alu_c), %dl
movl alu_div_shl3_8_d(,%eax,4), %eax
movl alu_div_shl1_8_c_d(%eax,%edx,4), %eax
movb %al, (alu_r+2)
movb %ah, (alu_c)
# end alu_div_shl1_8_c
# alu_div_shl1_8_c
movl $0, %eax
movl $0, %edx
movb (alu_r+3), %al
movb (alu_c), %dl
movl alu_div_shl3_8_d(,%eax,4), %eax
movl alu_div_shl1_8_c_d(%eax,%edx,4), %eax
movb %al, (alu_r+3)
movb %ah, (alu_c)
# end alu_div_shl1_8_c
# end alu_div_shl1_32_c
# alu_div_gte32
movl $0, (alu_c)
movl (alu_r), %eax
movl %eax, (alu_x)
movl (alu_d), %eax
movl %eax, (alu_y)
# alu_sub32
movl $0, %eax
movl $0, %ecx
movl $0x1, (alu_c)
# alu_sub16_fast
movw (alu_x+0), %ax
movw (alu_y+0), %cx
movw alu_inv16(,%ecx,2), %cx
movl alu_add16(,%eax,4), %edx
movl (%edx,%ecx,4), %edx
movl alu_add16(,%edx,4), %edx
movl (alu_c), %ecx
movl (%edx,%ecx,4), %edx
movw %dx, (alu_t+0)
movl %edx, (alu_c-2)
# end alu_sub16_fast
# alu_sub16_fast
movw (alu_x+2), %ax
movw (alu_y+2), %cx
movw alu_inv16(,%ecx,2), %cx
movl alu_add16(,%eax,4), %edx
movl (%edx,%ecx,4), %edx
movl alu_add16(,%edx,4), %edx
movl (alu_c), %ecx
movl (%edx,%ecx,4), %edx
movw %dx, (alu_t+2)
movl %edx, (alu_c-2)
# end alu_sub16_fast
# end alu_sub32
movl $0, %eax
movb (alu_c), %al
movb alu_true(%eax), %al
movl %eax, (alu_t)
# end alu_div_gte32
movl (alu_t), %eax
movl alu_sel_r(,%eax,4), %edx
movl %edx, (alu_psel_r)
movl alu_sel_q(,%eax,4), %edx
movl %edx, (alu_psel_q)
movl (alu_psel_r), %eax
movl (%eax), %eax
movl %eax, (alu_sr)
movl (alu_sr), %eax
movl %eax, (alu_x)
movl (alu_d), %eax
movl %eax, (alu_y)
# alu_sub32
movl $0, %eax
movl $0, %ecx
movl $0x1, (alu_c)
# alu_sub16_fast
movw (alu_x+0), %ax
movw (alu_y+0), %cx
movw alu_inv16(,%ecx,2), %cx
movl alu_add16(,%eax,4), %edx
movl (%edx,%ecx,4), %edx
movl alu_add16(,%edx,4), %edx
movl (alu_c), %ecx
movl (%edx,%ecx,4), %edx
movw %dx, (alu_sr+0)
movl %edx, (alu_c-2)
# end alu_sub16_fast
# alu_sub16_fast
movw (alu_x+2), %ax
movw (alu_y+2), %cx
movw alu_inv16(,%ecx,2), %cx
movl alu_add16(,%eax,4), %edx
movl (%edx,%ecx,4), %edx
movl alu_add16(,%edx,4), %edx
movl (alu_c), %ecx
movl (%edx,%ecx,4), %edx
movw %dx, (alu_sr+2)
movl %edx, (alu_c-2)
# end alu_sub16_fast
# end alu_sub32
movl (alu_psel_r), %eax
movl (alu_sr), %edx
movl %edx, (%eax)
movl (alu_psel_q), %eax
movl (%eax), %eax
movl %eax, (alu_sq)
# alu_div_setb32
movl $0, %eax
movb (alu_sq+2), %al
movb alu_b_s_5(%eax), %al
movb %al, (alu_sq+2)
# end alu_div_setb32
movl (alu_psel_q), %eax
movl (alu_sq), %edx
movl %edx, (%eax)
# alu_bit
movl $0, %edx
movb (alu_n+2), %dl
movl alu_b4(,%edx,4), %eax
movl %eax, (alu_c)
# end alu_bit
# alu_div_shl1_32_c
# alu_div_shl1_8_c
movl $0, %eax
movl $0, %edx
movb (alu_r+0), %al
movb (alu_c), %dl
movl alu_div_shl3_8_d(,%eax,4), %eax
movl alu_div_shl1_8_c_d(%eax,%edx,4), %eax
movb %al, (alu_r+0)
movb %ah, (alu_c)
# end alu_div_shl1_8_c
# alu_div_shl1_8_c
movl $0, %eax
movl $0, %edx
movb (alu_r+1), %al
movb (alu_c), %dl
movl alu_div_shl3_8_d(,%eax,4), %eax
movl alu_div_shl1_8_c_d(%eax,%edx,4), %eax
movb %al, (alu_r+1)
movb %ah, (alu_c)
# end alu_div_shl1_8_c
# alu_div_shl1_8_c
movl $0, %eax
movl $0, %edx
movb (alu_r+2), %al
movb (alu_c), %dl
movl alu_div_shl3_8_d(,%eax,4), %eax
movl alu_div_shl1_8_c_d(%eax,%edx,4), %eax
movb %al, (alu_r+2)
movb %ah, (alu_c)
# end alu_div_shl1_8_c
# alu_div_shl1_8_c
movl $0, %eax
movl $0, %edx
movb (alu_r+3), %al
movb (alu_c), %dl
movl alu_div_shl3_8_d(,%eax,4), %eax
movl alu_div_shl1_8_c_d(%eax,%edx,4), %eax
movb %al, (alu_r+3)
movb %ah, (alu_c)
# end alu_div_shl1_8_c
# end alu_div_shl1_32_c
# alu_div_gte32
movl $0, (alu_c)
movl (alu_r), %eax
movl %eax, (alu_x)
movl (alu_d), %eax
movl %eax, (alu_y)
# alu_sub32
movl $0, %eax
movl $0, %ecx
movl $0x1, (alu_c)
# alu_sub16_fast
movw (alu_x+0), %ax
movw (alu_y+0), %cx
movw alu_inv16(,%ecx,2), %cx
movl alu_add16(,%eax,4), %edx
movl (%edx,%ecx,4), %edx
movl alu_add16(,%edx,4), %edx
movl (alu_c), %ecx
movl (%edx,%ecx,4), %edx
movw %dx, (alu_t+0)
movl %edx, (alu_c-2)
# end alu_sub16_fast
# alu_sub16_fast
movw (alu_x+2), %ax
movw (alu_y+2), %cx
movw alu_inv16(,%ecx,2), %cx
movl alu_add16(,%eax,4), %edx
movl (%edx,%ecx,4), %edx
movl alu_add16(,%edx,4), %edx
movl (alu_c), %ecx
movl (%edx,%ecx,4), %edx
movw %dx, (alu_t+2)
movl %edx, (alu_c-2)
# end alu_sub16_fast
# end alu_sub32
movl $0, %eax
movb (alu_c), %al
movb alu_true(%eax), %al
movl %eax, (alu_t)
# end alu_div_gte32
movl (alu_t), %eax
movl alu_sel_r(,%eax,4), %edx
movl %edx, (alu_psel_r)
movl alu_sel_q(,%eax,4), %edx
movl %edx, (alu_psel_q)
movl (alu_psel_r), %eax
movl (%eax), %eax
movl %eax, (alu_sr)
movl (alu_sr), %eax
movl %eax, (alu_x)
movl (alu_d), %eax
movl %eax, (alu_y)
# alu_sub32
movl $0, %eax
movl $0, %ecx
movl $0x1, (alu_c)
# alu_sub16_fast
movw (alu_x+0), %ax
movw (alu_y+0), %cx
movw alu_inv16(,%ecx,2), %cx
movl alu_add16(,%eax,4), %edx
movl (%edx,%ecx,4), %edx
movl alu_add16(,%edx,4), %edx
movl (alu_c), %ecx
movl (%edx,%ecx,4), %edx
movw %dx, (alu_sr+0)
movl %edx, (alu_c-2)
# end alu_sub16_fast
# alu_sub16_fast
movw (alu_x+2), %ax
movw (alu_y+2), %cx
movw alu_inv16(,%ecx,2), %cx
movl alu_add16(,%eax,4), %edx
movl (%edx,%ecx,4), %edx
movl alu_add16(,%edx,4), %edx
movl (alu_c), %ecx
movl (%edx,%ecx,4), %edx
movw %dx, (alu_sr+2)
movl %edx, (alu_c-2)
# end alu_sub16_fast
# end alu_sub32
movl (alu_psel_r), %eax
movl (alu_sr), %edx
movl %edx, (%eax)
movl (alu_psel_q), %eax
movl (%eax), %eax
movl %eax, (alu_sq)
# alu_div_setb32
movl $0, %eax
movb (alu_sq+2), %al
movb alu_b_s_4(%eax), %al
movb %al, (alu_sq+2)
# end alu_div_setb32
movl (alu_psel_q), %eax
movl (alu_sq), %edx
movl %edx, (%eax)
# alu_bit
movl $0, %edx
movb (alu_n+2), %dl
movl alu_b3(,%edx,4), %eax
movl %eax, (alu_c)
# end alu_bit
# alu_div_shl1_32_c
# alu_div_shl1_8_c
movl $0, %eax
movl $0, %edx
movb (alu_r+0), %al
movb (alu_c), %dl
movl alu_div_shl3_8_d(,%eax,4), %eax
movl alu_div_shl1_8_c_d(%eax,%edx,4), %eax
movb %al, (alu_r+0)
movb %ah, (alu_c)
# end alu_div_shl1_8_c
# alu_div_shl1_8_c
movl $0, %eax
movl $0, %edx
movb (alu_r+1), %al
movb (alu_c), %dl
movl alu_div_shl3_8_d(,%eax,4), %eax
movl alu_div_shl1_8_c_d(%eax,%edx,4), %eax
movb %al, (alu_r+1)
movb %ah, (alu_c)
# end alu_div_shl1_8_c
# alu_div_shl1_8_c
movl $0, %eax
movl $0, %edx
movb (alu_r+2), %al
movb (alu_c), %dl
movl alu_div_shl3_8_d(,%eax,4), %eax
movl alu_div_shl1_8_c_d(%eax,%edx,4), %eax
movb %al, (alu_r+2)
movb %ah, (alu_c)
# end alu_div_shl1_8_c
# alu_div_shl1_8_c
movl $0, %eax
movl $0, %edx
movb (alu_r+3), %al
movb (alu_c), %dl
movl alu_div_shl3_8_d(,%eax,4), %eax
movl alu_div_shl1_8_c_d(%eax,%edx,4), %eax
movb %al, (alu_r+3)
movb %ah, (alu_c)
# end alu_div_shl1_8_c
# end alu_div_shl1_32_c
# alu_div_gte32
movl $0, (alu_c)
movl (alu_r), %eax
movl %eax, (alu_x)
movl (alu_d), %eax
movl %eax, (alu_y)
# alu_sub32
movl $0, %eax
movl $0, %ecx
movl $0x1, (alu_c)
# alu_sub16_fast
movw (alu_x+0), %ax
movw (alu_y+0), %cx
movw alu_inv16(,%ecx,2), %cx
movl alu_add16(,%eax,4), %edx
movl (%edx,%ecx,4), %edx
movl alu_add16(,%edx,4), %edx
movl (alu_c), %ecx
movl (%edx,%ecx,4), %edx
movw %dx, (alu_t+0)
movl %edx, (alu_c-2)
# end alu_sub16_fast
# alu_sub16_fast
movw (alu_x+2), %ax
movw (alu_y+2), %cx
movw alu_inv16(,%ecx,2), %cx
movl alu_add16(,%eax,4), %edx
movl (%edx,%ecx,4), %edx
movl alu_add16(,%edx,4), %edx
movl (alu_c), %ecx
movl (%edx,%ecx,4), %edx
movw %dx, (alu_t+2)
movl %edx, (alu_c-2)
# end alu_sub16_fast
# end alu_sub32
movl $0, %eax
movb (alu_c), %al
movb alu_true(%eax), %al
movl %eax, (alu_t)
# end alu_div_gte32
movl (alu_t), %eax
movl alu_sel_r(,%eax,4), %edx
movl %edx, (alu_psel_r)
movl alu_sel_q(,%eax,4), %edx
movl %edx, (alu_psel_q)
movl (alu_psel_r), %eax
movl (%eax), %eax
movl %eax, (alu_sr)
movl (alu_sr), %eax
movl %eax, (alu_x)
movl (alu_d), %eax
movl %eax, (alu_y)
# alu_sub32
movl $0, %eax
movl $0, %ecx
movl $0x1, (alu_c)
# alu_sub16_fast
movw (alu_x+0), %ax
movw (alu_y+0), %cx
movw alu_inv16(,%ecx,2), %cx
movl alu_add16(,%eax,4), %edx
movl (%edx,%ecx,4), %edx
movl alu_add16(,%edx,4), %edx
movl (alu_c), %ecx
movl (%edx,%ecx,4), %edx
movw %dx, (alu_sr+0)
movl %edx, (alu_c-2)
# end alu_sub16_fast
# alu_sub16_fast
movw (alu_x+2), %ax
movw (alu_y+2), %cx
movw alu_inv16(,%ecx,2), %cx
movl alu_add16(,%eax,4), %edx
movl (%edx,%ecx,4), %edx
movl alu_add16(,%edx,4), %edx
movl (alu_c), %ecx
movl (%edx,%ecx,4), %edx
movw %dx, (alu_sr+2)
movl %edx, (alu_c-2)
# end alu_sub16_fast
# end alu_sub32
movl (alu_psel_r), %eax
movl (alu_sr), %edx
movl %edx, (%eax)
movl (alu_psel_q), %eax
movl (%eax), %eax
movl %eax, (alu_sq)
# alu_div_setb32
movl $0, %eax
movb (alu_sq+2), %al
movb alu_b_s_3(%eax), %al
movb %al, (alu_sq+2)
# end alu_div_setb32
movl (alu_psel_q), %eax
movl (alu_sq), %edx
movl %edx, (%eax)
# alu_bit
movl $0, %edx
movb (alu_n+2), %dl
movl alu_b2(,%edx,4), %eax
movl %eax, (alu_c)
# end alu_bit
# alu_div_shl1_32_c
# alu_div_shl1_8_c
movl $0, %eax
movl $0, %edx
movb (alu_r+0), %al
movb (alu_c), %dl
movl alu_div_shl3_8_d(,%eax,4), %eax
movl alu_div_shl1_8_c_d(%eax,%edx,4), %eax
movb %al, (alu_r+0)
movb %ah, (alu_c)
# end alu_div_shl1_8_c
# alu_div_shl1_8_c
movl $0, %eax
movl $0, %edx
movb (alu_r+1), %al
movb (alu_c), %dl
movl alu_div_shl3_8_d(,%eax,4), %eax
movl alu_div_shl1_8_c_d(%eax,%edx,4), %eax
movb %al, (alu_r+1)
movb %ah, (alu_c)
# end alu_div_shl1_8_c
# alu_div_shl1_8_c
movl $0, %eax
movl $0, %edx
movb (alu_r+2), %al
movb (alu_c), %dl
movl alu_div_shl3_8_d(,%eax,4), %eax
movl alu_div_shl1_8_c_d(%eax,%edx,4), %eax
movb %al, (alu_r+2)
movb %ah, (alu_c)
# end alu_div_shl1_8_c
# alu_div_shl1_8_c
movl $0, %eax
movl $0, %edx
movb (alu_r+3), %al
movb (alu_c), %dl
movl alu_div_shl3_8_d(,%eax,4), %eax
movl alu_div_shl1_8_c_d(%eax,%edx,4), %eax
movb %al, (alu_r+3)
movb %ah, (alu_c)
# end alu_div_shl1_8_c
# end alu_div_shl1_32_c
# alu_div_gte32
movl $0, (alu_c)
movl (alu_r), %eax
movl %eax, (alu_x)
movl (alu_d), %eax
movl %eax, (alu_y)
# alu_sub32
movl $0, %eax
movl $0, %ecx
movl $0x1, (alu_c)
# alu_sub16_fast
movw (alu_x+0), %ax
movw (alu_y+0), %cx
movw alu_inv16(,%ecx,2), %cx
movl alu_add16(,%eax,4), %edx
movl (%edx,%ecx,4), %edx
movl alu_add16(,%edx,4), %edx
movl (alu_c), %ecx
movl (%edx,%ecx,4), %edx
movw %dx, (alu_t+0)
movl %edx, (alu_c-2)
# end alu_sub16_fast
# alu_sub16_fast
movw (alu_x+2), %ax
movw (alu_y+2), %cx
movw alu_inv16(,%ecx,2), %cx
movl alu_add16(,%eax,4), %edx
movl (%edx,%ecx,4), %edx
movl alu_add16(,%edx,4), %edx
movl (alu_c), %ecx
movl (%edx,%ecx,4), %edx
movw %dx, (alu_t+2)
movl %edx, (alu_c-2)
# end alu_sub16_fast
# end alu_sub32
movl $0, %eax
movb (alu_c), %al
movb alu_true(%eax), %al
movl %eax, (alu_t)
# end alu_div_gte32
movl (alu_t), %eax
movl alu_sel_r(,%eax,4), %edx
movl %edx, (alu_psel_r)
movl alu_sel_q(,%eax,4), %edx
movl %edx, (alu_psel_q)
movl (alu_psel_r), %eax
movl (%eax), %eax
movl %eax, (alu_sr)
movl (alu_sr), %eax
movl %eax, (alu_x)
movl (alu_d), %eax
movl %eax, (alu_y)
# alu_sub32
movl $0, %eax
movl $0, %ecx
movl $0x1, (alu_c)
# alu_sub16_fast
movw (alu_x+0), %ax
movw (alu_y+0), %cx
movw alu_inv16(,%ecx,2), %cx
movl alu_add16(,%eax,4), %edx
movl (%edx,%ecx,4), %edx
movl alu_add16(,%edx,4), %edx
movl (alu_c), %ecx
movl (%edx,%ecx,4), %edx
movw %dx, (alu_sr+0)
movl %edx, (alu_c-2)
# end alu_sub16_fast
# alu_sub16_fast
movw (alu_x+2), %ax
movw (alu_y+2), %cx
movw alu_inv16(,%ecx,2), %cx
movl alu_add16(,%eax,4), %edx
movl (%edx,%ecx,4), %edx
movl alu_add16(,%edx,4), %edx
movl (alu_c), %ecx
movl (%edx,%ecx,4), %edx
movw %dx, (alu_sr+2)
movl %edx, (alu_c-2)
# end alu_sub16_fast
# end alu_sub32
movl (alu_psel_r), %eax
movl (alu_sr), %edx
movl %edx, (%eax)
movl (alu_psel_q), %eax
movl (%eax), %eax
movl %eax, (alu_sq)
# alu_div_setb32
movl $0, %eax
movb (alu_sq+2), %al
movb alu_b_s_2(%eax), %al
movb %al, (alu_sq+2)
# end alu_div_setb32
movl (alu_psel_q), %eax
movl (alu_sq), %edx
movl %edx, (%eax)
# alu_bit
movl $0, %edx
movb (alu_n+2), %dl
movl alu_b1(,%edx,4), %eax
movl %eax, (alu_c)
# end alu_bit
# alu_div_shl1_32_c
# alu_div_shl1_8_c
movl $0, %eax
movl $0, %edx
movb (alu_r+0), %al
movb (alu_c), %dl
movl alu_div_shl3_8_d(,%eax,4), %eax
movl alu_div_shl1_8_c_d(%eax,%edx,4), %eax
movb %al, (alu_r+0)
movb %ah, (alu_c)
# end alu_div_shl1_8_c
# alu_div_shl1_8_c
movl $0, %eax
movl $0, %edx
movb (alu_r+1), %al
movb (alu_c), %dl
movl alu_div_shl3_8_d(,%eax,4), %eax
movl alu_div_shl1_8_c_d(%eax,%edx,4), %eax
movb %al, (alu_r+1)
movb %ah, (alu_c)
# end alu_div_shl1_8_c
# alu_div_shl1_8_c
movl $0, %eax
movl $0, %edx
movb (alu_r+2), %al
movb (alu_c), %dl
movl alu_div_shl3_8_d(,%eax,4), %eax
movl alu_div_shl1_8_c_d(%eax,%edx,4), %eax
movb %al, (alu_r+2)
movb %ah, (alu_c)
# end alu_div_shl1_8_c
# alu_div_shl1_8_c
movl $0, %eax
movl $0, %edx
movb (alu_r+3), %al
movb (alu_c), %dl
movl alu_div_shl3_8_d(,%eax,4), %eax
movl alu_div_shl1_8_c_d(%eax,%edx,4), %eax
movb %al, (alu_r+3)
movb %ah, (alu_c)
# end alu_div_shl1_8_c
# end alu_div_shl1_32_c
# alu_div_gte32
movl $0, (alu_c)
movl (alu_r), %eax
movl %eax, (alu_x)
movl (alu_d), %eax
movl %eax, (alu_y)
# alu_sub32
movl $0, %eax
movl $0, %ecx
movl $0x1, (alu_c)
# alu_sub16_fast
movw (alu_x+0), %ax
movw (alu_y+0), %cx
movw alu_inv16(,%ecx,2), %cx
movl alu_add16(,%eax,4), %edx
movl (%edx,%ecx,4), %edx
movl alu_add16(,%edx,4), %edx
movl (alu_c), %ecx
movl (%edx,%ecx,4), %edx
movw %dx, (alu_t+0)
movl %edx, (alu_c-2)
# end alu_sub16_fast
# alu_sub16_fast
movw (alu_x+2), %ax
movw (alu_y+2), %cx
movw alu_inv16(,%ecx,2), %cx
movl alu_add16(,%eax,4), %edx
movl (%edx,%ecx,4), %edx
movl alu_add16(,%edx,4), %edx
movl (alu_c), %ecx
movl (%edx,%ecx,4), %edx
movw %dx, (alu_t+2)
movl %edx, (alu_c-2)
# end alu_sub16_fast
# end alu_sub32
movl $0, %eax
movb (alu_c), %al
movb alu_true(%eax), %al
movl %eax, (alu_t)
# end alu_div_gte32
movl (alu_t), %eax
movl alu_sel_r(,%eax,4), %edx
movl %edx, (alu_psel_r)
movl alu_sel_q(,%eax,4), %edx
movl %edx, (alu_psel_q)
movl (alu_psel_r), %eax
movl (%eax), %eax
movl %eax, (alu_sr)
movl (alu_sr), %eax
movl %eax, (alu_x)
movl (alu_d), %eax
movl %eax, (alu_y)
# alu_sub32
movl $0, %eax
movl $0, %ecx
movl $0x1, (alu_c)
# alu_sub16_fast
movw (alu_x+0), %ax
movw (alu_y+0), %cx
movw alu_inv16(,%ecx,2), %cx
movl alu_add16(,%eax,4), %edx
movl (%edx,%ecx,4), %edx
movl alu_add16(,%edx,4), %edx
movl (alu_c), %ecx
movl (%edx,%ecx,4), %edx
movw %dx, (alu_sr+0)
movl %edx, (alu_c-2)
# end alu_sub16_fast
# alu_sub16_fast
movw (alu_x+2), %ax
movw (alu_y+2), %cx
movw alu_inv16(,%ecx,2), %cx
movl alu_add16(,%eax,4), %edx
movl (%edx,%ecx,4), %edx
movl alu_add16(,%edx,4), %edx
movl (alu_c), %ecx
movl (%edx,%ecx,4), %edx
movw %dx, (alu_sr+2)
movl %edx, (alu_c-2)
# end alu_sub16_fast
# end alu_sub32
movl (alu_psel_r), %eax
movl (alu_sr), %edx
movl %edx, (%eax)
movl (alu_psel_q), %eax
movl (%eax), %eax
movl %eax, (alu_sq)
# alu_div_setb32
movl $0, %eax
movb (alu_sq+2), %al
movb alu_b_s_1(%eax), %al
movb %al, (alu_sq+2)
# end alu_div_setb32
movl (alu_psel_q), %eax
movl (alu_sq), %edx
movl %edx, (%eax)
# alu_bit
movl $0, %edx
movb (alu_n+2), %dl
movl alu_b0(,%edx,4), %eax
movl %eax, (alu_c)
# end alu_bit
# alu_div_shl1_32_c
# alu_div_shl1_8_c
movl $0, %eax
movl $0, %edx
movb (alu_r+0), %al
movb (alu_c), %dl
movl alu_div_shl3_8_d(,%eax,4), %eax
movl alu_div_shl1_8_c_d(%eax,%edx,4), %eax
movb %al, (alu_r+0)
movb %ah, (alu_c)
# end alu_div_shl1_8_c
# alu_div_shl1_8_c
movl $0, %eax
movl $0, %edx
movb (alu_r+1), %al
movb (alu_c), %dl
movl alu_div_shl3_8_d(,%eax,4), %eax
movl alu_div_shl1_8_c_d(%eax,%edx,4), %eax
movb %al, (alu_r+1)
movb %ah, (alu_c)
# end alu_div_shl1_8_c
# alu_div_shl1_8_c
movl $0, %eax
movl $0, %edx
movb (alu_r+2), %al
movb (alu_c), %dl
movl alu_div_shl3_8_d(,%eax,4), %eax
movl alu_div_shl1_8_c_d(%eax,%edx,4), %eax
movb %al, (alu_r+2)
movb %ah, (alu_c)
# end alu_div_shl1_8_c
# alu_div_shl1_8_c
movl $0, %eax
movl $0, %edx
movb (alu_r+3), %al
movb (alu_c), %dl
movl alu_div_shl3_8_d(,%eax,4), %eax
movl alu_div_shl1_8_c_d(%eax,%edx,4), %eax
movb %al, (alu_r+3)
movb %ah, (alu_c)
# end alu_div_shl1_8_c
# end alu_div_shl1_32_c
# alu_div_gte32
movl $0, (alu_c)
movl (alu_r), %eax
movl %eax, (alu_x)
movl (alu_d), %eax
movl %eax, (alu_y)
# alu_sub32
movl $0, %eax
movl $0, %ecx
movl $0x1, (alu_c)
# alu_sub16_fast
movw (alu_x+0), %ax
movw (alu_y+0), %cx
movw alu_inv16(,%ecx,2), %cx
movl alu_add16(,%eax,4), %edx
movl (%edx,%ecx,4), %edx
movl alu_add16(,%edx,4), %edx
movl (alu_c), %ecx
movl (%edx,%ecx,4), %edx
movw %dx, (alu_t+0)
movl %edx, (alu_c-2)
# end alu_sub16_fast
# alu_sub16_fast
movw (alu_x+2), %ax
movw (alu_y+2), %cx
movw alu_inv16(,%ecx,2), %cx
movl alu_add16(,%eax,4), %edx
movl (%edx,%ecx,4), %edx
movl alu_add16(,%edx,4), %edx
movl (alu_c), %ecx
movl (%edx,%ecx,4), %edx
movw %dx, (alu_t+2)
movl %edx, (alu_c-2)
# end alu_sub16_fast
# end alu_sub32
movl $0, %eax
movb (alu_c), %al
movb alu_true(%eax), %al
movl %eax, (alu_t)
# end alu_div_gte32
movl (alu_t), %eax
movl alu_sel_r(,%eax,4), %edx
movl %edx, (alu_psel_r)
movl alu_sel_q(,%eax,4), %edx
movl %edx, (alu_psel_q)
movl (alu_psel_r), %eax
movl (%eax), %eax
movl %eax, (alu_sr)
movl (alu_sr), %eax
movl %eax, (alu_x)
movl (alu_d), %eax
movl %eax, (alu_y)
# alu_sub32
movl $0, %eax
movl $0, %ecx
movl $0x1, (alu_c)
# alu_sub16_fast
movw (alu_x+0), %ax
movw (alu_y+0), %cx
movw alu_inv16(,%ecx,2), %cx
movl alu_add16(,%eax,4), %edx
movl (%edx,%ecx,4), %edx
movl alu_add16(,%edx,4), %edx
movl (alu_c), %ecx
movl (%edx,%ecx,4), %edx
movw %dx, (alu_sr+0)
movl %edx, (alu_c-2)
# end alu_sub16_fast
# alu_sub16_fast
movw (alu_x+2), %ax
movw (alu_y+2), %cx
movw alu_inv16(,%ecx,2), %cx
movl alu_add16(,%eax,4), %edx
movl (%edx,%ecx,4), %edx
movl alu_add16(,%edx,4), %edx
movl (alu_c), %ecx
movl (%edx,%ecx,4), %edx
movw %dx, (alu_sr+2)
movl %edx, (alu_c-2)
# end alu_sub16_fast
# end alu_sub32
movl (alu_psel_r), %eax
movl (alu_sr), %edx
movl %edx, (%eax)
movl (alu_psel_q), %eax
movl (%eax), %eax
movl %eax, (alu_sq)
# alu_div_setb32
movl $0, %eax
movb (alu_sq+2), %al
movb alu_b_s_0(%eax), %al
movb %al, (alu_sq+2)
# end alu_div_setb32
movl (alu_psel_q), %eax
movl (alu_sq), %edx
movl %edx, (%eax)
# alu_bit
movl $0, %edx
movb (alu_n+1), %dl
movl alu_b7(,%edx,4), %eax
movl %eax, (alu_c)
# end alu_bit
# alu_div_shl1_32_c
# alu_div_shl1_8_c
movl $0, %eax
movl $0, %edx
movb (alu_r+0), %al
movb (alu_c), %dl
movl alu_div_shl3_8_d(,%eax,4), %eax
movl alu_div_shl1_8_c_d(%eax,%edx,4), %eax
movb %al, (alu_r+0)
movb %ah, (alu_c)
# end alu_div_shl1_8_c
# alu_div_shl1_8_c
movl $0, %eax
movl $0, %edx
movb (alu_r+1), %al
movb (alu_c), %dl
movl alu_div_shl3_8_d(,%eax,4), %eax
movl alu_div_shl1_8_c_d(%eax,%edx,4), %eax
movb %al, (alu_r+1)
movb %ah, (alu_c)
# end alu_div_shl1_8_c
# alu_div_shl1_8_c
movl $0, %eax
movl $0, %edx
movb (alu_r+2), %al
movb (alu_c), %dl
movl alu_div_shl3_8_d(,%eax,4), %eax
movl alu_div_shl1_8_c_d(%eax,%edx,4), %eax
movb %al, (alu_r+2)
movb %ah, (alu_c)
# end alu_div_shl1_8_c
# alu_div_shl1_8_c
movl $0, %eax
movl $0, %edx
movb (alu_r+3), %al
movb (alu_c), %dl
movl alu_div_shl3_8_d(,%eax,4), %eax
movl alu_div_shl1_8_c_d(%eax,%edx,4), %eax
movb %al, (alu_r+3)
movb %ah, (alu_c)
# end alu_div_shl1_8_c
# end alu_div_shl1_32_c
# alu_div_gte32
movl $0, (alu_c)
movl (alu_r), %eax
movl %eax, (alu_x)
movl (alu_d), %eax
movl %eax, (alu_y)
# alu_sub32
movl $0, %eax
movl $0, %ecx
movl $0x1, (alu_c)
# alu_sub16_fast
movw (alu_x+0), %ax
movw (alu_y+0), %cx
movw alu_inv16(,%ecx,2), %cx
movl alu_add16(,%eax,4), %edx
movl (%edx,%ecx,4), %edx
movl alu_add16(,%edx,4), %edx
movl (alu_c), %ecx
movl (%edx,%ecx,4), %edx
movw %dx, (alu_t+0)
movl %edx, (alu_c-2)
# end alu_sub16_fast
# alu_sub16_fast
movw (alu_x+2), %ax
movw (alu_y+2), %cx
movw alu_inv16(,%ecx,2), %cx
movl alu_add16(,%eax,4), %edx
movl (%edx,%ecx,4), %edx
movl alu_add16(,%edx,4), %edx
movl (alu_c), %ecx
movl (%edx,%ecx,4), %edx
movw %dx, (alu_t+2)
movl %edx, (alu_c-2)
# end alu_sub16_fast
# end alu_sub32
movl $0, %eax
movb (alu_c), %al
movb alu_true(%eax), %al
movl %eax, (alu_t)
# end alu_div_gte32
movl (alu_t), %eax
movl alu_sel_r(,%eax,4), %edx
movl %edx, (alu_psel_r)
movl alu_sel_q(,%eax,4), %edx
movl %edx, (alu_psel_q)
movl (alu_psel_r), %eax
movl (%eax), %eax
movl %eax, (alu_sr)
movl (alu_sr), %eax
movl %eax, (alu_x)
movl (alu_d), %eax
movl %eax, (alu_y)
# alu_sub32
movl $0, %eax
movl $0, %ecx
movl $0x1, (alu_c)
# alu_sub16_fast
movw (alu_x+0), %ax
movw (alu_y+0), %cx
movw alu_inv16(,%ecx,2), %cx
movl alu_add16(,%eax,4), %edx
movl (%edx,%ecx,4), %edx
movl alu_add16(,%edx,4), %edx
movl (alu_c), %ecx
movl (%edx,%ecx,4), %edx
movw %dx, (alu_sr+0)
movl %edx, (alu_c-2)
# end alu_sub16_fast
# alu_sub16_fast
movw (alu_x+2), %ax
movw (alu_y+2), %cx
movw alu_inv16(,%ecx,2), %cx
movl alu_add16(,%eax,4), %edx
movl (%edx,%ecx,4), %edx
movl alu_add16(,%edx,4), %edx
movl (alu_c), %ecx
movl (%edx,%ecx,4), %edx
movw %dx, (alu_sr+2)
movl %edx, (alu_c-2)
# end alu_sub16_fast
# end alu_sub32
movl (alu_psel_r), %eax
movl (alu_sr), %edx
movl %edx, (%eax)
movl (alu_psel_q), %eax
movl (%eax), %eax
movl %eax, (alu_sq)
# alu_div_setb32
movl $0, %eax
movb (alu_sq+1), %al
movb alu_b_s_7(%eax), %al
movb %al, (alu_sq+1)
# end alu_div_setb32
movl (alu_psel_q), %eax
movl (alu_sq), %edx
movl %edx, (%eax)
# alu_bit
movl $0, %edx
movb (alu_n+1), %dl
movl alu_b6(,%edx,4), %eax
movl %eax, (alu_c)
# end alu_bit
# alu_div_shl1_32_c
# alu_div_shl1_8_c
movl $0, %eax
movl $0, %edx
movb (alu_r+0), %al
movb (alu_c), %dl
movl alu_div_shl3_8_d(,%eax,4), %eax
movl alu_div_shl1_8_c_d(%eax,%edx,4), %eax
movb %al, (alu_r+0)
movb %ah, (alu_c)
# end alu_div_shl1_8_c
# alu_div_shl1_8_c
movl $0, %eax
movl $0, %edx
movb (alu_r+1), %al
movb (alu_c), %dl
movl alu_div_shl3_8_d(,%eax,4), %eax
movl alu_div_shl1_8_c_d(%eax,%edx,4), %eax
movb %al, (alu_r+1)
movb %ah, (alu_c)
# end alu_div_shl1_8_c
# alu_div_shl1_8_c
movl $0, %eax
movl $0, %edx
movb (alu_r+2), %al
movb (alu_c), %dl
movl alu_div_shl3_8_d(,%eax,4), %eax
movl alu_div_shl1_8_c_d(%eax,%edx,4), %eax
movb %al, (alu_r+2)
movb %ah, (alu_c)
# end alu_div_shl1_8_c
# alu_div_shl1_8_c
movl $0, %eax
movl $0, %edx
movb (alu_r+3), %al
movb (alu_c), %dl
movl alu_div_shl3_8_d(,%eax,4), %eax
movl alu_div_shl1_8_c_d(%eax,%edx,4), %eax
movb %al, (alu_r+3)
movb %ah, (alu_c)
# end alu_div_shl1_8_c
# end alu_div_shl1_32_c
# alu_div_gte32
movl $0, (alu_c)
movl (alu_r), %eax
movl %eax, (alu_x)
movl (alu_d), %eax
movl %eax, (alu_y)
# alu_sub32
movl $0, %eax
movl $0, %ecx
movl $0x1, (alu_c)
# alu_sub16_fast
movw (alu_x+0), %ax
movw (alu_y+0), %cx
movw alu_inv16(,%ecx,2), %cx
movl alu_add16(,%eax,4), %edx
movl (%edx,%ecx,4), %edx
movl alu_add16(,%edx,4), %edx
movl (alu_c), %ecx
movl (%edx,%ecx,4), %edx
movw %dx, (alu_t+0)
movl %edx, (alu_c-2)
# end alu_sub16_fast
# alu_sub16_fast
movw (alu_x+2), %ax
movw (alu_y+2), %cx
movw alu_inv16(,%ecx,2), %cx
movl alu_add16(,%eax,4), %edx
movl (%edx,%ecx,4), %edx
movl alu_add16(,%edx,4), %edx
movl (alu_c), %ecx
movl (%edx,%ecx,4), %edx
movw %dx, (alu_t+2)
movl %edx, (alu_c-2)
# end alu_sub16_fast
# end alu_sub32
movl $0, %eax
movb (alu_c), %al
movb alu_true(%eax), %al
movl %eax, (alu_t)
# end alu_div_gte32
movl (alu_t), %eax
movl alu_sel_r(,%eax,4), %edx
movl %edx, (alu_psel_r)
movl alu_sel_q(,%eax,4), %edx
movl %edx, (alu_psel_q)
movl (alu_psel_r), %eax
movl (%eax), %eax
movl %eax, (alu_sr)
movl (alu_sr), %eax
movl %eax, (alu_x)
movl (alu_d), %eax
movl %eax, (alu_y)
# alu_sub32
movl $0, %eax
movl $0, %ecx
movl $0x1, (alu_c)
# alu_sub16_fast
movw (alu_x+0), %ax
movw (alu_y+0), %cx
movw alu_inv16(,%ecx,2), %cx
movl alu_add16(,%eax,4), %edx
movl (%edx,%ecx,4), %edx
movl alu_add16(,%edx,4), %edx
movl (alu_c), %ecx
movl (%edx,%ecx,4), %edx
movw %dx, (alu_sr+0)
movl %edx, (alu_c-2)
# end alu_sub16_fast
# alu_sub16_fast
movw (alu_x+2), %ax
movw (alu_y+2), %cx
movw alu_inv16(,%ecx,2), %cx
movl alu_add16(,%eax,4), %edx
movl (%edx,%ecx,4), %edx
movl alu_add16(,%edx,4), %edx
movl (alu_c), %ecx
movl (%edx,%ecx,4), %edx
movw %dx, (alu_sr+2)
movl %edx, (alu_c-2)
# end alu_sub16_fast
# end alu_sub32
movl (alu_psel_r), %eax
movl (alu_sr), %edx
movl %edx, (%eax)
movl (alu_psel_q), %eax
movl (%eax), %eax
movl %eax, (alu_sq)
# alu_div_setb32
movl $0, %eax
movb (alu_sq+1), %al
movb alu_b_s_6(%eax), %al
movb %al, (alu_sq+1)
# end alu_div_setb32
movl (alu_psel_q), %eax
movl (alu_sq), %edx
movl %edx, (%eax)
# alu_bit
movl $0, %edx
movb (alu_n+1), %dl
movl alu_b5(,%edx,4), %eax
movl %eax, (alu_c)
# end alu_bit
# alu_div_shl1_32_c
# alu_div_shl1_8_c
movl $0, %eax
movl $0, %edx
movb (alu_r+0), %al
movb (alu_c), %dl
movl alu_div_shl3_8_d(,%eax,4), %eax
movl alu_div_shl1_8_c_d(%eax,%edx,4), %eax
movb %al, (alu_r+0)
movb %ah, (alu_c)
# end alu_div_shl1_8_c
# alu_div_shl1_8_c
movl $0, %eax
movl $0, %edx
movb (alu_r+1), %al
movb (alu_c), %dl
movl alu_div_shl3_8_d(,%eax,4), %eax
movl alu_div_shl1_8_c_d(%eax,%edx,4), %eax
movb %al, (alu_r+1)
movb %ah, (alu_c)
# end alu_div_shl1_8_c
# alu_div_shl1_8_c
movl $0, %eax
movl $0, %edx
movb (alu_r+2), %al
movb (alu_c), %dl
movl alu_div_shl3_8_d(,%eax,4), %eax
movl alu_div_shl1_8_c_d(%eax,%edx,4), %eax
movb %al, (alu_r+2)
movb %ah, (alu_c)
# end alu_div_shl1_8_c
# alu_div_shl1_8_c
movl $0, %eax
movl $0, %edx
movb (alu_r+3), %al
movb (alu_c), %dl
movl alu_div_shl3_8_d(,%eax,4), %eax
movl alu_div_shl1_8_c_d(%eax,%edx,4), %eax
movb %al, (alu_r+3)
movb %ah, (alu_c)
# end alu_div_shl1_8_c
# end alu_div_shl1_32_c
# alu_div_gte32
movl $0, (alu_c)
movl (alu_r), %eax
movl %eax, (alu_x)
movl (alu_d), %eax
movl %eax, (alu_y)
# alu_sub32
movl $0, %eax
movl $0, %ecx
movl $0x1, (alu_c)
# alu_sub16_fast
movw (alu_x+0), %ax
movw (alu_y+0), %cx
movw alu_inv16(,%ecx,2), %cx
movl alu_add16(,%eax,4), %edx
movl (%edx,%ecx,4), %edx
movl alu_add16(,%edx,4), %edx
movl (alu_c), %ecx
movl (%edx,%ecx,4), %edx
movw %dx, (alu_t+0)
movl %edx, (alu_c-2)
# end alu_sub16_fast
# alu_sub16_fast
movw (alu_x+2), %ax
movw (alu_y+2), %cx
movw alu_inv16(,%ecx,2), %cx
movl alu_add16(,%eax,4), %edx
movl (%edx,%ecx,4), %edx
movl alu_add16(,%edx,4), %edx
movl (alu_c), %ecx
movl (%edx,%ecx,4), %edx
movw %dx, (alu_t+2)
movl %edx, (alu_c-2)
# end alu_sub16_fast
# end alu_sub32
movl $0, %eax
movb (alu_c), %al
movb alu_true(%eax), %al
movl %eax, (alu_t)
# end alu_div_gte32
movl (alu_t), %eax
movl alu_sel_r(,%eax,4), %edx
movl %edx, (alu_psel_r)
movl alu_sel_q(,%eax,4), %edx
movl %edx, (alu_psel_q)
movl (alu_psel_r), %eax
movl (%eax), %eax
movl %eax, (alu_sr)
movl (alu_sr), %eax
movl %eax, (alu_x)
movl (alu_d), %eax
movl %eax, (alu_y)
# alu_sub32
movl $0, %eax
movl $0, %ecx
movl $0x1, (alu_c)
# alu_sub16_fast
movw (alu_x+0), %ax
movw (alu_y+0), %cx
movw alu_inv16(,%ecx,2), %cx
movl alu_add16(,%eax,4), %edx
movl (%edx,%ecx,4), %edx
movl alu_add16(,%edx,4), %edx
movl (alu_c), %ecx
movl (%edx,%ecx,4), %edx
movw %dx, (alu_sr+0)
movl %edx, (alu_c-2)
# end alu_sub16_fast
# alu_sub16_fast
movw (alu_x+2), %ax
movw (alu_y+2), %cx
movw alu_inv16(,%ecx,2), %cx
movl alu_add16(,%eax,4), %edx
movl (%edx,%ecx,4), %edx
movl alu_add16(,%edx,4), %edx
movl (alu_c), %ecx
movl (%edx,%ecx,4), %edx
movw %dx, (alu_sr+2)
movl %edx, (alu_c-2)
# end alu_sub16_fast
# end alu_sub32
movl (alu_psel_r), %eax
movl (alu_sr), %edx
movl %edx, (%eax)
movl (alu_psel_q), %eax
movl (%eax), %eax
movl %eax, (alu_sq)
# alu_div_setb32
movl $0, %eax
movb (alu_sq+1), %al
movb alu_b_s_5(%eax), %al
movb %al, (alu_sq+1)
# end alu_div_setb32
movl (alu_psel_q), %eax
movl (alu_sq), %edx
movl %edx, (%eax)
# alu_bit
movl $0, %edx
movb (alu_n+1), %dl
movl alu_b4(,%edx,4), %eax
movl %eax, (alu_c)
# end alu_bit
# alu_div_shl1_32_c
# alu_div_shl1_8_c
movl $0, %eax
movl $0, %edx
movb (alu_r+0), %al
movb (alu_c), %dl
movl alu_div_shl3_8_d(,%eax,4), %eax
movl alu_div_shl1_8_c_d(%eax,%edx,4), %eax
movb %al, (alu_r+0)
movb %ah, (alu_c)
# end alu_div_shl1_8_c
# alu_div_shl1_8_c
movl $0, %eax
movl $0, %edx
movb (alu_r+1), %al
movb (alu_c), %dl
movl alu_div_shl3_8_d(,%eax,4), %eax
movl alu_div_shl1_8_c_d(%eax,%edx,4), %eax
movb %al, (alu_r+1)
movb %ah, (alu_c)
# end alu_div_shl1_8_c
# alu_div_shl1_8_c
movl $0, %eax
movl $0, %edx
movb (alu_r+2), %al
movb (alu_c), %dl
movl alu_div_shl3_8_d(,%eax,4), %eax
movl alu_div_shl1_8_c_d(%eax,%edx,4), %eax
movb %al, (alu_r+2)
movb %ah, (alu_c)
# end alu_div_shl1_8_c
# alu_div_shl1_8_c
movl $0, %eax
movl $0, %edx
movb (alu_r+3), %al
movb (alu_c), %dl
movl alu_div_shl3_8_d(,%eax,4), %eax
movl alu_div_shl1_8_c_d(%eax,%edx,4), %eax
movb %al, (alu_r+3)
movb %ah, (alu_c)
# end alu_div_shl1_8_c
# end alu_div_shl1_32_c
# alu_div_gte32
movl $0, (alu_c)
movl (alu_r), %eax
movl %eax, (alu_x)
movl (alu_d), %eax
movl %eax, (alu_y)
# alu_sub32
movl $0, %eax
movl $0, %ecx
movl $0x1, (alu_c)
# alu_sub16_fast
movw (alu_x+0), %ax
movw (alu_y+0), %cx
movw alu_inv16(,%ecx,2), %cx
movl alu_add16(,%eax,4), %edx
movl (%edx,%ecx,4), %edx
movl alu_add16(,%edx,4), %edx
movl (alu_c), %ecx
movl (%edx,%ecx,4), %edx
movw %dx, (alu_t+0)
movl %edx, (alu_c-2)
# end alu_sub16_fast
# alu_sub16_fast
movw (alu_x+2), %ax
movw (alu_y+2), %cx
movw alu_inv16(,%ecx,2), %cx
movl alu_add16(,%eax,4), %edx
movl (%edx,%ecx,4), %edx
movl alu_add16(,%edx,4), %edx
movl (alu_c), %ecx
movl (%edx,%ecx,4), %edx
movw %dx, (alu_t+2)
movl %edx, (alu_c-2)
# end alu_sub16_fast
# end alu_sub32
movl $0, %eax
movb (alu_c), %al
movb alu_true(%eax), %al
movl %eax, (alu_t)
# end alu_div_gte32
movl (alu_t), %eax
movl alu_sel_r(,%eax,4), %edx
movl %edx, (alu_psel_r)
movl alu_sel_q(,%eax,4), %edx
movl %edx, (alu_psel_q)
movl (alu_psel_r), %eax
movl (%eax), %eax
movl %eax, (alu_sr)
movl (alu_sr), %eax
movl %eax, (alu_x)
movl (alu_d), %eax
movl %eax, (alu_y)
# alu_sub32
movl $0, %eax
movl $0, %ecx
movl $0x1, (alu_c)
# alu_sub16_fast
movw (alu_x+0), %ax
movw (alu_y+0), %cx
movw alu_inv16(,%ecx,2), %cx
movl alu_add16(,%eax,4), %edx
movl (%edx,%ecx,4), %edx
movl alu_add16(,%edx,4), %edx
movl (alu_c), %ecx
movl (%edx,%ecx,4), %edx
movw %dx, (alu_sr+0)
movl %edx, (alu_c-2)
# end alu_sub16_fast
# alu_sub16_fast
movw (alu_x+2), %ax
movw (alu_y+2), %cx
movw alu_inv16(,%ecx,2), %cx
movl alu_add16(,%eax,4), %edx
movl (%edx,%ecx,4), %edx
movl alu_add16(,%edx,4), %edx
movl (alu_c), %ecx
movl (%edx,%ecx,4), %edx
movw %dx, (alu_sr+2)
movl %edx, (alu_c-2)
# end alu_sub16_fast
# end alu_sub32
movl (alu_psel_r), %eax
movl (alu_sr), %edx
movl %edx, (%eax)
movl (alu_psel_q), %eax
movl (%eax), %eax
movl %eax, (alu_sq)
# alu_div_setb32
movl $0, %eax
movb (alu_sq+1), %al
movb alu_b_s_4(%eax), %al
movb %al, (alu_sq+1)
# end alu_div_setb32
movl (alu_psel_q), %eax
movl (alu_sq), %edx
movl %edx, (%eax)
# alu_bit
movl $0, %edx
movb (alu_n+1), %dl
movl alu_b3(,%edx,4), %eax
movl %eax, (alu_c)
# end alu_bit
# alu_div_shl1_32_c
# alu_div_shl1_8_c
movl $0, %eax
movl $0, %edx
movb (alu_r+0), %al
movb (alu_c), %dl
movl alu_div_shl3_8_d(,%eax,4), %eax
movl alu_div_shl1_8_c_d(%eax,%edx,4), %eax
movb %al, (alu_r+0)
movb %ah, (alu_c)
# end alu_div_shl1_8_c
# alu_div_shl1_8_c
movl $0, %eax
movl $0, %edx
movb (alu_r+1), %al
movb (alu_c), %dl
movl alu_div_shl3_8_d(,%eax,4), %eax
movl alu_div_shl1_8_c_d(%eax,%edx,4), %eax
movb %al, (alu_r+1)
movb %ah, (alu_c)
# end alu_div_shl1_8_c
# alu_div_shl1_8_c
movl $0, %eax
movl $0, %edx
movb (alu_r+2), %al
movb (alu_c), %dl
movl alu_div_shl3_8_d(,%eax,4), %eax
movl alu_div_shl1_8_c_d(%eax,%edx,4), %eax
movb %al, (alu_r+2)
movb %ah, (alu_c)
# end alu_div_shl1_8_c
# alu_div_shl1_8_c
movl $0, %eax
movl $0, %edx
movb (alu_r+3), %al
movb (alu_c), %dl
movl alu_div_shl3_8_d(,%eax,4), %eax
movl alu_div_shl1_8_c_d(%eax,%edx,4), %eax
movb %al, (alu_r+3)
movb %ah, (alu_c)
# end alu_div_shl1_8_c
# end alu_div_shl1_32_c
# alu_div_gte32
movl $0, (alu_c)
movl (alu_r), %eax
movl %eax, (alu_x)
movl (alu_d), %eax
movl %eax, (alu_y)
# alu_sub32
movl $0, %eax
movl $0, %ecx
movl $0x1, (alu_c)
# alu_sub16_fast
movw (alu_x+0), %ax
movw (alu_y+0), %cx
movw alu_inv16(,%ecx,2), %cx
movl alu_add16(,%eax,4), %edx
movl (%edx,%ecx,4), %edx
movl alu_add16(,%edx,4), %edx
movl (alu_c), %ecx
movl (%edx,%ecx,4), %edx
movw %dx, (alu_t+0)
movl %edx, (alu_c-2)
# end alu_sub16_fast
# alu_sub16_fast
movw (alu_x+2), %ax
movw (alu_y+2), %cx
movw alu_inv16(,%ecx,2), %cx
movl alu_add16(,%eax,4), %edx
movl (%edx,%ecx,4), %edx
movl alu_add16(,%edx,4), %edx
movl (alu_c), %ecx
movl (%edx,%ecx,4), %edx
movw %dx, (alu_t+2)
movl %edx, (alu_c-2)
# end alu_sub16_fast
# end alu_sub32
movl $0, %eax
movb (alu_c), %al
movb alu_true(%eax), %al
movl %eax, (alu_t)
# end alu_div_gte32
movl (alu_t), %eax
movl alu_sel_r(,%eax,4), %edx
movl %edx, (alu_psel_r)
movl alu_sel_q(,%eax,4), %edx
movl %edx, (alu_psel_q)
movl (alu_psel_r), %eax
movl (%eax), %eax
movl %eax, (alu_sr)
movl (alu_sr), %eax
movl %eax, (alu_x)
movl (alu_d), %eax
movl %eax, (alu_y)
# alu_sub32
movl $0, %eax
movl $0, %ecx
movl $0x1, (alu_c)
# alu_sub16_fast
movw (alu_x+0), %ax
movw (alu_y+0), %cx
movw alu_inv16(,%ecx,2), %cx
movl alu_add16(,%eax,4), %edx
movl (%edx,%ecx,4), %edx
movl alu_add16(,%edx,4), %edx
movl (alu_c), %ecx
movl (%edx,%ecx,4), %edx
movw %dx, (alu_sr+0)
movl %edx, (alu_c-2)
# end alu_sub16_fast
# alu_sub16_fast
movw (alu_x+2), %ax
movw (alu_y+2), %cx
movw alu_inv16(,%ecx,2), %cx
movl alu_add16(,%eax,4), %edx
movl (%edx,%ecx,4), %edx
movl alu_add16(,%edx,4), %edx
movl (alu_c), %ecx
movl (%edx,%ecx,4), %edx
movw %dx, (alu_sr+2)
movl %edx, (alu_c-2)
# end alu_sub16_fast
# end alu_sub32
movl (alu_psel_r), %eax
movl (alu_sr), %edx
movl %edx, (%eax)
movl (alu_psel_q), %eax
movl (%eax), %eax
movl %eax, (alu_sq)
# alu_div_setb32
movl $0, %eax
movb (alu_sq+1), %al
movb alu_b_s_3(%eax), %al
movb %al, (alu_sq+1)
# end alu_div_setb32
movl (alu_psel_q), %eax
movl (alu_sq), %edx
movl %edx, (%eax)
# alu_bit
movl $0, %edx
movb (alu_n+1), %dl
movl alu_b2(,%edx,4), %eax
movl %eax, (alu_c)
# end alu_bit
# alu_div_shl1_32_c
# alu_div_shl1_8_c
movl $0, %eax
movl $0, %edx
movb (alu_r+0), %al
movb (alu_c), %dl
movl alu_div_shl3_8_d(,%eax,4), %eax
movl alu_div_shl1_8_c_d(%eax,%edx,4), %eax
movb %al, (alu_r+0)
movb %ah, (alu_c)
# end alu_div_shl1_8_c
# alu_div_shl1_8_c
movl $0, %eax
movl $0, %edx
movb (alu_r+1), %al
movb (alu_c), %dl
movl alu_div_shl3_8_d(,%eax,4), %eax
movl alu_div_shl1_8_c_d(%eax,%edx,4), %eax
movb %al, (alu_r+1)
movb %ah, (alu_c)
# end alu_div_shl1_8_c
# alu_div_shl1_8_c
movl $0, %eax
movl $0, %edx
movb (alu_r+2), %al
movb (alu_c), %dl
movl alu_div_shl3_8_d(,%eax,4), %eax
movl alu_div_shl1_8_c_d(%eax,%edx,4), %eax
movb %al, (alu_r+2)
movb %ah, (alu_c)
# end alu_div_shl1_8_c
# alu_div_shl1_8_c
movl $0, %eax
movl $0, %edx
movb (alu_r+3), %al
movb (alu_c), %dl
movl alu_div_shl3_8_d(,%eax,4), %eax
movl alu_div_shl1_8_c_d(%eax,%edx,4), %eax
movb %al, (alu_r+3)
movb %ah, (alu_c)
# end alu_div_shl1_8_c
# end alu_div_shl1_32_c
# alu_div_gte32
movl $0, (alu_c)
movl (alu_r), %eax
movl %eax, (alu_x)
movl (alu_d), %eax
movl %eax, (alu_y)
# alu_sub32
movl $0, %eax
movl $0, %ecx
movl $0x1, (alu_c)
# alu_sub16_fast
movw (alu_x+0), %ax
movw (alu_y+0), %cx
movw alu_inv16(,%ecx,2), %cx
movl alu_add16(,%eax,4), %edx
movl (%edx,%ecx,4), %edx
movl alu_add16(,%edx,4), %edx
movl (alu_c), %ecx
movl (%edx,%ecx,4), %edx
movw %dx, (alu_t+0)
movl %edx, (alu_c-2)
# end alu_sub16_fast
# alu_sub16_fast
movw (alu_x+2), %ax
movw (alu_y+2), %cx
movw alu_inv16(,%ecx,2), %cx
movl alu_add16(,%eax,4), %edx
movl (%edx,%ecx,4), %edx
movl alu_add16(,%edx,4), %edx
movl (alu_c), %ecx
movl (%edx,%ecx,4), %edx
movw %dx, (alu_t+2)
movl %edx, (alu_c-2)
# end alu_sub16_fast
# end alu_sub32
movl $0, %eax
movb (alu_c), %al
movb alu_true(%eax), %al
movl %eax, (alu_t)
# end alu_div_gte32
movl (alu_t), %eax
movl alu_sel_r(,%eax,4), %edx
movl %edx, (alu_psel_r)
movl alu_sel_q(,%eax,4), %edx
movl %edx, (alu_psel_q)
movl (alu_psel_r), %eax
movl (%eax), %eax
movl %eax, (alu_sr)
movl (alu_sr), %eax
movl %eax, (alu_x)
movl (alu_d), %eax
movl %eax, (alu_y)
# alu_sub32
movl $0, %eax
movl $0, %ecx
movl $0x1, (alu_c)
# alu_sub16_fast
movw (alu_x+0), %ax
movw (alu_y+0), %cx
movw alu_inv16(,%ecx,2), %cx
movl alu_add16(,%eax,4), %edx
movl (%edx,%ecx,4), %edx
movl alu_add16(,%edx,4), %edx
movl (alu_c), %ecx
movl (%edx,%ecx,4), %edx
movw %dx, (alu_sr+0)
movl %edx, (alu_c-2)
# end alu_sub16_fast
# alu_sub16_fast
movw (alu_x+2), %ax
movw (alu_y+2), %cx
movw alu_inv16(,%ecx,2), %cx
movl alu_add16(,%eax,4), %edx
movl (%edx,%ecx,4), %edx
movl alu_add16(,%edx,4), %edx
movl (alu_c), %ecx
movl (%edx,%ecx,4), %edx
movw %dx, (alu_sr+2)
movl %edx, (alu_c-2)
# end alu_sub16_fast
# end alu_sub32
movl (alu_psel_r), %eax
movl (alu_sr), %edx
movl %edx, (%eax)
movl (alu_psel_q), %eax
movl (%eax), %eax
movl %eax, (alu_sq)
# alu_div_setb32
movl $0, %eax
movb (alu_sq+1), %al
movb alu_b_s_2(%eax), %al
movb %al, (alu_sq+1)
# end alu_div_setb32
movl (alu_psel_q), %eax
movl (alu_sq), %edx
movl %edx, (%eax)
# alu_bit
movl $0, %edx
movb (alu_n+1), %dl
movl alu_b1(,%edx,4), %eax
movl %eax, (alu_c)
# end alu_bit
# alu_div_shl1_32_c
# alu_div_shl1_8_c
movl $0, %eax
movl $0, %edx
movb (alu_r+0), %al
movb (alu_c), %dl
movl alu_div_shl3_8_d(,%eax,4), %eax
movl alu_div_shl1_8_c_d(%eax,%edx,4), %eax
movb %al, (alu_r+0)
movb %ah, (alu_c)
# end alu_div_shl1_8_c
# alu_div_shl1_8_c
movl $0, %eax
movl $0, %edx
movb (alu_r+1), %al
movb (alu_c), %dl
movl alu_div_shl3_8_d(,%eax,4), %eax
movl alu_div_shl1_8_c_d(%eax,%edx,4), %eax
movb %al, (alu_r+1)
movb %ah, (alu_c)
# end alu_div_shl1_8_c
# alu_div_shl1_8_c
movl $0, %eax
movl $0, %edx
movb (alu_r+2), %al
movb (alu_c), %dl
movl alu_div_shl3_8_d(,%eax,4), %eax
movl alu_div_shl1_8_c_d(%eax,%edx,4), %eax
movb %al, (alu_r+2)
movb %ah, (alu_c)
# end alu_div_shl1_8_c
# alu_div_shl1_8_c
movl $0, %eax
movl $0, %edx
movb (alu_r+3), %al
movb (alu_c), %dl
movl alu_div_shl3_8_d(,%eax,4), %eax
movl alu_div_shl1_8_c_d(%eax,%edx,4), %eax
movb %al, (alu_r+3)
movb %ah, (alu_c)
# end alu_div_shl1_8_c
# end alu_div_shl1_32_c
# alu_div_gte32
movl $0, (alu_c)
movl (alu_r), %eax
movl %eax, (alu_x)
movl (alu_d), %eax
movl %eax, (alu_y)
# alu_sub32
movl $0, %eax
movl $0, %ecx
movl $0x1, (alu_c)
# alu_sub16_fast
movw (alu_x+0), %ax
movw (alu_y+0), %cx
movw alu_inv16(,%ecx,2), %cx
movl alu_add16(,%eax,4), %edx
movl (%edx,%ecx,4), %edx
movl alu_add16(,%edx,4), %edx
movl (alu_c), %ecx
movl (%edx,%ecx,4), %edx
movw %dx, (alu_t+0)
movl %edx, (alu_c-2)
# end alu_sub16_fast
# alu_sub16_fast
movw (alu_x+2), %ax
movw (alu_y+2), %cx
movw alu_inv16(,%ecx,2), %cx
movl alu_add16(,%eax,4), %edx
movl (%edx,%ecx,4), %edx
movl alu_add16(,%edx,4), %edx
movl (alu_c), %ecx
movl (%edx,%ecx,4), %edx
movw %dx, (alu_t+2)
movl %edx, (alu_c-2)
# end alu_sub16_fast
# end alu_sub32
movl $0, %eax
movb (alu_c), %al
movb alu_true(%eax), %al
movl %eax, (alu_t)
# end alu_div_gte32
movl (alu_t), %eax
movl alu_sel_r(,%eax,4), %edx
movl %edx, (alu_psel_r)
movl alu_sel_q(,%eax,4), %edx
movl %edx, (alu_psel_q)
movl (alu_psel_r), %eax
movl (%eax), %eax
movl %eax, (alu_sr)
movl (alu_sr), %eax
movl %eax, (alu_x)
movl (alu_d), %eax
movl %eax, (alu_y)
# alu_sub32
movl $0, %eax
movl $0, %ecx
movl $0x1, (alu_c)
# alu_sub16_fast
movw (alu_x+0), %ax
movw (alu_y+0), %cx
movw alu_inv16(,%ecx,2), %cx
movl alu_add16(,%eax,4), %edx
movl (%edx,%ecx,4), %edx
movl alu_add16(,%edx,4), %edx
movl (alu_c), %ecx
movl (%edx,%ecx,4), %edx
movw %dx, (alu_sr+0)
movl %edx, (alu_c-2)
# end alu_sub16_fast
# alu_sub16_fast
movw (alu_x+2), %ax
movw (alu_y+2), %cx
movw alu_inv16(,%ecx,2), %cx
movl alu_add16(,%eax,4), %edx
movl (%edx,%ecx,4), %edx
movl alu_add16(,%edx,4), %edx
movl (alu_c), %ecx
movl (%edx,%ecx,4), %edx
movw %dx, (alu_sr+2)
movl %edx, (alu_c-2)
# end alu_sub16_fast
# end alu_sub32
movl (alu_psel_r), %eax
movl (alu_sr), %edx
movl %edx, (%eax)
movl (alu_psel_q), %eax
movl (%eax), %eax
movl %eax, (alu_sq)
# alu_div_setb32
movl $0, %eax
movb (alu_sq+1), %al
movb alu_b_s_1(%eax), %al
movb %al, (alu_sq+1)
# end alu_div_setb32
movl (alu_psel_q), %eax
movl (alu_sq), %edx
movl %edx, (%eax)
# alu_bit
movl $0, %edx
movb (alu_n+1), %dl
movl alu_b0(,%edx,4), %eax
movl %eax, (alu_c)
# end alu_bit
# alu_div_shl1_32_c
# alu_div_shl1_8_c
movl $0, %eax
movl $0, %edx
movb (alu_r+0), %al
movb (alu_c), %dl
movl alu_div_shl3_8_d(,%eax,4), %eax
movl alu_div_shl1_8_c_d(%eax,%edx,4), %eax
movb %al, (alu_r+0)
movb %ah, (alu_c)
# end alu_div_shl1_8_c
# alu_div_shl1_8_c
movl $0, %eax
movl $0, %edx
movb (alu_r+1), %al
movb (alu_c), %dl
movl alu_div_shl3_8_d(,%eax,4), %eax
movl alu_div_shl1_8_c_d(%eax,%edx,4), %eax
movb %al, (alu_r+1)
movb %ah, (alu_c)
# end alu_div_shl1_8_c
# alu_div_shl1_8_c
movl $0, %eax
movl $0, %edx
movb (alu_r+2), %al
movb (alu_c), %dl
movl alu_div_shl3_8_d(,%eax,4), %eax
movl alu_div_shl1_8_c_d(%eax,%edx,4), %eax
movb %al, (alu_r+2)
movb %ah, (alu_c)
# end alu_div_shl1_8_c
# alu_div_shl1_8_c
movl $0, %eax
movl $0, %edx
movb (alu_r+3), %al
movb (alu_c), %dl
movl alu_div_shl3_8_d(,%eax,4), %eax
movl alu_div_shl1_8_c_d(%eax,%edx,4), %eax
movb %al, (alu_r+3)
movb %ah, (alu_c)
# end alu_div_shl1_8_c
# end alu_div_shl1_32_c
# alu_div_gte32
movl $0, (alu_c)
movl (alu_r), %eax
movl %eax, (alu_x)
movl (alu_d), %eax
movl %eax, (alu_y)
# alu_sub32
movl $0, %eax
movl $0, %ecx
movl $0x1, (alu_c)
# alu_sub16_fast
movw (alu_x+0), %ax
movw (alu_y+0), %cx
movw alu_inv16(,%ecx,2), %cx
movl alu_add16(,%eax,4), %edx
movl (%edx,%ecx,4), %edx
movl alu_add16(,%edx,4), %edx
movl (alu_c), %ecx
movl (%edx,%ecx,4), %edx
movw %dx, (alu_t+0)
movl %edx, (alu_c-2)
# end alu_sub16_fast
# alu_sub16_fast
movw (alu_x+2), %ax
movw (alu_y+2), %cx
movw alu_inv16(,%ecx,2), %cx
movl alu_add16(,%eax,4), %edx
movl (%edx,%ecx,4), %edx
movl alu_add16(,%edx,4), %edx
movl (alu_c), %ecx
movl (%edx,%ecx,4), %edx
movw %dx, (alu_t+2)
movl %edx, (alu_c-2)
# end alu_sub16_fast
# end alu_sub32
movl $0, %eax
movb (alu_c), %al
movb alu_true(%eax), %al
movl %eax, (alu_t)
# end alu_div_gte32
movl (alu_t), %eax
movl alu_sel_r(,%eax,4), %edx
movl %edx, (alu_psel_r)
movl alu_sel_q(,%eax,4), %edx
movl %edx, (alu_psel_q)
movl (alu_psel_r), %eax
movl (%eax), %eax
movl %eax, (alu_sr)
movl (alu_sr), %eax
movl %eax, (alu_x)
movl (alu_d), %eax
movl %eax, (alu_y)
# alu_sub32
movl $0, %eax
movl $0, %ecx
movl $0x1, (alu_c)
# alu_sub16_fast
movw (alu_x+0), %ax
movw (alu_y+0), %cx
movw alu_inv16(,%ecx,2), %cx
movl alu_add16(,%eax,4), %edx
movl (%edx,%ecx,4), %edx
movl alu_add16(,%edx,4), %edx
movl (alu_c), %ecx
movl (%edx,%ecx,4), %edx
movw %dx, (alu_sr+0)
movl %edx, (alu_c-2)
# end alu_sub16_fast
# alu_sub16_fast
movw (alu_x+2), %ax
movw (alu_y+2), %cx
movw alu_inv16(,%ecx,2), %cx
movl alu_add16(,%eax,4), %edx
movl (%edx,%ecx,4), %edx
movl alu_add16(,%edx,4), %edx
movl (alu_c), %ecx
movl (%edx,%ecx,4), %edx
movw %dx, (alu_sr+2)
movl %edx, (alu_c-2)
# end alu_sub16_fast
# end alu_sub32
movl (alu_psel_r), %eax
movl (alu_sr), %edx
movl %edx, (%eax)
movl (alu_psel_q), %eax
movl (%eax), %eax
movl %eax, (alu_sq)
# alu_div_setb32
movl $0, %eax
movb (alu_sq+1), %al
movb alu_b_s_0(%eax), %al
movb %al, (alu_sq+1)
# end alu_div_setb32
movl (alu_psel_q), %eax
movl (alu_sq), %edx
movl %edx, (%eax)
# alu_bit
movl $0, %edx
movb (alu_n+0), %dl
movl alu_b7(,%edx,4), %eax
movl %eax, (alu_c)
# end alu_bit
# alu_div_shl1_32_c
# alu_div_shl1_8_c
movl $0, %eax
movl $0, %edx
movb (alu_r+0), %al
movb (alu_c), %dl
movl alu_div_shl3_8_d(,%eax,4), %eax
movl alu_div_shl1_8_c_d(%eax,%edx,4), %eax
movb %al, (alu_r+0)
movb %ah, (alu_c)
# end alu_div_shl1_8_c
# alu_div_shl1_8_c
movl $0, %eax
movl $0, %edx
movb (alu_r+1), %al
movb (alu_c), %dl
movl alu_div_shl3_8_d(,%eax,4), %eax
movl alu_div_shl1_8_c_d(%eax,%edx,4), %eax
movb %al, (alu_r+1)
movb %ah, (alu_c)
# end alu_div_shl1_8_c
# alu_div_shl1_8_c
movl $0, %eax
movl $0, %edx
movb (alu_r+2), %al
movb (alu_c), %dl
movl alu_div_shl3_8_d(,%eax,4), %eax
movl alu_div_shl1_8_c_d(%eax,%edx,4), %eax
movb %al, (alu_r+2)
movb %ah, (alu_c)
# end alu_div_shl1_8_c
# alu_div_shl1_8_c
movl $0, %eax
movl $0, %edx
movb (alu_r+3), %al
movb (alu_c), %dl
movl alu_div_shl3_8_d(,%eax,4), %eax
movl alu_div_shl1_8_c_d(%eax,%edx,4), %eax
movb %al, (alu_r+3)
movb %ah, (alu_c)
# end alu_div_shl1_8_c
# end alu_div_shl1_32_c
# alu_div_gte32
movl $0, (alu_c)
movl (alu_r), %eax
movl %eax, (alu_x)
movl (alu_d), %eax
movl %eax, (alu_y)
# alu_sub32
movl $0, %eax
movl $0, %ecx
movl $0x1, (alu_c)
# alu_sub16_fast
movw (alu_x+0), %ax
movw (alu_y+0), %cx
movw alu_inv16(,%ecx,2), %cx
movl alu_add16(,%eax,4), %edx
movl (%edx,%ecx,4), %edx
movl alu_add16(,%edx,4), %edx
movl (alu_c), %ecx
movl (%edx,%ecx,4), %edx
movw %dx, (alu_t+0)
movl %edx, (alu_c-2)
# end alu_sub16_fast
# alu_sub16_fast
movw (alu_x+2), %ax
movw (alu_y+2), %cx
movw alu_inv16(,%ecx,2), %cx
movl alu_add16(,%eax,4), %edx
movl (%edx,%ecx,4), %edx
movl alu_add16(,%edx,4), %edx
movl (alu_c), %ecx
movl (%edx,%ecx,4), %edx
movw %dx, (alu_t+2)
movl %edx, (alu_c-2)
# end alu_sub16_fast
# end alu_sub32
movl $0, %eax
movb (alu_c), %al
movb alu_true(%eax), %al
movl %eax, (alu_t)
# end alu_div_gte32
movl (alu_t), %eax
movl alu_sel_r(,%eax,4), %edx
movl %edx, (alu_psel_r)
movl alu_sel_q(,%eax,4), %edx
movl %edx, (alu_psel_q)
movl (alu_psel_r), %eax
movl (%eax), %eax
movl %eax, (alu_sr)
movl (alu_sr), %eax
movl %eax, (alu_x)
movl (alu_d), %eax
movl %eax, (alu_y)
# alu_sub32
movl $0, %eax
movl $0, %ecx
movl $0x1, (alu_c)
# alu_sub16_fast
movw (alu_x+0), %ax
movw (alu_y+0), %cx
movw alu_inv16(,%ecx,2), %cx
movl alu_add16(,%eax,4), %edx
movl (%edx,%ecx,4), %edx
movl alu_add16(,%edx,4), %edx
movl (alu_c), %ecx
movl (%edx,%ecx,4), %edx
movw %dx, (alu_sr+0)
movl %edx, (alu_c-2)
# end alu_sub16_fast
# alu_sub16_fast
movw (alu_x+2), %ax
movw (alu_y+2), %cx
movw alu_inv16(,%ecx,2), %cx
movl alu_add16(,%eax,4), %edx
movl (%edx,%ecx,4), %edx
movl alu_add16(,%edx,4), %edx
movl (alu_c), %ecx
movl (%edx,%ecx,4), %edx
movw %dx, (alu_sr+2)
movl %edx, (alu_c-2)
# end alu_sub16_fast
# end alu_sub32
movl (alu_psel_r), %eax
movl (alu_sr), %edx
movl %edx, (%eax)
movl (alu_psel_q), %eax
movl (%eax), %eax
movl %eax, (alu_sq)
# alu_div_setb32
movl $0, %eax
movb (alu_sq+0), %al
movb alu_b_s_7(%eax), %al
movb %al, (alu_sq+0)
# end alu_div_setb32
movl (alu_psel_q), %eax
movl (alu_sq), %edx
movl %edx, (%eax)
# alu_bit
movl $0, %edx
movb (alu_n+0), %dl
movl alu_b6(,%edx,4), %eax
movl %eax, (alu_c)
# end alu_bit
# alu_div_shl1_32_c
# alu_div_shl1_8_c
movl $0, %eax
movl $0, %edx
movb (alu_r+0), %al
movb (alu_c), %dl
movl alu_div_shl3_8_d(,%eax,4), %eax
movl alu_div_shl1_8_c_d(%eax,%edx,4), %eax
movb %al, (alu_r+0)
movb %ah, (alu_c)
# end alu_div_shl1_8_c
# alu_div_shl1_8_c
movl $0, %eax
movl $0, %edx
movb (alu_r+1), %al
movb (alu_c), %dl
movl alu_div_shl3_8_d(,%eax,4), %eax
movl alu_div_shl1_8_c_d(%eax,%edx,4), %eax
movb %al, (alu_r+1)
movb %ah, (alu_c)
# end alu_div_shl1_8_c
# alu_div_shl1_8_c
movl $0, %eax
movl $0, %edx
movb (alu_r+2), %al
movb (alu_c), %dl
movl alu_div_shl3_8_d(,%eax,4), %eax
movl alu_div_shl1_8_c_d(%eax,%edx,4), %eax
movb %al, (alu_r+2)
movb %ah, (alu_c)
# end alu_div_shl1_8_c
# alu_div_shl1_8_c
movl $0, %eax
movl $0, %edx
movb (alu_r+3), %al
movb (alu_c), %dl
movl alu_div_shl3_8_d(,%eax,4), %eax
movl alu_div_shl1_8_c_d(%eax,%edx,4), %eax
movb %al, (alu_r+3)
movb %ah, (alu_c)
# end alu_div_shl1_8_c
# end alu_div_shl1_32_c
# alu_div_gte32
movl $0, (alu_c)
movl (alu_r), %eax
movl %eax, (alu_x)
movl (alu_d), %eax
movl %eax, (alu_y)
# alu_sub32
movl $0, %eax
movl $0, %ecx
movl $0x1, (alu_c)
# alu_sub16_fast
movw (alu_x+0), %ax
movw (alu_y+0), %cx
movw alu_inv16(,%ecx,2), %cx
movl alu_add16(,%eax,4), %edx
movl (%edx,%ecx,4), %edx
movl alu_add16(,%edx,4), %edx
movl (alu_c), %ecx
movl (%edx,%ecx,4), %edx
movw %dx, (alu_t+0)
movl %edx, (alu_c-2)
# end alu_sub16_fast
# alu_sub16_fast
movw (alu_x+2), %ax
movw (alu_y+2), %cx
movw alu_inv16(,%ecx,2), %cx
movl alu_add16(,%eax,4), %edx
movl (%edx,%ecx,4), %edx
movl alu_add16(,%edx,4), %edx
movl (alu_c), %ecx
movl (%edx,%ecx,4), %edx
movw %dx, (alu_t+2)
movl %edx, (alu_c-2)
# end alu_sub16_fast
# end alu_sub32
movl $0, %eax
movb (alu_c), %al
movb alu_true(%eax), %al
movl %eax, (alu_t)
# end alu_div_gte32
movl (alu_t), %eax
movl alu_sel_r(,%eax,4), %edx
movl %edx, (alu_psel_r)
movl alu_sel_q(,%eax,4), %edx
movl %edx, (alu_psel_q)
movl (alu_psel_r), %eax
movl (%eax), %eax
movl %eax, (alu_sr)
movl (alu_sr), %eax
movl %eax, (alu_x)
movl (alu_d), %eax
movl %eax, (alu_y)
# alu_sub32
movl $0, %eax
movl $0, %ecx
movl $0x1, (alu_c)
# alu_sub16_fast
movw (alu_x+0), %ax
movw (alu_y+0), %cx
movw alu_inv16(,%ecx,2), %cx
movl alu_add16(,%eax,4), %edx
movl (%edx,%ecx,4), %edx
movl alu_add16(,%edx,4), %edx
movl (alu_c), %ecx
movl (%edx,%ecx,4), %edx
movw %dx, (alu_sr+0)
movl %edx, (alu_c-2)
# end alu_sub16_fast
# alu_sub16_fast
movw (alu_x+2), %ax
movw (alu_y+2), %cx
movw alu_inv16(,%ecx,2), %cx
movl alu_add16(,%eax,4), %edx
movl (%edx,%ecx,4), %edx
movl alu_add16(,%edx,4), %edx
movl (alu_c), %ecx
movl (%edx,%ecx,4), %edx
movw %dx, (alu_sr+2)
movl %edx, (alu_c-2)
# end alu_sub16_fast
# end alu_sub32
movl (alu_psel_r), %eax
movl (alu_sr), %edx
movl %edx, (%eax)
movl (alu_psel_q), %eax
movl (%eax), %eax
movl %eax, (alu_sq)
# alu_div_setb32
movl $0, %eax
movb (alu_sq+0), %al
movb alu_b_s_6(%eax), %al
movb %al, (alu_sq+0)
# end alu_div_setb32
movl (alu_psel_q), %eax
movl (alu_sq), %edx
movl %edx, (%eax)
# alu_bit
movl $0, %edx
movb (alu_n+0), %dl
movl alu_b5(,%edx,4), %eax
movl %eax, (alu_c)
# end alu_bit
# alu_div_shl1_32_c
# alu_div_shl1_8_c
movl $0, %eax
movl $0, %edx
movb (alu_r+0), %al
movb (alu_c), %dl
movl alu_div_shl3_8_d(,%eax,4), %eax
movl alu_div_shl1_8_c_d(%eax,%edx,4), %eax
movb %al, (alu_r+0)
movb %ah, (alu_c)
# end alu_div_shl1_8_c
# alu_div_shl1_8_c
movl $0, %eax
movl $0, %edx
movb (alu_r+1), %al
movb (alu_c), %dl
movl alu_div_shl3_8_d(,%eax,4), %eax
movl alu_div_shl1_8_c_d(%eax,%edx,4), %eax
movb %al, (alu_r+1)
movb %ah, (alu_c)
# end alu_div_shl1_8_c
# alu_div_shl1_8_c
movl $0, %eax
movl $0, %edx
movb (alu_r+2), %al
movb (alu_c), %dl
movl alu_div_shl3_8_d(,%eax,4), %eax
movl alu_div_shl1_8_c_d(%eax,%edx,4), %eax
movb %al, (alu_r+2)
movb %ah, (alu_c)
# end alu_div_shl1_8_c
# alu_div_shl1_8_c
movl $0, %eax
movl $0, %edx
movb (alu_r+3), %al
movb (alu_c), %dl
movl alu_div_shl3_8_d(,%eax,4), %eax
movl alu_div_shl1_8_c_d(%eax,%edx,4), %eax
movb %al, (alu_r+3)
movb %ah, (alu_c)
# end alu_div_shl1_8_c
# end alu_div_shl1_32_c
# alu_div_gte32
movl $0, (alu_c)
movl (alu_r), %eax
movl %eax, (alu_x)
movl (alu_d), %eax
movl %eax, (alu_y)
# alu_sub32
movl $0, %eax
movl $0, %ecx
movl $0x1, (alu_c)
# alu_sub16_fast
movw (alu_x+0), %ax
movw (alu_y+0), %cx
movw alu_inv16(,%ecx,2), %cx
movl alu_add16(,%eax,4), %edx
movl (%edx,%ecx,4), %edx
movl alu_add16(,%edx,4), %edx
movl (alu_c), %ecx
movl (%edx,%ecx,4), %edx
movw %dx, (alu_t+0)
movl %edx, (alu_c-2)
# end alu_sub16_fast
# alu_sub16_fast
movw (alu_x+2), %ax
movw (alu_y+2), %cx
movw alu_inv16(,%ecx,2), %cx
movl alu_add16(,%eax,4), %edx
movl (%edx,%ecx,4), %edx
movl alu_add16(,%edx,4), %edx
movl (alu_c), %ecx
movl (%edx,%ecx,4), %edx
movw %dx, (alu_t+2)
movl %edx, (alu_c-2)
# end alu_sub16_fast
# end alu_sub32
movl $0, %eax
movb (alu_c), %al
movb alu_true(%eax), %al
movl %eax, (alu_t)
# end alu_div_gte32
movl (alu_t), %eax
movl alu_sel_r(,%eax,4), %edx
movl %edx, (alu_psel_r)
movl alu_sel_q(,%eax,4), %edx
movl %edx, (alu_psel_q)
movl (alu_psel_r), %eax
movl (%eax), %eax
movl %eax, (alu_sr)
movl (alu_sr), %eax
movl %eax, (alu_x)
movl (alu_d), %eax
movl %eax, (alu_y)
# alu_sub32
movl $0, %eax
movl $0, %ecx
movl $0x1, (alu_c)
# alu_sub16_fast
movw (alu_x+0), %ax
movw (alu_y+0), %cx
movw alu_inv16(,%ecx,2), %cx
movl alu_add16(,%eax,4), %edx
movl (%edx,%ecx,4), %edx
movl alu_add16(,%edx,4), %edx
movl (alu_c), %ecx
movl (%edx,%ecx,4), %edx
movw %dx, (alu_sr+0)
movl %edx, (alu_c-2)
# end alu_sub16_fast
# alu_sub16_fast
movw (alu_x+2), %ax
movw (alu_y+2), %cx
movw alu_inv16(,%ecx,2), %cx
movl alu_add16(,%eax,4), %edx
movl (%edx,%ecx,4), %edx
movl alu_add16(,%edx,4), %edx
movl (alu_c), %ecx
movl (%edx,%ecx,4), %edx
movw %dx, (alu_sr+2)
movl %edx, (alu_c-2)
# end alu_sub16_fast
# end alu_sub32
movl (alu_psel_r), %eax
movl (alu_sr), %edx
movl %edx, (%eax)
movl (alu_psel_q), %eax
movl (%eax), %eax
movl %eax, (alu_sq)
# alu_div_setb32
movl $0, %eax
movb (alu_sq+0), %al
movb alu_b_s_5(%eax), %al
movb %al, (alu_sq+0)
# end alu_div_setb32
movl (alu_psel_q), %eax
movl (alu_sq), %edx
movl %edx, (%eax)
# alu_bit
movl $0, %edx
movb (alu_n+0), %dl
movl alu_b4(,%edx,4), %eax
movl %eax, (alu_c)
# end alu_bit
# alu_div_shl1_32_c
# alu_div_shl1_8_c
movl $0, %eax
movl $0, %edx
movb (alu_r+0), %al
movb (alu_c), %dl
movl alu_div_shl3_8_d(,%eax,4), %eax
movl alu_div_shl1_8_c_d(%eax,%edx,4), %eax
movb %al, (alu_r+0)
movb %ah, (alu_c)
# end alu_div_shl1_8_c
# alu_div_shl1_8_c
movl $0, %eax
movl $0, %edx
movb (alu_r+1), %al
movb (alu_c), %dl
movl alu_div_shl3_8_d(,%eax,4), %eax
movl alu_div_shl1_8_c_d(%eax,%edx,4), %eax
movb %al, (alu_r+1)
movb %ah, (alu_c)
# end alu_div_shl1_8_c
# alu_div_shl1_8_c
movl $0, %eax
movl $0, %edx
movb (alu_r+2), %al
movb (alu_c), %dl
movl alu_div_shl3_8_d(,%eax,4), %eax
movl alu_div_shl1_8_c_d(%eax,%edx,4), %eax
movb %al, (alu_r+2)
movb %ah, (alu_c)
# end alu_div_shl1_8_c
# alu_div_shl1_8_c
movl $0, %eax
movl $0, %edx
movb (alu_r+3), %al
movb (alu_c), %dl
movl alu_div_shl3_8_d(,%eax,4), %eax
movl alu_div_shl1_8_c_d(%eax,%edx,4), %eax
movb %al, (alu_r+3)
movb %ah, (alu_c)
# end alu_div_shl1_8_c
# end alu_div_shl1_32_c
# alu_div_gte32
movl $0, (alu_c)
movl (alu_r), %eax
movl %eax, (alu_x)
movl (alu_d), %eax
movl %eax, (alu_y)
# alu_sub32
movl $0, %eax
movl $0, %ecx
movl $0x1, (alu_c)
# alu_sub16_fast
movw (alu_x+0), %ax
movw (alu_y+0), %cx
movw alu_inv16(,%ecx,2), %cx
movl alu_add16(,%eax,4), %edx
movl (%edx,%ecx,4), %edx
movl alu_add16(,%edx,4), %edx
movl (alu_c), %ecx
movl (%edx,%ecx,4), %edx
movw %dx, (alu_t+0)
movl %edx, (alu_c-2)
# end alu_sub16_fast
# alu_sub16_fast
movw (alu_x+2), %ax
movw (alu_y+2), %cx
movw alu_inv16(,%ecx,2), %cx
movl alu_add16(,%eax,4), %edx
movl (%edx,%ecx,4), %edx
movl alu_add16(,%edx,4), %edx
movl (alu_c), %ecx
movl (%edx,%ecx,4), %edx
movw %dx, (alu_t+2)
movl %edx, (alu_c-2)
# end alu_sub16_fast
# end alu_sub32
movl $0, %eax
movb (alu_c), %al
movb alu_true(%eax), %al
movl %eax, (alu_t)
# end alu_div_gte32
movl (alu_t), %eax
movl alu_sel_r(,%eax,4), %edx
movl %edx, (alu_psel_r)
movl alu_sel_q(,%eax,4), %edx
movl %edx, (alu_psel_q)
movl (alu_psel_r), %eax
movl (%eax), %eax
movl %eax, (alu_sr)
movl (alu_sr), %eax
movl %eax, (alu_x)
movl (alu_d), %eax
movl %eax, (alu_y)
# alu_sub32
movl $0, %eax
movl $0, %ecx
movl $0x1, (alu_c)
# alu_sub16_fast
movw (alu_x+0), %ax
movw (alu_y+0), %cx
movw alu_inv16(,%ecx,2), %cx
movl alu_add16(,%eax,4), %edx
movl (%edx,%ecx,4), %edx
movl alu_add16(,%edx,4), %edx
movl (alu_c), %ecx
movl (%edx,%ecx,4), %edx
movw %dx, (alu_sr+0)
movl %edx, (alu_c-2)
# end alu_sub16_fast
# alu_sub16_fast
movw (alu_x+2), %ax
movw (alu_y+2), %cx
movw alu_inv16(,%ecx,2), %cx
movl alu_add16(,%eax,4), %edx
movl (%edx,%ecx,4), %edx
movl alu_add16(,%edx,4), %edx
movl (alu_c), %ecx
movl (%edx,%ecx,4), %edx
movw %dx, (alu_sr+2)
movl %edx, (alu_c-2)
# end alu_sub16_fast
# end alu_sub32
movl (alu_psel_r), %eax
movl (alu_sr), %edx
movl %edx, (%eax)
movl (alu_psel_q), %eax
movl (%eax), %eax
movl %eax, (alu_sq)
# alu_div_setb32
movl $0, %eax
movb (alu_sq+0), %al
movb alu_b_s_4(%eax), %al
movb %al, (alu_sq+0)
# end alu_div_setb32
movl (alu_psel_q), %eax
movl (alu_sq), %edx
movl %edx, (%eax)
# alu_bit
movl $0, %edx
movb (alu_n+0), %dl
movl alu_b3(,%edx,4), %eax
movl %eax, (alu_c)
# end alu_bit
# alu_div_shl1_32_c
# alu_div_shl1_8_c
movl $0, %eax
movl $0, %edx
movb (alu_r+0), %al
movb (alu_c), %dl
movl alu_div_shl3_8_d(,%eax,4), %eax
movl alu_div_shl1_8_c_d(%eax,%edx,4), %eax
movb %al, (alu_r+0)
movb %ah, (alu_c)
# end alu_div_shl1_8_c
# alu_div_shl1_8_c
movl $0, %eax
movl $0, %edx
movb (alu_r+1), %al
movb (alu_c), %dl
movl alu_div_shl3_8_d(,%eax,4), %eax
movl alu_div_shl1_8_c_d(%eax,%edx,4), %eax
movb %al, (alu_r+1)
movb %ah, (alu_c)
# end alu_div_shl1_8_c
# alu_div_shl1_8_c
movl $0, %eax
movl $0, %edx
movb (alu_r+2), %al
movb (alu_c), %dl
movl alu_div_shl3_8_d(,%eax,4), %eax
movl alu_div_shl1_8_c_d(%eax,%edx,4), %eax
movb %al, (alu_r+2)
movb %ah, (alu_c)
# end alu_div_shl1_8_c
# alu_div_shl1_8_c
movl $0, %eax
movl $0, %edx
movb (alu_r+3), %al
movb (alu_c), %dl
movl alu_div_shl3_8_d(,%eax,4), %eax
movl alu_div_shl1_8_c_d(%eax,%edx,4), %eax
movb %al, (alu_r+3)
movb %ah, (alu_c)
# end alu_div_shl1_8_c
# end alu_div_shl1_32_c
# alu_div_gte32
movl $0, (alu_c)
movl (alu_r), %eax
movl %eax, (alu_x)
movl (alu_d), %eax
movl %eax, (alu_y)
# alu_sub32
movl $0, %eax
movl $0, %ecx
movl $0x1, (alu_c)
# alu_sub16_fast
movw (alu_x+0), %ax
movw (alu_y+0), %cx
movw alu_inv16(,%ecx,2), %cx
movl alu_add16(,%eax,4), %edx
movl (%edx,%ecx,4), %edx
movl alu_add16(,%edx,4), %edx
movl (alu_c), %ecx
movl (%edx,%ecx,4), %edx
movw %dx, (alu_t+0)
movl %edx, (alu_c-2)
# end alu_sub16_fast
# alu_sub16_fast
movw (alu_x+2), %ax
movw (alu_y+2), %cx
movw alu_inv16(,%ecx,2), %cx
movl alu_add16(,%eax,4), %edx
movl (%edx,%ecx,4), %edx
movl alu_add16(,%edx,4), %edx
movl (alu_c), %ecx
movl (%edx,%ecx,4), %edx
movw %dx, (alu_t+2)
movl %edx, (alu_c-2)
# end alu_sub16_fast
# end alu_sub32
movl $0, %eax
movb (alu_c), %al
movb alu_true(%eax), %al
movl %eax, (alu_t)
# end alu_div_gte32
movl (alu_t), %eax
movl alu_sel_r(,%eax,4), %edx
movl %edx, (alu_psel_r)
movl alu_sel_q(,%eax,4), %edx
movl %edx, (alu_psel_q)
movl (alu_psel_r), %eax
movl (%eax), %eax
movl %eax, (alu_sr)
movl (alu_sr), %eax
movl %eax, (alu_x)
movl (alu_d), %eax
movl %eax, (alu_y)
# alu_sub32
movl $0, %eax
movl $0, %ecx
movl $0x1, (alu_c)
# alu_sub16_fast
movw (alu_x+0), %ax
movw (alu_y+0), %cx
movw alu_inv16(,%ecx,2), %cx
movl alu_add16(,%eax,4), %edx
movl (%edx,%ecx,4), %edx
movl alu_add16(,%edx,4), %edx
movl (alu_c), %ecx
movl (%edx,%ecx,4), %edx
movw %dx, (alu_sr+0)
movl %edx, (alu_c-2)
# end alu_sub16_fast
# alu_sub16_fast
movw (alu_x+2), %ax
movw (alu_y+2), %cx
movw alu_inv16(,%ecx,2), %cx
movl alu_add16(,%eax,4), %edx
movl (%edx,%ecx,4), %edx
movl alu_add16(,%edx,4), %edx
movl (alu_c), %ecx
movl (%edx,%ecx,4), %edx
movw %dx, (alu_sr+2)
movl %edx, (alu_c-2)
# end alu_sub16_fast
# end alu_sub32
movl (alu_psel_r), %eax
movl (alu_sr), %edx
movl %edx, (%eax)
movl (alu_psel_q), %eax
movl (%eax), %eax
movl %eax, (alu_sq)
# alu_div_setb32
movl $0, %eax
movb (alu_sq+0), %al
movb alu_b_s_3(%eax), %al
movb %al, (alu_sq+0)
# end alu_div_setb32
movl (alu_psel_q), %eax
movl (alu_sq), %edx
movl %edx, (%eax)
# alu_bit
movl $0, %edx
movb (alu_n+0), %dl
movl alu_b2(,%edx,4), %eax
movl %eax, (alu_c)
# end alu_bit
# alu_div_shl1_32_c
# alu_div_shl1_8_c
movl $0, %eax
movl $0, %edx
movb (alu_r+0), %al
movb (alu_c), %dl
movl alu_div_shl3_8_d(,%eax,4), %eax
movl alu_div_shl1_8_c_d(%eax,%edx,4), %eax
movb %al, (alu_r+0)
movb %ah, (alu_c)
# end alu_div_shl1_8_c
# alu_div_shl1_8_c
movl $0, %eax
movl $0, %edx
movb (alu_r+1), %al
movb (alu_c), %dl
movl alu_div_shl3_8_d(,%eax,4), %eax
movl alu_div_shl1_8_c_d(%eax,%edx,4), %eax
movb %al, (alu_r+1)
movb %ah, (alu_c)
# end alu_div_shl1_8_c
# alu_div_shl1_8_c
movl $0, %eax
movl $0, %edx
movb (alu_r+2), %al
movb (alu_c), %dl
movl alu_div_shl3_8_d(,%eax,4), %eax
movl alu_div_shl1_8_c_d(%eax,%edx,4), %eax
movb %al, (alu_r+2)
movb %ah, (alu_c)
# end alu_div_shl1_8_c
# alu_div_shl1_8_c
movl $0, %eax
movl $0, %edx
movb (alu_r+3), %al
movb (alu_c), %dl
movl alu_div_shl3_8_d(,%eax,4), %eax
movl alu_div_shl1_8_c_d(%eax,%edx,4), %eax
movb %al, (alu_r+3)
movb %ah, (alu_c)
# end alu_div_shl1_8_c
# end alu_div_shl1_32_c
# alu_div_gte32
movl $0, (alu_c)
movl (alu_r), %eax
movl %eax, (alu_x)
movl (alu_d), %eax
movl %eax, (alu_y)
# alu_sub32
movl $0, %eax
movl $0, %ecx
movl $0x1, (alu_c)
# alu_sub16_fast
movw (alu_x+0), %ax
movw (alu_y+0), %cx
movw alu_inv16(,%ecx,2), %cx
movl alu_add16(,%eax,4), %edx
movl (%edx,%ecx,4), %edx
movl alu_add16(,%edx,4), %edx
movl (alu_c), %ecx
movl (%edx,%ecx,4), %edx
movw %dx, (alu_t+0)
movl %edx, (alu_c-2)
# end alu_sub16_fast
# alu_sub16_fast
movw (alu_x+2), %ax
movw (alu_y+2), %cx
movw alu_inv16(,%ecx,2), %cx
movl alu_add16(,%eax,4), %edx
movl (%edx,%ecx,4), %edx
movl alu_add16(,%edx,4), %edx
movl (alu_c), %ecx
movl (%edx,%ecx,4), %edx
movw %dx, (alu_t+2)
movl %edx, (alu_c-2)
# end alu_sub16_fast
# end alu_sub32
movl $0, %eax
movb (alu_c), %al
movb alu_true(%eax), %al
movl %eax, (alu_t)
# end alu_div_gte32
movl (alu_t), %eax
movl alu_sel_r(,%eax,4), %edx
movl %edx, (alu_psel_r)
movl alu_sel_q(,%eax,4), %edx
movl %edx, (alu_psel_q)
movl (alu_psel_r), %eax
movl (%eax), %eax
movl %eax, (alu_sr)
movl (alu_sr), %eax
movl %eax, (alu_x)
movl (alu_d), %eax
movl %eax, (alu_y)
# alu_sub32
movl $0, %eax
movl $0, %ecx
movl $0x1, (alu_c)
# alu_sub16_fast
movw (alu_x+0), %ax
movw (alu_y+0), %cx
movw alu_inv16(,%ecx,2), %cx
movl alu_add16(,%eax,4), %edx
movl (%edx,%ecx,4), %edx
movl alu_add16(,%edx,4), %edx
movl (alu_c), %ecx
movl (%edx,%ecx,4), %edx
movw %dx, (alu_sr+0)
movl %edx, (alu_c-2)
# end alu_sub16_fast
# alu_sub16_fast
movw (alu_x+2), %ax
movw (alu_y+2), %cx
movw alu_inv16(,%ecx,2), %cx
movl alu_add16(,%eax,4), %edx
movl (%edx,%ecx,4), %edx
movl alu_add16(,%edx,4), %edx
movl (alu_c), %ecx
movl (%edx,%ecx,4), %edx
movw %dx, (alu_sr+2)
movl %edx, (alu_c-2)
# end alu_sub16_fast
# end alu_sub32
movl (alu_psel_r), %eax
movl (alu_sr), %edx
movl %edx, (%eax)
movl (alu_psel_q), %eax
movl (%eax), %eax
movl %eax, (alu_sq)
# alu_div_setb32
movl $0, %eax
movb (alu_sq+0), %al
movb alu_b_s_2(%eax), %al
movb %al, (alu_sq+0)
# end alu_div_setb32
movl (alu_psel_q), %eax
movl (alu_sq), %edx
movl %edx, (%eax)
# alu_bit
movl $0, %edx
movb (alu_n+0), %dl
movl alu_b1(,%edx,4), %eax
movl %eax, (alu_c)
# end alu_bit
# alu_div_shl1_32_c
# alu_div_shl1_8_c
movl $0, %eax
movl $0, %edx
movb (alu_r+0), %al
movb (alu_c), %dl
movl alu_div_shl3_8_d(,%eax,4), %eax
movl alu_div_shl1_8_c_d(%eax,%edx,4), %eax
movb %al, (alu_r+0)
movb %ah, (alu_c)
# end alu_div_shl1_8_c
# alu_div_shl1_8_c
movl $0, %eax
movl $0, %edx
movb (alu_r+1), %al
movb (alu_c), %dl
movl alu_div_shl3_8_d(,%eax,4), %eax
movl alu_div_shl1_8_c_d(%eax,%edx,4), %eax
movb %al, (alu_r+1)
movb %ah, (alu_c)
# end alu_div_shl1_8_c
# alu_div_shl1_8_c
movl $0, %eax
movl $0, %edx
movb (alu_r+2), %al
movb (alu_c), %dl
movl alu_div_shl3_8_d(,%eax,4), %eax
movl alu_div_shl1_8_c_d(%eax,%edx,4), %eax
movb %al, (alu_r+2)
movb %ah, (alu_c)
# end alu_div_shl1_8_c
# alu_div_shl1_8_c
movl $0, %eax
movl $0, %edx
movb (alu_r+3), %al
movb (alu_c), %dl
movl alu_div_shl3_8_d(,%eax,4), %eax
movl alu_div_shl1_8_c_d(%eax,%edx,4), %eax
movb %al, (alu_r+3)
movb %ah, (alu_c)
# end alu_div_shl1_8_c
# end alu_div_shl1_32_c
# alu_div_gte32
movl $0, (alu_c)
movl (alu_r), %eax
movl %eax, (alu_x)
movl (alu_d), %eax
movl %eax, (alu_y)
# alu_sub32
movl $0, %eax
movl $0, %ecx
movl $0x1, (alu_c)
# alu_sub16_fast
movw (alu_x+0), %ax
movw (alu_y+0), %cx
movw alu_inv16(,%ecx,2), %cx
movl alu_add16(,%eax,4), %edx
movl (%edx,%ecx,4), %edx
movl alu_add16(,%edx,4), %edx
movl (alu_c), %ecx
movl (%edx,%ecx,4), %edx
movw %dx, (alu_t+0)
movl %edx, (alu_c-2)
# end alu_sub16_fast
# alu_sub16_fast
movw (alu_x+2), %ax
movw (alu_y+2), %cx
movw alu_inv16(,%ecx,2), %cx
movl alu_add16(,%eax,4), %edx
movl (%edx,%ecx,4), %edx
movl alu_add16(,%edx,4), %edx
movl (alu_c), %ecx
movl (%edx,%ecx,4), %edx
movw %dx, (alu_t+2)
movl %edx, (alu_c-2)
# end alu_sub16_fast
# end alu_sub32
movl $0, %eax
movb (alu_c), %al
movb alu_true(%eax), %al
movl %eax, (alu_t)
# end alu_div_gte32
movl (alu_t), %eax
movl alu_sel_r(,%eax,4), %edx
movl %edx, (alu_psel_r)
movl alu_sel_q(,%eax,4), %edx
movl %edx, (alu_psel_q)
movl (alu_psel_r), %eax
movl (%eax), %eax
movl %eax, (alu_sr)
movl (alu_sr), %eax
movl %eax, (alu_x)
movl (alu_d), %eax
movl %eax, (alu_y)
# alu_sub32
movl $0, %eax
movl $0, %ecx
movl $0x1, (alu_c)
# alu_sub16_fast
movw (alu_x+0), %ax
movw (alu_y+0), %cx
movw alu_inv16(,%ecx,2), %cx
movl alu_add16(,%eax,4), %edx
movl (%edx,%ecx,4), %edx
movl alu_add16(,%edx,4), %edx
movl (alu_c), %ecx
movl (%edx,%ecx,4), %edx
movw %dx, (alu_sr+0)
movl %edx, (alu_c-2)
# end alu_sub16_fast
# alu_sub16_fast
movw (alu_x+2), %ax
movw (alu_y+2), %cx
movw alu_inv16(,%ecx,2), %cx
movl alu_add16(,%eax,4), %edx
movl (%edx,%ecx,4), %edx
movl alu_add16(,%edx,4), %edx
movl (alu_c), %ecx
movl (%edx,%ecx,4), %edx
movw %dx, (alu_sr+2)
movl %edx, (alu_c-2)
# end alu_sub16_fast
# end alu_sub32
movl (alu_psel_r), %eax
movl (alu_sr), %edx
movl %edx, (%eax)
movl (alu_psel_q), %eax
movl (%eax), %eax
movl %eax, (alu_sq)
# alu_div_setb32
movl $0, %eax
movb (alu_sq+0), %al
movb alu_b_s_1(%eax), %al
movb %al, (alu_sq+0)
# end alu_div_setb32
movl (alu_psel_q), %eax
movl (alu_sq), %edx
movl %edx, (%eax)
# alu_bit
movl $0, %edx
movb (alu_n+0), %dl
movl alu_b0(,%edx,4), %eax
movl %eax, (alu_c)
# end alu_bit
# alu_div_shl1_32_c
# alu_div_shl1_8_c
movl $0, %eax
movl $0, %edx
movb (alu_r+0), %al
movb (alu_c), %dl
movl alu_div_shl3_8_d(,%eax,4), %eax
movl alu_div_shl1_8_c_d(%eax,%edx,4), %eax
movb %al, (alu_r+0)
movb %ah, (alu_c)
# end alu_div_shl1_8_c
# alu_div_shl1_8_c
movl $0, %eax
movl $0, %edx
movb (alu_r+1), %al
movb (alu_c), %dl
movl alu_div_shl3_8_d(,%eax,4), %eax
movl alu_div_shl1_8_c_d(%eax,%edx,4), %eax
movb %al, (alu_r+1)
movb %ah, (alu_c)
# end alu_div_shl1_8_c
# alu_div_shl1_8_c
movl $0, %eax
movl $0, %edx
movb (alu_r+2), %al
movb (alu_c), %dl
movl alu_div_shl3_8_d(,%eax,4), %eax
movl alu_div_shl1_8_c_d(%eax,%edx,4), %eax
movb %al, (alu_r+2)
movb %ah, (alu_c)
# end alu_div_shl1_8_c
# alu_div_shl1_8_c
movl $0, %eax
movl $0, %edx
movb (alu_r+3), %al
movb (alu_c), %dl
movl alu_div_shl3_8_d(,%eax,4), %eax
movl alu_div_shl1_8_c_d(%eax,%edx,4), %eax
movb %al, (alu_r+3)
movb %ah, (alu_c)
# end alu_div_shl1_8_c
# end alu_div_shl1_32_c
# alu_div_gte32
movl $0, (alu_c)
movl (alu_r), %eax
movl %eax, (alu_x)
movl (alu_d), %eax
movl %eax, (alu_y)
# alu_sub32
movl $0, %eax
movl $0, %ecx
movl $0x1, (alu_c)
# alu_sub16_fast
movw (alu_x+0), %ax
movw (alu_y+0), %cx
movw alu_inv16(,%ecx,2), %cx
movl alu_add16(,%eax,4), %edx
movl (%edx,%ecx,4), %edx
movl alu_add16(,%edx,4), %edx
movl (alu_c), %ecx
movl (%edx,%ecx,4), %edx
movw %dx, (alu_t+0)
movl %edx, (alu_c-2)
# end alu_sub16_fast
# alu_sub16_fast
movw (alu_x+2), %ax
movw (alu_y+2), %cx
movw alu_inv16(,%ecx,2), %cx
movl alu_add16(,%eax,4), %edx
movl (%edx,%ecx,4), %edx
movl alu_add16(,%edx,4), %edx
movl (alu_c), %ecx
movl (%edx,%ecx,4), %edx
movw %dx, (alu_t+2)
movl %edx, (alu_c-2)
# end alu_sub16_fast
# end alu_sub32
movl $0, %eax
movb (alu_c), %al
movb alu_true(%eax), %al
movl %eax, (alu_t)
# end alu_div_gte32
movl (alu_t), %eax
movl alu_sel_r(,%eax,4), %edx
movl %edx, (alu_psel_r)
movl alu_sel_q(,%eax,4), %edx
movl %edx, (alu_psel_q)
movl (alu_psel_r), %eax
movl (%eax), %eax
movl %eax, (alu_sr)
movl (alu_sr), %eax
movl %eax, (alu_x)
movl (alu_d), %eax
movl %eax, (alu_y)
# alu_sub32
movl $0, %eax
movl $0, %ecx
movl $0x1, (alu_c)
# alu_sub16_fast
movw (alu_x+0), %ax
movw (alu_y+0), %cx
movw alu_inv16(,%ecx,2), %cx
movl alu_add16(,%eax,4), %edx
movl (%edx,%ecx,4), %edx
movl alu_add16(,%edx,4), %edx
movl (alu_c), %ecx
movl (%edx,%ecx,4), %edx
movw %dx, (alu_sr+0)
movl %edx, (alu_c-2)
# end alu_sub16_fast
# alu_sub16_fast
movw (alu_x+2), %ax
movw (alu_y+2), %cx
movw alu_inv16(,%ecx,2), %cx
movl alu_add16(,%eax,4), %edx
movl (%edx,%ecx,4), %edx
movl alu_add16(,%edx,4), %edx
movl (alu_c), %ecx
movl (%edx,%ecx,4), %edx
movw %dx, (alu_sr+2)
movl %edx, (alu_c-2)
# end alu_sub16_fast
# end alu_sub32
movl (alu_psel_r), %eax
movl (alu_sr), %edx
movl %edx, (%eax)
movl (alu_psel_q), %eax
movl (%eax), %eax
movl %eax, (alu_sq)
# alu_div_setb32
movl $0, %eax
movb (alu_sq+0), %al
movb alu_b_s_0(%eax), %al
movb %al, (alu_sq+0)
# end alu_div_setb32
movl (alu_psel_q), %eax
movl (alu_sq), %edx
movl %edx, (%eax)
# end alu_divrem
movl (alu_r), %eax
# end alu_umod
movl %eax, (R2)

# end emit modu

# emit/mov>subu4(indiru4(vregp(4)),modu4(addu4(subu4(indiru4(addrlp4(v)),indiru4(vregp(4))),cnstu4(13)),cnstu4(26)))

# emit subu

movl (R3), %eax
movl (R2), %edx
# alu_sub
movl %eax, (alu_x)
movl %edx, (alu_y)
# alu_sub32
movl $0, %eax
movl $0, %ecx
movl $0x1, (alu_c)
# alu_sub16_fast
movw (alu_x+0), %ax
movw (alu_y+0), %cx
movw alu_inv16(,%ecx,2), %cx
movl alu_add16(,%eax,4), %edx
movl (%edx,%ecx,4), %edx
movl alu_add16(,%edx,4), %edx
movl (alu_c), %ecx
movl (%edx,%ecx,4), %edx
movw %dx, (alu_s+0)
movl %edx, (alu_c-2)
# end alu_sub16_fast
# alu_sub16_fast
movw (alu_x+2), %ax
movw (alu_y+2), %cx
movw alu_inv16(,%ecx,2), %cx
movl alu_add16(,%eax,4), %edx
movl (%edx,%ecx,4), %edx
movl alu_add16(,%edx,4), %edx
movl (alu_c), %ecx
movl (%edx,%ecx,4), %edx
movw %dx, (alu_s+2)
movl %edx, (alu_c-2)
# end alu_sub16_fast
# end alu_sub32
movl (alu_s), %eax
# end alu_sub
movl %eax, (R3)

# end emit subu

# emit/mov>asgnu4(addrlp4(v),subu4(indiru4(vregp(4)),modu4(addu4(subu4(indiru4(addrlp4(v)),indiru4(vregp(4))),cnstu4(13)),cnstu4(26))))

# emit asgnu

# (ADDRL)
# (offset -4)
movl (fp), %eax
movl push(%eax), %eax
movl (on), %edx
# select data %eax %edx
movl %eax, (data_p)
movl sel_data(,%edx,4), %eax
# end select data
movl (R3), %edx
movl %edx, (%eax)

# end emit asgnu

# emit/mov>labelv(16)

# emit labelv

.LCI16:

# end emit labelv

# emit/mov>labelv(15)

# emit labelv

.LCI15:

# end emit labelv

# emit/mov>cnstp4(0x40000000)
movl $0x40000000, (R3)
# emit/mov>addrlp4(v)

# emit addrlp

# (offset -4)
movl (fp), %eax
movl push(%eax), %eax
movl %eax, (R2)

# end emit addrlp

# emit/mov>indiru4(addrlp4(v))

# emit indiru

movl (R2), %eax
movl (on), %edx
# select data %eax %edx
movl %eax, (data_p)
movl sel_data(,%edx,4), %eax
# end select data
movl (%eax), %eax
movl %eax, (R2)

# end emit indiru

# emit/mov>asgnu4(cnstp4(0x40000000),indiru4(addrlp4(v)))

# emit asgnu

# (!ADDRL)
movl (R3), %eax
movl (on), %edx
# select data %eax %edx
movl %eax, (data_p)
movl sel_data(,%edx,4), %eax
# end select data
movl (R2), %edx
movl %edx, (%eax)

# end emit asgnu

# emit/mov>labelv(12)

# emit labelv

.LCI12:

# end emit labelv

# emit/mov>labelv(10)

# emit labelv

.LCI10:

# end emit labelv

# emit/mov>jumpv(addrgp4(9))

# emit jumpv

jmp .LCI9

# end emit jumpv

# emit/mov>cnsti4(0)
movl $0, (R0)
# emit/mov>reti4(cnsti4(0))

# emit reti


# end emit reti

# emit/mov>labelv(7)

# emit labelv

.LCI7:

# end emit labelv

# epilogue
# movl %ebp, %esp
movl $sp, %eax
movl (on), %edx
# select data %eax %edx
movl %eax, (data_p)
movl sel_data(,%edx,4), %eax
# end select data
movl (fp), %edx
movl %edx, (%eax)
# end movl %ebp, %esp
# pop8 D2
movl (sp), %eax
movl (%eax), %edx
movl %edx, (stack_temp)
movl 4(%eax), %edx
movl %edx, (stack_temp+4)
movl $sp, %eax
movl (on), %edx
# select data %eax %edx
movl %eax, (data_p)
movl sel_data(,%edx,4), %eax
# end select data
movl (sp), %edx
movl pop(%edx), %edx
movl pop(%edx), %edx
movl %edx, (%eax)
movl $D2, %eax
movl (on), %edx
# select data %eax %edx
movl %eax, (data_p)
movl sel_data(,%edx,4), %eax
# end select data
movl (stack_temp), %edx
movl %edx, (%eax)
movl (stack_temp+4), %edx
movl %edx, 4(%eax)
# end pop8
# pop8 D1
movl (sp), %eax
movl (%eax), %edx
movl %edx, (stack_temp)
movl 4(%eax), %edx
movl %edx, (stack_temp+4)
movl $sp, %eax
movl (on), %edx
# select data %eax %edx
movl %eax, (data_p)
movl sel_data(,%edx,4), %eax
# end select data
movl (sp), %edx
movl pop(%edx), %edx
movl pop(%edx), %edx
movl %edx, (%eax)
movl $D1, %eax
movl (on), %edx
# select data %eax %edx
movl %eax, (data_p)
movl sel_data(,%edx,4), %eax
# end select data
movl (stack_temp), %edx
movl %edx, (%eax)
movl (stack_temp+4), %edx
movl %edx, 4(%eax)
# end pop8
# pop F2
movl (sp), %eax
movl (%eax), %edx
movl %edx, (stack_temp)
movl $sp, %eax
movl (on), %edx
# select data %eax %edx
movl %eax, (data_p)
movl sel_data(,%edx,4), %eax
# end select data
movl (sp), %edx
movl pop(%edx), %edx
movl %edx, (%eax)
movl $F2, %eax
movl (on), %edx
# select data %eax %edx
movl %eax, (data_p)
movl sel_data(,%edx,4), %eax
# end select data
movl (stack_temp), %edx
movl %edx, (%eax)
# end pop
# pop F1
movl (sp), %eax
movl (%eax), %edx
movl %edx, (stack_temp)
movl $sp, %eax
movl (on), %edx
# select data %eax %edx
movl %eax, (data_p)
movl sel_data(,%edx,4), %eax
# end select data
movl (sp), %edx
movl pop(%edx), %edx
movl %edx, (%eax)
movl $F1, %eax
movl (on), %edx
# select data %eax %edx
movl %eax, (data_p)
movl sel_data(,%edx,4), %eax
# end select data
movl (stack_temp), %edx
movl %edx, (%eax)
# end pop
# pop R3
movl (sp), %eax
movl (%eax), %edx
movl %edx, (stack_temp)
movl $sp, %eax
movl (on), %edx
# select data %eax %edx
movl %eax, (data_p)
movl sel_data(,%edx,4), %eax
# end select data
movl (sp), %edx
movl pop(%edx), %edx
movl %edx, (%eax)
movl $R3, %eax
movl (on), %edx
# select data %eax %edx
movl %eax, (data_p)
movl sel_data(,%edx,4), %eax
# end select data
movl (stack_temp), %edx
movl %edx, (%eax)
# end pop
# pop R2
movl (sp), %eax
movl (%eax), %edx
movl %edx, (stack_temp)
movl $sp, %eax
movl (on), %edx
# select data %eax %edx
movl %eax, (data_p)
movl sel_data(,%edx,4), %eax
# end select data
movl (sp), %edx
movl pop(%edx), %edx
movl %edx, (%eax)
movl $R2, %eax
movl (on), %edx
# select data %eax %edx
movl %eax, (data_p)
movl sel_data(,%edx,4), %eax
# end select data
movl (stack_temp), %edx
movl %edx, (%eax)
# end pop
# pop R1
movl (sp), %eax
movl (%eax), %edx
movl %edx, (stack_temp)
movl $sp, %eax
movl (on), %edx
# select data %eax %edx
movl %eax, (data_p)
movl sel_data(,%edx,4), %eax
# end select data
movl (sp), %edx
movl pop(%edx), %edx
movl %edx, (%eax)
movl $R1, %eax
movl (on), %edx
# select data %eax %edx
movl %eax, (data_p)
movl sel_data(,%edx,4), %eax
# end select data
movl (stack_temp), %edx
movl %edx, (%eax)
# end pop
# pop fp
movl (sp), %eax
movl (%eax), %edx
movl %edx, (stack_temp)
movl $sp, %eax
movl (on), %edx
# select data %eax %edx
movl %eax, (data_p)
movl sel_data(,%edx,4), %eax
# end select data
movl (sp), %edx
movl pop(%edx), %edx
movl %edx, (%eax)
movl $fp, %eax
movl (on), %edx
# select data %eax %edx
movl %eax, (data_p)
movl sel_data(,%edx,4), %eax
# end select data
movl (stack_temp), %edx
movl %edx, (%eax)
# end pop
# ret
# pop %eax
movl (sp), %eax
movl (%eax), %edx
movl %edx, (stack_temp)
movl $sp, %eax
movl (on), %edx
# select data %eax %edx
movl %eax, (data_p)
movl sel_data(,%edx,4), %eax
# end select data
movl (sp), %edx
movl pop(%edx), %edx
movl %edx, (%eax)
movl (stack_temp), %edx
movl %edx, %eax
# end pop
jmp *%eax
# end ret
.Lf19:
.size main,.Lf19-main


.section .plt

.data
.LCS8:  # <LCS>
.byte 0x74
.byte 0x68
.byte 0x65
.byte 0x20
.byte 0x77
.byte 0x6f
.byte 0x72
.byte 0x6c
.byte 0x64
.byte 0x20
.byte 0x69
.byte 0x73
.byte 0x20
.byte 0x61
.byte 0x20
.byte 0x6d
.byte 0x6f
.byte 0x76
.byte 0x69
.byte 0x6e
.byte 0x67
.byte 0x20
.byte 0x74
.byte 0x61
.byte 0x72
.byte 0x67
.byte 0x65
.byte 0x74
.byte 0x20
.byte 0x2e
.byte 0x2e
.byte 0x2e
.byte 0x2e
.byte 0xd
.byte 0xa
.byte 0x0

.text
