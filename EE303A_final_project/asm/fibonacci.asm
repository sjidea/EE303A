start: // Find nth fibonacci number 
add:
subleq one, n; // n = n - 1

loop:
subleq k, k;
subleq n, z;
subleq z, k;
subleq z, z; // k = n

subleq i, k, print_result; // if(i < k) goto print_result

subleq temp, temp;
subleq an1, z;
subleq z, temp;
subleq z, z; // mov temp, an1 :: temp = an1

subleq an0, z; 
subleq z, temp;
subleq z, z; // add temp, an0 :: temp = temp + an0

subleq an0, an0;
subleq an1, z;
subleq z, an0;
subleq z, z; // mov an0, an1 :: an0 = an1

subleq an1, an1;
subleq temp, z; 
subleq z, an1;
subleq z, z; // mov an1, temp :: an1 = temp

subleq one, z;
subleq z, i;
subleq z, z; // i += 1;

subleq z, z, loop; // jump to loop

print_result:
subleq an1, z;
subleq z, print_int; // print result on transcript window
subleq z, z; // mov result, an1

halt_with_beep:
subleq beep, print_char; // print result on transcript window

z: data 0;
one: data 1;
i: data 1;
n: data 10;
k: data 0;
an0: data 0;
an1: data 1;
temp: data 0;
beep : data -7;
print_int(-2):
print_char(-1):

