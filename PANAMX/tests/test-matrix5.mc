int main() {
    matrix m;
    matrix n;
    m = [1.6, 3.9;
         2.4, 4.3;
         5.7, 7.2];
    n = [12.3, 15.6, 14.5, 18.8;
         23.4, 21.8, 9.5,  10.7];
    m = m * n;
    printm(m);
    return 0;
}
