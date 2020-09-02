int digit_cnt(char *user_input){
    int digits = 0;    
    int index = 0;
    
    while (user_input[index] != 0){
        if (user_input[index] >= '0' && user_input[index] <= '9'){
            digits++;
        }
        index++;
    }

    return digits;
}

int main(int argc, char **argv){
    digit_cnt (argv[1]); 
    return 0;
}

