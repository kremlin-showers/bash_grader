BEGIN {
    # Sets Field seperator to ,
    FS=",";
}

# In the first line adds total column if not already present.
# Also if total column exists then sets variable x to zero
(NR == 1 && $NF != "Total") { printf("%s,Total\n",$0) }
(NR == 1 && $NF == "Total") { printf("%s\n",$0); x = 1}
(NR > 1 && x != 1) {
    total = 0
    for (i = 3; i <= NF; i++) {
        total = total + $i; 
    }
    printf("%s,%.2f\n",$0,total);
}
(NR > 1 && x == 1) {
    total = 0
    printf("%s,%s,",$1,$2);
    for (i = 3; i < NF; i++) {
        printf("%s,",$i);
        total = total + $i; 
    }
    printf("%.2f\n",total);
}