import argparse
import pathlib
import sys
import time

try:
    import serial
except ImportError:
    serial = None

from compiler import compile


def build_program(path):
    words = []
    with open(path, "r", encoding="utf-8") as src:
        for line_no, line in enumerate(src, start=1):
            text = line.strip()
            if not text:
                continue
            words.append(compile(text, line_no))
    return words


def send_command(port, command, response_size=19):
    port.write(command.encode("ascii"))
    port.flush()
    return port.read(response_size).decode("ascii", errors="replace")


def load_program(port_name, asm_path, baudrate=9600, timeout=1.0, delay=0.0):
    if serial is None:
        raise RuntimeError("pyserial is required: install it with `pip install pyserial`")

    words = build_program(asm_path)

    with serial.Serial(
        port=port_name,
        baudrate=baudrate,
        bytesize=serial.EIGHTBITS,
        parity=serial.PARITY_EVEN,
        stopbits=serial.STOPBITS_TWO,
        timeout=timeout,
    ) as port:
        send_command(port, "RESET\r\n", response_size=7)

        for address, word in enumerate(words):
            command = "PWR {0:04X} {1:08X}\r\n".format(address, word)
            response = send_command(port, command)
            print(response, end="" if response.endswith("\n") else "\n")

            if delay:
                time.sleep(delay)

        send_command(port, "RESET\r\n", response_size=7)


def main():
    parser = argparse.ArgumentParser(description="Load assembled program words through the UART debugger.")
    parser.add_argument("port", help="Serial port name, for example COM5")
    parser.add_argument(
        "asm",
        nargs="?",
        default=str(pathlib.Path(__file__).with_name("program.asm")),
        help="Assembly source file, defaults to software/program.asm",
    )
    parser.add_argument("--baudrate", type=int, default=9600)
    parser.add_argument("--timeout", type=float, default=1.0)
    parser.add_argument("--delay", type=float, default=0.0)
    args = parser.parse_args()

    load_program(args.port, pathlib.Path(args.asm), args.baudrate, args.timeout, args.delay)


if __name__ == "__main__":
    try:
        main()
    except Exception as exc:
        print("program_loader.py:", exc, file=sys.stderr)
        sys.exit(1)
