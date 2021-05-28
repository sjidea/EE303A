// Greatest common divisor (faster)
// Wanyeong Jung
// Last modified: 04 Dec 2019
// Finds GCD of two numbers in [1, 128] using Euclidean algorithm

start:
subleq a, ma;
subleq b, mb;

repeat:
// print intermediate results
subleq ma, Z1, found_gcd;
subleq Z0, Z0;

// print intermediate results
subleq ma, print_int;
subleq mb, print_int;
subleq newline_char, print_char;

sub_b: subleq ma, mb, sub_b;
sub_b_done: // b += a, swap a and b
subleq mb, Z0;
subleq mb, mb;
subleq Z0, ma;
subleq Z1, mb;
subleq Z0, Z0;
subleq Z1, Z1, repeat;

found_gcd:
// print GCD
subleq mb, print_int;

halt: subleq halt_char, print_char;

Z0: data 0;
Z1: data 0;

a: data 99;
b: data 27;
ma: data 0;
mb: data 0;

halt_char : data -'\a';
newline_char : data -'\n';

print_int(-2):
print_char(-1):
