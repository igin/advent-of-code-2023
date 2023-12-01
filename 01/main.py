digit_map = {
    "one":      "1",
    "two":      "2", 
    "three":    "3", 
    "four":     "4", 
    "five":     "5", 
    "six":      "6", 
    "seven":    "7", 
    "eight":    "8", 
    "nine":     "9"
}

def run():
    with open('./input.txt') as input_file:
        lines = input_file.readlines()
        parsed_lines = parse_lines(lines)
        total = compute_sum(parsed_lines)
        print(f"result: {total}")

def parse_lines(input_lines):
    parsed_lines = []
    for line in input_lines:
        digits = []
        #line = line.replace('*','')
        for spelled_digit, digit in digit_map.items():
            found_index = 0
            while found_index < len(line):
                found_index = line.find(spelled_digit, found_index)
                if found_index != -1:
                    digits.append({'index': found_index, 'digit': digit})
                else:
                    break

                found_index += 1

            

        for digit in range(0,10):
            found_index = 0
            while found_index < len(line):
                found_index = line.find(str(digit), found_index)
                if found_index != -1:
                    digits.append({'index': found_index, 'digit': str(digit)})
                else:
                    break

                found_index += 1
        
        sorted_digits = sorted(digits, key=lambda a: a['index'])


        first_last = ''.join([sorted_digits[0]['digit'], sorted_digits[-1]['digit']])
        first_last_number = int(first_last)
        parsed_lines.append(first_last_number)

        print(f"{line} -> {sorted_digits} -> {first_last_number}")


    return parsed_lines

def compute_sum(char_lines):
    return sum(char_lines)

if __name__ == '__main__':
    run()