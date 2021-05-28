start:
print_char:
subleq a, a;
subleq p, Z;
subleq Z, a;
subleq Z, Z;
a: subleq 0, Z;
subleq Z, output;
subleq Z, Z;

subleq m1, p;

subleq a, a;
subleq E, Z;
subleq Z, a;
subleq Z, Z;
subleq p, a, halt;
subleq Z, Z, print_char;

halt: subleq halt_char, output;

m1: data -1;
Z: data 0;
p: data d; // pointer
d: data "Hello, world!!\n";
E: data E;
halt_char: data -'\a';
output(-1):
