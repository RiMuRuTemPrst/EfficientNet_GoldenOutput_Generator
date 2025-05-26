def divide_values_in_file(input_file, output_file, divisor):
    with open(input_file, 'r') as f_in, open(output_file, 'w') as f_out:
        for line in f_in:
            line = line.strip()
            if line == '':
                continue  # bỏ qua dòng trống
            try:
                val = float(line)
                divided_val = val / (1<<10)
                f_out.write(f"{divided_val}\n")
            except ValueError:
                print(f"Cảnh báo: không thể chuyển dòng này thành số: {line}")

if __name__ == "__main__":
    input_filename = "Sw/bias.txt"   # file đầu vào
    output_filename = "Sw/bias_dense.txt" # file đầu ra
    divisor = 32.0                 # số chia, bạn có thể thay đổi ở đây hoặc nhập từ bàn phím

    divide_values_in_file(input_filename, output_filename, divisor)
    print(f"Chuyển đổi xong, kết quả lưu tại {output_filename}")