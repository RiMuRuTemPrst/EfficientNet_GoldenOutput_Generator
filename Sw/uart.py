import serial

def read_hex_lines_to_bytes(file_path):
    data = []
    with open(file_path, 'r') as f:
        for line in f:
            line = line.strip()
            if not line:
                continue
            try:
                val = int(line, 16)  # Giá trị có thể > 255
                if 0 <= val <= 0xFFFF:
                    # Tách thành 2 byte: MSB, LSB
                    high = (val >> 8) & 0xFF
                    low = val & 0xFF
                    data.extend([high, low])
            except ValueError:
                print(f"⚠️ Bỏ qua dòng không hợp lệ: {line}")
    return data
def transmit_n_bits_at_a_time(serial_port, data_bytes, n_bits):
    if n_bits % 8 != 0:
        raise ValueError("n must be a multiple of 8 (e.g., 8, 16, 24, 32)")
    n_bytes = n_bits // 8

    for i in range(0, len(data_bytes), n_bytes):
        chunk = data_bytes[i:i + n_bytes]
        if len(chunk) < n_bytes:
            chunk += [0] * (n_bytes - len(chunk))  # padding nếu thiếu
        serial_port.write(bytes(chunk))
        print(f"Sent: {chunk}")

def main():
    hex_file_path = '/home/manhung/Hung/CNN/Fused-Block-CNN/address/golden_full_fused/hex/global_ram.hex'  # Đổi tên nếu cần
    port_name = 'COM3'  # Hoặc '/dev/ttyUSB0' nếu trên Linux
    baudrate = 9600
    n_bits = 16  # Truyền 16 bit (2 byte) mỗi lần

    data_bytes = read_hex_lines_to_bytes(hex_file_path)

    with serial.Serial(port=port_name, baudrate=baudrate, timeout=1) as ser:
        transmit_n_bits_at_a_time(ser, data_bytes, n_bits)

if __name__ == '__main__':
    main()
