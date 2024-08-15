BEGIN {
    FS="%"
}

{
    printf("Commit ID: \033[32m%s\n", $2)
    printf("\t\033[0mMessage:\033[32m%s\n", $3)
    printf("\t\033[0mTime\033[0;33m:%s\n", $4)
    printf("\033[0m\n\n\n")
}