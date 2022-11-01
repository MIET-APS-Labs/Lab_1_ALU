li x1, 0  # cntr
li x2, 5  # op 1
li x3, 8  # op 2
li x4, 0  # res
beq x1, x2, 16 # if x1 == x2 then 4
add x4, x3, x4 # x4 = x3 + x3
addi x1, x1, 1 # x1 = x1 + 1
jal x0, -12  # jump to -3 and save position to ra
add x0, x4, x0 # x0 = x4 + x0
nop




