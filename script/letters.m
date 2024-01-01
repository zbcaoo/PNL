function textString = letters(i)
    if i>=10
        switch i
            case 10
                textString = 'A';
            case 11
                textString = 'B';
            case 12
                textString = 'C';
            case 13
                textString = 'D';
            case 14
                textString = 'E';
            case 15
                textString = 'F';
            case 16
                textString = 'G';
            case 17
                textString = 'H';
            case 18
                textString = 'I';
            case 19
                textString = 'J';
            case 20
                textString = 'K';
            case 21
                textString = 'L';
            case 22
                textString = 'M';
            case 23
                textString = 'N';
            case 24
                textString = 'O';
            case 25
                textString = 'P';
            case 26
                textString = 'Q';
            case 27
                textString = 'R';
            case 28
                textString = 'S';
            case 29
                textString = 'T';
            case 30
                textString = 'U';
            case 31
                textString = 'V';
            case 32
                textString = 'W';
            case 33
                textString = 'X';
            case 34
                textString = 'Y';
            case 35
                textString = 'Z';
        end
    else
        textString = num2str(i);
    end
end

