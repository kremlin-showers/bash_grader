BEGIN {
    FS=",";
    i=0;

}
FNR == 1 {
    Exams[i]=FILENAME;
    i++;
}

FNR != 1 {
    roll=tolower($1);
    roll=roll "," $2;
    rolllist[roll][FILENAME]=$3;
}

END {
    HEADER="Roll_Number,Name";
    len=length(Exams);
    for (i=0;i<len;i++)
    {
        HEADER= HEADER "," Exams[i]
    }
    gsub(/\.csv/,"",HEADER);
    print HEADER;
    for (i in rolllist)
    {
        output=i
        for (j=0;j<len;j++)
        {
            if (rolllist[i][Exams[j]] != "")
            {
                output = output "," rolllist[i][Exams[j]]
            }
            else
            {
                output = output ",a"
            }
        }
        print output


    }

}