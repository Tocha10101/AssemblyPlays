	.data

size:		.space 	4
height:		.space	4
width:		.space	4
temp:		.space	4
bits_per_pixel:	.space	4
header:		.space	54

errorMessage:	.asciiz	"Can't open the file"
success:	.asciiz "Correct execution"
created:	.asciiz	"Created the black file"

s_size:		.asciiz	"Size:\t\t"
s_width:	.asciiz	"Width:\t\t"
s_height:	.asciiz "Height:\t\t"
s_bpp:		.asciiz	"Bits Per Pixel:\t"
newline:	.asciiz "\n"

input:		"C:\\Users\\Antek\\Desktop\\Assembly plays\\LAND.bmp"
output:		"C:\\Users\\Antek\\Desktop\\Assembly plays\\black.bmp"
	.text
	.globl main
	
main:
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
	
	
	# a variable to count the iterations
	# li	$t2, 0
	# move	$k0, $t1
	# loop_h:
	# 	lb	$t3, ($t1)	# let's see if it works
	#	sb	$t3, header
	#	addiu	$t1, $t1, 1
	#	addiu	$t2, $t2, 1
	#	bne	$t2, 53, loop_h
	
	
	move $k0, $t1
	# HEADER WRITING
	la	$a0, ($t0)
	la	$a1, header
	li	$a2, 54
	li	$v0, 15
	syscall
	
	# PIXEL WRITING
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
	
