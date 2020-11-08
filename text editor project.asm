INCLUDE Irvine32.inc
.data

error byte "can't open file !",0
msg1 byte "please enter file path : ",0
file_path byte 20 dup(?)
FileHandle Handle ? 
buffer_size = 5000
count1 dword ?

buffer byte buffer_size dup (?)


.code
main PROC

;msg1 : "enter path"

mov edx , offset msg1 
call writestring
;call crlf  

; enter path code
 
 mov edx , offset file_path
  mov ecx , lengthof file_path
 call readstring
 ; mov ecx , eax 
 call crlf
call MENU ; display menu to user 
call readdec
call CHOOSE  ; choose function

back :
  exit
main ENDP
;--------------------------------------------------
; print menu to user to select any function he want
;--------------------------------------------------
.data

msg2 byte "enter Number of Function : ",0

L1 byte "           <1>READ ",0
L2 byte "           <2>DISPLAY",0
L3 byte "           <3>APPEND",0
L4 byte "           <4>FIND",0
L5 byte "           <5>REPLACE",0
L6 byte "           <6>REMOVE",0
L7 byte "           <7>COUNT CHARACTERS AND WORDS",0
L8 byte "           <8>WRITE",0
L9 byte "           <9>EXIT",0


.code 
MENU proc 

mov edx , offset msg2 
call writestring
call crlf

mov edx ,offset L1
call writestring
call crlf

mov edx ,offset L2
call writestring
call crlf

mov edx ,offset L3
call writestring
call crlf

mov edx ,offset L4
call writestring
call crlf

mov edx ,offset L5
call writestring
call crlf

mov edx ,offset L6
call writestring
call crlf

mov edx ,offset L7
call writestring
call crlf

mov edx ,offset L8
call writestring
call crlf

mov edx ,offset L9
call writestring
call crlf

ret
MENU endp
;------------------------------------------------
; choose number of functions
;------------------------------------------------

.data
cheak_file byte "file was READ !!",0

.code
CHOOSE proc

cmp eax , 1
jne label2
call READ_FILE

mov edx , offset cheak_file
call writestring
call crlf
jmp EXT 


label2 :

cmp eax , 2
jne label3
call DISPLAY_FILE
jmp EXT

label3 :

cmp eax , 3
jne label4
call APPEND
jmp EXT

label4 :
cmp eax , 4
jne label5
call FIND
jmp EXT

label5 :

cmp eax , 5
jne label6
call REPLACE
jmp EXT

label6 :

cmp eax , 6
jne label7
call REMOVE
jmp EXT

label7 :

cmp eax , 7
jne label8
call calculate
jmp EXT

label8 :
cmp eax , 8
jne label9
;call WRITE
jmp EXT

label9 :
cmp eax , 9
ret


EXT :
call MENU
call readdec
call CHOOSE

ret
CHOOSE endp
;--------------------------------------------
;Function(1): READ from file
;--------------------------------------------

.code
READ_FILE proc

mov edx , offset file_path
call OpenInputFile
mov FileHandle , eax
cmp eax , INVALID_HANDLE_VALUE

jne file_ok
mov edx , offset error
call writestring
jmp ext

file_ok:

mov edx , offset buffer
mov ecx ,lengthof buffer 
call readfromfile

mov count1 , eax

ext :
mov eax,FileHandle
call closefile
ret
READ_FILE endp
;----------------------------------------------
;DISPLAY FILE 
;----------------------------------------------

.data

.code
DISPLAY_FILE proc

call READ_FILE

mov edx , offset buffer 
call writestring
call crlf

ext :

ret
DISPLAY_FILE endp
;----------------------------------------------
;append string at last of file 
;----------------------------------------------

.data
bag1 dword ?
append_string byte 100 dup (?)
msg4 byte "enter string : ",0
str_len dword ?
target dword buffer_size dup(?)
.code
APPEND proc
;invoke str_copy , addr buffer ,addr target   ;copy string from buffer to target

mov edx , offset msg4
call writestring
call crlf

mov ecx ,lengthof append_string
mov edx , offset append_string
call readstring
mov str_len , eax
add eax , count1
mov bag1 , eax
mov esi , offset append_string
mov edi , offset buffer
add edi ,count1
;mov al," "
;mov [edi],al
mov ecx , lengthof append_string

l : 

mov bl ,[esi]
mov  [edi] ,bl
add edi ,type buffer
add esi , type append_string

loop l

mov eax,0
mov edx , offset file_path
call createoutputfile

mov FileHandle ,eax

mov edx , offset buffer
mov ecx ,bag1
mov  eax,FileHandle

call writetofile
mov eax ,FileHandle
call closefile
ret
APPEND endp
;----------------------------------------------
; count words and characters
;-----------------------------------------------

.data
chars dword ?
words dword ?
msg5 byte "number of characters : ",0
msg6 byte "number of words : ",0

.code
calculate proc

mov ecx , count1
mov esi ,0

mov chars ,0
mov words ,0

loo:
cmp ecx ,1
jne cont
inc words
cont:
mov al , buffer [esi]

cmp al ,' '
je skip

cmp al , 0dh
je p2

cmp al , 0ah
je p2 

jmp p3  ;not enter 

p2 : 
inc words
dec ecx
inc esi
jmp  p1

p3 :

inc chars

jmp p1

skip :

inc words

p1 :
inc esi

loop loo

mov edx , offset msg5
call writestring
mov eax , chars 
call writedec
call crlf
mov edx , offset msg6
call writestring
mov eax , words
call writedec
call crlf
ret
calculate endp

;---------------------------------------------
;find
;----------------------------------------------
.data

bag2 dword ?
find_string byte 1000 dup(?)
counter dword 0
mmsg1 byte "enter string : ",0
mmsg2 byte "string found ",0
mmsg3 byte "string not found",0
mmsg4 byte "number of repeted string : ",0
variable dword 0
.code
FIND proc

mov edx , offset mmsg1
call writestring
mov bag2 ,0
mov edx , offset find_string
mov ecx , lengthof find_string
call readstring
mov counter ,eax

mov ecx , count1
mov esi ,0
mov edi ,0

check :
mov al , find_string[esi]
mov bl ,buffer [edi]
cmp al ,bl 
jne not_equ

inc esi
inc edi 
inc variable

jmp nxtt

not_equ :
mov esi ,0
inc edi
mov variable ,0

nxtt :
mov eax , variable
cmp eax , counter
je found 

again :
loop check
;cmp esi , ' '
;jne noStringFound

jmp checkbag

found :

inc bag2
jmp again 

checkbag:
;inc edi
cmp bag2,0
jna noStringFound

;inc edi
;cmp edi , ' '
;je noStringFound

mov edx , offset mmsg2
mov ebx ,0
call msgbox
jmp Skip

noStringFound:
mov edx , offset mmsg3
mov ebx ,0
call msgbox

Skip :
mov edx, offset mmsg4
call writestring
mov eax, bag2
call writedec
call crlf
ret
FIND endp

;-------------------------------------------------------
;remove
;-------------------------------------------------------
.data
tmp dword 0
str1 byte "enter string : ",0
str2 byte "enter number of replacement : ",0
str3 byte  "string wasn't found!! ",0
num dword ? 
remove_string byte 20 dup(?)
check dword 0
search_str dword 0
times dword 0
var3 dword 0
var4 dword 0
.code

REMOVE proc

mov edx , offset str2
call writestring

call readdec 
mov num, eax

;mov ebx ,offset file_buffer
mov edx , offset str1
call writestring

mov edx , offset remove_string
mov ecx ,lengthof remove_string
call readstring

call crlf

mov ecx , lengthof remove_string
mov search_str ,eax  

mov esi , offset buffer
mov edi ,offset remove_string

mov ecx , count1 
ooo: 
goo :
mov tmp ,ecx
mov al , byte ptr [edi]
mov bl , byte ptr [esi]
cmp al ,bl 
jne noo
mov edi ,offset remove_string
mov edx ,esi
mov ecx , search_str 
second :
mov al , byte ptr  [edi]
mov bl , byte ptr [edx]
cmp al ,bl
jne noo
inc edx
inc edi
loop second
;---
sub edi , search_str 
inc edi 
;push edi
mov esi ,edx 
push esi
mov esi ,edx
sub edx , search_str
mov edi , edx
push ecx
mov ecx , count1
;sub ecx,var3

cld
rep movsb
inc var4

pop ecx
pop esi
mov edi , offset remove_string
mov esi , offset buffer
;mov edx , 0
mov ebx ,num
cmp var4 ,ebx
jne goo
jmp ext
noo :
call remov 

loop ooo

ext :
mov eax,0
mov edx , offset file_path
call createoutputfile

mov FileHandle ,eax

mov edx , offset buffer

mov ecx ,count1
mov  eax,FileHandle

call writetofile
mov eax ,FileHandle
call closefile

ret
REMOVE endp

;---------------------------------
;REPLCE
;---------------------------------
.data
bta3 dword ?
conan dword 0
str67 byte "enter numbererererer : ",0
str4 byte "enter replace string : ",0
replace_str1 byte 100 dup(?)
replace_str2 byte 100 dup(?)
str5 byte "enter string : ",0
fund dword 0
count_rep dword 0
.code 
REPLACE proc

mov replace_str1,0
mov replace_str2,0
mov count_rep,0
mov edx ,offset str4
call writestring
call crlf
mov edx ,offset replace_str1
mov ecx, sizeof replace_str1
call readstring
mov edx ,offset str5
call writestring
call crlf
mov edx ,offset replace_str2
mov ecx, sizeof replace_str2
call readstring
mov fund, eax
mov edx , offset str67
 call writestring

call readdec
mov ecx, lengthof buffer
mov esi ,offset buffer
mov edi,offset replace_str1

lgg:
cmp eax, count_rep
jz ex
mov tmp ,ecx
mov bl,byte ptr [esi] 
cmp bl ,byte ptr [edi]
jnz lp
mov ecx, fund
mov edi,offset replace_str1
mov edx,esi
lu:
mov bl,byte ptr [edx] 
cmp bl ,byte ptr [edi]
jnz lp
inc edi
inc edx
loop lu
inc count_rep
mov esi,edx
sub edx, fund
push ecx
mov ecx, fund
push esi
mov esi ,offset  replace_str2
mov edi , edx
rep movsb
pop esi
pop ecx 
lp:
inc esi
mov ecx, tmp 
mov edi ,offset replace_str1
loop lgg
 ex:
mov eax,0
mov edx , offset file_path
call createoutputfile

mov FileHandle ,eax

mov edx , offset buffer
call writestring

mov ecx ,count1
mov eax,FileHandle

call writetofile
mov eax ,FileHandle
call closefile
  
ret
REPLACE endp
;-----------------------------

remov proc
.code

inc var3
inc esi 
mov edi, offset remove_string
mov ecx, tmp

ret
remov endp
END main
;------------------------------
;The End
