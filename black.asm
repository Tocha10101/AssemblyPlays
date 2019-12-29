	.data

header:		.space	54
div_value:	.word	0xFFFFFFFF
red:		.byte	0xff

errorMessage:	.asciiz	"Can't open the file"
success:	.asciiz "Correct execution"
created:	.asciiz	"Created the black file"

s_size:		.asciiz	"Size:\t\t"
s_width:	.asciiz	"Width:\t\t"
s_height:	.asciiz "Height:\t\t"
s_bpp:		.asciiz	"Bits Per Pixel:\t"
s_padding:	.asciiz "Padding: \t"
newline:	.asciiz "\n"

s_cos:		.asciiz "Enter a cosine of the angle * (2 ^ 32): "

input:		"C:\\Users\\Antek\\Desktop\\Assembly plays\\input.bmp"
output:		"C:\\Users\\Antek\\Desktop\\Assembly plays\\black.bmp"

s_sin:		.asciiz "Enter a sine of the angle * (2 ^ 32): "

.align	2
width:		.space	4
height:		.space	4
cos:		.space	4
sin:		.space	4

	.text
	.globl main
	
main:

	# s2 - row length in bytes
	# k1 - padding
	# t8 - pointer to the allocated space for PIXELS
	# t7 - size
	# t6 - width
	# t5 - height
	# t4 - bits per pixel
	# s0 - i (width) iterator
	# s1 - j (height) iterator
	# s7 - the red value to write
	
	
	
	
	# reads the cosine
	la	$a0, s_cos
	li	$v0, 4
	syscall
	
	li	$v0, 5
	syscall
	
	sw	$v0, cos
	move	$s0, $v0
	
	
	li	$v0, 4
	la	$a0, newline
	syscall

	la	$s2, div_value
	divu	$s0, $s2
	mfhi	$a0
	
	li	$v0, 1
	syscall
	
	li	$v0, 4
	la	$a0, newline
	syscall
	
	# reads the sine
	la	$a0, s_sin
	li	$v0, 4
	syscall
	
	li	$v0, 5
	syscall
	sw	$v0, sin
	move	$s1, $v0
	
	li	$v0, 4
	la	$a0, newline
	syscall
	
	# otwieranie pliku
	la	$a0, input
	li	$a1, 0
	li	$a2, 0
	li	$v0, 13
	syscall
	
	# sprawdzenie poprawno?ci otwarcia pliku
	move	$t0, $v0	# zachowujemy w t0 deskryptor
	bltz	$t0, error
	
	# czytanie headera
	move	$a0, $t0
	li	$v0, 14
	la	$a1, header
	li	$a2, 54
	syscall
	
	la	$k0, header
	
	ulw	$t7, 2($k0)	# od tej pory size siedzi w rejestrze t7
	
	ulw	$t6, 18($k0)	# umieszczamy width w rejestrze t6
	
	ulw	$t5, 22($k0)	# umieszczamy height w $t5
	
	ulw	$t4, 28($k0)	# bpp w t4
	
	# padding
	li	$t2, 4
	div	$t6, $t2
	mfhi	$k1		# num of padding bytes
	
	
	# WYPISANIE INFORMACJI
	# size
	la	$a0, s_size
	li	$v0, 4
	syscall
	
	move	$a0, $t7
	li	$v0, 1
	syscall
	
	la	$a0, newline
	li	$v0, 4
	syscall
	
	# width
	la	$a0, s_width
	li	$v0, 4
	syscall
	
	move	$a0, $t6
	li	$v0, 1
	syscall
	
	la	$a0, newline
	li	$v0, 4
	syscall
	
	# height
	la	$a0, s_height
	li	$v0, 4
	syscall
	
	move	$a0, $t5
	li	$v0, 1
	syscall
	
	la	$a0, newline
	li	$v0, 4
	syscall
	
	# bpp
	la	$a0, s_bpp
	li	$v0, 4
	syscall
	
	move	$a0, $t4
	li	$v0, 1
	syscall
	
	la	$a0, newline
	li	$v0, 4
	syscall
	
	# padding
	la	$a0, s_padding
	li	$v0, 4
	syscall
	
	move	$a0, $k1
	li	$v0, 1
	syscall
	
	la	$a0, newline
	li	$v0, 4
	syscall
	
	# alokacja pami?ci na ca?y plik
	li	$v0, 9
	move	$a0, $t7	# ilosc pamieci
	syscall
	
	move	$t1, $v0	# adres do zaalokowanej pamieci
	
	# alokacja pami?ci tylko na pixele
	li	$v0, 9
	subiu	$t7, $t7, 54
	move	$a0, $t7
	addiu	$t7, $t7, 54
	syscall
	
	move	$t8, $v0	# pointer do zaalokowanych pixeli
		
	move	$s0, $zero
	move	$s1, $zero
		
	addi 	$s7, $zero, 3	# only in this place s7 is for multiplication
	mul 	$s2, $t6, $s7
	addu	$s2, $s2, $k1	# row_length in bytes
	# let's color it into red	
	loop_outter:
		la	$t9, ($t8)	# perhaps you don't need it in future
		mul	$t3, $s2, $s1	# j mnozymy przez row_length
		addu	$t9, $t9, $t3	# do odpowiedniego wiersza
		
		li	$v0, 1
		move	$a0, $s1
		syscall
		li	$v0, 4
		la	$a0, newline
		syscall
		
		loop_inner:
			lb	$s7, red
			sb	$zero, ($t9)
			sb	$zero, 1($t9)
			sb	$s7, 2($t9)
			addi	$t9, $t9, 3		# 3 bajty na pixel -> moving to the next pixel
			addi	$s0, $s0, 1		# i++
			blt	$s0, $t6, loop_inner	# i < width
			move	$s0, $zero
		
		addi	$s1, $s1, 1			# j++
		blt	$s1, $t5, loop_outter		# j < height
	
	# wczytanie pliku do pamieci
	move	$a0, $t0
	la	$a1, ($t1)
	la	$a2, ($t7)
	li	$v0, 14
	syscall
	
	# zamykanie pliku
	move 	$a0, $t0
	li	$v0, 16
	syscall
	# Zapis do pliku
	# otwieranie
	la	$a0, output
	li	$a1, 1		# DAFAQ?? - Podobne do append mode - 9
	li	$a2, 0
	li	$v0, 13
	
	syscall
	move	$t0, $v0
	
	# sprawdzenie czy sie poprawnie otworzyl
	bltz	$t0, error
	# HEADER WRITING
	la	$a0, ($t0)
	la	$a1, header
	li	$a2, 54
	li	$v0, 15
	syscall
	
	# modifying pixels
	
	# PIXEL WRITING TO FILE
	la	$a1, ($t8)
	subiu	$t7, $t7, 54
	la	$a2, ($t7)
	addiu	$t7, $t7, 54
	li	$v0, 15
	syscall
	
	li	$v0, 4
	la	$a0, success
	syscall
	
	
	# zamkniecie pliku
	move	$a0, $t0
	li	$v0, 16
	syscall
	
	# koniec programu
	la	$v0, 10
	syscall
	
error:
	li	$v0, 4
	la	$a0, errorMessage
	syscall
	
