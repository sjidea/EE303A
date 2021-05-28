// Greatest common divisor
// Wanyeong Jung
// Last modified: 04 Dec 2019
// Finds GCD of two numbers in [1, 127] using Euclidean algorithm

start:

repeat:
// print intermediate results
subleq a, Z0;
subleq Z0, print_int;
subleq Z0, Z0;
subleq b, Z0;
subleq Z0, print_int;
subleq Z0, Z0;
subleq newline_char, print_char;

sub_b:
subleq a, b, sub_b_done;
subleq Z0, Z0, sub_b;
// swap a and b
sub_b_done:
subleq b, Z0, found_gcd;
// b += a, swap a and b
subleq b, b;
subleq a, Z1;
subleq Z0, a;
subleq Z1, b;
subleq Z0, Z0;
subleq Z1, Z1, repeat;

found_gcd:
// print GCD
subleq a, Z1;
subleq Z1, print_int;

halt: subleq halt_char, print_char;

Z0: data 0;
Z1: data 0;

a: data 99;
b: data 27;

halt_char : data -'\a';
newline_char : data -'\n';

print_int(-2):
print_char(-1):
