input=input ("string:")
split_input=str.split(input,"_")
for item in split_input:
    print(f'[{split_input.index(item)}] {item}')